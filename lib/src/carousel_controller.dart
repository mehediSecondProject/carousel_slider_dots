part of 'smooth_carousel.dart';

/// Controls a [SmoothCarousel] from outside.
///
/// Create it once, pass it to the carousel and call its methods after
/// the carousel is built (see [onReady]).
class SmoothCarouselController {
  /// Creates a carousel controller.
  SmoothCarouselController();

  _SmoothCarouselState? _state;
  final Completer<void> _readyCompleter = Completer<void>();

  /// Whether the controller is attached to a carousel.
  bool get isReady => _state != null;

  /// Completes when the controller is attached to a carousel.
  Future<void> get onReady => _readyCompleter.future;

  /// Index of the current page, or `0` when not attached.
  int get currentIndex => _state?._currentIndex ?? 0;

  void _attach(_SmoothCarouselState state) {
    _state = state;
    if (!_readyCompleter.isCompleted) _readyCompleter.complete();
  }

  void _detach(_SmoothCarouselState state) {
    if (_state == state) _state = null;
  }

  _SmoothCarouselState get _attached {
    assert(_state != null, 'SmoothCarouselController is not attached.');
    return _state!;
  }

  /// Animates to the next page.
  Future<void> nextPage({
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.linear,
  }) {
    return _attached._animateBy(1, duration, curve);
  }

  /// Animates to the previous page.
  Future<void> previousPage({
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.linear,
  }) {
    return _attached._animateBy(-1, duration, curve);
  }

  /// Jumps to [index] without animation.
  void jumpToPage(int index) => _attached._jumpToIndex(index);

  /// Animates to [index].
  Future<void> animateToPage(
    int index, {
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.linear,
  }) {
    return _attached._animateToIndex(
      index,
      duration,
      curve,
      CarouselPageChangedReason.controller,
    );
  }

  /// Starts auto play, also when [CarouselOptions.autoPlay] is `false`.
  void startAutoPlay() => _attached._setAutoPlay(true);

  /// Stops auto play.
  void stopAutoPlay() => _attached._setAutoPlay(false);
}
