import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import '../common/portal_animations.dart';
import '../common/portal_utils.dart';
import '../common/premium_flip_counter.dart';
import 'models/currency_swap_style.dart';

/// A premium, bidirectional currency swap interaction widget.
class CurrencySwapInteraction extends StatefulWidget {
  /// Creates a [CurrencySwapInteraction].
  const CurrencySwapInteraction({
    super.key,
    required this.currencies,
    required this.initialFromCurrency,
    required this.initialToCurrency,
    this.initialAmount = 10.0,
    this.exchangeRate = 0.96,
    this.title = 'Swap Currency',
    this.proceedLabel = 'Proceed',
    this.onAmountChanged,
    this.onFromCurrencyChanged,
    this.onToCurrencyChanged,
    this.onProceed,
    this.style = const CurrencySwapStyle(),
  });

  /// The list of available currencies.
  final List<Currency> currencies;

  /// The initial "from" currency.
  final Currency initialFromCurrency;

  /// The initial "to" currency.
  final Currency initialToCurrency;

  /// The initial amount to convert.
  final double initialAmount;

  /// The current exchange rate (from -> to).
  final double exchangeRate;

  /// The title displayed at the top.
  final String title;

  /// The label for the proceed button.
  final String proceedLabel;

  /// Callback when the amount changes.
  final ValueChanged<double>? onAmountChanged;

  /// Callback when the "from" currency changes.
  final ValueChanged<Currency>? onFromCurrencyChanged;

  /// Callback when the "to" currency changes.
  final ValueChanged<Currency>? onToCurrencyChanged;

  /// Callback when the proceed button is pressed.
  final VoidCallback? onProceed;

  /// The style configuration.
  final CurrencySwapStyle style;

  @override
  State<CurrencySwapInteraction> createState() => _CurrencySwapInteractionState();
}

class _CurrencySwapInteractionState extends State<CurrencySwapInteraction> {
  late Currency _fromCurrency;
  late Currency _toCurrency;
  late double _fromAmount;
  late double _toAmount;

  late TextEditingController _fromController;
  late TextEditingController _toController;

  @override
  void initState() {
    super.initState();
    _fromCurrency = widget.initialFromCurrency;
    _toCurrency = widget.initialToCurrency;
    _fromAmount = widget.initialAmount;
    _toAmount = _fromAmount * widget.exchangeRate;

    _fromController = TextEditingController(text: _formatValue(_fromAmount));
    _toController = TextEditingController(text: _formatValue(_toAmount));
  }

