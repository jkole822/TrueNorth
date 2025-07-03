import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'app.dart';

late ValueNotifier<GraphQLClient> client;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initHiveForFlutter(); // Required for GraphQL cache

  const storage = FlutterSecureStorage();
  final token = await storage.read(key: 'jwt');

  final HttpLink httpLink = HttpLink('https://truenorthserver.fly.dev/graphql');

  final Link link = token != null && token.isNotEmpty
      ? AuthLink(getToken: () async => 'Bearer $token').concat(httpLink)
      : httpLink;

  client = ValueNotifier(GraphQLClient(link: link, cache: GraphQLCache()));

  runApp(GraphQLProvider(client: client, child: TrueNorthApp()));
}
