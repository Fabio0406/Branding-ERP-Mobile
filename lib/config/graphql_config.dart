// lib/config/graphql_config.dart
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GraphQLConfig {
  static late ValueNotifier<GraphQLClient> client;
  static late GraphQLClient _client;

  static Future<void> initialize() async {
    await initHiveForFlutter();
    
    final HttpLink httpLink = HttpLink(
      'http://192.168.26.9:4000/graphql',
    );

    final AuthLink authLink = AuthLink(
      getToken: () async {
        final prefs = await SharedPreferences.getInstance();
        return 'Bearer ${prefs.getString('auth_token') ?? ''}';
      },
    );

    // WebSocket con protocolo correcto
    final WebSocketLink wsLink = WebSocketLink(
      'ws://192.168.26.9:4000/graphql',
      config: const SocketClientConfig(
        autoReconnect: true,
        inactivityTimeout: Duration(seconds: 30),
      ),
    );

    final Link link = Link.split(
      (request) => request.isSubscription,
      wsLink,
      authLink.concat(httpLink),
    );

    _client = GraphQLClient(
      link: link,
      cache: GraphQLCache(store: HiveStore()),
    );

    client = ValueNotifier(_client);
  }

  static GraphQLClient get instance => _client;
}