  @override
  void didUpdateWidget(CurrencySwapInteraction oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.exchangeRate != widget.exchangeRate) {
      setState(() {
        _toAmount = _fromAmount * widget.exchangeRate;
        _toController.text = _formatValue(_toAmount);
      });
    }
  }

  String _formatValue(double value) => value % 1 == 0 ? value.toInt().toString() : value.toStringAsFixed(2);

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  void _handleHaptic() {
    if (widget.style.enableHaptics) {
      HapticFeedback.lightImpact();
    }
  }

  void _updateFromAmount(String value) {
    final val = double.tryParse(value) ?? 0.0;
    setState(() {
      _fromAmount = val;
      _toAmount = val * widget.exchangeRate;
      _toController.text = _formatValue(_toAmount);
    });
    widget.onAmountChanged?.call(_fromAmount);
  }

  void _updateToAmount(String value) {
    final val = double.tryParse(value) ?? 0.0;
    setState(() {
      _toAmount = val;
      _fromAmount = val / widget.exchangeRate;
      _fromController.text = _formatValue(_fromAmount);
    });
    widget.onAmountChanged?.call(_fromAmount);
  }

  void _swapCurrencies() {
    _handleHaptic();
    setState(() {
      final tempCurrency = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = tempCurrency;

      // We maintain the 'from' amount and recalculate 'to' based on new exchange rate
      // But usually in a swap, you want to flip the amounts too.
      final tempAmount = _fromAmount;
      _fromAmount = _toAmount;
      _toAmount = tempAmount;

      _fromController.text = _formatValue(_fromAmount);
      _toController.text = _formatValue(_toAmount);
    });
    widget.onFromCurrencyChanged?.call(_fromCurrency);
    widget.onToCurrencyChanged?.call(_toCurrency);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.translucent,
      child: Container(
        padding: widget.style.padding,
        decoration: BoxDecoration(
          color: widget.style.backgroundColor,
          borderRadius: widget.style.borderRadius,
          boxShadow: [
            BoxShadow(
              color: widget.style.mainShadowColor,
              blurRadius: 40,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: widget.style.titleStyle,
            ),
            SizedBox(height: widget.style.spacing),
            Stack(
              alignment: Alignment.center,
              children: [
                Column(
                  children: [
                    _CurrencyInputBox(
                      controller: _fromController,
                      amount: _fromAmount,
                      selectedCurrency: _fromCurrency,
                      currencies: widget.currencies,
                      style: widget.style,
                      isTop: true,
                      onChanged: _updateFromAmount,
                      onCurrencyChanged: (currency) {
                        _handleHaptic();
                        setState(() => _fromCurrency = currency);
                        widget.onFromCurrencyChanged?.call(currency);
                      },
                    ),
                    const SizedBox(height: 1), // Reduced separation
                    _CurrencyInputBox(
                      controller: _toController,
                      amount: _toAmount,
                      selectedCurrency: _toCurrency,
                      currencies: widget.currencies,
                      style: widget.style,
                      isTop: false,
                      onChanged: _updateToAmount,
                      onCurrencyChanged: (currency) {
                        _handleHaptic();
                        setState(() => _toCurrency = currency);
                        widget.onToCurrencyChanged?.call(currency);
                      },
                    ),
                  ],
                ),
                _SwapButton(
                  style: widget.style,
                  onPressed: _swapCurrencies,
                ),
              ],
            ),
            SizedBox(height: widget.style.spacing),
            _ProceedButton(
              label: widget.proceedLabel,
              onPressed: () {
                FocusScope.of(context).unfocus();
                widget.onProceed?.call();
              },
              style: widget.style,
              onTapDown: _handleHaptic,
            ),
            SizedBox(height: widget.style.spacing),
            Center(
              child: Text(
                '1 ${_fromCurrency.code} ≈ ${widget.exchangeRate.toStringAsFixed(4)} ${_toCurrency.code}',
                style: widget.style.rateTextStyle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SwapButton extends StatefulWidget {
  const _SwapButton({
    required this.onPressed,
    required this.style,
  });
  final VoidCallback onPressed;
  final CurrencySwapStyle style;

  @override
  State<_SwapButton> createState() => _SwapButtonState();
}

class _SwapButtonState extends State<_SwapButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _turns = 0.0;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Swap currencies',
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            setState(() => _turns += 0.5);
            widget.onPressed();
          },
          child: AnimatedRotation(
            turns: _turns,
            duration: const Duration(milliseconds: 400),
            curve: PortalSpringCurve(),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _isHovered 
                  ? widget.style.inputBackgroundColor 
                  : widget.style.swapButtonBackgroundColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: _isHovered 
                    ? widget.style.buttonColor.withValues(alpha: 0.5) 
                    : widget.style.swapButtonBorderColor, 
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.style.mainShadowColor,
                    blurRadius: _isHovered ? 15 : 10,
                    offset: Offset(0, _isHovered ? 6 : 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.swap_vert,
                size: 20,
                color: widget.style.swapButtonIconColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CurrencyInputBox extends StatefulWidget {
  const _CurrencyInputBox({
    required this.controller,
    required this.amount,
    required this.selectedCurrency,
    required this.currencies,
    required this.style,
    required this.isTop,
    required this.onChanged,
    required this.onCurrencyChanged,
  });

  final TextEditingController controller;
  final double amount;
  final Currency selectedCurrency;
  final List<Currency> currencies;
  final CurrencySwapStyle style;
  final bool isTop;
  final ValueChanged<String> onChanged;
  final ValueChanged<Currency> onCurrencyChanged;

  @override
  State<_CurrencyInputBox> createState() => _CurrencyInputBoxState();
}

class _CurrencyInputBoxState extends State<_CurrencyInputBox> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Measure text height and add a small buffer (1.2x) to prevent overflows
    // especially when dealing with cursor height or specific font metrics.
    final double textHeight = PortalUtils.measureText('8', widget.style.amountStyle).height * 1.2;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: widget.style.inputBackgroundColor,
        borderRadius: widget.isTop
            ? widget.style.inputBorderRadius.copyWith(bottomLeft: Radius.zero, bottomRight: Radius.zero)
            : widget.style.inputBorderRadius.copyWith(topLeft: Radius.zero, topRight: Radius.zero),
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: textHeight,
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  Opacity(
                    opacity: _isFocused ? 0.0 : 1.0,
                    child: IgnorePointer(
                      ignoring: _isFocused,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: _CurrencyFlipDisplay(
                          amount: widget.amount,
                          style: widget.style,
                        ),
                      ),
                    ),
                  ),
                  Opacity(
                    opacity: _isFocused ? 1.0 : 0.0,
                    child: IgnorePointer(
                      ignoring: !_isFocused,
                      child: TextField(
                        controller: widget.controller,
                        focusNode: _focusNode,
                        textAlignVertical: TextAlignVertical.center,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                        ],
                        style: widget.style.amountStyle,
                        cursorColor: widget.style.cursorColor,
                        cursorWidth: 1.5,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: widget.onChanged,
                      ),
                    ),
                  ),
                  if (!_isFocused)
                    Positioned.fill(
                      child: GestureDetector(
                        onTap: () {
                          _focusNode.requestFocus();
                        },
                        behavior: HitTestBehavior.opaque,
                      ),
                    ),
                ],
              ),
            ),
          ),
          _CurrencySelector(
            selectedCurrency: widget.selectedCurrency,
            currencies: widget.currencies,
            style: widget.style,
            onChanged: widget.onCurrencyChanged,
          ),
        ],
      ),
    );
  }
}

