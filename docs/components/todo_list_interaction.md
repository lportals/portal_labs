# Todo List Interaction

![Todo List Showcase](https://raw.githubusercontent.com/lportals/portal_labs/main/docs/gifs/to_do_list_interaction.gif)

A high-fidelity task management component featuring a sophisticated "concentric
island" design, sliding spring segmented controls, and choreographed diagonal
"flight" animations for task completion.

#### Key Features

- **Concentric Island Aesthetic**: Multi-layered design with the date title
  perfectly centered in the outer container and tasks strictly contained within
  a white interactive island.
- **Choreographed Flight Physics**: Completing a task triggers a 3-stage visual
  event: (1) Lateral horizontal shift, (2) State toggle, and (3) Diagonal flight
  to its new position in the completed section.
- **Morphing Segmented Control**: A custom 3-tab filter (To-do, Completed,
  Pending) where the active bubble elastically morphs and slides using
  high-performance physics.
- **Independent Animation Cycles**: Supports rapid-fire user interactions;
  multiple tasks can fly simultaneously without interrupting each other's
  transition paths.
- **Fully Theme-Aware**: Every aspect including background colors, radii,
  spacing, localization filters, and spring stiffness is configurable via
  `TodoListStyle`.

#### Integration

```dart
import 'package:portal_labs/portal_labs.dart';

TodoListInteraction(
  dateString: 'Apr 17, Friday',
  categories: [
    TodoCategory(id: 'work', title: 'Work'),
  ],
  items: [
    TodoItem(id: '1', categoryId: 'work', title: 'Finish UI Component'),
    TodoItem(id: '2', categoryId: 'work', title: 'Code Review', isCompleted: true),
  ],
  onChanged: (updatedItems) => print('Task list updated'),
)
```
