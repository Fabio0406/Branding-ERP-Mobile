// lib/widgets/notificacion_card.dart
import 'package:flutter/material.dart';
import '../models/notificacion.dart';

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

class NotificacionCard extends StatelessWidget {
  final Notificacion notificacion;
  final bool esNueva;

  const NotificacionCard({
    Key? key,
    required this.notificacion,
    this.esNueva = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: esNueva ? 3 : 1,
      color: esNueva ? AppColors.info.withOpacity(0.05) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: esNueva 
          ? BorderSide(color: AppColors.info.withOpacity(0.3), width: 1)
          : BorderSide.none,
      ),
      child: InkWell(
        onTap: () => _manejarTap(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getColorTipo().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _getColorTipo().withOpacity(0.3)),
                ),
                child: Icon(
                  _getIconoTipo(),
                  color: _getColorTipo(),
                  size: 20,
                ),
              ),
              
              const SizedBox(width: 12),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notificacion.titulo,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: esNueva ? FontWeight.bold : FontWeight.w500,
                              color: esNueva ? AppColors.navy : AppColors.navy.withOpacity(0.8),
                            ),
                          ),
                        ),
                        if (esNueva)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppColors.info,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    
                    const SizedBox(height: 6),
                    
                    Text(
                      notificacion.mensaje,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.navy.withOpacity(0.7),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 12),
                    
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.lightBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            Icons.schedule,
                            size: 14,
                            color: AppColors.lightBlue,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          notificacion.fechaFormateada,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.lightBlue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (notificacion.proyecto != null) ...[
                          const SizedBox(width: 16),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.blueGray.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              Icons.business,
                              size: 14,
                              color: AppColors.blueGray,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              notificacion.proyecto!.cliente.nombreEmpresa,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.blueGray,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getColorTipo() {
    switch (notificacion.tipo) {
      case TipoNotificacion.nuevoProyecto:
        return AppColors.success;
      case TipoNotificacion.cambioEstado:
        return AppColors.info;
      case TipoNotificacion.aprobacionPendiente:
        return AppColors.warning;
      case TipoNotificacion.entregaProxima:
        return AppColors.error;
      case TipoNotificacion.reunionProgramada:
        return AppColors.blueGray;
      case TipoNotificacion.tareaAsignada:
        return AppColors.lightBlue;
      default:
        return AppColors.navy;
    }
  }

  IconData _getIconoTipo() {
    switch (notificacion.tipo) {
      case TipoNotificacion.nuevoProyecto:
        return Icons.add_circle;
      case TipoNotificacion.cambioEstado:
        return Icons.update;
      case TipoNotificacion.aprobacionPendiente:
        return Icons.approval;
      case TipoNotificacion.entregaProxima:
        return Icons.schedule;
      case TipoNotificacion.reunionProgramada:
        return Icons.people;
      case TipoNotificacion.tareaAsignada:
        return Icons.assignment;
      default:
        return Icons.notifications;
    }
  }

  void _manejarTap(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _getColorTipo().withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _getColorTipo().withOpacity(0.3)),
              ),
              child: Icon(
                _getIconoTipo(),
                color: _getColorTipo(),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                notificacion.titulo,
                style: TextStyle(
                  color: AppColors.navy,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notificacion.mensaje,
              style: TextStyle(
                color: AppColors.navy.withOpacity(0.8),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.lightBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.lightBlue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.schedule, color: AppColors.lightBlue, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    notificacion.fechaFormateada,
                    style: TextStyle(
                      color: AppColors.lightBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (notificacion.proyecto != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.blueGray.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.blueGray.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.business, color: AppColors.blueGray, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        notificacion.proyecto!.cliente.nombreEmpresa,
                        style: TextStyle(
                          color: AppColors.blueGray,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.navy.withOpacity(0.7),
            ),
            child: const Text('Cerrar'),
          ),
          if (notificacion.accionUrl != null)
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                // Implementar navegación a la URL de acción
              },
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: const Text('Ver detalles'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _getColorTipo(),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
        ],
      ),
    );
  }
}