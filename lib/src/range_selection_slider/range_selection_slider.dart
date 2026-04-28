import 'package:flutter/material.dart';
import '../common/portal_utils.dart';
import '../common/premium_flip_counter.dart';
import 'models/range_slider_style.dart';

/// A premium range selection component featuring a stylized slider and 3D flip counters.
///
/// Designed for price ranges or numeric intervals, it provides a highly tactile
/// and visual way to select values.
///
/// Features:
/// - **Custom Range Slider:** Thick active track and thin inactive track with
/// shadowed circular handles.
/// - **3D Flip Values:** Animated transitions for numeric values when the slider moves.
/// - **Adaptive Formatting:** Automatic comma separation and currency prefixing.
/// - **Zero-Dependency:** Using only vanilla Flutter components and internal utils.
class RangeSelectionSlider extends StatefulWidget {

  /// Creates a [RangeSelectionSlider] with the given configuration.
  const RangeSelectionSlider({
    super.key,
    required this.values,
    this.min = 0,
    this.max = 5000,
    this.onChanged,
    this.onApply,
    this.onCancel,
    this.style = const RangeSliderStyle(),
    this.divisions,
    this.title = 'Price Range',
    this.showActions = true,
  });
  /// The current range values.
  final RangeValues values;

  /// The minimum possible value.
  final double min;

  /// The maximum possible value.
  final double max;

  /// Callback when values are changed during dragging.
  final ValueChanged<RangeValues>? onChanged;

  /// Callback when "Apply" is pressed.
  final ValueChanged<RangeValues>? onApply;

  /// Callback when "Cancel" is pressed.
  final VoidCallback? onCancel;

  /// The title displayed at the top.
  final String title;

  /// Style configuration for the component.
  final RangeSliderStyle style;

  /// Fraction of decimals or steps.
  final int? divisions;

  /// Whether to show the action buttons (Apply/Cancel).
  /// If [onApply] and [onCancel] are both null, they won't be shown even if this is true.
  final bool showActions;

  @override
  State<RangeSelectionSlider> createState() => _RangeSelectionSliderState();
}

class _RangeSelectionSliderState extends State<RangeSelectionSlider> {
  late RangeValues _currentValues;
  late RangeValues _prevValues;

  @override
  void initState() {
    super.initState();
    _currentValues = widget.values;
    _prevValues = _currentValues;
  }

