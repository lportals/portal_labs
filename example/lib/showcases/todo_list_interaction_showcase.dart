import 'package:flutter/material.dart';
import 'package:portal_labs/portal_labs.dart';

class TodoListInteractionShowcase extends StatelessWidget {
  const TodoListInteractionShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Todo List Interaction',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: const SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 32),
          child: TodoListInteraction(
            dateString: 'Apr 17, Friday',
            categories: [
              TodoCategory(id: 'work', title: 'Work'),
              TodoCategory(id: 'personal', title: 'Personal Projects'),
            ],
            items: [
              TodoItem(
                id: '1',
                title: 'User testing',
                categoryId: 'work',
              ),
              TodoItem(
                id: '2',
                title: 'Iterate designs',
                categoryId: 'work',
              ),
              TodoItem(
                id: '3',
                title: 'Landing wireframes',
                categoryId: 'work',
                isCompleted: true,
              ),
              TodoItem(
                id: '4',
                title: 'Motion ideas',
                categoryId: 'personal',
              ),
              TodoItem(
                id: '5',
                title: 'Figma variables',
                categoryId: 'personal',
              ),
              TodoItem(
                id: '6',
                title: 'Hero section',
                categoryId: 'personal',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
