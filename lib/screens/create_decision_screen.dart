import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class CreateDecisionScreen extends StatefulWidget {
  const CreateDecisionScreen({super.key});

  @override
  State<CreateDecisionScreen> createState() => _CreateDecisionScreenState();
}

class _CreateDecisionScreenState extends State<CreateDecisionScreen> {
  final List<String> categories = [
    'Career',
    'Relationships',
    'Health',
    'Finance',
    'Personal Growth',
    'Other',
  ];

  final List<String> emotions = [
    'Calm',
    'Hopeful',
    'Curious',
    'Excited',
    'Anxious',
    'Confused',
    'Overwhelmed',
    'Tired',
    'Frustrated',
    'Sad',
  ];

  final _formKey = GlobalKey<FormState>();
  final _desiredOutcomeController = TextEditingController();
  final _questionController = TextEditingController();
  String? _selectedCategory;
  Set<String> _selectedEmotions = {};

  final _mutation = """
    mutation CreateDecision(\$input: DecisionInput!) {
      createDecision(input: \$input)
    }
  """;

  void _onCreateDecision(RunMutation runMutation) {
    runMutation({
      'input': {
        'category': _selectedCategory,
        'desiredOutcome': _desiredOutcomeController.text,
        'emotions': _selectedEmotions.toList(),
        'question': _questionController.text,
      },
    });
  }

  @override
  void dispose() {
    _desiredOutcomeController.dispose();
    _questionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Comtemplation")),
      body: Mutation(
        options: MutationOptions(
          document: gql(_mutation),
          onCompleted: (data) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Pointing in right direction!')),
            );
            Navigator.pop(context, 'refresh');
          },
          onError: (error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${error?.graphqlErrors.first.message}'),
              ),
            );
          },
        ),
        builder: (runMutation, result) {
          return Padding(
            padding: const EdgeInsetsGeometry.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Which category relates to your decision?',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedCategory,
                    items: categories.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedCategory = newValue;
                      });
                    },
                  ),
                  const SizedBox(height: 40),
                  Text('How are you currently feeling?'),
                  Wrap(
                    spacing: 8.0,
                    children: emotions.map((emotion) {
                      return FilterChip(
                        label: Text(emotion),
                        selected: _selectedEmotions.contains(emotion),
                        onSelected: (bool selected) {
                          setState(() {
                            if (selected) {
                              _selectedEmotions.add(emotion);
                            } else {
                              _selectedEmotions.remove(emotion);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _questionController,
                    decoration: InputDecoration(
                      labelText: 'What are you trying to decide?',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'This field is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _desiredOutcomeController,
                    decoration: InputDecoration(
                      labelText: 'What do you hope to feel or achieve?',
                    ),
                  ),
                  const SizedBox(height: 60),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: result?.isLoading ?? false
                            ? null
                            : () {
                                if (_formKey.currentState?.validate() ??
                                    false) {
                                  _onCreateDecision(runMutation);
                                }
                              },
                        label: Text("Point North"),
                        icon: Icon(Icons.explore),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
