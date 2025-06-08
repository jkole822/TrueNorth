import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';
import 'package:true_north/screens/create_decision_screen.dart';
import 'package:true_north/main.dart';
import 'package:true_north/utils/utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic>? _decisions;
  bool _loading = true;

  Future<void> _fetchDecisions({int limit = 10, int offset = 0}) async {
    setState(() => _loading = true);

    final result = await client.value.query(
      QueryOptions(
        document: gql('''
        query GetDecisions {
          decisions {
            id
            question
            progress
            createdAt
          }
        }
      '''),
        variables: {'limit': limit, 'offset': offset},
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    setState(() {
      _loading = false;
      if (!result.hasException) {
        _decisions = result.data?['decisions'];
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchDecisions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("TrueNorth")),
      body: Padding(
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
                    onTap: () {
                      // TODO: Navigate to DecisionDetailScreen when ready
                      // Navigator.push(context, MaterialPageRoute(
                      //   builder: (context) => DecisionDetailScreen(id: decision['id']),
                      // ));
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
