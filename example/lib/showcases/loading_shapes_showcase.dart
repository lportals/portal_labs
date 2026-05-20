import 'package:flutter/material.dart';
import 'package:portal_labs/portal_labs.dart';
import '../showcase_shell.dart';

class LoadingShapesShowcase extends StatefulWidget {
  const LoadingShapesShowcase({super.key});

  @override
  State<LoadingShapesShowcase> createState() => _LoadingShapesShowcaseState();
}

class _LoadingShapesShowcaseState extends State<LoadingShapesShowcase> {
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    return ShowcaseShell(
      title: 'Loading Shapes',
      description:
          'High-fidelity loading indicator with a physics-based momentum rotation engine and smooth 120-point vertex morphing.',
      codeSnippet: '''LoadingShapes(
  isLoading: true,
  style: LoadingShapesStyle(
    size: 140.0,
    color: Color(0xFF1D1D1F),
    transitionDuration: Duration(milliseconds: 800),
    baseRotationSpeed: 0.007,
    boostRotationSpeed: 0.02,
    shapes: [
      PortalShapeDefinition(sides: 5, smoothness: 0.4),
      PortalShapeDefinition(sides: 2, innerRadiusRatio: 0.6, smoothness: 0.7),
    ],
  ),
)''',
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LoadingShapes(
              isLoading: _isLoading,
              style: LoadingShapesStyle(
                size: 160,
                color: const Color(0xFF1D1D1F),
                shadows: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 60),
            const Text(
              'Thinking...',
              style: TextStyle(
                color: Color(0xFF1D1D1F),
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Creating your masterpiece: 99%',
              style: TextStyle(
                color: const Color(0xFF1D1D1F).withValues(alpha: 0.5),
                fontSize: 16,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 80),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = !_isLoading;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1D1D1F),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 18,
                ),
                shape: const StadiumBorder(),
              ),
              child: Text(
                _isLoading ? 'Stop Loading' : 'Start Loading',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
