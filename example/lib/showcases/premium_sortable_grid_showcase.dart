import 'package:flutter/material.dart';
import 'package:portal_labs/portal_labs.dart';
import '../showcase_shell.dart';

class PremiumSortableGridShowcase extends StatefulWidget {
  const PremiumSortableGridShowcase({super.key});

  @override
  State<PremiumSortableGridShowcase> createState() => _PremiumSortableGridShowcaseState();
}

class _PremiumSortableGridShowcaseState extends State<PremiumSortableGridShowcase> {
  late List<Map<String, dynamic>> _items;
  int _crossAxisCount = 3;

  @override
  void initState() {
    super.initState();
    _resetItems();
  }

  void _resetItems() {
    setState(() {
      _items = List.generate(6, (i) => {
        'id': i + 1,
        'color': [
          Colors.blue,
          Colors.orange,
          Colors.red,
          Colors.green,
          Colors.purple,
          Colors.amber
        ][i % 6],
      });
    });
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      final item = _items.removeAt(oldIndex);
      _items.insert(newIndex, item);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ShowcaseShell(
      title: 'Sortable Grid',
      backgroundColor: Colors.white,
      description: 'A high-fidelity reorderable grid powered by physics-based spring simulations. '
          'Features a tactile "Pulse-on-Hold" interaction and intelligent sensor zones for '
          'seamless organization even in empty grid areas.',
      infoItems: const [
        'Spring Physics: Uses PortalSpringCurve for liquid, momentum-based motion.',
        'Pulse Interaction: Visual feedback during long-press to signal drag readiness.',
        'ID-Based Tracking: Robust reordering that maintains item identity across layouts.',
        'Haptic Engine: Integrated tactile feedback on every interaction phase.',
        'Adaptive Height: Automatically calculates grid bounds to maintain layout stability.',
      ],
      codeSnippet: '''PremiumSortableGrid<Map<String, dynamic>>(
  items: _items,
  idBuilder: (item) => item['id'],
  onReorder: (oldIndex, newIndex) {
    setState(() {
      final item = _items.removeAt(oldIndex);
      _items.insert(newIndex, item);
    });
  },
  emptyBuilder: (context) => Center(child: Text("Empty Grid")),
  style: PremiumSortableGridStyle(
    crossAxisCount: $_crossAxisCount,
    spacing: 12.0,
  ),
  itemBuilder: (context, item) => Container(
    decoration: BoxDecoration(
      color: item['color'],
      borderRadius: BorderRadius.circular(16),
    ),
  ),
)''',
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: _crossAxisCount > 1 ? () => setState(() => _crossAxisCount--) : null,
                        icon: const Icon(Icons.remove, size: 20),
                        visualDensity: VisualDensity.compact,
                      ),
                      IconButton(
                        onPressed: _crossAxisCount < 5 ? () => setState(() => _crossAxisCount++) : null,
                        icon: const Icon(Icons.add, size: 20),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: PremiumSortableGrid<Map<String, dynamic>>(
                items: _items,
                idBuilder: (item) => item['id'],
                onReorder: _onReorder,
                emptyBuilder: (context) => _buildEmptyState(),
                style: PremiumSortableGridStyle(
                  crossAxisCount: _crossAxisCount,
                  spacing: 12.0,
                  borderRadius: BorderRadius.circular(16),
                  showMagneticGhost: false,
                  flybackDuration: const Duration(milliseconds: 800),
                ),
                itemBuilder: (context, item) => _buildItem(item),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(Map<String, dynamic> item) {
    return Container(
      decoration: BoxDecoration(
        color: item['color'],
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Icon(Icons.grid_off_rounded, size: 48, color: Colors.grey[200]),
          const SizedBox(height: 16),
          TextButton(onPressed: _resetItems, child: const Text('Restore Items')),
        ],
      ),
    );
  }
}
