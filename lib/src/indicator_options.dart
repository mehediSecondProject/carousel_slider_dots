import 'package:flutter/widgets.dart';

import 'dot_indicator_style.dart';

/// Where a [SmoothCarousel] places its indicator.
enum IndicatorPosition {
  /// Below the carousel.
  bottom,

  /// Above the carousel.
  top,

  /// Left of the carousel. Pair with a vertical indicator axis.
  left,

  /// Right of the carousel. Pair with a vertical indicator axis.
  right,

  /// On top of the whole carousel area, including the side pages, placed
  /// with [CarouselIndicatorOptions.alignment].
  overlay,

  /// On top of the current (centered) page, placed with
  /// [CarouselIndicatorOptions.alignment] — for example on the card's
  /// bottom center, top center, left or right side.
  onItem,
}

/// Builds a completely custom indicator for a [SmoothCarousel].
typedef CarouselIndicatorBuilder = Widget Function(
  BuildContext context,
  int activeIndex,
  int count,
);

/// Configuration of the indicator shown by a [SmoothCarousel].
@immutable
class CarouselIndicatorOptions {
  /// Creates indicator options.
  const CarouselIndicatorOptions({
    this.isDotEnable = true,
    this.style = const SmoothDotIndicatorStyle(),
    this.position = IndicatorPosition.bottom,
    this.spacing = 12,
    this.alignment,
    this.padding = EdgeInsets.zero,
    this.enableTap = true,
    this.tapAnimationDuration = const Duration(milliseconds: 400),
    this.tapAnimationCurve = Curves.easeInOut,
    this.builder,
  });

  /// Whether the indicator is shown. When `false` nothing is built and
  /// the space of the indicator and its [spacing] is removed.
  final bool isDotEnable;

  /// Look and animation of the dots.
  final SmoothDotIndicatorStyle style;

  /// Where the indicator is placed.
  final IndicatorPosition position;

  /// Gap between the carousel and the indicator. For
  /// [IndicatorPosition.overlay] it is the distance from the edge.
  final double spacing;

  /// Alignment of the indicator.
  ///
  /// * [IndicatorPosition.overlay] and [IndicatorPosition.onItem]: any
  ///   point of the carousel or the current page. Defaults to
  ///   [Alignment.bottomCenter].
  /// * [IndicatorPosition.top] and [IndicatorPosition.bottom]: the
  ///   horizontal part is used (start, center, end).
  /// * [IndicatorPosition.left] and [IndicatorPosition.right]: the
  ///   vertical part is used (top, center, bottom).
  ///
  /// Other positions default to [Alignment.center].
  final AlignmentGeometry? alignment;

  /// Padding around the indicator.
  final EdgeInsetsGeometry padding;

  /// Whether tapping a dot navigates to its page.
  final bool enableTap;

  /// Duration of the page animation after a dot tap.
  final Duration tapAnimationDuration;

  /// Curve of the page animation after a dot tap.
  final Curve tapAnimationCurve;

  /// Replaces the dot indicator with any widget.
  final CarouselIndicatorBuilder? builder;
}
