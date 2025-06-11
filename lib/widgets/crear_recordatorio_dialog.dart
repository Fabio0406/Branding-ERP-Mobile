// lib/widgets/crear_recordatorio_dialog.dart
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

class CrearRecordatorioDialog extends StatefulWidget {
  const CrearRecordatorioDialog({Key? key}) : super(key: key);

  @override
  State<CrearRecordatorioDialog> createState() => _CrearRecordatorioDialogState();
}

class _CrearRecordatorioDialogState extends State<CrearRecordatorioDialog> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  
  DateTime _fechaSeleccionada = DateTime.now().add(const Duration(hours: 1));
  TipoRecordatorio _tipoSeleccionado = TipoRecordatorio.reunion;
  PrioridadRecordatorio _prioridadSeleccionada = PrioridadRecordatorio.media;

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.blueGray.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.add_task,
              color: AppColors.blueGray,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Crear Recordatorio',
            style: TextStyle(
              color: AppColors.navy,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _tituloController,
                decoration: InputDecoration(
                  labelText: 'Título *',
                  labelStyle: TextStyle(color: AppColors.navy),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.lightBlue),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.lightBlue.withOpacity(0.5)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.blueGray, width: 2),
                  ),
                  prefixIcon: Icon(Icons.title, color: AppColors.lightBlue),
                ),
                style: TextStyle(color: AppColors.navy),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El título es requerido';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _descripcionController,
                decoration: InputDecoration(
                  labelText: 'Descripción',
                  labelStyle: TextStyle(color: AppColors.navy),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.lightBlue),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.lightBlue.withOpacity(0.5)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.blueGray, width: 2),
                  ),
                  prefixIcon: Icon(Icons.description, color: AppColors.lightBlue),
                ),
                style: TextStyle(color: AppColors.navy),
                maxLines: 3,
              ),
              
              const SizedBox(height: 16),
              
              DropdownButtonFormField<TipoRecordatorio>(
                value: _tipoSeleccionado,
                decoration: InputDecoration(
                  labelText: 'Tipo',
                  labelStyle: TextStyle(color: AppColors.navy),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.lightBlue),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.lightBlue.withOpacity(0.5)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.blueGray, width: 2),
                  ),
                  prefixIcon: Icon(Icons.category, color: AppColors.lightBlue),
                ),
                style: TextStyle(color: AppColors.navy),
                dropdownColor: Colors.white,
                items: TipoRecordatorio.values.map((tipo) {
                  return DropdownMenuItem(
                    value: tipo,
                    child: Row(
                      children: [
                        Icon(
                          _getTipoIcon(tipo),
                          color: _getTipoColor(tipo),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _getTipoLabel(tipo),
                          style: TextStyle(color: AppColors.navy),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _tipoSeleccionado = value!;
                  });
                },
              ),
              
              const SizedBox(height: 16),
              
              DropdownButtonFormField<PrioridadRecordatorio>(
                value: _prioridadSeleccionada,
                decoration: InputDecoration(
                  labelText: 'Prioridad',
                  labelStyle: TextStyle(color: AppColors.navy),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.lightBlue),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.lightBlue.withOpacity(0.5)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.blueGray, width: 2),
                  ),
                  prefixIcon: Icon(Icons.priority_high, color: AppColors.lightBlue),
                ),
                style: TextStyle(color: AppColors.navy),
                dropdownColor: Colors.white,
                items: PrioridadRecordatorio.values.map((prioridad) {
                  return DropdownMenuItem(
                    value: prioridad,
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: _getPrioridadColor(prioridad),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _getPrioridadLabel(prioridad),
                          style: TextStyle(color: AppColors.navy),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _prioridadSeleccionada = value!;
                  });
                },
              ),
              
              const SizedBox(height: 16),
              
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.lightBlue.withOpacity(0.5)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.lightBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.calendar_today, color: AppColors.lightBlue),
                  ),
                  title: Text(
                    'Fecha y Hora',
                    style: TextStyle(
                      color: AppColors.navy,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    '${_fechaSeleccionada.day}/${_fechaSeleccionada.month}/${_fechaSeleccionada.year} '
                    '${_fechaSeleccionada.hour.toString().padLeft(2, '0')}:'
                    '${_fechaSeleccionada.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(color: AppColors.blueGray),
                  ),
                  trailing: Icon(Icons.edit, color: AppColors.lightBlue),
                  onTap: _seleccionarFecha,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.navy.withOpacity(0.7),
          ),
          child: const Text('Cancelar'),
        ),
        ElevatedButton.icon(
          onPressed: _crearRecordatorio,
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Crear'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.blueGray,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
      ],
    );
  }

  String _getTipoLabel(TipoRecordatorio tipo) {
    switch (tipo) {
      case TipoRecordatorio.entrega:
        return 'Entrega';
      case TipoRecordatorio.reunion:
        return 'Reunión';
      case TipoRecordatorio.aprobacion:
        return 'Aprobación';
      case TipoRecordatorio.seguimiento:
        return 'Seguimiento';
      case TipoRecordatorio.deadline:
        return 'Fecha límite';
      case TipoRecordatorio.presentacion:
        return 'Presentación';
    }
  }

  IconData _getTipoIcon(TipoRecordatorio tipo) {
    switch (tipo) {
      case TipoRecordatorio.entrega:
        return Icons.file_upload;
      case TipoRecordatorio.reunion:
        return Icons.people;
      case TipoRecordatorio.aprobacion:
        return Icons.check_circle;
      case TipoRecordatorio.seguimiento:
        return Icons.track_changes;
      case TipoRecordatorio.deadline:
        return Icons.alarm;
      case TipoRecordatorio.presentacion:
        return Icons.present_to_all;
    }
  }

  Color _getTipoColor(TipoRecordatorio tipo) {
    switch (tipo) {
      case TipoRecordatorio.entrega:
        return AppColors.info;
      case TipoRecordatorio.reunion:
        return AppColors.success;
      case TipoRecordatorio.aprobacion:
        return AppColors.warning;
      case TipoRecordatorio.seguimiento:
        return AppColors.lightBlue;
      case TipoRecordatorio.deadline:
        return AppColors.error;
      case TipoRecordatorio.presentacion:
        return AppColors.blueGray;
    }
  }

  String _getPrioridadLabel(PrioridadRecordatorio prioridad) {
    switch (prioridad) {
      case PrioridadRecordatorio.baja:
        return 'Baja';
      case PrioridadRecordatorio.media:
        return 'Media';
      case PrioridadRecordatorio.alta:
        return 'Alta';
      case PrioridadRecordatorio.urgente:
        return 'Urgente';
    }
  }

  Color _getPrioridadColor(PrioridadRecordatorio prioridad) {
    switch (prioridad) {
      case PrioridadRecordatorio.baja:
        return AppColors.success;
      case PrioridadRecordatorio.media:
        return AppColors.warning;
      case PrioridadRecordatorio.alta:
        return AppColors.info;
      case PrioridadRecordatorio.urgente:
        return AppColors.error;
    }
  }

  Future<void> _seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.blueGray,
              onPrimary: Colors.white,
              onSurface: AppColors.navy,
            ),
          ),
          child: child!,
        );
      },
    );

    if (fecha != null) {
      final hora = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_fechaSeleccionada),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: AppColors.blueGray,
                onPrimary: Colors.white,
                onSurface: AppColors.navy,
              ),
            ),
            child: child!,
          );
        },
      );

      if (hora != null) {
        setState(() {
          _fechaSeleccionada = DateTime(
            fecha.year,
            fecha.month,
            fecha.day,
            hora.hour,
            hora.minute,
          );
        });
      }
    }
  }

  void _crearRecordatorio() {
  if (_formKey.currentState!.validate()) {
    final recordatorio = Recordatorio(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      titulo: _tituloController.text,
      descripcion: _descripcionController.text.isEmpty ? null : _descripcionController.text,
      fechaRecordatorio: _fechaSeleccionada,
      tipo: _tipoSeleccionado,
      prioridad: _prioridadSeleccionada,
      visto: false,
      createdAt: DateTime.now(),
    );

    // Crear recordatorio con notificación (manejado en el BLoC)
    context.read<RecordatoriosBloc>().add(CrearRecordatorio(recordatorio));
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            const Text('Recordatorio creado exitosamente'),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
}