import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'app.dart';

final HttpLink httpLink = HttpLink(
  'https://truenorthserver.fly.dev/graphql',
  defaultHeaders: {'Content-Type': 'application/json'},
);

ValueNotifier<GraphQLClient> client = ValueNotifier(
  GraphQLClient(link: httpLink, cache: GraphQLCache()),
);

void main() {
  runApp(GraphQLProvider(client: client, child: TrueNorthApp()));
}
