// lib/widgets/proyecto_card.dart
import 'package:flutter/material.dart';
import '../models/proyecto.dart';

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

class ProyectoCard extends StatelessWidget {
  final Proyecto proyecto;

  const ProyectoCard({Key? key, required this.proyecto}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
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
                        Text(
                          proyecto.nombre,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.navy,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          proyecto.cliente.nombreEmpresa,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.blueGray,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (proyecto.marca != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            'Marca: ${proyecto.marca!.nombre}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.lightBlue,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (proyecto.tipo != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getColorTipo().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _getColorTipo().withOpacity(0.3)),
                      ),
                      child: Text(
                        proyecto.tipo!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _getColorTipo(),
                        ),
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.lightBlue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.lightBlue.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.lightBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(Icons.calendar_today, size: 16, color: AppColors.lightBlue),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Inicio: ${proyecto.fechaInicioFormateada}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.navy,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        if (proyecto.etapas.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.blueGray.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${proyecto.etapas.length} etapas',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.blueGray,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                    
                    if (proyecto.etapas.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Progreso',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.navy,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '${(_calcularProgreso() * 100).toInt()}% completado',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: _getColorTipo(),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: _calcularProgreso(),
                              backgroundColor: AppColors.lightBlue.withOpacity(0.2),
                              valueColor: AlwaysStoppedAnimation<Color>(_getColorTipo()),
                              minHeight: 6,
                            ),
                          ),
                        ],
                      ),
                    ],
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
    switch (proyecto.tipo?.toLowerCase()) {
      case 'rebranding':
        return AppColors.warning;
      case 'creacion':
        return AppColors.success;
      case 'extension':
        return AppColors.info;
      default:
        return AppColors.blueGray;
    }
  }

  IconData _getIconoTipo() {
    switch (proyecto.tipo?.toLowerCase()) {
      case 'rebranding':
        return Icons.refresh;
      case 'creacion':
        return Icons.add_circle;
      case 'extension':
        return Icons.extension;
      default:
        return Icons.work;
    }
  }

  double _calcularProgreso() {
    if (proyecto.etapas.isEmpty) return 0.0;
    
    final completadas = proyecto.etapas
        .where((etapa) => etapa.estado?.toLowerCase() == 'completada')
        .length;
    
    return completadas / proyecto.etapas.length;
  }

  void _mostrarDetalles(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.darkNavy.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.lightBlue.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                Row(
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
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            proyecto.nombre,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.navy,
                            ),
                          ),
                          Text(
                            proyecto.cliente.nombreEmpresa,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.blueGray,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                if (proyecto.etapas.isNotEmpty) ...[
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.blueGray.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.timeline, color: AppColors.blueGray, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Etapas del Proyecto',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.navy,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: proyecto.etapas.length,
                      itemBuilder: (context, index) {
                        final etapa = proyecto.etapas[index];
                        final isCompleted = etapa.estado?.toLowerCase() == 'completada';
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: isCompleted 
                              ? AppColors.success.withOpacity(0.05)
                              : AppColors.lightBlue.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isCompleted 
                                ? AppColors.success.withOpacity(0.3)
                                : AppColors.lightBlue.withOpacity(0.3),
                            ),
                          ),
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isCompleted 
                                  ? AppColors.success.withOpacity(0.1)
                                  : AppColors.lightBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                isCompleted
                                    ? Icons.check_circle
                                    : Icons.radio_button_unchecked,
                                color: isCompleted
                                    ? AppColors.success
                                    : AppColors.lightBlue,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              etapa.descripcion ?? 'Sin descripción',
                              style: TextStyle(
                                color: AppColors.navy,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: etapa.responsable != null
                                ? Text(
                                    'Responsable: ${etapa.responsable}',
                                    style: TextStyle(color: AppColors.navy.withOpacity(0.7)),
                                  )
                                : null,
                            trailing: etapa.fechaLimite != null
                                ? Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.lightBlue.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${etapa.fechaLimite!.day}/${etapa.fechaLimite!.month}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.lightBlue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                ] else ...[
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: AppColors.lightBlue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              Icons.timeline_outlined,
                              size: 48,
                              color: AppColors.lightBlue,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No hay etapas definidas',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.navy,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Este proyecto aún no tiene etapas configuradas',
                            style: TextStyle(color: AppColors.navy.withOpacity(0.7)),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}