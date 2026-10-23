import 'package:flutter/widgets.dart';

/// Why the current page of a [SmoothCarousel] changed.
enum CarouselPageChangedReason {
  /// The page was changed by the auto play timer.
  timed,

  /// The page was changed by the user swiping.
  manual,

  /// The page was changed through a [SmoothCarouselController] or by
  /// tapping a dot of the indicator.
  controller,
}

/// How the center page is emphasised when
/// [CarouselOptions.enlargeCenterPage] is enabled.
enum CenterPageEnlargeStrategy {
  /// Side pages are scaled down around their own center.
  scale,

  /// Side pages keep their width but lose height.
  height,

  /// Side pages are scaled down towards the center page.
  zoom,
}

/// Called whenever the current page of a carousel changes.
typedef CarouselPageChangedCallback = void Function(
  int index,
  CarouselPageChangedReason reason,
);

/// Called on every scroll update with the current page position.
///
/// The value is fractional while scrolling and is always in the range
/// `0 <= value < itemCount`, also for infinite carousels.
typedef CarouselScrolledCallback = void Function(double? position);

/// Configuration of a [SmoothCarousel].
@immutable
class CarouselOptions {
  /// Creates carousel options.
  const CarouselOptions({
    this.height,
    this.aspectRatio = 16 / 9,
    this.viewportFraction = 0.8,
    this.initialPage = 0,
    this.enableInfiniteScroll = true,
    this.animateToClosest = true,
    this.reverse = false,
    this.autoPlay = false,
    this.autoPlayInterval = const Duration(seconds: 4),
    this.autoPlayAnimationDuration = const Duration(milliseconds: 800),
    this.autoPlayCurve = Curves.fastOutSlowIn,
    this.enlargeCenterPage = false,
    this.enlargeStrategy = CenterPageEnlargeStrategy.scale,
    this.enlargeFactor = 0.3,
    this.onPageChanged,
    this.onScrolled,
    this.scrollPhysics,
    this.pageSnapping = true,
    this.scrollDirection = Axis.horizontal,
    this.pauseAutoPlayOnTouch = true,
    this.pauseAutoPlayOnManualNavigate = true,
    this.pauseAutoPlayInFiniteScroll = false,
    this.pageViewKey,
    this.disableCenter = false,
    this.padEnds = true,
    this.clipBehavior = Clip.hardEdge,
  }) : assert(viewportFraction > 0),
       assert(aspectRatio > 0),
       assert(enlargeFactor >= 0 && enlargeFactor < 1);

  /// Fixed height of the carousel. When `null`, [aspectRatio] is used.
  final double? height;

  /// Width / height ratio used when [height] is `null`.
  final double aspectRatio;

  /// Fraction of the viewport each page fills.
  final double viewportFraction;

  /// Index of the page shown first.
  final int initialPage;

  /// Whether the carousel loops endlessly.
  final bool enableInfiniteScroll;

  /// In an infinite carousel, whether controller navigation takes the
  /// shortest way round instead of always moving forward.
  final bool animateToClosest;

  /// Whether pages are laid out in reverse order.
  final bool reverse;

  /// Whether pages advance automatically.
  final bool autoPlay;

  /// Time between two auto play page changes.
  final Duration autoPlayInterval;

  /// Duration of the auto play page animation.
  final Duration autoPlayAnimationDuration;

  /// Curve of the auto play page animation.
  final Curve autoPlayCurve;

  /// Whether the center page is bigger than the side pages.
  final bool enlargeCenterPage;

  /// How the center page is enlarged.
  final CenterPageEnlargeStrategy enlargeStrategy;

  /// How much smaller the side pages are, between 0 and 1.
  final double enlargeFactor;

  /// Called when the current page changes.
  final CarouselPageChangedCallback? onPageChanged;

  /// Called on every scroll update.
  final CarouselScrolledCallback? onScrolled;

  /// Physics of the underlying [PageView].
  final ScrollPhysics? scrollPhysics;

  /// Whether the [PageView] snaps to whole pages.
  final bool pageSnapping;

