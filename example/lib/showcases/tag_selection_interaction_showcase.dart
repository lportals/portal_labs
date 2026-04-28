import 'package:flutter/material.dart';
import 'package:portal_labs/portal_labs.dart';
import '../showcase_shell.dart';

class TagSelectionInteractionShowcase extends StatefulWidget {
  const TagSelectionInteractionShowcase({super.key});

  @override
  State<TagSelectionInteractionShowcase> createState() =>
      _TagSelectionInteractionShowcaseState();
}

class _TagSelectionInteractionShowcaseState
    extends State<TagSelectionInteractionShowcase> {
  final List<TagModel> _allTags = const [
    TagModel(id: '1', label: 'Node'),
    TagModel(id: '2', label: 'React'),
    TagModel(id: '3', label: 'Jest'),
    TagModel(id: '4', label: 'Next'),
    TagModel(id: '5', label: 'JavaScript'),
    TagModel(id: '6', label: 'Express'),
    TagModel(id: '7', label: 'Vue'),
    TagModel(id: '8', label: 'TypeScript'),
    TagModel(id: '9', label: 'Svelte'),
    TagModel(id: '10', label: 'Gatsby'),
    TagModel(id: '11', label: 'Flutter'),
    TagModel(id: '12', label: 'Dart'),
    TagModel(id: '13', label: 'Supabase'),
    TagModel(id: '14', label: 'Mocha'),
    TagModel(id: '15', label: 'Backbone'),
  ];

  Set<String> _selectedIds = {'1', '2', '3', '4'};

  @override
  Widget build(BuildContext context) {
    return ShowcaseShell(
      title: 'Tag Selection',
      backgroundColor: const Color(0xFFFBFBFD),
      description:
          'Magic Move tag selection with custom Apple-inspired spring physics. '
          'Self-measuring Wrap layouts with dynamic natural sizing. Custom '
          'damped harmonic oscillator replicates premium OS bounce and flight.',
      codeSnippet: '''TagSelectionInteraction(
  allTags: [
    TagModel(id: '1', label: 'Flutter'),
    TagModel(id: '2', label: 'Dart'),
    TagModel(id: '3', label: 'Supabase'),
  ],
  initialSelectedIds: {'1'},
  onChanged: (selectedIds) => print('\${selectedIds.length} tags'),
)''',
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            TagSelectionInteraction(
              allTags: _allTags,
              initialSelectedIds: _selectedIds,
              onChanged: (ids) => setState(() => _selectedIds = ids),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
