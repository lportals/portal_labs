import 'package:flutter/material.dart';
import 'package:portal_labs/portal_labs.dart';
import '../showcase_shell.dart';

class ArchiveFolderShowcase extends StatefulWidget {
  const ArchiveFolderShowcase({super.key});

  @override
  State<ArchiveFolderShowcase> createState() => _ArchiveFolderShowcaseState();
}

class _ArchiveFolderShowcaseState extends State<ArchiveFolderShowcase> {
  Color _selectedColor = const Color(0xFF30BB53);
  ArchiveFolderOrientation _orientation = ArchiveFolderOrientation.horizontal;
  bool _enableItemRotation = true;

  final List<Color> _folderColors = [
    const Color(0xFF30BB53), // Vibrant Green
    const Color(0xFF0082F4), // Bright Blue
    const Color(0xFFF78926), // Energetic Orange
  ];

  @override
  Widget build(BuildContext context) {
    return ShowcaseShell(
      title: 'Archive Folder',
      description:
          'A premium glassmorphic folder interaction with 3D perspective, '
          'side-tab geometry, and asymmetric reveal physics. Featuring '
          '"Pop-to-Front" Z-stacking and fully customizable dynamic sizing.',
      codeSnippet:
          '''
ArchiveFolder(
  title: 'Memories',
  subtitle: 'Collection 2026',
  style: ArchiveFolderStyle(
    enableItemRotation: $_enableItemRotation,
    orientation: $_orientation,
  ),
  items: [
    ArchiveItem(
      label: 'TROUPIAL STAMP',
      child: Image.network('...'),
    ),
  ],
)''',
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // ----------------------------------------------------------------
              // Archive folder widget
              // ----------------------------------------------------------------
              SizedBox(
                height:
                    MediaQuery.of(context).size.height *
                    0.45, // Usa el 45% de la pantalla para el showcase
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: ArchiveFolder(
                      title: 'Memories',
                      subtitle: 'Collection 2026',
                      style: ArchiveFolderStyle(
                        folderColor: _selectedColor,
                        orientation: _orientation,
                        enableItemRotation: _enableItemRotation,
                        itemRevealDistance: 70.0,
                        itemSpacing:
                            _orientation == ArchiveFolderOrientation.horizontal
                            ? 75.0
                            : 38.0,
                      ),
                      items: [
                        ArchiveItem(
                          color: const Color(0xFFFDFCFB),
                          label: 'HISTORIC STAMP',
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: Image.network(
                              'https://classiclatinamerica.com/wp-content/uploads/2018/07/Screen-Shot-2018-07-24-at-14.17.24.png',
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => const Center(
                                child: Icon(
                                  Icons.image_not_supported_outlined,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),
                        ArchiveItem(
                          label: 'TROUPIAL STAMP',
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: Image.network(
                              'https://www.birdtheme.org/showimages/venezuel/i/vzu196104l.jpg',
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => const Center(
                                child: Icon(
                                  Icons.image_not_supported_outlined,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),
                        ArchiveItem(
                          color: const Color(0xFFF5F7FA),
                          label: 'BACHACO STAMP',
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: Image.network(
                              'https://i.pinimg.com/736x/ce/a9/25/cea92554894220ac987269fb22f47c36.jpg',
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => const Center(
                                child: Icon(
                                  Icons.image_not_supported_outlined,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // ----------------------------------------------------------------
              // Colour picker
              // ----------------------------------------------------------------
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _folderColors.map((color) {
                  final bool isSelected = _selectedColor == color;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = color),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOutBack,
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? Colors.grey.withValues(alpha: 0.3)
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          boxShadow: [
                            if (isSelected)
                              BoxShadow(
                                color: color.withValues(alpha: 0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 30),

              // ----------------------------------------------------------------
              // Controls
              // ----------------------------------------------------------------
              Wrap(
                spacing: 20,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        value:
                            _orientation == ArchiveFolderOrientation.horizontal,
                        onChanged: (val) {
                          setState(() {
                            _orientation = val!
                                ? ArchiveFolderOrientation.horizontal
                                : ArchiveFolderOrientation.vertical;
                          });
                        },
                        activeColor: _selectedColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const Text(
                        'Horizontal Mode',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        value: _enableItemRotation,
                        onChanged: (val) {
                          setState(() => _enableItemRotation = val!);
                        },
                        activeColor: _selectedColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const Text(
                        'Organic Tilt',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}
