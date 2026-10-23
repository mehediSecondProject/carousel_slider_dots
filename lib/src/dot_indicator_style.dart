import 'package:flutter/material.dart';

/// How the window of visible dots follows the active dot once there are
/// more pages than [SmoothDotIndicatorStyle.maxVisibleDots].
enum DotScrollMode {
  /// The active dot first moves to its neighbour slot, then the whole row
  /// slides so there is always a free slot ahead. The active dot keeps
  /// visibly moving on every page change, also past the last visible slot.
  stepThenSlide,

  /// The row slides together with the active dot once it reaches the edge,
  /// so the active dot stays pinned to the first or last slot.
  slideWithActive,

  /// The active dot stays in the middle slot and the row slides under it.
  centered,
}

/// Builds a fully custom dot. The returned widget is sized by the
/// indicator, using the regular or the active dot size.
typedef DotBuilder = Widget Function(
  BuildContext context,
  int index,
  bool isActive,
);

/// Visual configuration of a [SmoothDotIndicator].
///
/// Sizes are given for a horizontal indicator. For [Axis.vertical] width
/// and height are swapped, so the active dot still stretches along the
/// indicator axis.
@immutable
class SmoothDotIndicatorStyle {
  /// Creates a dot indicator style.
  const SmoothDotIndicatorStyle({
    this.maxVisibleDots = 7,
    this.dotWidth = 7,
    this.dotHeight = 7,
    this.activeDotWidth = 18,
    this.activeDotHeight,
    this.spacing = 5,
    this.activeColor,
    this.inactiveColor,
    this.activeGradient,
    this.inactiveGradient,
    this.borderRadius,
    this.activeBorder,
    this.inactiveBorder,
    this.activeShadows,
    this.inactiveShadows,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOutCubic,
    this.slideDelay,
    this.scrollMode = DotScrollMode.stepThenSlide,
    this.edgeDotScale = 1,
    this.axis = Axis.horizontal,
    this.dotBuilder,
  }) : assert(maxVisibleDots > 0),
       assert(dotWidth >= 0 && dotHeight >= 0 && activeDotWidth >= 0),
       assert(spacing >= 0),
       assert(edgeDotScale >= 0);

  /// Maximum number of dots shown at the same time.
  final int maxVisibleDots;

  /// Width of an inactive dot.
  final double dotWidth;

  /// Height of an inactive dot.
  final double dotHeight;

  /// Width of the active dot.
  final double activeDotWidth;

  /// Height of the active dot. Defaults to [dotHeight].
  final double? activeDotHeight;

  /// Gap between two dots.
  final double spacing;

  /// Color of the active dot. Defaults to the theme's primary color.
  final Color? activeColor;

  /// Color of the inactive dots. Defaults to a light grey.
  final Color? inactiveColor;

  /// Gradient of the active dot. Takes precedence over [activeColor].
  final Gradient? activeGradient;

  /// Gradient of the inactive dots. Takes precedence over [inactiveColor].
  final Gradient? inactiveGradient;

  /// Corner radius of the dots. Defaults to fully rounded.
  final BorderRadius? borderRadius;

  /// Border of the active dot.
  final BoxBorder? activeBorder;

  /// Border of the inactive dots.
  final BoxBorder? inactiveBorder;

  /// Shadows of the active dot.
  final List<BoxShadow>? activeShadows;

  /// Shadows of the inactive dots.
  final List<BoxShadow>? inactiveShadows;

  /// Duration of every dot animation.
  final Duration duration;

  /// Curve of every dot animation.
  final Curve curve;

  /// Delay before the row slides in [DotScrollMode.stepThenSlide].
  /// Defaults to [duration], so the slide starts when the step ends.
  final Duration? slideDelay;

  /// How the visible window follows the active dot.
  final DotScrollMode scrollMode;

  /// Scale of the dots at the edges of the window when more dots are
  /// hidden behind them. `1` disables the effect; `0.6` gives an
  /// Instagram-like look.
  final double edgeDotScale;

  /// Direction of the indicator.
  final Axis axis;

  /// Optional builder that replaces the default dot decoration.
  final DotBuilder? dotBuilder;

  /// Returns a copy with the given fields replaced.
  SmoothDotIndicatorStyle copyWith({
    int? maxVisibleDots,
    double? dotWidth,
    double? dotHeight,
    double? activeDotWidth,
    double? activeDotHeight,
    double? spacing,
    Color? activeColor,
    Color? inactiveColor,
    Gradient? activeGradient,
    Gradient? inactiveGradient,
    BorderRadius? borderRadius,
    BoxBorder? activeBorder,
    BoxBorder? inactiveBorder,
    List<BoxShadow>? activeShadows,
    List<BoxShadow>? inactiveShadows,
    Duration? duration,
    Curve? curve,
    Duration? slideDelay,
    DotScrollMode? scrollMode,
    double? edgeDotScale,
    Axis? axis,
    DotBuilder? dotBuilder,
  }) {
    return SmoothDotIndicatorStyle(
      maxVisibleDots: maxVisibleDots ?? this.maxVisibleDots,
      dotWidth: dotWidth ?? this.dotWidth,
      dotHeight: dotHeight ?? this.dotHeight,
      activeDotWidth: activeDotWidth ?? this.activeDotWidth,
      activeDotHeight: activeDotHeight ?? this.activeDotHeight,
      spacing: spacing ?? this.spacing,
      activeColor: activeColor ?? this.activeColor,
      inactiveColor: inactiveColor ?? this.inactiveColor,
      activeGradient: activeGradient ?? this.activeGradient,
      inactiveGradient: inactiveGradient ?? this.inactiveGradient,
      borderRadius: borderRadius ?? this.borderRadius,
      activeBorder: activeBorder ?? this.activeBorder,
      inactiveBorder: inactiveBorder ?? this.inactiveBorder,
      activeShadows: activeShadows ?? this.activeShadows,
      inactiveShadows: inactiveShadows ?? this.inactiveShadows,
      duration: duration ?? this.duration,
      curve: curve ?? this.curve,
      slideDelay: slideDelay ?? this.slideDelay,
      scrollMode: scrollMode ?? this.scrollMode,
      edgeDotScale: edgeDotScale ?? this.edgeDotScale,
      axis: axis ?? this.axis,
      dotBuilder: dotBuilder ?? this.dotBuilder,
    );
  }
}
