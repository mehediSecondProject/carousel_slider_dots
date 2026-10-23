import 'dart:async';

import 'package:flutter/material.dart';

import 'carousel_options.dart';
import 'indicator_options.dart';
import 'smooth_dot_indicator.dart';

part 'carousel_controller.dart';

/// Builds a carousel page. [index] is in `0..itemCount - 1`; [realIndex]
/// is the raw [PageView] index, which keeps growing in infinite mode.
typedef CarouselItemBuilder = Widget Function(
  BuildContext context,
  int index,
  int realIndex,
);

/// A carousel slider with auto play, infinite scroll, enlarged center page
/// and an optional smooth dot indicator.
class SmoothCarousel extends StatefulWidget {
  /// Creates a carousel from a list of widgets.
  SmoothCarousel({
    super.key,
    required List<Widget> items,
    this.options = const CarouselOptions(),
    this.controller,
    this.indicator,
    this.disableGesture = false,
  }) : itemCount = items.length,
       itemBuilder = ((context, index, realIndex) => items[index]);

  /// Creates a carousel that builds its pages lazily.
  const SmoothCarousel.builder({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.options = const CarouselOptions(),
    this.controller,
    this.indicator,
    this.disableGesture = false,
  }) : assert(itemCount >= 0);

  /// Number of pages.
  final int itemCount;

  /// Builds each page.
  final CarouselItemBuilder itemBuilder;

  /// Carousel behaviour.
  final CarouselOptions options;

  /// Optional controller for programmatic navigation.
  final SmoothCarouselController? controller;

  /// Indicator configuration. `null` hides the indicator.
  final CarouselIndicatorOptions? indicator;

  /// Whether swiping is disabled. Controller navigation still works.
  final bool disableGesture;

  @override
  State<SmoothCarousel> createState() => _SmoothCarouselState();
}

class _SmoothCarouselState extends State<SmoothCarousel> {
  // Large start page so an infinite carousel can scroll backwards.
  static const int _realPageBase = 10000;

  late PageController _pageController;
  late int _currentIndex;
  late bool _autoPlayEnabled;

  // Keeps the PageView (and its scroll position) alive when the
  // indicator position changes the surrounding layout.
  final GlobalKey _carouselKey = GlobalKey();

  Timer? _autoPlayTimer;
  bool _touching = false;
  bool _userScrolling = false;
  CarouselPageChangedReason _changeReason = CarouselPageChangedReason.manual;

  CarouselOptions get _options => widget.options;

  int get _count => widget.itemCount;

  bool get _infinite => _options.enableInfiniteScroll && _count > 1;

  int get _basePage => _infinite ? _realPageBase : 0;

  int _clampIndex(int index) => _count == 0 ? 0 : index.clamp(0, _count - 1);

  int _pageToIndex(int page) {
    if (_count == 0) return 0;
    return _infinite ? (page - _basePage) % _count : _clampIndex(page);
  }

  int get _currentPage {
    if (_pageController.hasClients &&
        _pageController.position.haveDimensions &&
        _pageController.page != null) {
      return _pageController.page!.round();
    }
    return _basePage + _currentIndex;
  }

  @override
  void initState() {
    super.initState();
    _currentIndex = _clampIndex(_options.initialPage);
    _autoPlayEnabled = _options.autoPlay;
    _pageController = _createPageController(_currentIndex);
    widget.controller?._attach(this);
    _restartAutoPlay();
  }

  @override
  void didUpdateWidget(SmoothCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._detach(this);
      widget.controller?._attach(this);
    }

    _currentIndex = _clampIndex(_currentIndex);

    final CarouselOptions old = oldWidget.options;
    final bool wasInfinite =
        old.enableInfiniteScroll && oldWidget.itemCount > 1;
    if (old.viewportFraction != _options.viewportFraction ||
        wasInfinite != _infinite) {
      _pageController.removeListener(_handleScroll);
      _pageController.dispose();
      _pageController = _createPageController(_currentIndex);
    }

