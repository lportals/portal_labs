import 'package:flutter/material.dart';
import 'package:portal_labs/portal_labs.dart';
import '../showcase_shell.dart';

class PhysicsCollisionCardShowcase extends StatefulWidget {
  const PhysicsCollisionCardShowcase({super.key});

  @override
  State<PhysicsCollisionCardShowcase> createState() => _PhysicsCollisionCardShowcaseState();
}

class _PhysicsCollisionCardShowcaseState extends State<PhysicsCollisionCardShowcase> {
  // Configurable physics simulation settings
  Offset _gravity = const Offset(0.0, 900.0);
  double _restitution = 0.70;
  double _damping = 0.15;
  int _resetCounter = 0;

  // Avatars image mockup list with premium gradients
  final List<Map<String, dynamic>> _mockItems = [
    {
      'url': 'https://developers.google.com/static/focus/images/aistudio-icon-2026.png',
      'initials': 'AI',
      'radius': 36.0,
      'fit': BoxFit.contain,
      'padding': 0.0,
      'transparent': true,
    },
    {
      'url': 'https://antigravity.google/assets/image/brand/antigravity-icon__full-color.png',
      'initials': 'AG',
      'radius': 38.0,
      'fit': BoxFit.contain,
      'padding': 0.0,
      'transparent': true,
    },
    {
      'url': 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1d/Google_Gemini_icon_2025.svg/250px-Google_Gemini_icon_2025.svg.png?utm_source=commons.wikimedia.org&utm_campaign=index&utm_content=thumbnail',
      'initials': 'GE',
      'radius': 35.0,
      'fit': BoxFit.contain,
      'padding': 0.0,
      'transparent': true,
    },
    {
      'url': 'https://www.gstatic.com/devrel-devsite/prod/vb08cbdb02acf7f66ad9727ddfba9d81df8806422eb5dd63dba194c9c8c7997f7/firebase/images/touchicon-180.png',
      'initials': 'FB',
      'radius': 32.0,
      'fit': BoxFit.contain,
      'padding': 0.0,
      'transparent': true,
    },
    {
      'url': 'https://static.vecteezy.com/system/resources/previews/072/678/241/non_2x/google-flutter-logo-icon-free-png.png',
      'initials': 'FL',
      'radius': 34.0,
      'fit': BoxFit.contain,
      'padding': 0.0,
      'transparent': true,
    },
    {
      'url': 'https://upload.wikimedia.org/wikipedia/commons/thumb/3/31/Android_robot_head.svg/1280px-Android_robot_head.svg.png?utm_source=commons.wikimedia.org&utm_campaign=index&utm_content=thumbnail',
      'initials': 'AD',
      'radius': 36.0,
      'fit': BoxFit.contain,
      'padding': 0.0,
      'transparent': true,
    },
    {
      'url': 'https://crystalpng.com/wp-content/uploads/2025/05/google-logo.png',
      'initials': 'GO',
      'radius': 32.0,
      'fit': BoxFit.contain,
      'padding': 0.0,
      'transparent': true,
    },
    {
      'url': 'https://cdn-icons-png.freepik.com/512/975/975645.png',
      'initials': 'FK',
      'radius': 26.0,
      'fit': BoxFit.contain,
      'padding': 0.0,
      'transparent': true,
    },
  ];

  void _changeGravity(Offset newGravity) {
    setState(() {
      _gravity = newGravity;
    });
  }

