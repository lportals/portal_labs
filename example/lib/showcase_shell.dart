import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A reusable shell for every component showcase page.
///
/// Provides a consistent AppBar with a floating ⓘ info button that opens
/// a bottom sheet containing the component description and integration snippet.
///
/// For immersive, full-screen showcases (e.g. [MediaCollapsibleView]),
/// set [hasAppBar] to false — the ⓘ button will float as an overlay instead.
class ShowcaseShell extends StatelessWidget {
  /// The name of the component being showcased.
  final String title;

  /// A short, one or two-sentence description of what the component does
  /// and what problem it solves.
  final String description;

  /// The minimal Dart integration snippet shown in the info sheet.
  final String codeSnippet;

  /// The component demo widget.
  final Widget child;

  /// The scaffold background color.
  final Color backgroundColor;

  /// When false, no AppBar is rendered and the ⓘ button floats as a
  /// [Positioned] overlay. Use this for full-screen / immersive showcases.
  final bool hasAppBar;

  /// Whether to show the back button in immersive mode.
  final bool showBackButton;

  /// Whether to show the info button in immersive mode.
  final bool showInfoButton;

  /// Optional list of technical features or highlights to show in bullet points.
  final List<String>? infoItems;

  const ShowcaseShell({
    super.key,
    required this.title,
    required this.description,
    required this.codeSnippet,
    required this.child,
    this.backgroundColor = const Color(0xFFFAFAFA),
    this.hasAppBar = true,
    this.showBackButton = true,
    this.showInfoButton = true,
    this.infoItems,
  });


  void _showInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _InfoBottomSheet(
        title: title,
        description: description,
        codeSnippet: codeSnippet,
        infoItems: infoItems,
      ),

    );
  }

  @override
  Widget build(BuildContext context) {
    if (hasAppBar) {
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: backgroundColor,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.3,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                icon: const Icon(
                  Icons.info_outline_rounded,
                  color: Color(0xFF8E8E93),
                  size: 22,
                ),
                tooltip: 'About this component',
                onPressed: () => _showInfo(context),
              ),
            ),
          ],
        ),
        body: child,
      );
    }

    // Immersive mode: child fills the screen, ⓘ floats on top.
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          child,
          // Floating back button
          if (showBackButton)
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 16,
              child: _FloatingButton(
                icon: Icons.arrow_back_rounded,
                onTap: () => Navigator.of(context).pop(),
              ),
            ),
          // Floating info button
          if (showInfoButton)
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              right: 16,
              child: _FloatingButton(
                icon: Icons.info_outline_rounded,
                onTap: () => _showInfo(context),
              ),
            ),
        ],
      ),
    );
  }
}

/// A frosted-glass floating action button used in immersive mode.
class _FloatingButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _FloatingButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.35),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}

/// The draggable info bottom sheet shown when the ⓘ button is tapped.
class _InfoBottomSheet extends StatefulWidget {
  final String title;
  final String description;
  final String codeSnippet;
  final List<String>? infoItems;

  const _InfoBottomSheet({
    required this.title,
    required this.description,
    required this.codeSnippet,
    this.infoItems,
  });

  @override
  State<_InfoBottomSheet> createState() => _InfoBottomSheetState();
}

class _InfoBottomSheetState extends State<_InfoBottomSheet> {
  bool _copied = false;

  void _copyCode() async {
    await Clipboard.setData(ClipboardData(text: widget.codeSnippet));
    setState(() => _copied = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Transparent tap-to-close area
        Positioned.fill(
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            behavior: HitTestBehavior.opaque,
            child: Container(color: Colors.transparent),
          ),
        ),
        DraggableScrollableSheet(
          initialChildSize: 0.55,
          minChildSize: 0.35,
          maxChildSize: 0.92,
          snap: true,
          snapSizes: const [0.55, 0.92],
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF2F2F7),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  // Drag handle
                  Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 8),
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFCCCCCC),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // Scrollable content
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                      children: [
                        // Component label pill
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF111111),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'portal_labs',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Title
                        Text(
                          widget.title,
                          style: const TextStyle(
                            color: Color(0xFF111111),
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.8,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Description
                        Text(
                          widget.description,
                          style: const TextStyle(
                            color: Color(0xFF555555),
                            fontSize: 15,
                            height: 1.5,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        if (widget.infoItems != null && widget.infoItems!.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          ...widget.infoItems!.map((item) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.only(top: 6),
                                      child: Icon(Icons.circle, size: 4, color: Color(0xFF8E8E93)),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        item,
                                        style: const TextStyle(
                                          color: Color(0xFF555555),
                                          fontSize: 14,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                        ],
                        const SizedBox(height: 24),
                        // Code snippet header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Integration',
                              style: TextStyle(
                                color: Color(0xFF111111),
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.2,
                              ),
                            ),
                            GestureDetector(
                              onTap: _copyCode,
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                child: _copied
                                    ? const Row(
                                        key: ValueKey('copied'),
                                        children: [
                                          Icon(
                                            Icons.check_rounded,
                                            size: 14,
                                            color: Color(0xFF34C759),
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            'Copied',
                                            style: TextStyle(
                                              color: Color(0xFF34C759),
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      )
                                    : const Row(
                                        key: ValueKey('copy'),
                                        children: [
                                          Icon(
                                            Icons.copy_rounded,
                                            size: 14,
                                            color: Color(0xFF8E8E93),
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            'Copy',
                                            style: TextStyle(
                                              color: Color(0xFF8E8E93),
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Code block
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1C1C1E),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            widget.codeSnippet,
                            style: const TextStyle(
                              color: Color(0xFFE5E5EA),
                              fontSize: 12.5,
                              fontFamily: 'monospace',
                              height: 1.6,
                              letterSpacing: 0.1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
