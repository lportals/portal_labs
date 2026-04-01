import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
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
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFAFAFA),
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(
            color: Colors.black,
            size: 20,
          ),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
          ),
        ),
        actionIconTheme: ActionIconThemeData(
          backButtonIconBuilder: (BuildContext context) => const Icon(
            Icons.arrow_back_rounded,
            size: 20,
          ),
        ),
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
      ),
      // We inject the "Safe Area" mock at the very root of the application.
      // This ensures that all pages, including showcases, inherit the padding.
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            padding: kIsWeb ? const EdgeInsets.only(top: 20, bottom: 34) : null,
          ),
          child: child!,
        );
      },
      home: const HomePage(),
    );
  }
}
