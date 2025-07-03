import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';
import 'package:true_north/main.dart';
import 'package:true_north/utils/utils.dart';

class DecisionScreen extends StatefulWidget {
  final String id;
  const DecisionScreen({Key? key, required this.id}) : super(key: key);

  @override
  State<DecisionScreen> createState() => _DecisionScreenState();
}

class _DecisionScreenState extends State<DecisionScreen> {
  dynamic? _decision;
  bool _loading = true;
  String _selectedProgress = 'unstarted';
  final List<String> _progressOptions = [
    'unstarted',
    'in progress',
    'reflected',
    'resolved',
  ];

  Future<void> _fetchDecision() async {
    setState(() => _loading = true);

    final result = await client.value.query(
      QueryOptions(
        document: gql('''
        query GetDecision(\$id: String!) {
          decisionById(id: \$id) {
            id
            answer
            category
            desiredOutcome
            emotions
            progress
            question
            createdAt
          }
        }
      '''),
        variables: {'id': widget.id},
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    setState(() {
      _loading = false;
      if (!result.hasException) {
        _decision = result.data?['decisionById'];
        _selectedProgress = _decision?['progress'] ?? 'unstarted';
      }
    });
  }

  Future<void> _deleteDecision() async {
    setState(() => _loading = true);

    await client.value.mutate(
      MutationOptions(
        document: gql('''
        mutation DeleteDecision(\$id: String!) {
          deleteDecision(id: \$id)
        }
      '''),
        variables: {'id': widget.id},
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    setState(() => _loading = false);
  }

  Future<void> _updateDecision(String? newValue) async {
    setState(() {
      _loading = true;
    });

    await client.value.mutate(
      MutationOptions(
        document: gql('''
        mutation UpdateDecision(\$id: String!, \$input: UpdateDecisionInput!) {
          updateDecision(id: \$id, input: \$input)
        }
      '''),
        variables: {
          'id': widget.id,
          'input': {'progress': newValue},
        },
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    setState(() {
      _loading = false;
      _selectedProgress = newValue ?? 'unstarted';
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchDecision();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guidance'),
        actions: [
          IconButton(
            color: Colors.red,
            icon: const Icon(Icons.delete),
            tooltip: 'Delete Decision',
            onPressed: () async {
              await _deleteDecision();

              if (!context.mounted) return;

              Navigator.pop(context, 'refresh');
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _decision == null
          ? const Center(child: Text("Decision not found."))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _decision['question'] ?? '[No question]',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    DateFormat.yMMMd().add_jm().format(
                      DateTime.parse(_decision['createdAt']).toLocal(),
                    ),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'PROGRESS',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      DropdownButton<String>(
                        value: _selectedProgress,
                        items: _progressOptions.map((String progress) {
                          return DropdownMenuItem<String>(
                            value: progress,
                            child: Text(capitalize(progress)),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          _updateDecision(newValue);
                        },
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  if (_decision['category'] != null &&
                      _decision['category'].toString().isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CATEGORY',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(_decision['category']),
                      ],
                    ),
                  if (_decision['category'] != null &&
                      _decision['category'].toString().isNotEmpty)
                    const SizedBox(height: 16),
                  if (_decision['desiredOutcome'] != null &&
                      _decision['desiredOutcome'].toString().isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'DESIRED OUTCOME',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(_decision['desiredOutcome']),
                      ],
                    ),
                  if (_decision['desiredOutcome'] != null &&
                      _decision['desiredOutcome'].toString().isNotEmpty)
                    const SizedBox(height: 16),
                  if (_decision['emotions'] != null &&
                      _decision['emotions'] is List)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'EMOTIONAL STATE',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: (_decision['emotions'] as List)
                              .map<Widget>(
                                (e) => Chip(label: Text(e.toString())),
                              )
                              .toList(),
                        ),
                      ],
                    ),

                  const SizedBox(height: 16),
                  Text(
                    'ANSWER',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _decision['answer']?.toString().isNotEmpty == true
                        ? _decision['answer']
                        : '[No answer yet]',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
    );
  }
}
