// lib/screens/home_screen.dart
import 'package:branding_erp_mobile/bloc/recordatorios/recordatorios_event.dart';
import 'package:branding_erp_mobile/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/recordatorios/recordatorios_bloc.dart';
import '../bloc/recordatorios/recordatorios_state.dart';
import '../widgets/recordatorio_card.dart';
import '../widgets/resumen_dashboard.dart';
import '../widgets/bottom_navigation.dart';

class AppColors {
  static const Color darkNavy = Color(0xFF0D1321);
  static const Color navy = Color(0xFF1D2D44);
  static const Color blueGray = Color(0xFF3E5C76);
  static const Color lightBlue = Color(0xFF748CAB);
  static const Color cream = Color(0xFFF0EDD8);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  
  static var info;
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () => context.go('/notificaciones'),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              context.read<RecordatoriosBloc>().add(const RefrescarRecordatorios('1'));
            },
          ),
        ],
      ),
      backgroundColor: AppColors.cream,
      body: RefreshIndicator(
        color: AppColors.blueGray,
        onRefresh: () async {
          context.read<RecordatoriosBloc>().add(const RefrescarRecordatorios('1'));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Resumen del dashboard
              const ResumenDashboard(),
              
              const SizedBox(height: 24),
              
              // Recordatorios urgentes
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.error.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.warning_amber_rounded, 
                         color: AppColors.error, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Recordatorios Urgentes',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 12),
              
              BlocBuilder<RecordatoriosBloc, RecordatoriosState>(
                builder: (context, state) {
                  if (state is RecordatoriosLoading) {
                    return Center(
                      child: CircularProgressIndicator(color: AppColors.blueGray),
                    );
                  }
                  
                  if (state is RecordatoriosError) {
                    return Card(
                      color: AppColors.error.withOpacity(0.1),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: AppColors.error.withOpacity(0.3)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: AppColors.error),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Error: ${state.message}',
                                style: TextStyle(color: AppColors.error),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  
                  if (state is RecordatoriosLoaded) {
                    final urgentes = state.recordatoriosUrgentes;
                    
                    if (urgentes.isEmpty) {
                      return Card(
                        color: AppColors.success.withOpacity(0.1),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: AppColors.success.withOpacity(0.3)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle_outline, color: AppColors.success),
                              const SizedBox(width: 12),
                              Text(
                                'No hay recordatorios urgentes',
                                style: TextStyle(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    
                    return Column(
                      children: urgentes.take(3).map((recordatorio) => 
                        RecordatorioCard(
                          recordatorio: recordatorio,
                          esUrgente: true,
                        ),
                      ).toList(),
                    );
                  }
                  
                  return const SizedBox.shrink();
                },
              ),
              
              const SizedBox(height: 24),
              
              // Actividades de hoy
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.blueGray.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.blueGray.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.today_rounded, 
                             color: AppColors.blueGray, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Hoy',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.blueGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => context.go('/recordatorios'),
                    icon: Icon(Icons.arrow_forward, size: 16, color: AppColors.lightBlue),
                    label: Text(
                      'Ver todos',
                      style: TextStyle(color: AppColors.lightBlue, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              BlocBuilder<RecordatoriosBloc, RecordatoriosState>(
                builder: (context, state) {
                  if (state is RecordatoriosLoaded) {
                    final hoy = state.recordatoriosHoy;
                    
                    if (hoy.isEmpty) {
                      return Card(
                        color: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Icon(Icons.event_available, color: AppColors.lightBlue),
                              const SizedBox(width: 12),
                              Text(
                                'No hay actividades programadas para hoy',
                                style: TextStyle(color: AppColors.navy),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    
                    return Column(
                      children: hoy.take(3).map((recordatorio) => 
                        RecordatorioCard(recordatorio: recordatorio),
                      ).toList(),
                    );
                  }
                  
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigation(currentIndex: 0),
    );
  }

  Widget _buildTestNotificationButton(BuildContext context) {
  return FloatingActionButton.extended(
    onPressed: () async {
      // Probar notificación inmediata
      await NotificationService.mostrarNotificacionInmediata(
        titulo: 'Prueba de Notificación',
        mensaje: 'Esta es una notificación de prueba desde Branding ERP',
        isUrgent: false,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Notificación de prueba enviada'),
          backgroundColor: AppColors.info,
        ),
      );
    },
    icon: const Icon(Icons.notifications_active),
    label: const Text('Probar'),
    backgroundColor: AppColors.lightBlue,
  );
}
}