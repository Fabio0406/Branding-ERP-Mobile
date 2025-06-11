// lib/config/graphql_queries.dart
class GraphQLQueries {
  static const String getRecordatoriosPendientes = '''
    query GetRecordatoriosPendientes(\$usuarioId: ID!) {
      getRecordatoriosPendientes(usuarioId: \$usuarioId) {
        id
        titulo
        descripcion
        fechaRecordatorio
        tipo
        prioridad
        visto
        proyecto {
          id
          nombre
          cliente {
            nombreEmpresa
          }
        }
        createdAt
      }
    }
  ''';

  static const String getActividadesHoy = '''
    query GetActividadesHoy(\$usuarioId: ID!) {
      getActividadesHoy(usuarioId: \$usuarioId) {
        id
        titulo
        descripcion
        fechaInicio
        fechaFin
        tipo
        proyecto {
          id
          nombre
          cliente {
            nombreEmpresa
          }
        }
      }
    }
  ''';

  static const String getProyectosByUsuario = '''
    query GetProyectosByUsuario(\$usuarioId: ID!) {
      getProyectosByUsuario(usuarioId: \$usuarioId) {
        id
        nombre
        tipo
        fechaInicio
        cliente {
          id
          nombreEmpresa
          sector
        }
        marca {
          id
          nombre
          sector
        }
        etapas {
          id
          descripcion
          fechaLimite
          estado
          responsable
        }
        kpis {
          id
          tipo
          valor
          periodo
          fechaRegistro
        }
      }
    }
  ''';

  // 🔔 QUERY CORREGIDA PARA NOTIFICACIONES
  static const String getNotificaciones = '''
    query GetNotificaciones(\$usuarioId: ID!, \$limit: Int) {
      getNotificaciones(usuarioId: \$usuarioId, limit: \$limit) {
        id
        titulo
        mensaje
        tipo
        leida
        fecha
        accionUrl
        interaccion
        fechaInteraccion
        proyecto {
          id
          nombre
          tipo
          estado
          cliente {
            id
            nombreEmpresa
            sector
          }
        }
      }
    }
  ''';

  static const String marcarRecordatorioVisto = '''
    mutation MarcarRecordatorioVisto(\$recordatorioId: ID!) {
      marcarRecordatorioVisto(recordatorioId: \$recordatorioId)
    }
  ''';

  static const String crearRecordatorio = '''
    mutation CrearRecordatorio(\$input: RecordatorioInput!) {
      crearRecordatorio(input: \$input) {
        id
        titulo
        descripcion
        fechaRecordatorio
        tipo
        prioridad
        visto
      }
    }
  ''';

  static const String subscripcionNotificaciones = '''
    subscription NuevasNotificaciones(\$usuarioId: ID!) {
      nuevasNotificaciones(usuarioId: \$usuarioId) {
        id
        titulo
        mensaje
        tipo
        leida
        fecha
        proyecto {
          id
          nombre
        }
      }
    }
  ''';
// 🔔 MUTACIÓN PARA MARCAR NOTIFICACIÓN COMO LEÍDA
  static const String marcarNotificacionLeida = '''
    mutation MarcarNotificacionLeida(\$notificacionId: ID!, \$accion: String!) {
      registrarInteraccionNotificacion(notificacionId: \$notificacionId, accion: \$accion)
    }
  ''';

   // 🔔 QUERY PARA CONFIGURACIÓN DE NOTIFICACIONES
  static const String getUserNotificationSettings = '''
    query GetUserNotificationSettings(\$usuarioId: ID!) {
      getUserNotificationSettings(usuarioId: \$usuarioId) {
        notificacionesHabilitadas
        recordatoriosHabilitados
        proyectosHabilitados
        fcmToken
      }
    }
  ''';

  // 🔔 MUTACIÓN PARA ACTUALIZAR TOKEN FCM
  static const String updateUserFCMToken = '''
    mutation UpdateUserFCMToken(\$usuarioId: ID!, \$token: String!) {
      updateUserFCMToken(usuarioId: \$usuarioId, token: \$token) {
        success
        message
      }
    }
  ''';

  // 🔔 MUTACIÓN PARA ENVIAR NOTIFICACIÓN PUSH
  static const String sendPushNotification = '''
    mutation SendPushNotification(\$input: PushNotificationInput!) {
      sendPushNotification(input: \$input) {
        success
        messageId
        error
      }
    }
  ''';
  
}