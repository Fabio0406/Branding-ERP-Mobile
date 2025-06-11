// lib/bloc/recordatorios/recordatorios_bloc.dart
import 'package:branding_erp_mobile/models/cliente.dart';
import 'package:branding_erp_mobile/models/proyecto.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../../config/graphql_config.dart';
import '../../config/graphql_queries.dart';
import '../../models/recordatorio.dart';
import 'recordatorios_event.dart';
import 'recordatorios_state.dart';

class RecordatoriosBloc extends Bloc<RecordatoriosEvent, RecordatoriosState> {
  final GraphQLClient _client = GraphQLConfig.instance;

  RecordatoriosBloc() : super(RecordatoriosInitial()) {
    on<CargarRecordatorios>(_onCargarRecordatorios);
    on<MarcarRecordatorioVisto>(_onMarcarRecordatorioVisto);
    on<CrearRecordatorio>(_onCrearRecordatorio);
    on<RefrescarRecordatorios>(_onRefrescarRecordatorios);
  }

  Future<void> _onCargarRecordatorios(
    CargarRecordatorios event,
    Emitter<RecordatoriosState> emit,
  ) async {
    emit(RecordatoriosLoading());

    try {
      print('🔍 Cargando recordatorios para usuario: ${event.usuarioId}');
      
      final QueryOptions options = QueryOptions(
        document: gql(GraphQLQueries.getRecordatoriosPendientes),
        variables: {'usuarioId': event.usuarioId},
      );

      final QueryResult result = await _client.query(options);

      if (result.hasException) {
        print('❌ Error GraphQL: ${result.exception}');
        emit(RecordatoriosError(result.exception.toString()));
        return;
      }

      print('📝 Datos recibidos: ${result.data}');

      final List<dynamic> recordatoriosData = 
          result.data?['getRecordatoriosPendientes'] ?? [];

      print('📋 Número de recordatorios: ${recordatoriosData.length}');

      // Parsing seguro de cada recordatorio
      final List<Recordatorio> recordatorios = [];
      for (var data in recordatoriosData) {
        try {
          final recordatorio = _parseRecordatorioSafe(data);
          if (recordatorio != null) {
            recordatorios.add(recordatorio);
          }
        } catch (e) {
          print('⚠️ Error parsing recordatorio: $e');
          print('📄 Data problemática: $data');
          // Continuar con el siguiente recordatorio
        }
      }

      final now = DateTime.now();
      final hoy = DateTime(now.year, now.month, now.day);
      
      final recordatoriosUrgentes = recordatorios
          .where((r) => r.esUrgente && !r.visto)
          .toList();

      final recordatoriosHoy = recordatorios
          .where((r) => 
              DateTime(r.fechaRecordatorio.year, r.fechaRecordatorio.month, r.fechaRecordatorio.day)
                  .isAtSameMomentAs(hoy))
          .toList();

      print('✅ Recordatorios procesados:');
      print('   Total: ${recordatorios.length}');
      print('   Urgentes: ${recordatoriosUrgentes.length}');
      print('   Hoy: ${recordatoriosHoy.length}');

      emit(RecordatoriosLoaded(
        recordatorios: recordatorios,
        recordatoriosUrgentes: recordatoriosUrgentes,
        recordatoriosHoy: recordatoriosHoy,
      ));

    } catch (e, stackTrace) {
      print('❌ Error al cargar recordatorios: $e');
      print('📍 Stack trace: $stackTrace');
      emit(RecordatoriosError('Error al cargar recordatorios: $e'));
    }
  }