class _CurrencySelector extends StatefulWidget {
  const _CurrencySelector({
    required this.selectedCurrency,
    required this.currencies,
    required this.style,
    required this.onChanged,
  });

  final Currency selectedCurrency;
  final List<Currency> currencies;
  final CurrencySwapStyle style;
  final ValueChanged<Currency> onChanged;

  @override
  State<_CurrencySelector> createState() => _CurrencySelectorState();
}

class _CurrencySelectorState extends State<_CurrencySelector> with SingleTickerProviderStateMixin {
  late AnimationController _menuController;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _menuController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _hideMenu();
    _menuController.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    if (_overlayEntry == null) {
      _showMenu();
    } else {
      _hideMenu();
    }
  }

  void _showMenu() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    _menuController.forward();
  }

  void _hideMenu() async {
    await _menuController.reverse();
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: _hideMenu,
              behavior: HitTestBehavior.opaque,
              child: Container(color: Colors.transparent),
            ),
          ),
          CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            targetAnchor: Alignment.bottomRight,
            followerAnchor: Alignment.topRight,
            offset: const Offset(0, 4), 
            child: Material(
              color: Colors.transparent,
              child: AnimatedBuilder(
                animation: _menuController,
                builder: (context, child) {
                  final curvedValue = CurvedAnimation(
                    parent: _menuController,
                    curve: PortalSpringCurve(), // Spring bounce!
                    reverseCurve: Curves.easeOutCubic, // Smooth exit
                  ).value;

                  // Blur effect: starts at 5 and goes to 0
                  final double blurSigma = 5.0 * (1.0 - _menuController.value);

                  return Opacity(
                    opacity: _menuController.value.clamp(0.0, 1.0),
                    child: ImageFiltered(
                      imageFilter: ui.ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
                      child: Transform.translate(
                        // Slide UP from below (15px) to final position (0)
                        offset: Offset(0, 15 * (1 - curvedValue)),
                        child: Transform.scale(
                          scale: 0.90 + (0.10 * curvedValue),
                          child: child,
                        ),
                      ),
                    ),
                  );
                },
                child: Container(
                  width: 150,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: widget.style.dropdownBackgroundColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: widget.style.dropdownShadowColor.withValues(alpha: 0.1)),
                    boxShadow: [
                      BoxShadow(
                        color: widget.style.dropdownShadowColor,
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: widget.currencies.map((currency) {
                      final isSelected = currency.code == widget.selectedCurrency.code;
                      return InkWell(
                        onTap: () {
                          widget.onChanged(currency);
                          _hideMenu();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                          child: Row(
                            children: [
                              Text(currency.flag, style: const TextStyle(fontSize: 16)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  currency.code,
                                  style: widget.style.currencyTextStyle.copyWith(
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              if (isSelected) const Icon(Icons.check, size: 14, color: Colors.black54),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggleMenu,
        child: Container(
          constraints: const BoxConstraints(minWidth: 96),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), // Increased lateral padding
          decoration: BoxDecoration(
            color: widget.style.backgroundColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  widget.selectedCurrency.flag,
                  key: ValueKey(widget.selectedCurrency.flag),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              Semantics(
                key: ValueKey('currency_code_${widget.selectedCurrency.code}'),
                label: widget.selectedCurrency.code,
                container: true,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(widget.selectedCurrency.code.length, (index) {
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      reverseDuration: const Duration(milliseconds: 50), // Disappear quickly!
                      transitionBuilder: (child, animation) {
                        // Staggered interval based on letter index (0.15s delay per letter)
                        final double start = (index * 0.15).clamp(0.0, 0.9);
                        
                        final curve = CurvedAnimation(
                          parent: animation,
                          curve: Interval(start, 1.0, curve: PortalSpringCurve()),
                          reverseCurve: Curves.easeIn, // Smooth and fast 50ms exit
                        );
                        
                        return FadeTransition(
                          opacity: curve,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.4),
                              end: Offset.zero,
                            ).animate(curve),
                            child: child,
                          ),
                        );
                      },
                      child: Text(
                        widget.selectedCurrency.code[index],
                        key: ValueKey('${widget.selectedCurrency.code}_$index'),
                        style: widget.style.currencyTextStyle,
                      ),
                    );
                  }),
                ),
              ),
              RotationTransition(
                turns: _menuController.drive(Tween<double>(begin: 0, end: 0.5)),
                child: Icon(
                  Icons.keyboard_arrow_down, 
                  size: 16, 
                  color: widget.style.currencyTextStyle.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProceedButton extends StatefulWidget {
  const _ProceedButton({
    required this.label,
    this.onPressed,
    required this.style,
    this.onTapDown,
  });

  final String label;
  final VoidCallback? onPressed;
  final CurrencySwapStyle style;
  final VoidCallback? onTapDown;

  @override
  State<_ProceedButton> createState() => _ProceedButtonState();
}

class _ProceedButtonState extends State<_ProceedButton> {
  bool _isPressed = false;
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.label,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTapDown: (_) {
            setState(() => _isPressed = true);
            widget.onTapDown?.call();
          },
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: widget.onPressed,
          child: AnimatedScale(
            scale: _isPressed ? 0.98 : 1.0,
            duration: const Duration(milliseconds: 100),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: widget.onPressed == null 
                  ? widget.style.buttonColor.withValues(alpha: 0.5) 
                  : (_isHovered ? widget.style.buttonColor.withValues(alpha: 0.9) : widget.style.buttonColor),
                borderRadius: widget.style.buttonBorderRadius,
                boxShadow: _isHovered ? [
                  BoxShadow(
                    color: widget.style.buttonColor.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ] : null,
              ),
              child: Center(
                child: Text(
                  widget.label,
                  style: widget.style.buttonTextStyle.copyWith(
                    color: widget.style.buttonTextColor,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CurrencyFlipDisplay extends StatefulWidget {
  const _CurrencyFlipDisplay({
    required this.amount,
    required this.style,
  });

  final double amount;
  final CurrencySwapStyle style;

  @override
  State<_CurrencyFlipDisplay> createState() => _CurrencyFlipDisplayState();
}

class _CurrencyFlipDisplayState extends State<_CurrencyFlipDisplay> {
  bool _upward = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(_CurrencyFlipDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.amount != widget.amount) {
      setState(() {
        _upward = widget.amount >= oldWidget.amount;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String formatted = widget.amount % 1 == 0 
        ? widget.amount.toInt().toString() 
        : widget.amount.toStringAsFixed(2);

    return PremiumFlipCounter(
      key: const ValueKey('currency_flip_display'),
      value: formatted,
      upward: _upward,
      style: widget.style.amountStyle,
      padWithZero: false,
    );
  }
}