    if (old.autoPlay != _options.autoPlay) {
      _autoPlayEnabled = _options.autoPlay;
    }
    _restartAutoPlay();
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    widget.controller?._detach(this);
    _pageController.removeListener(_handleScroll);
    _pageController.dispose();
    super.dispose();
  }

  PageController _createPageController(int index) {
    return PageController(
      initialPage: _basePage + index,
      viewportFraction: _options.viewportFraction,
    )..addListener(_handleScroll);
  }

  void _handleScroll() {
    final CarouselScrolledCallback? onScrolled = _options.onScrolled;
    if (onScrolled == null) return;
    final double? page = _pageController.page;
    if (page == null || _count == 0) {
      onScrolled(page);
      return;
    }
    onScrolled(_infinite ? (page - _basePage) % _count : page);
  }

  void _handlePageChanged(int page) {
    final int index = _pageToIndex(page);
    if (index == _currentIndex) return;
    setState(() {
      _currentIndex = index;
    });
    _options.onPageChanged?.call(index, _changeReason);
  }

  // ---------------------------------------------------------------------
  // Navigation
  // ---------------------------------------------------------------------

  Future<void> _runAnimation(
    Future<void> Function() animate,
    CarouselPageChangedReason reason,
  ) async {
    if (!_pageController.hasClients) return;
    _changeReason = reason;
    try {
      await animate();
    } finally {
      if (mounted) _changeReason = CarouselPageChangedReason.manual;
    }
  }

  int _targetPage(int index) {
    final int target = _clampIndex(index);
    final int current = _currentPage;
    int diff = target - _pageToIndex(current);
    if (_infinite && _options.animateToClosest && diff.abs() > _count / 2) {
      diff += diff > 0 ? -_count : _count;
    }
    return current + diff;
  }

  Future<void> _animateToIndex(
    int index,
    Duration duration,
    Curve curve,
    CarouselPageChangedReason reason,
  ) {
    if (reason == CarouselPageChangedReason.controller) _onNavigated();
    return _runAnimation(
      () => _pageController.animateToPage(
        _targetPage(index),
        duration: duration,
        curve: curve,
      ),
      reason,
    );
  }

  Future<void> _animateBy(int delta, Duration duration, Curve curve) {
    _onNavigated();
    final int page = _currentPage + delta;
    if (!_infinite && (page < 0 || page >= _count)) return Future<void>.value();
    return _runAnimation(
      () =>
          _pageController.animateToPage(page, duration: duration, curve: curve),
      CarouselPageChangedReason.controller,
    );
  }

  void _jumpToIndex(int index) {
    if (!_pageController.hasClients) return;
    _onNavigated();
    _changeReason = CarouselPageChangedReason.controller;
    _pageController.jumpToPage(_targetPage(index));
    _changeReason = CarouselPageChangedReason.manual;
  }

  // ---------------------------------------------------------------------
  // Auto play
  // ---------------------------------------------------------------------

  void _setAutoPlay(bool enabled) {
    _autoPlayEnabled = enabled;
    _restartAutoPlay();
  }

  void _onNavigated() {
    if (_options.pauseAutoPlayOnManualNavigate) _restartAutoPlay();
  }

  bool get _shouldAutoPlay =>
      _autoPlayEnabled && !_touching && !_userScrolling && _count > 1;

  void _restartAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = null;
    if (!_shouldAutoPlay) return;
    _autoPlayTimer = Timer.periodic(_options.autoPlayInterval, (_) {
      _autoPlayTick();
    });
  }

  void _autoPlayTick() {
    if (!mounted || !_pageController.hasClients) return;
    // Do not animate while another route covers the carousel.
    if (ModalRoute.of(context)?.isCurrent == false) return;

    int page = _currentPage + 1;
    if (!_infinite && _currentIndex >= _count - 1) {
      if (_options.pauseAutoPlayInFiniteScroll) {
        _setAutoPlay(false);
        return;
      }
      page = 0;
    }

    _runAnimation(
      () => _pageController.animateToPage(
        page,
        duration: _options.autoPlayAnimationDuration,
        curve: _options.autoPlayCurve,
      ),
      CarouselPageChangedReason.timed,
    );
  }

  void _setTouching(bool touching) {
    if (!_options.pauseAutoPlayOnTouch || _touching == touching) return;
    _touching = touching;
    _restartAutoPlay();
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification.depth != 0) return false;
    if (notification is ScrollStartNotification &&
        notification.dragDetails != null) {
      _changeReason = CarouselPageChangedReason.manual;
      if (_options.pauseAutoPlayOnManualNavigate) {
        _userScrolling = true;
        _restartAutoPlay();
      }
    } else if (notification is ScrollEndNotification && _userScrolling) {
      _userScrolling = false;
      _restartAutoPlay();
    }
    return false;
  }

  // ---------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------

  Widget _buildPage(BuildContext context, int page) {
    final int index = _pageToIndex(page);
    Widget child = widget.itemBuilder(context, index, page);

    if (_options.enlargeCenterPage) {
      child = AnimatedBuilder(
        animation: _pageController,
        child: child,
        builder: (context, child) => _enlarge(page, child!),
      );
    }

    return _options.disableCenter ? child : Center(child: child);
  }

  Widget _enlarge(int page, Widget child) {
    double position = (_basePage + _currentIndex).toDouble();
    if (_pageController.hasClients &&
        _pageController.position.haveDimensions &&
        _pageController.page != null) {
      position = _pageController.page!;
    }

    final double distance = (position - page).abs();
    final double factor = _options.enlargeFactor;
    final double scale = (1 - distance * factor).clamp(1 - factor, 1.0);
    final bool horizontal = _options.scrollDirection == Axis.horizontal;

    switch (_options.enlargeStrategy) {
      case CenterPageEnlargeStrategy.scale:
        return Transform.scale(scale: scale, child: child);
      case CenterPageEnlargeStrategy.height:
        return FractionallySizedBox(
          heightFactor: horizontal ? scale : null,
          widthFactor: horizontal ? null : scale,
          child: child,
        );
      case CenterPageEnlargeStrategy.zoom:
        final bool before = page < position;
        final Alignment alignment = horizontal
            ? (before ? Alignment.centerRight : Alignment.centerLeft)
            : (before ? Alignment.bottomCenter : Alignment.topCenter);
        return Transform.scale(
          scale: scale,
          alignment: alignment,
          child: child,
        );
    }
  }

  Widget _buildCarousel() {
    Widget carousel = PageView.builder(
      key: _options.pageViewKey,
      controller: _pageController,
      itemCount: _infinite ? null : _count,
      itemBuilder: _buildPage,
      onPageChanged: _handlePageChanged,
      scrollDirection: _options.scrollDirection,
      reverse: _options.reverse,
      pageSnapping: _options.pageSnapping,
      padEnds: _options.padEnds,
      clipBehavior: _options.clipBehavior,
      physics: widget.disableGesture
          ? const NeverScrollableScrollPhysics()
          : _options.scrollPhysics,
    );

    carousel = NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: Listener(
        onPointerDown: (_) => _setTouching(true),
        onPointerUp: (_) => _setTouching(false),
        onPointerCancel: (_) => _setTouching(false),
        child: carousel,
      ),
    );

    return KeyedSubtree(
      key: _carouselKey,
      child: _options.height != null
          ? SizedBox(height: _options.height, child: carousel)
          : AspectRatio(aspectRatio: _options.aspectRatio, child: carousel),
    );
  }

  Widget _buildIndicator(CarouselIndicatorOptions indicator) {
    final Widget dots =
        indicator.builder?.call(context, _currentIndex, _count) ??
        SmoothDotIndicator(
          count: _count,
          activeIndex: _currentIndex,
          style: indicator.style,
          onDotTap: indicator.enableTap
              ? (index) => _animateToIndex(
                  index,
                  indicator.tapAnimationDuration,
                  indicator.tapAnimationCurve,
                  CarouselPageChangedReason.controller,
                )
              : null,
        );
    return Padding(padding: indicator.padding, child: dots);
  }

  @override
  Widget build(BuildContext context) {
    if (_count == 0) return const SizedBox.shrink();

    final Widget carousel = _buildCarousel();
    final CarouselIndicatorOptions? indicator = widget.indicator;
    if (indicator == null || !indicator.isDotEnable) return carousel;

    final Widget dots = _buildIndicator(indicator);
    final double gap = indicator.spacing;

    switch (indicator.position) {
      case IndicatorPosition.bottom:
      case IndicatorPosition.top:
        final Widget aligned = Align(
          alignment: indicator.alignment ?? Alignment.center,
          child: dots,
        );
        final bool top = indicator.position == IndicatorPosition.top;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (top) ...[aligned, SizedBox(height: gap)],
            carousel,
            if (!top) ...[SizedBox(height: gap), aligned],
          ],
        );
      case IndicatorPosition.left:
      case IndicatorPosition.right:
        final bool left = indicator.position == IndicatorPosition.left;
        final double y = (indicator.alignment ?? Alignment.center)
            .resolve(Directionality.maybeOf(context))
            .y;
        return Row(
          crossAxisAlignment: y < 0
              ? CrossAxisAlignment.start
              : (y > 0 ? CrossAxisAlignment.end : CrossAxisAlignment.center),
          children: [
            if (left) ...[dots, SizedBox(width: gap)],
            Expanded(child: carousel),
            if (!left) ...[SizedBox(width: gap), dots],
          ],
        );
      case IndicatorPosition.overlay:
        return Stack(
          children: [
            carousel,
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.all(gap),
                child: Align(
                  alignment: indicator.alignment ?? Alignment.bottomCenter,
                  child: dots,
                ),
              ),
            ),
          ],
        );
      case IndicatorPosition.onItem:
        // The current page is centered and fills viewportFraction of the
        // carousel along the scroll axis.
        final double fraction = _options.viewportFraction.clamp(0.0, 1.0);
        final bool horizontal = _options.scrollDirection == Axis.horizontal;
        return Stack(
          children: [
            carousel,
            Positioned.fill(
              child: Center(
                child: FractionallySizedBox(
                  widthFactor: horizontal ? fraction : 1,
                  heightFactor: horizontal ? 1 : fraction,
                  child: Padding(
                    padding: EdgeInsets.all(gap),
                    child: Align(
                      alignment: indicator.alignment ?? Alignment.bottomCenter,
                      child: dots,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
    }
  }
}
