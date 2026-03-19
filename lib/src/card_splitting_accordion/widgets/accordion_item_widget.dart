import 'package:flutter/material.dart';
import '../models/accordion_item.dart';
import '../models/accordion_style.dart';

/// A premium, context-aware widget that displays a single [AccordionItem].
/// 
/// This widget handles the complex logic of "splitting" cards when expanded
/// and grouping them into solid blocks when collapsed, using smooth animations
/// and precise corner rounding.
class AccordionItemWidget extends StatefulWidget {
  /// The data model for this accordion item.
  final AccordionItem item;

  /// Whether this item is currently expanded.
  final bool isExpanded;

  /// Callback triggered when the header is tapped.
  final VoidCallback onTap;

  /// The visual configuration for the accordion.
  final AccordionStyle style;
  
  /// The index of this item in the collection.
  final int index;

  /// Whether this is the first item in the list.
  final bool isFirst;

  /// Whether this is the last item in the list.
  final bool isLast;

  /// Whether this item belongs to the section above the expanded item.
  final bool isUpperSection;

  /// Whether this item belongs to the section below the expanded item.
  final bool isLowerSection;

  /// Whether this item is the point where the upper block "breaks" during expansion.
  final bool isAtEndOfUpperSection;

  /// Whether this item is the point where the lower block "starts" during expansion.
  final bool isAtStartOfLowerSection;

  /// Creates a new [AccordionItemWidget] with the required state flags.
  const AccordionItemWidget({
    super.key,
    required this.item,
    required this.index,
    required this.isExpanded,
    required this.onTap,
    required this.style,
    required this.isFirst,
    required this.isLast,
    required this.isUpperSection,
    required this.isLowerSection,
    required this.isAtEndOfUpperSection,
    required this.isAtStartOfLowerSection,
  });

  @override
  State<AccordionItemWidget> createState() => _AccordionItemWidgetState();
}

class _AccordionItemWidgetState extends State<AccordionItemWidget>
    with TickerProviderStateMixin {
  late AnimationController _expansionController;
  late AnimationController _neighborController;
  
  late Animation<double> _expansionAnimation;
  late Animation<double> _neighborAnimation;
  
  late Animation<double> _rotationAnimation;
  late Animation<double> _contentOpacityAnimation;

  @override
  void initState() {
    super.initState();
    
    _expansionController = AnimationController(
                                                                                               vsync: this,
      duration: widget.style.animationDuration,
      reverseDuration: widget.style.animationDuration,
    );

    _neighborController = AnimationController(
      vsync: this,
      duration: widget.style.animationDuration,
      reverseDuration: widget.style.animationDuration,
    );

    const curve = Curves.easeOutQuart;
    const reverseCurve = Curves.easeInOutCubic;

    _expansionAnimation = CurvedAnimation(
      parent: _expansionController,
      curve: curve,
      reverseCurve: reverseCurve,
    );

    _neighborAnimation = CurvedAnimation(
      parent: _neighborController,
      curve: curve,
      reverseCurve: reverseCurve,
    );
    
    _rotationAnimation = Tween<double>(begin: 0, end: 0.5).animate(_expansionAnimation);

    _contentOpacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _expansionController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );

    // Initial state setup
    if (widget.isExpanded) _expansionController.value = 1.0;
    if (widget.isUpperSection || widget.isLowerSection) {
      _neighborController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(AccordionItemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isExpanded != oldWidget.isExpanded) {
      widget.isExpanded ? _expansionController.forward() : _expansionController.reverse();
    }

    if (widget.isUpperSection || widget.isLowerSection) {
      _neighborController.forward();
    } else {
      _neighborController.reverse();
    }
  }

  @override
  void dispose() {
    _expansionController.dispose();
    _neighborController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_expansionController, _neighborController]),
      builder: (context, child) {
        final double expandT = _expansionAnimation.value;
        final double neighborT = _neighborAnimation.value;
        
        // Premium Phase Shifting: the rounding happens much faster than displacement
        final double rExpandT = Curves.easeOutQuint.transform(expandT);
        final double rNeighborT = Curves.easeOutQuint.transform(neighborT);
        
        final double maxR = widget.style.borderRadius;
        
        // Calculate dynamic rounding for each corner based on proximity to a "break point"
        final double topR = widget.isFirst ? maxR : 
                          (widget.isExpanded ? maxR * rExpandT : 
                          (widget.isAtStartOfLowerSection ? maxR * rNeighborT : 0.0));
                          
        final double bottomR = widget.isLast ? maxR : 
                             (widget.isExpanded ? maxR * rExpandT : 
                             (widget.isAtEndOfUpperSection ? maxR * rNeighborT : 0.0));

        // Interaction gap when cards are separated
        final double marginB = (widget.isExpanded ? widget.style.spacing * expandT : 0.0) +
                              (widget.isAtEndOfUpperSection ? widget.style.spacing * neighborT : 0.0);
        
        final borderRadius = BorderRadius.vertical(
          top: Radius.circular(topR),
          bottom: Radius.circular(bottomR),
        );

        return Padding(
          padding: EdgeInsets.only(bottom: marginB),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: widget.style.backgroundColor,
              borderRadius: borderRadius,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04 + (0.04 * expandT)),
                  blurRadius: 10 + (10 * expandT),
                  offset: Offset(0, 2 + (4 * expandT)),
                ),
              ],
              border: Border(
                top: (widget.isFirst || widget.isAtStartOfLowerSection || widget.isExpanded) 
                    ? BorderSide(color: widget.style.borderColor, width: 1.0)
                    : BorderSide.none,
                bottom: BorderSide(color: widget.style.borderColor, width: 1.0),
                left: BorderSide(color: widget.style.borderColor, width: 1.0),
                right: BorderSide(color: widget.style.borderColor, width: 1.0),
              ),
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: borderRadius,
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: widget.onTap,
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
                hoverColor: Colors.transparent,
                mouseCursor: SystemMouseCursors.click,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(),
                      SizeTransition(
                        sizeFactor: _expansionAnimation,
                        axisAlignment: -1,
                        child: _buildContent(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      constraints: const BoxConstraints(minHeight: 32),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (widget.item.icon != null) ...[
            Icon(
              widget.item.icon,
              color: widget.style.iconColor,
              size: 22,
            ),
            const SizedBox(width: 14),
          ],
          Expanded(
            child: Text(
              widget.item.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: widget.style.titleColor,
                letterSpacing: -0.2,
                height: 1.2,
              ),
            ),
          ),
          const SizedBox(width: 12),
          RotationTransition(
            turns: _rotationAnimation,
            child: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: widget.style.iconColor.withValues(alpha: 0.5),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return FadeTransition(
      opacity: _contentOpacityAnimation,
      child: Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 4),
        child: Text(
          widget.item.content,
          style: TextStyle(
            fontSize: 15,
            color: widget.style.contentColor,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}
