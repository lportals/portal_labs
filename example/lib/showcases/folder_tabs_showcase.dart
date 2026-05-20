import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:portal_labs/portal_labs.dart';
import '../showcase_shell.dart';

class FolderTabsShowcase extends StatefulWidget {
  const FolderTabsShowcase({super.key});

  @override
  State<FolderTabsShowcase> createState() => _FolderTabsShowcaseState();
}

class _FolderTabsShowcaseState extends State<FolderTabsShowcase> {
  late _FolderTheme _activeTheme;
  double _maxVisibleItems = 5.0;

  final List<_FolderTheme> _themes = const [
    _FolderTheme(
      name: 'Manila',
      folderColor: Color(0xFFE6D7C3),
      activeInkColor: Color(0xFF2C2216),
      inactiveInkColor: Color(0xFF8A7E6E),
      chipColor: Color(0xFFE6D7C3),
    ),
    _FolderTheme(
      name: 'Steel Blue',
      folderColor: Color(0xFF8DA5B4),
      activeInkColor: Color(0xFF1B2C38),
      inactiveInkColor: Color(0xFF5C7280),
      chipColor: Color(0xFF8DA5B4),
    ),
    _FolderTheme(
      name: 'Sage Green',
      folderColor: Color(0xFFA4B4A1),
      activeInkColor: Color(0xFF2B3828),
      inactiveInkColor: Color(0xFF6B7568),
      chipColor: Color(0xFFA4B4A1),
    ),
    _FolderTheme(
      name: 'Charcoal',
      folderColor: Color(0xFF333333),
      activeInkColor: Color(0xFFF5F5F5),
      inactiveInkColor: Color(0xFF888888),
      chipColor: Color(0xFF333333),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _activeTheme = _themes.first;
  }

  @override
  Widget build(BuildContext context) {
    return ShowcaseShell(
      title: 'Folder Tabs Studio',
      description:
          'An interactive, physics-driven file folder container. Tweak the visible height '
          'constraints and swap material color schemes dynamically using the Studio Controls panel below.',
      backgroundColor: const Color(0xFFF0F0F3),
      codeSnippet:
          '''FolderTabs(
  tabs: const ['Receipts', 'Contracts', 'Ideas'],
  style: FolderTabsStyle(
    folderColor: ${_activeTheme.folderColor.toString()},
    tabHeight: 38.0,
    tabProtrusionWidth: 125.0,
  ),
  children: [
    _buildFileList(..., maxVisibleItems: ${_maxVisibleItems.toInt()}),
  ],
)''',
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. The Interactive Folder
              FolderTabs(
                tabs: const ['Receipts', 'Contracts', 'Ideas'],
                style: FolderTabsStyle(
                  folderColor: _activeTheme.folderColor,
                  tabHeight: 38.0,
                  tabProtrusionWidth: 125.0,
                  borderRadius: 24.0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28.0,
                    vertical: 32.0,
                  ),
                  activeLabelStyle: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: _activeTheme.activeInkColor,
                    fontFamily: 'Courier',
                    letterSpacing: -0.2,
                  ),
                  inactiveLabelStyle: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: _activeTheme.inactiveInkColor,
                    fontFamily: 'Courier',
                    letterSpacing: -0.2,
                  ),
                ),
                children: [
                  _FolderContentList(
                    files: const [
                      'uber-trip-0512.pdf',
                      'starbucks-coffee.pdf',
                      'apple-developer-fee.pdf',
                    ],
                    maxItems: _maxVisibleItems.toInt(),
                    inkColor: _activeTheme.activeInkColor,
                  ),
                  _FolderContentList(
                    files: const [
                      'freelance-agreement.md',
                      'non-disclosure-agreement.md',
                      'office-lease-v2.pdf',
                      'partnership-terms.docx',
                      'consulting-services-contract.pdf',
                      'employment-contract-template.pdf',
                      'vendor-sla-final.pdf',
                    ],
                    maxItems: _maxVisibleItems.toInt(),
                    inkColor: _activeTheme.activeInkColor,
                  ),
                  _FolderContentList(
                    files: const [
                      'app-wireframes.sketch',
                      'marketing-strategy.md',
                      'brainstorming-session.txt',
                    ],
                    maxItems: _maxVisibleItems.toInt(),
                    inkColor: _activeTheme.activeInkColor,
                  ),
                ],
              ),

              const SizedBox(height: 36.0),

