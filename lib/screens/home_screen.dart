import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';
import 'package:true_north/screens/screens.dart';
import 'package:true_north/main.dart';
import 'package:true_north/utils/utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const itemsPerPage = 10;
  List<dynamic>? _decisions;
  bool _loading = true;
  int _page = 1;
  int _total = 0;

  bool get shouldShowPagination => (_total / itemsPerPage).ceil() > 1;
  bool get shouldEnableNextPagination =>
      _decisions != null && _decisions!.length == itemsPerPage;
  bool get shouldEnablePreviousPagination => _page != 1;

  Future<void> _fetchDecisions() async {
    setState(() => _loading = true);

    final result = await client.value.query(
      QueryOptions(
        document: gql('''
        query GetDecisions(\$limit: Int!, \$offset: Int!) {
          decisions(limit: \$limit, offset: \$offset) {
            decisions {
              id
              question
              progress
              createdAt
            }
            total
          }
        }
      '''),
        variables: {
          'limit': itemsPerPage,
          'offset': (_page - 1) * itemsPerPage,
        },
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    setState(() {
      _loading = false;
      if (!result.hasException) {
        _decisions = result.data?['decisions']['decisions'];
        _total = result.data?['decisions']['total'];
      }
    });
  }

  void onNext() {
    setState(() {
      if (shouldEnableNextPagination) _page++;
    });

    _fetchDecisions();
  }

  void onPrevious() {
    setState(() {
      if (shouldEnablePreviousPagination) _page--;
    });

    _fetchDecisions();
  }

  @override
  void initState() {
    super.initState();
    _fetchDecisions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("TrueNorth"),
        actions: [
          IconButton(
            color: Theme.of(context).primaryColor,
            icon: const Icon(Icons.logout),
            tooltip: 'Log Out',
            onPressed: () async {
              const storage = FlutterSecureStorage();
              await storage.write(key: 'jwt', value: null);

              if (!context.mounted) return;

              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              "Welcome 🌟👋 Need help finding your direction? Let's ground ourselves in today's choices.",
              style: TextStyle(fontSize: 20.0),
            ),
            const SizedBox(height: 32.0),
            Center(
              child: OutlinedButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateDecisionScreen(),
                    ),
                  );

                  if (result == 'refresh') {
                    await _fetchDecisions();
                  }
                },
                child: Column(
                  children: [
                    Icon(
                      Icons.explore,
                      color: Theme.of(context).primaryColor,
                      size: 32,
                    ),
                    const Text(
                      "Begin Contemplation",
                      style: TextStyle(fontSize: 24.0),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24.0),
            if (!_loading && shouldShowPagination)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: shouldEnablePreviousPagination
                        ? onPrevious
                        : null,
                    icon: Icon(Icons.chevron_left),
                    tooltip: 'Previous Page',
                  ),
                  SizedBox(width: 16),
                  IconButton(
                    onPressed: shouldEnableNextPagination ? onNext : null,
                    icon: Icon(Icons.chevron_right),
                    tooltip: 'Next Page',
                  ),
                ],
              ),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (_decisions != null && _decisions!.isNotEmpty)
              ..._decisions!.map((decision) {
                final createdAtRaw = decision['createdAt'] ?? '';
                final createdAt = DateTime.tryParse(createdAtRaw)?.toLocal();
                final formattedDate = createdAt != null
                    ? '${DateFormat('yMMMd').format(createdAt)}\n${DateFormat('h:mm a').format(createdAt)}'
                    : 'Unknown date';

                final progress = capitalize(decision['progress'] ?? 'Unknown');

                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DecisionScreen(id: decision['id']),
                        ),
                      );

                      _fetchDecisions();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  decision['question'] ?? '[No question]',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.chevron_right, size: 28),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                formattedDate,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Chip(
                                label: Text(progress),
                                labelStyle: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 0,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList()
            else
              const Text("No decisions yet."),
          ],
        ),
      ),
    );
  }
}
