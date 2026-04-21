import 'package:flutter/material.dart';
import 'package:portal_labs/src/tag_selection_interaction/tag_selection_interaction.dart';

class TagSelectionInteractionShowcase extends StatefulWidget {
  const TagSelectionInteractionShowcase({super.key});

  @override
  State<TagSelectionInteractionShowcase> createState() => _TagSelectionInteractionShowcaseState();
}

class _TagSelectionInteractionShowcaseState extends State<TagSelectionInteractionShowcase> {
  final List<TagModel> _allTags = [
    const TagModel(id: '1', label: 'Node'),
    const TagModel(id: '2', label: 'React'),
    const TagModel(id: '3', label: 'Jest'),
    const TagModel(id: '4', label: 'Next'),
    const TagModel(id: '5', label: 'JavaScript'),
    const TagModel(id: '6', label: 'Express'),
    const TagModel(id: '7', label: 'Vue'),
    const TagModel(id: '8', label: 'TypeScript'),
    const TagModel(id: '9', label: 'Svelte'),
    const TagModel(id: '10', label: 'Gatsby'),
    const TagModel(id: '11', label: 'Knockout'),
    const TagModel(id: '12', label: 'Backbone'),
    const TagModel(id: '13', label: 'Ember'),
    const TagModel(id: '14', label: 'Chai'),
    const TagModel(id: '15', label: 'Mocha'),
    const TagModel(id: '16', label: 'Flutter'),
    const TagModel(id: '17', label: 'Dart'),
    const TagModel(id: '18', label: 'Supabase'),
  ];

  Set<String> _selectedIds = {'1', '2', '3', '4'};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFD),
      appBar: AppBar(
        title: const Text(
          'Tag Selection Interaction',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            TagSelectionInteraction(
              allTags: _allTags,
              initialSelectedIds: _selectedIds,
              onChanged: (ids) {
                setState(() {
                  _selectedIds = ids;
                });
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