              // 2. Interactive Studio Controls Panel
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24.0),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x06000000),
                      blurRadius: 16.0,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.tune,
                          size: 16,
                          color: Colors.black.withValues(alpha: 0.5),
                        ),
                        const SizedBox(width: 8.0),
                        Text(
                          'STUDIO CONTROLS',
                          style: TextStyle(
                            fontSize: 11.0,
                            fontWeight: FontWeight.w900,
                            color: Colors.black.withValues(alpha: 0.5),
                            letterSpacing: 1.5,
                            fontFamily: 'Courier',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24.0),

                    // Color Option Row
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Folder Color Theme',
                                style: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black87,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                _activeTheme.name,
                                style: TextStyle(
                                  fontSize: 12.0,
                                  color: Colors.black.withValues(alpha: 0.4),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: List.generate(_themes.length, (index) {
                            final theme = _themes[index];
                            final isSelected = _activeTheme == theme;

                            return Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _activeTheme = theme;
                                  });
                                },
                                child: Container(
                                  width: 32.0,
                                  height: 32.0,
                                  decoration: BoxDecoration(
                                    color: theme.chipColor,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.blue.shade400
                                          : Colors.black.withValues(alpha: 0.1),
                                      width: isSelected ? 2.5 : 1.0,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: Colors.blue.shade200
                                                  .withValues(alpha: 0.4),
                                              blurRadius: 6.0,
                                              spreadRadius: 1.0,
                                            ),
                                          ]
                                        : null,
                                  ),
                                  alignment: Alignment.center,
                                  child: isSelected
                                      ? Icon(
                                          Icons.check,
                                          size: 14,
                                          color: theme.activeInkColor,
                                        )
                                      : null,
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),

                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 18.0),
                      child: Divider(
                        height: 1.0,
                        thickness: 1.0,
                        color: Color(0xFFF0F0F0),
                      ),
                    ),

                    // Max Visible Items Slider
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Max Capped Items',
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w800,
                                color: Colors.black87,
                                letterSpacing: -0.2,
                              ),
                            ),
                            Text(
                              '${_maxVisibleItems.toInt()} visible',
                              style: TextStyle(
                                fontSize: 13.0,
                                fontWeight: FontWeight.w700,
                                color: Colors.blue.shade500,
                                fontFamily: 'Courier',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10.0),
                        SliderTheme(
                          data: SliderThemeData(
                            activeTrackColor: Colors.blue.shade400,
                            inactiveTrackColor: Colors.grey.shade200,
                            thumbColor: Colors.blue.shade500,
                            overlayColor: Colors.blue.shade100.withValues(
                              alpha: 0.3,
                            ),
                            valueIndicatorColor: Colors.blue.shade600,
                          ),
                          child: Slider(
                            value: _maxVisibleItems,
                            min: 2.0,
                            max: 7.0,
                            divisions: 5,
                            label: '${_maxVisibleItems.toInt()}',
                            onChanged: (value) {
                              setState(() {
                                _maxVisibleItems = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FolderTheme {
  const _FolderTheme({
    required this.name,
    required this.folderColor,
    required this.activeInkColor,
    required this.inactiveInkColor,
    required this.chipColor,
  });

  final String name;
  final Color folderColor;
  final Color activeInkColor;
  final Color inactiveInkColor;
  final Color chipColor;
}

class _FolderContentList extends StatelessWidget {
  const _FolderContentList({
    required this.files,
    required this.maxItems,
    required this.inkColor,
  });

  final List<String> files;
  final int maxItems;
  final Color inkColor;

  @override
  Widget build(BuildContext context) {
    // Each file row is exactly 43px tall (12px top/bottom padding + 18px text + 1px divider)
    final double capHeight = 43.0 * maxItems;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: capHeight),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: List.generate(files.length, (index) {
            final fileName = files[index];

            return Material(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Opening file: $fileName',
                            style: const TextStyle(
                              fontFamily: 'Courier',
                              fontWeight: FontWeight.bold,
                              fontSize: 13.5,
                            ),
                          ),
                          backgroundColor: inkColor.withValues(alpha: 0.9),
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                      );
                    },
                    highlightColor: inkColor.withValues(alpha: 0.08),
                    splashColor: inkColor.withValues(alpha: 0.12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12.0,
                        horizontal: 8.0,
                      ),
                      child: Text(
                        fileName,
                        style: TextStyle(
                          fontSize: 14.5,
                          color: inkColor.withValues(alpha: 0.9),
                          fontFamily: 'Courier',
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ),
                  Divider(
                    height: 1.0,
                    thickness: 1.0,
                    color: inkColor.withValues(alpha: 0.12),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
