// lib/bloc/recordatorios/recordatorios_event.dart
import 'package:equatable/equatable.dart';
import '../../models/recordatorio.dart';

abstract class RecordatoriosEvent extends Equatable {
  const RecordatoriosEvent();

  @override
  List<Object?> get props => [];
}

class CargarRecordatorios extends RecordatoriosEvent {
  final String usuarioId;

  const CargarRecordatorios(this.usuarioId);

  @override
  List<Object?> get props => [usuarioId];
}

class MarcarRecordatorioVisto extends RecordatoriosEvent {
  final String recordatorioId;

  const MarcarRecordatorioVisto(this.recordatorioId);

  @override
  List<Object?> get props => [recordatorioId];
}

class CrearRecordatorio extends RecordatoriosEvent {
  final Recordatorio recordatorio;

  const CrearRecordatorio(this.recordatorio);

  @override
  List<Object?> get props => [recordatorio];
}

class RefrescarRecordatorios extends RecordatoriosEvent {
  final String usuarioId;

  const RefrescarRecordatorios(this.usuarioId);

  @override
  List<Object?> get props => [usuarioId];
}