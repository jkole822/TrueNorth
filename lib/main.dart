import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';

late ValueNotifier<GraphQLClient> client;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initHiveForFlutter(); // Required for GraphQL cache

  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('jwt');

  final HttpLink httpLink = HttpLink('https://truenorthserver.fly.dev/graphql');

  final Link link = token != null
      ? AuthLink(getToken: () async => 'Bearer $token').concat(httpLink)
      : httpLink;

  client = ValueNotifier(GraphQLClient(link: link, cache: GraphQLCache()));

  runApp(GraphQLProvider(client: client, child: TrueNorthApp()));
}
