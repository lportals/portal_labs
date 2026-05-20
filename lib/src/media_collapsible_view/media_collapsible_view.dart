import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';

import 'package:portal_labs/src/media_collapsible_view/models/media_comment.dart';
import 'package:portal_labs/src/media_collapsible_view/models/media_view_style.dart';

export 'package:portal_labs/src/media_collapsible_view/models/media_comment.dart';
export 'package:portal_labs/src/media_collapsible_view/models/media_view_style.dart';

/// A high-fidelity Reels-inspired view with MATHEMATICAL Safe Area transitions.
class MediaCollapsibleView extends StatefulWidget {
  /// Creates a [MediaCollapsibleView] with the given media content and callbacks.
  const MediaCollapsibleView({
    super.key,
    required this.mediaImage,
    required this.userAvatarImage,
    required this.comments,
    this.mediaBuilder,
    this.style = const MediaViewStyle(),
    this.onSendComment,
    this.onLike,
    this.onShare,
  });

  /// The image provider for the main media content.
  final ImageProvider mediaImage;

  /// The image provider for the user's avatar.
  final ImageProvider userAvatarImage;

  /// The list of comments to display in the collapsible sheet.
  final List<MediaComment> comments;

  /// An optional builder for a custom media widget.
  /// If provided, this replaces the default network image renderer.
  final WidgetBuilder? mediaBuilder;

  /// Style configuration for the component.
  final MediaViewStyle style;

  /// Callback invoked when the user submits a new comment.
  final Function(String)? onSendComment;

  /// Callback invoked when the user taps the like button.
  final VoidCallback? onLike;

  /// Callback invoked when the user taps the share button.
  final VoidCallback? onShare;

  @override
  State<MediaCollapsibleView> createState() => _MediaCollapsibleViewState();
}