  void _resetSimulation() {
    setState(() {
      _resetCounter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isSpaceMode = _gravity == Offset.zero;

    // Recreate items to trigger full physics state rebuild on reset
    final List<PhysicsCollisionItem> physicsItems = _mockItems.map((item) {
      final bool isTransparent = item['transparent'] as bool? ?? false;

      return PhysicsCollisionItem(
        radius: item['radius'] as double,
        decoration: isTransparent
            ? const BoxDecoration(color: Colors.transparent)
            : null,
        clipToCircle: !isTransparent,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (!isTransparent) ...[
              // Base background
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: item['gradient'] as List<Color>,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(item['padding'] as double? ?? 0.0),
                  child: item['url'] != null
                      ? Image.network(
                          item['url'] as String,
                          fit: item['fit'] as BoxFit? ?? BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => _buildFallback(item),
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return _buildFallback(item);
                          },
                        )
                      : _buildFallback(item),
                ),
              ),
              // Gloss / Specular Highlights
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: 0.35),
                        Colors.white.withValues(alpha: 0.0),
                        Colors.black.withValues(alpha: 0.12),
                      ],
                      stops: const [0.0, 0.55, 1.0],
                    ),
                  ),
                ),
              ),
              // Circular inner ring outline
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ] else ...[
              // Transparent items render the PNG logo directly without circular bg, gloss, or borders
              item['url'] != null
                  ? Image.network(
                      item['url'] as String,
                      fit: item['fit'] as BoxFit? ?? BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildFallback(item),
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return _buildFallback(item);
                      },
                    )
                  : _buildFallback(item),
            ],
          ],
        ),
      );
    }).toList();

    return ShowcaseShell(
      title: 'Physics Collision Card',
      description: 'An interactive 2D rigid-body physics simulator. Drag, fling, '
          'and toss cards to witness organic collisions. Adjust gravity, damping, '
          'and restitution coefficients in real-time.',
      codeSnippet: '''PhysicsCollisionCard(
  items: [
    PhysicsCollisionItem(
      radius: 36.0,
      child: Image.network('https://...'),
    ),
    PhysicsCollisionItem(
      radius: 28.0,
      child: Icon(Icons.bolt, color: Colors.white),
    ),
  ],
  style: PhysicsCollisionCardStyle(
    gravity: Offset(0.0, 900.0),
    restitution: 0.75,
    damping: 0.15,
  ),
)''',
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              // Unified self-contained Card with a solid white background frame
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: isSpaceMode ? const Color(0xFF030712) : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSpaceMode ? const Color(0xFF1F2937) : const Color(0xFFECECEF),
                    width: 1.5,
                  ),
                  boxShadow: isSpaceMode
                      ? const [
                          BoxShadow(
                            color: Color(0x33000000),
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ]
                      : const [
                          BoxShadow(
                            color: Color(0x0A000000),
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top: The Physics Simulation Grid Area Card
                    Padding(
                      padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
                      child: SizedBox(
                        height: 280, // Sized compact to fit beautifully on all device profiles
                        child: PhysicsCollisionCard(
                          key: ValueKey('physics_card_$_resetCounter'),
                          items: physicsItems,
                          style: PhysicsCollisionCardStyle(
                            cardDecoration: const BoxDecoration(), // Completely transparent
                            gridPadding: EdgeInsets.zero, // Outer padding managed by parent Column
                            gridDecoration: BoxDecoration(
                              color: isSpaceMode ? const Color(0xFF0B1120) : const Color(0xFFF9FAFC),
                              borderRadius: BorderRadius.circular(16), // Concentric: 24 (parent) - 8 (padding)
                              border: Border.all(
                                color: isSpaceMode
                                    ? const Color(0xFF1E293B)
                                    : const Color(0xFFE5E7EB).withAlpha((255 * 0.4).round()),
                                width: 1.5,
                              ),
                            ),
                            itemDecoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSpaceMode ? const Color(0xFF1F2937) : Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: isSpaceMode
                                      ? const Color(0xFF6366F1).withValues(alpha: 0.4)
                                      : const Color(0x22000000),
                                  blurRadius: isSpaceMode ? 12 : 10,
                                  spreadRadius: isSpaceMode ? 1 : 0,
                                  offset: isSpaceMode ? Offset.zero : const Offset(0, 5),
                                ),
                              ],
                            ),
                            gravity: _gravity,
                            restitution: _restitution,
                            damping: _damping,
                            enableHaptics: true,
                            showGrid: true,
                            showStars: isSpaceMode,
                            gridColor: isSpaceMode
                                ? const Color(0xFF1E293B).withValues(alpha: 0.25)
                                : const Color(0xFFE5E7EB),
                            gridBackgroundColor: isSpaceMode ? const Color(0xFF0B1120) : const Color(0xFFF9FAFC),
                          ),
                        ),
                      ),
                    ),

                    // Divider between simulation box and controls, keeping visual padding margins
                    const SizedBox(height: 12),
                    Divider(height: 1, color: isSpaceMode ? const Color(0xFF1F2937) : const Color(0xFFECECEF)),
                    const SizedBox(height: 12),

                    // Bottom: Gravity / Controls Panel (resting directly on parent white/dark card background)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Presets Horizontal Row
                          Row(
                            children: [
                              _buildPresetButton('Earth', const Offset(0.0, 900.0), 0.70, 0.15),
                              const SizedBox(width: 12),
                              _buildPresetButton('Jelly', const Offset(0.0, 450.0), 0.95, 0.05),
                              const SizedBox(width: 12),
                              _buildPresetButton('Heavy', const Offset(0.0, 1800.0), 0.15, 0.40),
                              const Spacer(),
                              GestureDetector(
                                onTap: _resetSimulation,
                                child: Text(
                                  'Reset',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isSpaceMode ? Colors.white70 : const Color(0xFF666666),
                                    decoration: TextDecoration.underline,
                                    decorationColor: isSpaceMode ? Colors.white70 : const Color(0xFF666666),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Divider(height: 1, color: isSpaceMode ? const Color(0xFF1F2937) : const Color(0xFFECECEF)),
                          const SizedBox(height: 12),

                          // Gravity Option
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () => _changeGravity(Offset.zero),
                                behavior: HitTestBehavior.opaque,
                                child: SizedBox(
                                  width: 80,
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 250),
                                    transitionBuilder: (Widget child, Animation<double> animation) {
                                      return FadeTransition(
                                        opacity: animation,
                                        child: SizeTransition(
                                          sizeFactor: animation,
                                          axis: Axis.horizontal,
                                          axisAlignment: -1.0,
                                          child: child,
                                        ),
                                      );
                                    },
                                    child: _gravity == Offset.zero
                                        ? const Column(
                                            key: ValueKey('anti_gravity_label'),
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                'ANTI',
                                                style: TextStyle(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w900,
                                                  letterSpacing: 0.8,
                                                  color: Color(0xFF6366F1),
                                                ),
                                              ),
                                              Text(
                                                'GRAVITY',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w900,
                                                  letterSpacing: 0.8,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          )
                                        : const Text(
                                            key: ValueKey('normal_gravity_label'),
                                            'GRAVITY',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 0.8,
                                              color: Color(0xFF8E8E93),
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(child: _buildGravitySegmentedControl()),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Divider(height: 1, color: isSpaceMode ? const Color(0xFF1F2937) : const Color(0xFFECECEF)),
                          const SizedBox(height: 12),

                          // Restitution Slider
                          Row(
                            children: [
                              const SizedBox(
                                width: 80,
                                child: Text(
                                  'BOUNCINESS',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.8,
                                    color: Color(0xFF8E8E93),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    trackHeight: 2.0,
                                    activeTrackColor: isSpaceMode ? const Color(0xFF6366F1) : Colors.black,
                                    inactiveTrackColor: isSpaceMode ? const Color(0xFF1F2937) : const Color(0xFFECECEF),
                                    thumbColor: isSpaceMode ? const Color(0xFF6366F1) : Colors.black,
                                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5.0),
                                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 10.0),
                                  ),
                                  child: Slider(
                                    value: _restitution,
                                    min: 0.0,
                                    max: 1.0,
                                    onChanged: (val) => setState(() => _restitution = val),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              SizedBox(
                                width: 30,
                                child: Text(
                                  _restitution.toStringAsFixed(2),
                                  textAlign: TextAlign.end,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: isSpaceMode ? Colors.white : Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Damping Slider
                          Row(
                            children: [
                              const SizedBox(
                                width: 80,
                                child: Text(
                                  'FRICTION',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.8,
                                    color: Color(0xFF8E8E93),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    trackHeight: 2.0,
                                    activeTrackColor: isSpaceMode ? const Color(0xFF6366F1) : Colors.black,
                                    inactiveTrackColor: isSpaceMode ? const Color(0xFF1F2937) : const Color(0xFFECECEF),
                                    thumbColor: isSpaceMode ? const Color(0xFF6366F1) : Colors.black,
                                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5.0),
                                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 10.0),
                                  ),
                                  child: Slider(
                                    value: _damping,
                                    min: 0.0,
                                    max: 0.8,
                                    onChanged: (val) => setState(() => _damping = val),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              SizedBox(
                                width: 30,
                                child: Text(
                                  _damping.toStringAsFixed(2),
                                  textAlign: TextAlign.end,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: isSpaceMode ? Colors.white : Colors.black,
                                  ),
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
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPresetButton(String name, Offset gravity, double restitution, double damping) {
    final bool isSpaceMode = _gravity == Offset.zero;
    final bool isSelected = _gravity == gravity &&
        (_restitution - restitution).abs() < 0.02 &&
        (_damping - damping).abs() < 0.02;

    return GestureDetector(
      onTap: () {
        setState(() {
          _gravity = gravity;
          _restitution = restitution;
          _damping = damping;
        });
      },
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 150),
        style: TextStyle(
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isSelected
              ? (isSpaceMode ? Colors.white : Colors.black)
              : (isSpaceMode ? const Color(0xFF9CA3AF) : const Color(0xFF8E8E93)),
        ),
        child: Text(name),
      ),
    );
  }

  Widget _buildGravitySegmentedControl() {
    final bool isSpaceMode = _gravity == Offset.zero;
    final List<Map<String, dynamic>> options = [
      {'vector': const Offset(0.0, 900.0), 'label': 'Down'},
      {'vector': const Offset(0.0, -900.0), 'label': 'Up'},
      {'vector': const Offset(-900.0, 0.0), 'label': 'Left'},
      {'vector': const Offset(900.0, 0.0), 'label': 'Right'},
    ];

    final int selectedIndex = options.indexWhere((opt) => opt['vector'] == _gravity);

    return LayoutBuilder(
      builder: (context, constraints) {
        final double totalWidth = constraints.maxWidth;
        final double tabWidth = totalWidth / options.length;

        return Container(
          height: 38,
          decoration: BoxDecoration(
            color: isSpaceMode ? const Color(0xFF111827) : const Color(0xFFF4F4F6),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Stack(
            children: [
              // Gliding selection highlight capsule
              AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                left: selectedIndex >= 0 ? selectedIndex * tabWidth + 2 : 2,
                top: 2,
                bottom: 2,
                width: tabWidth - 4,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: selectedIndex >= 0 ? 1.0 : 0.0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSpaceMode ? const Color(0xFF1F2937) : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: isSpaceMode
                          ? null
                          : const [
                              BoxShadow(
                                color: Color(0x12000000),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                    ),
                  ),
                ),
              ),
              // Options row
              Row(
                children: List.generate(options.length, (index) {
                  final opt = options[index];
                  final vector = opt['vector'] as Offset;
                  final label = opt['label'] as String;
                  final bool isSelected = index == selectedIndex;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () => _changeGravity(vector),
                      behavior: HitTestBehavior.opaque,
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 150),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected
                                ? (isSpaceMode ? Colors.white : Colors.black)
                                : (isSpaceMode ? const Color(0xFF9CA3AF) : const Color(0xFF8E8E93)),
                          ),
                          child: Text(label),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFallback(Map<String, dynamic> item) {
    final IconData? icon = item['icon'] as IconData?;
    final String initials = item['initials'] as String;
    return Center(
      child: icon != null
          ? Icon(
              icon,
              color: Colors.white,
              size: 24,
            )
          : Text(
              initials,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
    );
  }
}
