import 'package:flutter/material.dart';
import 'package:portal_labs/portal_labs.dart';
import '../showcase_shell.dart';

class TodoListInteractionShowcase extends StatelessWidget {
  const TodoListInteractionShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    return ShowcaseShell(
      title: 'Todo List Interaction',
      backgroundColor: Colors.white,
      description:
          'High-fidelity task manager with concentric Island design and '
          'diagonal flight animations. Tri-stage completion interaction with '
          'lateral shift, state toggle, and diagonal landing. Concurrent animation support.',
      codeSnippet: '''TodoListInteraction(
  dateString: 'Apr 17, Friday',
  categories: [
    TodoCategory(id: 'work', title: 'Work'),
    TodoCategory(id: 'personal', title: 'Personal'),
  ],
  items: [
    TodoItem(id: '1', title: 'User testing', categoryId: 'work'),
    TodoItem(id: '2', title: 'Design review', categoryId: 'personal'),
  ],
)''',
      child: const SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 32),
          child: TodoListInteraction(
            dateString: 'Apr 17, Friday',
            categories: [
              TodoCategory(id: 'work', title: 'Work'),
              TodoCategory(id: 'personal', title: 'Personal Projects'),
            ],
            items: [
              TodoItem(id: '1', title: 'User testing', categoryId: 'work'),
              TodoItem(id: '2', title: 'Iterate designs', categoryId: 'work'),
              TodoItem(
                id: '3',
                title: 'Landing wireframes',
                categoryId: 'work',
                isCompleted: true,
              ),
              TodoItem(id: '4', title: 'Motion ideas', categoryId: 'personal'),
              TodoItem(
                id: '5',
                title: 'Figma variables',
                categoryId: 'personal',
              ),
              TodoItem(id: '6', title: 'Hero section', categoryId: 'personal'),
            ],
          ),
        ),
      ),
    );
  }
}