class _MediaCollapsibleViewState extends State<MediaCollapsibleView>
    with TickerProviderStateMixin {
  late AnimationController _sheetController;
  late ScrollController _scrollController;
  final TextEditingController _textController = TextEditingController();

  double _currentExtent = 0.0;
  static const double _mainPhase = 0.63;
  static const double _fullPhase = 1.0;

  // PADDING STABILIZATION: To prevent navigation flashes/jitter
  EdgeInsets? _stablePadding;

  @override
  void initState() {
    super.initState();
    _sheetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scrollController = ScrollController();
    _sheetController.addListener(() {
      if (mounted) setState(() => _currentExtent = _sheetController.value);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Capture initial padding to keep it stable during pop transitions
    _stablePadding ??= MediaQuery.of(context).viewPadding;
  }

  @override
  void dispose() {
    _sheetController.dispose();
    _scrollController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _handleSend() {
    if (_textController.text.trim().isNotEmpty) {
      widget.onSendComment?.call(_textController.text.trim());
      _textController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  void _handleVerticalDragUpdate(
    DragUpdateDetails details,
    Size size,
    double top,
    double bottom,
  ) {
    final double safeHeight = size.height - top - bottom;
    if (safeHeight <= 0) return;
    final double deltaUnits = -details.primaryDelta! / safeHeight;
    _sheetController.value = (_sheetController.value + deltaUnits).clamp(
      0.0,
      1.0,
    );
  }

  void _handleVerticalDragEnd(DragEndDetails details) {
    if (_currentExtent >= 1.0 &&
        _scrollController.hasClients &&
        _scrollController.offset > 0) {
      return;
    }
    final double velocity = -details.primaryVelocity! / 1000;
    double target = 0.0;
    if (_sheetController.value + (velocity * 0.1) > 0.85) {
      target = _fullPhase;
    } else if (_sheetController.value + (velocity * 0.1) > 0.3) {
      target = _mainPhase;
    }
    _sheetController.animateTo(target, curve: Curves.easeOutCubic);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = _stablePadding ?? MediaQuery.of(context).viewPadding;

    final double safeHeight = size.height - padding.top - padding.bottom;
    final double videoTargetHeight = safeHeight * 0.35;
    final double videoTargetWidth = videoTargetHeight / 1.25;

    final double t = (_currentExtent / _mainPhase).clamp(0.0, 1.0);
    final double currentTopOffset =
        Curves.easeInOutCubic.transform(t) * padding.top;
    final double currentSheetHeight =
        (safeHeight * _currentExtent) +
        (padding.bottom * (_currentExtent > 0 ? 1 : 0));

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Material(
        color: widget
            .style
            .backgroundColor, // Stabilize background for transitions
        child: Scaffold(
          backgroundColor: Colors.transparent,
          resizeToAvoidBottomInset:
              false, // PREVENT FLASHES ON KEYBOARD DISMISSAL
          body: Stack(
            fit: StackFit.expand,
            children: [
              _buildBackground(),
              _buildMediaFrame(
                size,
                currentTopOffset,
                videoTargetHeight,
                videoTargetWidth,
                t,
                padding,
              ),
              if (_currentExtent > 0.01)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: currentSheetHeight,
                  child: _buildInteractiveSheet(
                    context,
                    size,
                    padding,
                    currentSheetHeight,
                  ),
                ),
              _buildHeaderActions(padding, t),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackground() {
    return RepaintBoundary(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image(
            image: widget.mediaImage,
            fit: BoxFit.cover,
            gaplessPlayback: true,
          ),
          BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: widget.style.blurAmount,
              sigmaY: widget.style.blurAmount,
            ),
            child: Container(
              color: widget.style.backgroundColor.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaFrame(
    Size size,
    double currentTop,
    double targetH,
    double targetW,
    double t,
    EdgeInsets padding,
  ) {
    final double currentW = (size.width - (t * (size.width - targetW))).clamp(
      targetW,
      size.width,
    );
    final double currentH = (size.height - (t * (size.height - targetH))).clamp(
      targetH,
      size.height,
    );
    final double radius = (t * 28).clamp(0.0, 28.0);

    return Positioned(
      top: currentTop,
      left: (size.width - currentW) / 2,
      width: currentW,
      height: currentH,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Stack(
          fit: StackFit.expand,
          children: [
            widget.mediaBuilder?.call(context) ??
                Image(image: widget.mediaImage, fit: BoxFit.cover),
            if (_currentExtent < 0.1)
              Positioned(
                right: 16 + (padding.right > 0 ? padding.right : 0),
                bottom: 40,
                child: Column(
                  children: [
                    _buildActionBtn(
                      Icons.favorite_outline,
                      '124K',
                      widget.onLike,
                    ),
                    const SizedBox(height: 16),
                    _buildActionBtn(
                      Icons.chat_bubble_outline,
                      '${widget.comments.length}',
                      () => _sheetController.animateTo(_mainPhase),
                    ),
                    const SizedBox(height: 16),
                    _buildActionBtn(Icons.send_outlined, '', widget.onShare),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderActions(EdgeInsets padding, double t) {
    // WEB/DESKTOP STABILIZATION: ensure some baseline margin if top safe area is 0
    final double activeTop = (padding.top > 0) ? padding.top : 20.0;

    return Positioned(
      top: activeTop + 8,
      left: 16 + (padding.left > 0 ? padding.left : 0),
      child: Opacity(
        opacity: (1.0 - (t * 2.5)).clamp(0.0, 1.0),
        child: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: widget.style.textColor,
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildInteractiveSheet(
    BuildContext context,
    Size size,
    EdgeInsets padding,
    double currentHeight,
  ) {
    return GestureDetector(
      onVerticalDragUpdate: (d) =>
          _handleVerticalDragUpdate(d, size, padding.top, padding.bottom),
      onVerticalDragEnd: _handleVerticalDragEnd,
      child: Opacity(
        opacity: (_currentExtent * 10).clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            color: widget.style.sheetBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: currentHeight < 50
              ? const SizedBox.shrink()
              : Stack(
                  children: [
                    if (currentHeight > 160)
                      Positioned.fill(
                        top: 60,
                        bottom: 110 + padding.bottom,
                        child: MediaQuery.removePadding(
                          context: context,
                          removeTop: true,
                          child: ListView.builder(
                            controller: _scrollController,
                            physics: _currentExtent >= 0.6
                                ? const AlwaysScrollableScrollPhysics()
                                : const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.only(
                              left: padding.left > 0 ? padding.left : 0,
                              right: padding.right > 0 ? padding.right : 0,
                            ),
                            itemCount: widget.comments.length,
                            itemBuilder: (context, i) => _CommentTile(
                              comment: widget.comments[i],
                              textColor: widget.style.textColor,
                              secondaryTextColor:
                                  widget.style.secondaryTextColor,
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Column(
                        children: [
                          Container(
                            height: 4,
                            width: 40,
                            margin: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: widget.style.textColor.withValues(
                                alpha: 0.2,
                              ),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          if (currentHeight > 80) ...[
                            Text(
                              'Comments',
                              style: TextStyle(
                                color: widget.style.textColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Divider(
                              color: widget.style.dividerColor,
                              height: 1,
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (currentHeight > 140)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: _buildInputSection(padding),
                      ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildInputSection(EdgeInsets padding) {
    // WEB/DESKTOP STABILIZATION: ensure some baseline margin if bottom safe area is 0
    final double bottomPadding = (padding.bottom > 0) ? padding.bottom : 12.0;

    return Container(
      padding: EdgeInsets.fromLTRB(
        16 + (padding.left > 0 ? padding.left : 0),
        12,
        16 + (padding.right > 0 ? padding.right : 0),
        bottomPadding + 12,
      ),
      decoration: BoxDecoration(
        color: widget.style.sheetBackgroundColor,
        border: Border(top: BorderSide(color: widget.style.dividerColor)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['❤️', '🙌', '🔥', '👏', '😢', '😍', '😮', '😂']
                .map(
                  (e) => GestureDetector(
                    onTap: () => _textController.text += e,
                    child: Text(e, style: const TextStyle(fontSize: 20)),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(radius: 17, backgroundImage: widget.userAvatarImage),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 42,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: widget.style.textColor.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(21),
                  ),
                  child: TextField(
                    controller: _textController,
                    onSubmitted: (_) => _handleSend(),
                    style: TextStyle(
                      color: widget.style.textColor,
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      hintText: widget.style.commentHintText,
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                        color: widget.style.textColor.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: _handleSend,
                icon: Icon(
                  Icons.send_rounded,
                  color: widget.style.accentColor,
                  size: 24,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionBtn(IconData icon, String label, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: widget.style.textColor, size: 30),
          if (label.isNotEmpty)
            Text(
              label,
              style: TextStyle(
                color: widget.style.textColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({
    required this.comment,
    required this.textColor,
    required this.secondaryTextColor,
  });
  final MediaComment comment;
  final Color textColor;
  final Color secondaryTextColor;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(backgroundImage: comment.avatarImage),
        title: Text(
          comment.userName,
          style: TextStyle(
            color: secondaryTextColor,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          comment.text,
          style: TextStyle(color: textColor, fontSize: 14),
        ),
        trailing: Icon(
          Icons.favorite_border,
          size: 16,
          color: textColor.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}