  @override
  void didUpdateWidget(RangeSelectionSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.values != widget.values) {
      _prevValues = _currentValues;
      _currentValues = widget.values;
    }
  }

  void _handleChanged(RangeValues values) {
    setState(() {
      _prevValues = _currentValues;
      _currentValues = values;
    });
    widget.onChanged?.call(values);
  }

  /// Updates only one side of the range from manual input.
  void _updateManualValue(double? start, double? end) {
    RangeValues newValues = _currentValues;
    if (start != null) {
      // Clamp and ensure start does not exceed end
      final clampedStart = start.clamp(widget.min, _currentValues.end - 1);
      newValues = RangeValues(clampedStart, _currentValues.end);
    } else if (end != null) {
      // Clamp and ensure end is not less than start
      final clampedEnd = end.clamp(_currentValues.start + 1, widget.max);
      newValues = RangeValues(_currentValues.start, clampedEnd);
    }

    if (newValues != _currentValues) {
      _handleChanged(newValues);
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = widget.style;

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: style.backgroundColor,
          borderRadius: BorderRadius.circular(style.borderRadius),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(widget.title, style: style.titleStyle),
            const SizedBox(height: 12),

            // Custom Stylized Range Slider
            _buildSlider(style),

            const SizedBox(height: 16),

            // From Field
            _ValueField(
              key: const ValueKey('from_field'),
              label: style.fromLabel,
              value: _currentValues.start.round(),
              isIncreasing: _currentValues.start >= _prevValues.start,
              style: style,
              onSubmitted: (val) => _updateManualValue(val.toDouble(), null),
            ),

            const SizedBox(height: 8),

            // To Field
            _ValueField(
              key: const ValueKey('to_field'),
              label: style.toLabel,
              value: _currentValues.end.round(),
              isIncreasing: _currentValues.end >= _prevValues.end,
              style: style,
              onSubmitted: (val) => _updateManualValue(null, val.toDouble()),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            if (widget.showActions &&
                (widget.onApply != null || widget.onCancel != null))
              Row(
                children: [
                  if (widget.onApply != null)
                    Expanded(
                      child: _ActionButton(
                        label: style.applyLabel,
                        onPressed: () => widget.onApply!.call(_currentValues),
                        backgroundColor: style.primaryButtonColor,
                        textColor: style.primaryButtonTextColor,
                        height: style.buttonHeight,
                      ),
                    ),
                  if (widget.onApply != null && widget.onCancel != null)
                    const SizedBox(width: 12),
                  if (widget.onCancel != null)
                    Expanded(
                      child: _ActionButton(
                        label: style.cancelLabel,
                        onPressed: widget.onCancel,
                        backgroundColor: Colors.transparent,
                        textColor: style.secondaryButtonTextColor,
                        borderColor: style.secondaryButtonBorderColor,
                        height: style.buttonHeight,
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider(RangeSliderStyle style) {
    return SliderTheme(
      data: SliderThemeData(
        rangeTrackShape: const _CustomRangeTrackShape(),
        trackHeight: 2,
        activeTrackColor: style.activeTrackColor,
        inactiveTrackColor: style.inactiveTrackColor,
        thumbColor: style.thumbColor,
        rangeThumbShape: _CustomRangeThumbShape(
          borderColor: style.thumbBorderColor,
        ),
        overlayColor: style.activeTrackColor.withValues(alpha: 0.1),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
      ),
      child: RangeSlider(
        values: _currentValues,
        min: widget.min,
        max: widget.max,
        divisions: widget.divisions,
        onChanged: _handleChanged,
      ),
    );
  }
}

/// A specialized internal field for displaying "From/To" values with flip animation.
/// Now supports manual editing via TextField on tap.
class _ValueField extends StatefulWidget {

  const _ValueField({
    super.key,
    required this.label,
    required this.value,
    required this.isIncreasing,
    required this.style,
    required this.onSubmitted,
  });
  final String label;
  final int value;
  final bool isIncreasing;
  final RangeSliderStyle style;
  final ValueChanged<int> onSubmitted;

  @override
  State<_ValueField> createState() => _ValueFieldState();
}

class _ValueFieldState extends State<_ValueField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.toString());
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(_ValueField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && !_isFocused) {
      _controller.text = widget.value.toString();
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
    if (!_isFocused) {
      _submit();
    }
  }

  void _submit() {
    final newValue = int.tryParse(_controller.text);
    if (newValue != null) {
      widget.onSubmitted(newValue);
    } else {
      // Revert if invalid
      _controller.text = widget.value.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = widget.style;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (!_isFocused) {
          setState(() {
            _isFocused = true;
          });
          _focusNode.requestFocus();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: style.fieldBackgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isFocused
                ? style.thumbColor.withValues(alpha: 0.5)
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.label, style: style.fieldLabelStyle),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(style.currencySymbol, style: style.fieldValueStyle),
                Expanded(
                  child: _isFocused
                      ? TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          autofocus: true,
                          keyboardType: TextInputType.number,
                          style: style.fieldValueStyle,
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            border: InputBorder.none,
                          ),
                          onSubmitted: (_) => _focusNode.unfocus(),
                          onTapOutside: (_) => _focusNode.unfocus(),
                        )
                      : _PriceFlipDisplay(
                          value: widget.value,
                          upward: widget.isIncreasing,
                          textStyle: style.fieldValueStyle,
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Complex price display that handles commas and animates digits.
class _PriceFlipDisplay extends StatelessWidget {

  const _PriceFlipDisplay({
    required this.value,
    required this.upward,
    required this.textStyle,
  });
  final int value;
  final bool upward;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    final String formatted = PortalUtils.formatNumber(value);

    return PremiumFlipCounter(
      value: formatted,
      upward: upward,
      style: textStyle,
    );
  }
}

class _ActionButton extends StatelessWidget {

  const _ActionButton({
    required this.label,
    this.onPressed,
    required this.backgroundColor,
    required this.textColor,
    this.borderColor,
    required this.height,
  });
  final String label;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;
  final double height;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(height / 2),
          border: borderColor != null ? Border.all(color: borderColor!) : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 15, // Made smaller as requested
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
      ),
    );
  }
}

/// CUSTOM PAINTERS FOR SLIDER

/// A custom track shape for the range slider that draws a thin inactive track
/// and a thick, rounded active track.
class _CustomRangeTrackShape extends RangeSliderTrackShape {
  /// Creates a [const] instance of [_CustomRangeTrackShape].
  const _CustomRangeTrackShape();
  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required Offset startThumbCenter,
    required Offset endThumbCenter,
    bool isEnabled = false,
    bool isDiscrete = false,
    required TextDirection textDirection,
  }) {
    if (sliderTheme.trackHeight! <= 0) return;

    final Color activeColor = sliderTheme.activeTrackColor!;
    final Color inactiveColor = sliderTheme.inactiveTrackColor!;

    final Paint activePaint = Paint()..color = activeColor;
    final Paint inactivePaint = Paint()..color = inactiveColor;

    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    // Draw Inactive parts (Uniform thickness)
    // Left inactive
    context.canvas.drawRRect(
      RRect.fromLTRBR(
        trackRect.left,
        trackRect.top + trackRect.height / 2 - 4.0,
        startThumbCenter.dx,
        trackRect.top + trackRect.height / 2 + 4.0,
        const Radius.circular(4.0),
      ),
      inactivePaint,
    );

    // Right inactive
    context.canvas.drawRRect(
      RRect.fromLTRBR(
        endThumbCenter.dx,
        trackRect.top + trackRect.height / 2 - 4.0,
        trackRect.right,
        trackRect.top + trackRect.height / 2 + 4.0,
        const Radius.circular(4.0),
      ),
      inactivePaint,
    );

    // Draw Active part (Thick)
    context.canvas.drawRRect(
      RRect.fromLTRBR(
        startThumbCenter.dx,
        trackRect.top + trackRect.height / 2 - 4.0, // 8px height
        endThumbCenter.dx,
        trackRect.top + trackRect.height / 2 + 4.0,
        const Radius.circular(4.0),
      ),
      activePaint,
    );
  }

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight!;
    final double trackLeft = offset.dx + 20;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width - 40;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}

/// A custom thumb shape for the range slider displaying a white circle
/// with a colored border and a shadow.
class _CustomRangeThumbShape extends RangeSliderThumbShape {

  /// Creates a [const] instance of [_CustomRangeThumbShape] with the given [borderColor].
  const _CustomRangeThumbShape({required this.borderColor});
  /// The color of the thumb's border.
  final Color borderColor;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => const Size(28, 28);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    bool isDiscrete = false,
    bool isEnabled = false,
    bool? isOnTop,
    required SliderThemeData sliderTheme,
    Thumb? thumb,
    TextDirection? textDirection,
    bool? isPressed,
  }) {
    final Canvas canvas = context.canvas;

    // Draw Shadow
    final Path shadowPath = Path()
      ..addOval(Rect.fromCircle(center: center, radius: 14));
    canvas.drawShadow(shadowPath, Colors.black, 4, true);

    // Draw Outer Border (White fill first to hide track behind)
    final Paint fillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 14, fillPaint);

    // Draw Border
    final Paint borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    canvas.drawCircle(center, 11, borderPaint);

    // Draw Inner Circle (White)
    final Paint innerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 8, innerPaint);
  }
}
