// lib/screens/notificaciones_screen.dart
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../config/graphql_queries.dart';
import '../models/notificacion.dart';
import '../widgets/bottom_navigation.dart';
import '../widgets/notificacion_card.dart';

class AppColors {
  static const Color darkNavy = Color(0xFF0D1321);
  static const Color navy = Color(0xFF1D2D44);
  static const Color blueGray = Color(0xFF3E5C76);
  static const Color lightBlue = Color(0xFF748CAB);
  static const Color cream = Color(0xFFF0EDD8);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
}

class NotificacionesScreen extends StatelessWidget {
  const NotificacionesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: const Icon(Icons.mark_email_read, color: Colors.white),
              onPressed: () => _marcarTodasComoLeidas(context),
              tooltip: 'Marcar todas como leídas',
            ),
          ),
        ],
      ),
      backgroundColor: AppColors.cream,
      body: Query(
        options: QueryOptions(
          document: gql(GraphQLQueries.getNotificaciones),
          variables: const {
            'usuarioId': '1', // Usuario actual
            'limit': 50,
          },
          // 🔔 CONFIGURACIÓN ADICIONAL PARA DEBUGGING
          errorPolicy: ErrorPolicy.all,
          fetchPolicy: FetchPolicy.cacheAndNetwork,
        ),
        builder: (QueryResult result, {VoidCallback? refetch, FetchMore? fetchMore}) {
          // 🔔 DEBUGGING: Imprimir información del resultado
          print('🔍 Query result hasException: ${result.hasException}');
          print('🔍 Query result isLoading: ${result.isLoading}');
          print('🔍 Query result data: ${result.data}');
          
          if (result.hasException) {
            print('❌ GraphQL Exception: ${result.exception}');
            return _buildErrorWidget(context, result.exception.toString(), refetch);
          }

          if (result.isLoading && (result.data == null)) {
            return _buildLoadingWidget();
          }

          // 🔔 MANEJO SEGURO DE DATOS CON VALIDACIONES NULL
          List<Notificacion> notificaciones = [];
          
          try {
            final data = result.data;
            if (data != null && data['getNotificaciones'] != null) {
              final List<dynamic> notificacionesData = data['getNotificaciones'] as List<dynamic>;
              
              // 🔔 FILTRAR Y PARSEAR NOTIFICACIONES DE FORMA SEGURA
              for (var notifData in notificacionesData) {
                try {
                  if (notifData != null && notifData is Map<String, dynamic>) {
                    final notificacion = Notificacion.fromJson(notifData);
                    notificaciones.add(notificacion);
                  }
                } catch (e) {
                  print('⚠️ Error parsing individual notification: $e');
                  // Continuar con las demás notificaciones
                }
              }
            }
          } catch (e) {
            print('❌ Error processing notifications data: $e');
            return _buildErrorWidget(context, 'Error procesando notificaciones: $e', refetch);
          }

          if (notificaciones.isEmpty) {
            return _buildEmptyWidget();
          }

          // Separar notificaciones leídas y no leídas
          final noLeidas = notificaciones.where((n) => !n.leida).toList();
          final leidas = notificaciones.where((n) => n.leida).toList();

          return RefreshIndicator(
            color: AppColors.blueGray,
            onRefresh: () async => refetch?.call(),
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // 🔔 ESTADÍSTICAS DE NOTIFICACIONES
                _buildStatsCard(notificaciones.length, noLeidas.length),
                
                const SizedBox(height: 16),
                
                if (noLeidas.isNotEmpty) ...[
                  _buildSectionHeader(
                    'Nuevas (${noLeidas.length})', 
                    AppColors.info, 
                    Icons.fiber_new
                  ),
                  const SizedBox(height: 12),
                  ...noLeidas.map((notificacion) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: NotificacionCard(
                      notificacion: notificacion,
                      esNueva: true,
                    ),
                  )),
                  const SizedBox(height: 24),
                ],
                
                if (leidas.isNotEmpty) ...[
                  _buildSectionHeader(
                    'Anteriores', 
                    AppColors.navy, 
                    Icons.history
                  ),
                  const SizedBox(height: 12),
                  ...leidas.map((notificacion) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: NotificacionCard(
                      notificacion: notificacion,
                      esNueva: false,
                    ),
                  )),
                ],
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: const CustomBottomNavigation(currentIndex: 3),
    );
  }

  Widget _buildStatsCard(int total, int noLeidas) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkNavy.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.lightBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.notifications, color: AppColors.lightBlue, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$total notificaciones',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.navy,
                  ),
                ),
                Text(
                  noLeidas > 0 ? '$noLeidas sin leer' : 'Todas las notificaciones están leídas',
                  style: TextStyle(
                    color: noLeidas > 0 ? AppColors.info : AppColors.success,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (noLeidas > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.info,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$noLeidas',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, String error, VoidCallback? retry) {
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
              'Error al cargar notificaciones',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.navy,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Hubo un problema al obtener las notificaciones. Por favor, inténtalo de nuevo.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.navy.withOpacity(0.7)),
            ),
            const SizedBox(height: 8),
            if (error.isNotEmpty)
              Text(
                'Error técnico: ${error.length > 100 ? error.substring(0, 100) + "..." : error}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.error,
                  fontSize: 12,
                ),
              ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: retry,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blueGray,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.blueGray),
          const SizedBox(height: 16),
          Text(
            'Cargando notificaciones...',
            style: TextStyle(color: AppColors.navy),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
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
              child: Icon(Icons.notifications_off_outlined, 
                        size: 64, 
                        color: AppColors.lightBlue),
            ),
            const SizedBox(height: 24),
            Text(
              'No tienes notificaciones',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.navy,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Cuando tengas nuevas notificaciones aparecerán aquí',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.navy.withOpacity(0.7)),
            ),
          ],
        ),
      ),
    );
  }

  void _marcarTodasComoLeidas(BuildContext context) {
    // TODO: Implementar mutación para marcar todas como leídas
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            const Text('Todas las notificaciones marcadas como leídas'),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}