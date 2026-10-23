import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'dot_indicator_style.dart';

/// An animated page indicator that keeps a limited window of dots and
/// slides it smoothly when there are more pages than visible dots.
///
/// It is used by [SmoothCarousel], but works with any [PageView] or
/// custom pager: pass the page count and the current index.
class SmoothDotIndicator extends StatefulWidget {
  /// Creates a dot indicator.
  const SmoothDotIndicator({
    super.key,
    required this.count,
    required this.activeIndex,
    this.style = const SmoothDotIndicatorStyle(),
    this.onDotTap,
    this.isDotEnable = true,
  }) : assert(count >= 0);

  /// Total number of pages.
  final int count;

  /// Index of the current page.
  final int activeIndex;

  /// Visual configuration.
  final SmoothDotIndicatorStyle style;

  /// Called with the dot index when a dot is tapped.
  final ValueChanged<int>? onDotTap;

  /// Whether the dots are shown. When `false` the indicator is a
  /// [SizedBox.shrink] and takes no space.
  final bool isDotEnable;

  @override
  State<SmoothDotIndicator> createState() => _SmoothDotIndicatorState();
}

class _SmoothDotIndicatorState extends State<SmoothDotIndicator> {
  // First page shown in the dot window.
  int _windowStart = 0;

  Timer? _slideTimer;

  SmoothDotIndicatorStyle get _style => widget.style;

  int get _visibleDots => math.min(widget.count, _style.maxVisibleDots);

  int get _activeIndex =>
      widget.count == 0 ? 0 : widget.activeIndex.clamp(0, widget.count - 1);

  @override
  void initState() {
    super.initState();
    _windowStart = _settledStart(_activeIndex, _windowStart);
  }

  @override
  void didUpdateWidget(SmoothDotIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activeIndex != widget.activeIndex ||
        oldWidget.count != widget.count ||
        oldWidget.style.maxVisibleDots != _style.maxVisibleDots ||
        oldWidget.style.scrollMode != _style.scrollMode) {
      _onActiveIndexChanged();
    }
  }

  @override
  void dispose() {
    _slideTimer?.cancel();
    super.dispose();
  }

  int _clampStart(int start) {
    final int maxStart = math.max(0, widget.count - _visibleDots);
    return start.clamp(0, maxStart);
  }

  // Smallest move of the window that keeps [index] visible.
  int _visibleStart(int index, int from) {
    return _clampStart(from.clamp(index - (_visibleDots - 1), index));
  }

  // Where the window rests once all animations are done.
  int _settledStart(int index, int from) {
    switch (_style.scrollMode) {
      case DotScrollMode.centered:
        return _clampStart(index - (_visibleDots - 1) ~/ 2);
      case DotScrollMode.slideWithActive:
        return _visibleStart(index, from);
      case DotScrollMode.stepThenSlide:
        // Keep one free slot on each side, so the next step is visible.
        final int lookAhead = _visibleDots >= 3 ? 1 : 0;
        return _clampStart(
          from.clamp(index - (_visibleDots - 1 - lookAhead), index - lookAhead),
        );
    }
  }

  void _onActiveIndexChanged() {
    _slideTimer?.cancel();
    final int index = _activeIndex;

    if (_style.scrollMode != DotScrollMode.stepThenSlide) {
      _windowStart = _settledStart(index, _windowStart);
      return;
    }

    // Step 1: move the active dot into its neighbour slot.
    _windowStart = _visibleStart(index, _windowStart);

    // Step 2: slide the row once the dot has arrived.
    final int target = _settledStart(index, _windowStart);
    if (target == _windowStart) return;

    _slideTimer = Timer(_style.slideDelay ?? _style.duration, () {
      if (!mounted) return;
      setState(() {
        _windowStart = target;
      });
    });
  }

  BoxDecoration _decoration(BuildContext context, bool isActive) {
    final Color activeColor =
        _style.activeColor ?? Theme.of(context).colorScheme.primary;
    final Color inactiveColor = _style.inactiveColor ?? Colors.grey.shade400;
    final double radius = math.max(
      math.max(_style.dotWidth, _style.dotHeight),
      math.max(_style.activeDotWidth, _style.activeDotHeight ?? 0),
    );

    return BoxDecoration(
      color: isActive ? activeColor : inactiveColor,
      gradient: isActive ? _style.activeGradient : _style.inactiveGradient,
      border: isActive ? _style.activeBorder : _style.inactiveBorder,
      boxShadow: isActive ? _style.activeShadows : _style.inactiveShadows,
      borderRadius: _style.borderRadius ?? BorderRadius.circular(radius),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int count = widget.count;
    if (count == 0 || !widget.isDotEnable) return const SizedBox.shrink();

    final int active = _activeIndex;
    final int visible = _visibleDots;
    final bool horizontal = _style.axis == Axis.horizontal;

    // Main axis = along the indicator, cross axis = across it.
    final double dotMain = _style.dotWidth;
    final double dotCross = _style.dotHeight;
    final double activeMain = _style.activeDotWidth;
    final double activeCross = _style.activeDotHeight ?? _style.dotHeight;
    final double activeExtra = activeMain - dotMain;
    final double pitch = dotMain + _style.spacing;

    final double viewportMain =
        visible * dotMain +
        (visible - 1) * _style.spacing +
        math.max(0, activeExtra);
    final double viewportCross = math.max(dotCross, activeCross);

    // Build a few dots beyond the window so they can slide in.
    final int first = math.max(0, _windowStart - visible);
    final int last = math.min(count - 1, _windowStart + 2 * visible - 1);

    final List<Widget> dots = <Widget>[];
    for (int index = first; index <= last; index++) {
      final bool isActive = index == active;
      final int slot = index - _windowStart;

      final double main = isActive ? activeMain : dotMain;
      final double cross = isActive ? activeCross : dotCross;
      final double mainOffset =
          slot * pitch + (index > active ? activeExtra : 0);
      final double crossOffset = (viewportCross - cross) / 2;

      final bool hiddenBefore = _windowStart > 0;
      final bool hiddenAfter = _windowStart + visible < count;
      final bool atEdge =
          slot < 0 ||
          slot >= visible ||
          (slot == 0 && hiddenBefore) ||
          (slot == visible - 1 && hiddenAfter);
      final double scale = !isActive && atEdge ? _style.edgeDotScale : 1;

      Widget dot =
          _style.dotBuilder?.call(context, index, isActive) ??
          AnimatedContainer(
            duration: _style.duration,
            curve: _style.curve,
            decoration: _decoration(context, isActive),
          );

      if (widget.onDotTap != null) {
        dot = GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => widget.onDotTap!(index),
          child: dot,
        );
      }

      dots.add(
        AnimatedPositioned(
          key: ValueKey<int>(index),
          duration: _style.duration,
          curve: _style.curve,
          left: horizontal ? mainOffset : crossOffset,
          top: horizontal ? crossOffset : mainOffset,
          width: horizontal ? main : cross,
          height: horizontal ? cross : main,
          child: AnimatedScale(
            scale: scale,
            duration: _style.duration,
            curve: _style.curve,
            child: dot,
          ),
        ),
      );
    }

    return Semantics(
      label: 'Page ${active + 1} of $count',
      child: SizedBox(
        width: horizontal ? viewportMain : viewportCross,
        height: horizontal ? viewportCross : viewportMain,
        child: ClipRect(
          child: Stack(clipBehavior: Clip.none, children: dots),
        ),
      ),
    );
  }
}