  /// Axis along which pages scroll.
  final Axis scrollDirection;

  /// Whether auto play pauses while the carousel is touched.
  final bool pauseAutoPlayOnTouch;

  /// Whether auto play pauses while the user swipes and restarts its
  /// interval after any manual or controller navigation.
  final bool pauseAutoPlayOnManualNavigate;

  /// For a finite carousel, whether auto play stops at the last page
  /// instead of going back to the first one.
  final bool pauseAutoPlayInFiniteScroll;

  /// Key passed to the underlying [PageView].
  final PageStorageKey<dynamic>? pageViewKey;

  /// Whether pages are not wrapped in a [Center] widget.
  final bool disableCenter;

  /// Whether the first and last page can be centered.
  final bool padEnds;

  /// Clip behavior of the underlying [PageView].
  final Clip clipBehavior;

  /// Returns a copy with the given fields replaced.
  CarouselOptions copyWith({
    double? height,
    double? aspectRatio,
    double? viewportFraction,
    int? initialPage,
    bool? enableInfiniteScroll,
    bool? animateToClosest,
    bool? reverse,
    bool? autoPlay,
    Duration? autoPlayInterval,
    Duration? autoPlayAnimationDuration,
    Curve? autoPlayCurve,
    bool? enlargeCenterPage,
    CenterPageEnlargeStrategy? enlargeStrategy,
    double? enlargeFactor,
    CarouselPageChangedCallback? onPageChanged,
    CarouselScrolledCallback? onScrolled,
    ScrollPhysics? scrollPhysics,
    bool? pageSnapping,
    Axis? scrollDirection,
    bool? pauseAutoPlayOnTouch,
    bool? pauseAutoPlayOnManualNavigate,
    bool? pauseAutoPlayInFiniteScroll,
    PageStorageKey<dynamic>? pageViewKey,
    bool? disableCenter,
    bool? padEnds,
    Clip? clipBehavior,
  }) {
    return CarouselOptions(
      height: height ?? this.height,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      viewportFraction: viewportFraction ?? this.viewportFraction,
      initialPage: initialPage ?? this.initialPage,
      enableInfiniteScroll: enableInfiniteScroll ?? this.enableInfiniteScroll,
      animateToClosest: animateToClosest ?? this.animateToClosest,
      reverse: reverse ?? this.reverse,
      autoPlay: autoPlay ?? this.autoPlay,
      autoPlayInterval: autoPlayInterval ?? this.autoPlayInterval,
      autoPlayAnimationDuration:
          autoPlayAnimationDuration ?? this.autoPlayAnimationDuration,
      autoPlayCurve: autoPlayCurve ?? this.autoPlayCurve,
      enlargeCenterPage: enlargeCenterPage ?? this.enlargeCenterPage,
      enlargeStrategy: enlargeStrategy ?? this.enlargeStrategy,
      enlargeFactor: enlargeFactor ?? this.enlargeFactor,
      onPageChanged: onPageChanged ?? this.onPageChanged,
      onScrolled: onScrolled ?? this.onScrolled,
      scrollPhysics: scrollPhysics ?? this.scrollPhysics,
      pageSnapping: pageSnapping ?? this.pageSnapping,
      scrollDirection: scrollDirection ?? this.scrollDirection,
      pauseAutoPlayOnTouch: pauseAutoPlayOnTouch ?? this.pauseAutoPlayOnTouch,
      pauseAutoPlayOnManualNavigate:
          pauseAutoPlayOnManualNavigate ?? this.pauseAutoPlayOnManualNavigate,
      pauseAutoPlayInFiniteScroll:
          pauseAutoPlayInFiniteScroll ?? this.pauseAutoPlayInFiniteScroll,
      pageViewKey: pageViewKey ?? this.pageViewKey,
      disableCenter: disableCenter ?? this.disableCenter,
      padEnds: padEnds ?? this.padEnds,
      clipBehavior: clipBehavior ?? this.clipBehavior,
    );
  }
}
