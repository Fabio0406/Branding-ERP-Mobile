// lib/main.dart
import 'package:branding_erp_mobile/bloc/recordatorios/recordatorios_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'config/graphql_config.dart';
import 'bloc/recordatorios/recordatorios_bloc.dart';
import 'screens/home_screen.dart';
import 'screens/recordatorios_screen.dart';
import 'screens/proyectos_screen.dart';
import 'screens/notificaciones_screen.dart';
import 'services/notification_service.dart';
import 'services/firebase_messaging_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // 1. Inicializar timezone para Bolivia
    tz.initializeTimeZones();
    
    // 2. Inicializar Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // 3. Inicializar GraphQL
    await GraphQLConfig.initialize();
    
    // 4. Inicializar servicios de notificación
    await NotificationService.initialize();
    
    runApp(MyApp());
  } catch (e) {
    // En caso de error, mostrar pantalla de error
    runApp(ErrorApp(error: e.toString()));
  }
}

class AppColors {
  static const Color darkNavy = Color(0xFF0D1321);      // #0D1321
  static const Color navy = Color(0xFF1D2D44);          // #1D2D44
  static const Color blueGray = Color(0xFF3E5C76);      // #3E5C76
  static const Color lightBlue = Color(0xFF748CAB);     // #748CAB
  static const Color cream = Color(0xFFF0EDD8);         // #F0EDD8
  
  // Colores derivados para estados
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
}

class MyApp extends StatelessWidget {
  final GoRouter _router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/recordatorios',
        builder: (context, state) => const RecordatoriosScreen(),
      ),
      GoRoute(
        path: '/proyectos',
        builder: (context, state) => const ProyectosScreen(),
      ),
      GoRoute(
        path: '/notificaciones',
        builder: (context, state) => const NotificacionesScreen(),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      client: GraphQLConfig.client,
      child: MultiBlocProvider(
        providers: [
          BlocProvider<RecordatoriosBloc>(
            create: (context) => RecordatoriosBloc()..add(const CargarRecordatorios('1')),
          ),
        ],
        child: MaterialApp.router(
          title: 'Branding ERP Mobile',
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.blueGray,
              brightness: Brightness.light,
              primary: AppColors.blueGray,
              secondary: AppColors.lightBlue,
              surface: AppColors.cream,
              background: AppColors.cream,
              onPrimary: Colors.white,
              onSecondary: Colors.white,
              onSurface: AppColors.darkNavy,
              onBackground: AppColors.darkNavy,
            ),
            appBarTheme: AppBarTheme(
              backgroundColor: AppColors.navy,
              foregroundColor: Colors.white,
              elevation: 2,
              shadowColor: AppColors.darkNavy.withOpacity(0.3),
              titleTextStyle: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
              iconTheme: const IconThemeData(color: Colors.white),
            ),
            cardTheme: CardTheme(
              color: Colors.white,
              elevation: 3,
              shadowColor: AppColors.darkNavy.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blueGray,
                foregroundColor: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.blueGray,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            floatingActionButtonTheme: FloatingActionButtonThemeData(
              backgroundColor: AppColors.lightBlue,
              foregroundColor: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            tabBarTheme: TabBarTheme(
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              indicatorColor: AppColors.cream,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
            ),
            bottomNavigationBarTheme: BottomNavigationBarThemeData(
              backgroundColor: Colors.white,
              selectedItemColor: AppColors.blueGray,
              unselectedItemColor: AppColors.lightBlue.withOpacity(0.6),
              elevation: 8,
              type: BottomNavigationBarType.fixed,
              showUnselectedLabels: true,
            ),
            progressIndicatorTheme: ProgressIndicatorThemeData(
              color: AppColors.blueGray,
              linearTrackColor: AppColors.lightBlue.withOpacity(0.3),
              circularTrackColor: AppColors.lightBlue.withOpacity(0.3),
            ),
            scaffoldBackgroundColor: AppColors.cream,
            brightness: Brightness.light,
          ),
          routerConfig: _router,
          builder: (context, child) {
            // Inicializar servicios con contexto después de que la app esté lista
            WidgetsBinding.instance.addPostFrameCallback((_) {
              NotificationService.initialize(context: context);
              FirebaseMessagingService.initialize(context: context);
            });
            return child!;
          },
        ),
      ),
    );
  }
}

// Widget de error en caso de falla en la inicialización
class ErrorApp extends StatelessWidget {
  final String error;
  
  const ErrorApp({Key? key, required this.error}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: AppColors.cream,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Error de Inicialización',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.navy,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'No se pudo inicializar la aplicación correctamente.',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.navy.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  error,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.error,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    // Reiniciar la app
                    main();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blueGray,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}