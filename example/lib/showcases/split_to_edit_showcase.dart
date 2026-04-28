import 'package:flutter/material.dart';
import 'package:portal_labs/portal_labs.dart';
import '../showcase_shell.dart';

class SplitToEditShowcase extends StatefulWidget {
  const SplitToEditShowcase({super.key});

  @override
  State<SplitToEditShowcase> createState() => _SplitToEditShowcaseState();
}

class _SplitToEditShowcaseState extends State<SplitToEditShowcase> {
  int _hours = 2;
  int _minutes = 30;

  @override
  Widget build(BuildContext context) {
    return ShowcaseShell(
      title: 'Split to Edit',
      description:
          'Duration picker that splits from a unified view into editable '
          'segments with an ElasticOutCurve bounce transition. Haptic '
          'integration provides a premium mechanical feel.',
      backgroundColor: const Color(0xFFF5F5F7),
      codeSnippet: '''SplitToEditDuration(
  hours: 1,
  minutes: 42,
  onChanged: (h, m) => print('New time: \$h:\$m'),
)''',
      child: Align(
        alignment: const Alignment(0, -0.15),
        child: SplitToEditDuration(
          hours: _hours,
          minutes: _minutes,
          onChanged: (h, m) => setState(() {
            _hours = h;
            _minutes = m;
          }),
        ),
      ),
    );
  }
}
