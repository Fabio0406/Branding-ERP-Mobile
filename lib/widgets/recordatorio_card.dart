// lib/widgets/recordatorio_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/recordatorio.dart';
import '../bloc/recordatorios/recordatorios_bloc.dart';
import '../bloc/recordatorios/recordatorios_event.dart';

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

class RecordatorioCard extends StatelessWidget {
  final Recordatorio recordatorio;
  final bool esUrgente;

  const RecordatorioCard({
    Key? key,
    required this.recordatorio,
    this.esUrgente = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: esUrgente ? 4 : 2,
      color: esUrgente ? AppColors.error.withOpacity(0.05) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: esUrgente 
          ? BorderSide(color: AppColors.error.withOpacity(0.3), width: 1)
          : BorderSide.none,
      ),
      child: InkWell(
        onTap: () => _mostrarDetalles(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildIconoPrioridad(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recordatorio.titulo,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: esUrgente ? AppColors.error : AppColors.navy,
                          ),
                        ),
                        if (recordatorio.descripcion != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            recordatorio.descripcion!,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.navy.withOpacity(0.7),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (!recordatorio.visto)
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.check_circle_outline, color: AppColors.success),
                        onPressed: () => _marcarVisto(context),
                        tooltip: 'Marcar como visto',
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: esUrgente 
                        ? AppColors.error.withOpacity(0.1) 
                        : AppColors.blueGray.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.schedule,
                      size: 16,
                      color: esUrgente ? AppColors.error : AppColors.blueGray,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    recordatorio.fechaFormateada,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: esUrgente ? AppColors.error : AppColors.navy.withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getColorTiempo(),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      recordatorio.tiempoRestante,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              
              if (recordatorio.proyecto != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.lightBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.lightBlue.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.business,
                        size: 16,
                        color: AppColors.lightBlue,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${recordatorio.proyecto!.cliente.nombreEmpresa} - ${recordatorio.proyecto!.nombre}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.lightBlue,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildIconoPrioridad() {
    IconData icono;
    Color color;

    switch (recordatorio.tipo) {
      case TipoRecordatorio.entrega:
        icono = Icons.file_upload;
        color = AppColors.info;
        break;
      case TipoRecordatorio.reunion:
        icono = Icons.people;
        color = AppColors.success;
        break;
      case TipoRecordatorio.aprobacion:
        icono = Icons.check_circle;
        color = AppColors.warning;
        break;
      case TipoRecordatorio.deadline:
        icono = Icons.alarm;
        color = AppColors.error;
        break;
      case TipoRecordatorio.presentacion:
        icono = Icons.present_to_all;
        color = AppColors.lightBlue;
        break;
      default:
        icono = Icons.notifications;
        color = AppColors.blueGray;
    }

    if (esUrgente) {
      color = AppColors.error;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Icon(icono, color: color, size: 20),
    );
  }

  Color _getColorTiempo() {
    final difference = recordatorio.fechaRecordatorio.difference(DateTime.now());
    
    if (difference.isNegative) {
      return AppColors.error;
    } else if (difference.inHours < 24) {
      return AppColors.warning;
    } else if (difference.inDays < 7) {
      return AppColors.info;
    } else {
      return AppColors.success;
    }
  }

  void _marcarVisto(BuildContext context) {
  // Marcar como visto en el BLoC
  context.read<RecordatoriosBloc>().add(MarcarRecordatorioVisto(recordatorio.id));
  
  // La cancelación de notificación ya se maneja en el BLoC
  
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: const Text('Recordatorio marcado como visto'),
      backgroundColor: AppColors.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      duration: const Duration(seconds: 2),
    ),
  );
}

  void _mostrarDetalles(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            _buildIconoPrioridad(),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                recordatorio.titulo,
                style: TextStyle(
                  color: AppColors.navy,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (recordatorio.descripcion != null) ...[
              Text(
                recordatorio.descripcion!,
                style: TextStyle(color: AppColors.navy.withOpacity(0.8)),
              ),
              const SizedBox(height: 16),
            ],
            
            _buildDetalleRow('Fecha:', recordatorio.fechaFormateada),
            _buildDetalleRow('Tipo:', recordatorio.tipo.toString().split('.').last),
            _buildDetalleRow('Prioridad:', recordatorio.prioridad.toString().split('.').last),
            
            if (recordatorio.proyecto != null) ...[
              _buildDetalleRow('Cliente:', recordatorio.proyecto!.cliente.nombreEmpresa),
              _buildDetalleRow('Proyecto:', recordatorio.proyecto!.nombre),
            ],
          ],
        ),
        actions: [
          if (!recordatorio.visto)
            TextButton.icon(
              onPressed: () {
                _marcarVisto(context);
                Navigator.of(context).pop();
              },
              icon: Icon(Icons.check, color: AppColors.success),
              label: Text('Marcar como visto', style: TextStyle(color: AppColors.success)),
            ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blueGray,
              foregroundColor: Colors.white,
            ),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetalleRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.navy,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: AppColors.navy.withOpacity(0.8)),
            ),
          ),
        ],
      ),
    );
  }
}