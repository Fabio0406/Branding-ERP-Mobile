// lib/bloc/recordatorios/recordatorios_state.dart
import 'package:equatable/equatable.dart';
import '../../models/recordatorio.dart';

abstract class RecordatoriosState extends Equatable {
  const RecordatoriosState();

  @override
  List<Object?> get props => [];
}

class RecordatoriosInitial extends RecordatoriosState {}

class RecordatoriosLoading extends RecordatoriosState {}

class RecordatoriosLoaded extends RecordatoriosState {
  final List<Recordatorio> recordatorios;
  final List<Recordatorio> recordatoriosUrgentes;
  final List<Recordatorio> recordatoriosHoy;

  const RecordatoriosLoaded({
    required this.recordatorios,
    required this.recordatoriosUrgentes,
    required this.recordatoriosHoy,
  });

  @override
  List<Object?> get props => [recordatorios, recordatoriosUrgentes, recordatoriosHoy];

  RecordatoriosLoaded copyWith({
    List<Recordatorio>? recordatorios,
    List<Recordatorio>? recordatoriosUrgentes,
    List<Recordatorio>? recordatoriosHoy,
  }) {
    return RecordatoriosLoaded(
      recordatorios: recordatorios ?? this.recordatorios,
      recordatoriosUrgentes: recordatoriosUrgentes ?? this.recordatoriosUrgentes,
      recordatoriosHoy: recordatoriosHoy ?? this.recordatoriosHoy,
    );
  }
}

class RecordatoriosError extends RecordatoriosState {
  final String message;

  const RecordatoriosError(this.message);

  @override
  List<Object?> get props => [message];
}
