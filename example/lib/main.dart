import 'package:flutter/material.dart';
import 'home_page.dart';

void main() {
  runApp(const PortalLabsApp());
}

/// A showcase application for premium Flutter UI components.
class PortalLabsApp extends StatelessWidget {
  const PortalLabsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Portal Labs',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFFAFAFA),
        useMaterial3: true,
        fontFamily: 'Inter',
      ),
      home: const HomePage(),
    );
  }
}

