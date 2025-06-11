// lib/screens/proyectos_screen.dart
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../config/graphql_queries.dart';
import '../models/proyecto.dart';
import '../widgets/bottom_navigation.dart';
import '../widgets/proyecto_card.dart';

class AppColors {
  static const Color darkNavy = Color(0xFF0D1321);
  static const Color navy = Color(0xFF1D2D44);
  static const Color blueGray = Color(0xFF3E5C76);
  static const Color lightBlue = Color(0xFF748CAB);
  static const Color cream = Color(0xFFF0EDD8);
  static const Color error = Color(0xFFF44336);
}

class ProyectosScreen extends StatelessWidget {
  const ProyectosScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Proyectos'),
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
      ),
      backgroundColor: AppColors.cream,
      body: Query(
        options: QueryOptions(
          document: gql(GraphQLQueries.getProyectosByUsuario),
          variables: const {'usuarioId': '1'}, // Usuario actual
        ),
        builder: (QueryResult result, {VoidCallback? refetch, FetchMore? fetchMore}) {
          if (result.hasException) {
            return Center(
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
                      child: Icon(Icons.error_outline, 
                                size: 64, 
                                color: AppColors.error),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Error al cargar proyectos',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.navy,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      result.exception.toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.navy.withOpacity(0.7)),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: refetch,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blueGray,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (result.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.blueGray),
                  const SizedBox(height: 16),
                  Text(
                    'Cargando proyectos...',
                    style: TextStyle(color: AppColors.navy),
                  ),
                ],
              ),
            );
          }

          final List<dynamic> proyectosData = result.data?['getProyectosByUsuario'] ?? [];
          final proyectos = proyectosData.map((data) => Proyecto.fromJson(data)).toList();

          if (proyectos.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.lightBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(Icons.work_off_outlined, 
                                size: 64, 
                                color: AppColors.lightBlue),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No tienes proyectos asignados',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.navy,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Los proyectos que te asignen aparecerán aquí',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.navy.withOpacity(0.7)),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            color: AppColors.blueGray,
            onRefresh: () async => refetch?.call(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: proyectos.length,
              itemBuilder: (context, index) {
                return ProyectoCard(proyecto: proyectos[index]);
              },
            ),
          );
        },
      ),
      bottomNavigationBar: const CustomBottomNavigation(currentIndex: 2),
    );
  }
}