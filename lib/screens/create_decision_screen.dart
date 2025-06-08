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

  final _desiredOutcomeController = TextEditingController();
  final _questionController = TextEditingController();
  String? _selectedCategory;
  Set<String> _selectedEmotions = {};

  String buildDecisionPrompt({
    required String mainQuestion,
    String? category,
    List<String>? emotions,
    String? desiredOutcome,
  }) {
    final buffer = StringBuffer();

    if (category != null && category.isNotEmpty) {
      buffer.writeln("Category: $category.");
    }

    if (emotions != null && emotions.isNotEmpty) {
      final emotionList = emotions.join(', ');
      buffer.writeln("Current emotional state: $emotionList.");
    }

    if (desiredOutcome != null && desiredOutcome.isNotEmpty) {
      buffer.writeln("What I hope to feel or achieve: $desiredOutcome.");
    }

    buffer.writeln("Here is my question: $mainQuestion");

    return buffer.toString();
  }

  final _mutation = """
    mutation CreateDecision(\$input: DecisionInput!) {
      createDecision(input: \$input) {
        answer
      }
    }
  """;

  void _onCreateDecision(RunMutation runMutation) {
    final question = buildDecisionPrompt(
      mainQuestion: _questionController.text,
      category: _selectedCategory,
      emotions: _selectedEmotions.toList(),
      desiredOutcome: _desiredOutcomeController.text,
    );

    runMutation({
      'input': {'question': question},
    });
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
            padding: EdgeInsetsGeometry.all(20),
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
                      onPressed: () => _onCreateDecision(runMutation),
                      label: Text("Point North"),
                      icon: Icon(Icons.explore),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
