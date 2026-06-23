import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'home_page.dart';
import 'app_theme.dart';

void main() {
  // Ensure Flutter bindings are initialized for system overlay control.
  WidgetsFlutterBinding.ensureInitialized();

  // Set the system UI to a clean, immersive state.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Color(0xFFFAFAFA),
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const PortalLabsApp());
}

/// A showcase application for premium Flutter UI components.
///
/// This entry point is engineered to provide a high-fidelity environment
/// with consistent aesthetics and physics across all platforms.
class PortalLabsApp extends StatelessWidget {
  const PortalLabsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Portal Labs',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,

      // Global interaction logic:
      // 1. Force BouncingScrollPhysics for a premium tactile feel on all platforms.
      // 2. Disable default scrollbars for a cleaner minimalist look.
      // 3. Enable dragging with mouse and trackpad devices on web/desktop.
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        physics: const BouncingScrollPhysics(),
        scrollbars: false,
        dragDevices: {
          ui.PointerDeviceKind.touch,
          ui.PointerDeviceKind.mouse,
          ui.PointerDeviceKind.trackpad,
          ui.PointerDeviceKind.stylus,
        },
      ),

      // Global wrapper for environment injection and accessibility.
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            // Provides a consistent safe area mock for Web and Desktop.
            padding: kIsWeb
                ? const EdgeInsets.only(top: 20, bottom: 34)
                : MediaQuery.of(context).padding,
          ),
          child: child!,
        );
      },
      // Move SelectionArea here so it is a descendant of MaterialApp's internal Overlay.
      home: const SelectionArea(child: HomePage()),
    );
  }
}