  Recordatorio? _parseRecordatorioSafe(dynamic data) {
    try {
      if (data == null) return null;

      // Parsing seguro de campos básicos
      final id = _getStringSafe(data, 'id');
      final titulo = _getStringSafe(data, 'titulo');
      final fechaRecordatorioStr = _getStringSafe(data, 'fechaRecordatorio');
      final tipoStr = _getStringSafe(data, 'tipo');
      final prioridadStr = _getStringSafe(data, 'prioridad');

      if (id.isEmpty || titulo.isEmpty || fechaRecordatorioStr.isEmpty) {
        print('⚠️ Campos requeridos faltantes en recordatorio');
        return null;
      }

      // Parsing de fecha
      DateTime fechaRecordatorio;
      try {
        fechaRecordatorio = DateTime.parse(fechaRecordatorioStr);
      } catch (e) {
        print('⚠️ Error parsing fecha: $fechaRecordatorioStr');
        return null;
      }

      // Parsing de enums
      TipoRecordatorio tipo;
      try {
        tipo = TipoRecordatorio.values.firstWhere(
          (e) => e.toString().split('.').last.toUpperCase() == tipoStr.toUpperCase(),
          orElse: () => TipoRecordatorio.reunion,
        );
      } catch (e) {
        tipo = TipoRecordatorio.reunion;
      }

      PrioridadRecordatorio prioridad;
      try {
        prioridad = PrioridadRecordatorio.values.firstWhere(
          (e) => e.toString().split('.').last.toUpperCase() == prioridadStr.toUpperCase(),
          orElse: () => PrioridadRecordatorio.media,
        );
      } catch (e) {
        prioridad = PrioridadRecordatorio.media;
      }

      // Parsing de proyecto (opcional)
      Proyecto? proyecto;
      if (data['proyecto'] != null) {
        try {
          proyecto = _parseProyectoSafe(data['proyecto']);
        } catch (e) {
          print('⚠️ Error parsing proyecto: $e');
          // proyecto queda como null
        }
      }

      // Parsing de fecha de creación
      DateTime createdAt;
      try {
        final createdAtStr = _getStringSafe(data, 'createdAt');
        createdAt = createdAtStr.isNotEmpty 
            ? DateTime.parse(createdAtStr) 
            : DateTime.now();
      } catch (e) {
        createdAt = DateTime.now();
      }

      return Recordatorio(
        id: id,
        titulo: titulo,
        descripcion: _getStringSafe(data, 'descripcion').isNotEmpty 
            ? _getStringSafe(data, 'descripcion') 
            : null,
        fechaRecordatorio: fechaRecordatorio,
        tipo: tipo,
        prioridad: prioridad,
        visto: _getBoolSafe(data, 'visto'),
        proyecto: proyecto,
        createdAt: createdAt,
      );

    } catch (e) {
      print('❌ Error completo parsing recordatorio: $e');
      return null;
    }
  }

  Proyecto? _parseProyectoSafe(dynamic data) {
    try {
      if (data == null) return null;

      final id = _getStringSafe(data, 'id');
      final nombre = _getStringSafe(data, 'nombre');

      if (id.isEmpty || nombre.isEmpty) return null;

      // Parsing de cliente
      Cliente? cliente;
      if (data['cliente'] != null) {
        final clienteData = data['cliente'];
        final clienteId = _getStringSafe(clienteData, 'id');
        final nombreEmpresa = _getStringSafe(clienteData, 'nombreEmpresa');
        
        if (clienteId.isNotEmpty && nombreEmpresa.isNotEmpty) {
          cliente = Cliente(
            id: clienteId,
            nombreEmpresa: nombreEmpresa,
            contacto: _getIntSafe(clienteData, 'contacto'),
            sector: _getStringSafe(clienteData, 'sector').isNotEmpty 
                ? _getStringSafe(clienteData, 'sector') 
                : null,
          );
        }
      }

      if (cliente == null) {
        // Crear cliente por defecto para evitar errores
        cliente = Cliente(
          id: '0',
          nombreEmpresa: 'Cliente desconocido',
        );
      }

      return Proyecto(
        id: id,
        nombre: nombre,
        tipo: _getStringSafe(data, 'tipo').isNotEmpty 
            ? _getStringSafe(data, 'tipo') 
            : null,
        fechaInicio: _getDateTimeSafe(data, 'fechaInicio'),
        cliente: cliente,
        marca: null, // Por ahora simplificado
        etapas: const [],
        kpis: const [],
      );

    } catch (e) {
      print('❌ Error parsing proyecto: $e');
      return null;
    }
  }

  String _getStringSafe(dynamic data, String key) {
    try {
      final value = data[key];
      if (value == null) return '';
      return value.toString();
    } catch (e) {
      return '';
    }
  }

  bool _getBoolSafe(dynamic data, String key) {
    try {
      final value = data[key];
      if (value == null) return false;
      if (value is bool) return value;
      if (value is String) return value.toLowerCase() == 'true';
      return false;
    } catch (e) {
      return false;
    }
  }

  int? _getIntSafe(dynamic data, String key) {
    try {
      final value = data[key];
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    } catch (e) {
      return null;
    }
  }

  DateTime? _getDateTimeSafe(dynamic data, String key) {
    try {
      final value = _getStringSafe(data, key);
      if (value.isEmpty) return null;
      return DateTime.parse(value);
    } catch (e) {
      return null;
    }
  }

  Future<void> _onMarcarRecordatorioVisto(
    MarcarRecordatorioVisto event,
    Emitter<RecordatoriosState> emit,
  ) async {
    try {
      print('🔄 Marcando recordatorio como visto: ${event.recordatorioId}');
      
      final MutationOptions options = MutationOptions(
        document: gql(GraphQLQueries.marcarRecordatorioVisto),
        variables: {'recordatorioId': event.recordatorioId},
      );

      final QueryResult result = await _client.mutate(options);

      if (result.hasException) {
        print('❌ Error en mutation: ${result.exception}');
        emit(RecordatoriosError(result.exception.toString()));
        return;
      }

      print('✅ Recordatorio marcado como visto');
      // Recargar recordatorios después de marcar como visto
      add(const RefrescarRecordatorios('1'));

    } catch (e) {
      print('❌ Error al marcar recordatorio: $e');
      emit(RecordatoriosError('Error al marcar recordatorio: $e'));
    }
  }

  
Future<void> _onCrearRecordatorio(
  CrearRecordatorio event,
  Emitter<RecordatoriosState> emit,
) async {
  try {
    print('🆕 Creando recordatorio: ${event.recordatorio.titulo}');
    
    // Formatear fecha correctamente para GraphQL
    final fechaFormateada = event.recordatorio.fechaRecordatorio.toUtc().toIso8601String();
    print('📅 Fecha formateada: $fechaFormateada');
    
    final MutationOptions options = MutationOptions(
      document: gql(GraphQLQueries.crearRecordatorio),
      variables: {
        'input': {
          'titulo': event.recordatorio.titulo,
          'descripcion': event.recordatorio.descripcion ?? '',
          'fechaRecordatorio': fechaFormateada,
          'tipo': event.recordatorio.tipo.toString().split('.').last.toUpperCase(),
          'prioridad': event.recordatorio.prioridad.toString().split('.').last.toUpperCase(),
          'proyectoId': event.recordatorio.proyecto?.id,
          'usuarioId': '1',
        }
      },
    );

    print('📝 Variables enviadas: ${options.variables}');

    final QueryResult result = await _client.mutate(options);

    if (result.hasException) {
      print('❌ Error en mutation crear: ${result.exception}');
      emit(RecordatoriosError('Error al crear recordatorio: ${result.exception}'));
      return;
    }

    print('✅ Recordatorio creado exitosamente');
    // Recargar recordatorios después de crear uno nuevo
    add(const RefrescarRecordatorios('1'));

  } catch (e) {
    print('❌ Error al crear recordatorio: $e');
    emit(RecordatoriosError('Error al crear recordatorio: $e'));
  }
}

  Future<void> _onRefrescarRecordatorios(
    RefrescarRecordatorios event,
    Emitter<RecordatoriosState> emit,
  ) async {
    add(CargarRecordatorios(event.usuarioId));
  }

  
}