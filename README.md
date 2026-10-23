# carousel_slider_dots

A fully customizable Flutter **carousel slider** with a **smooth sliding dots
indicator**. It has every feature you know from popular carousel packages —
auto play, infinite scroll, enlarged center page, vertical mode, controller —
plus an indicator that keeps animating smoothly, even with hundreds of pages.

Works on Android, iOS, web, macOS, Windows and Linux (pure Dart, no native
code).

## Screenshots

<p>
  <img src="https://raw.githubusercontent.com/mehediSecondProject/carousel_slider_dots/main/screenshots/pattern_01.png" width="180" alt="Default carousel with the smooth sliding dots indicator">
  <img src="https://raw.githubusercontent.com/mehediSecondProject/carousel_slider_dots/main/screenshots/pattern_02.png" width="180" alt="Image carousel with network images">
  <img src="https://raw.githubusercontent.com/mehediSecondProject/carousel_slider_dots/main/screenshots/pattern_10.png" width="180" alt="Enlarged center page">
  <img src="https://raw.githubusercontent.com/mehediSecondProject/carousel_slider_dots/main/screenshots/pattern_15.png" width="180" alt="Free scroll and vertical carousel">
  <img src="https://raw.githubusercontent.com/mehediSecondProject/carousel_slider_dots/main/screenshots/pattern_19.png" width="180" alt="Indicator on the right and overlaid">
  <img src="https://raw.githubusercontent.com/mehediSecondProject/carousel_slider_dots/main/screenshots/pattern_21.png" width="180" alt="Gradient, bordered and square dots">
  <img src="https://raw.githubusercontent.com/mehediSecondProject/carousel_slider_dots/main/screenshots/pattern_23.png" width="180" alt="Custom dot builder and page counter">
  <img src="https://raw.githubusercontent.com/mehediSecondProject/carousel_slider_dots/main/screenshots/pattern_27.png" width="180" alt="Carousel controller">
  <img src="https://raw.githubusercontent.com/mehediSecondProject/carousel_slider_dots/main/screenshots/pattern_32.png" width="180" alt="Dots placed anywhere">
  <img src="https://raw.githubusercontent.com/mehediSecondProject/carousel_slider_dots/main/screenshots/playground_01.png" width="180" alt="Playground with every option">
</p>

## Why another carousel?

Most dot indicators either show one dot per page (too many for long lists)
or pin the active dot to the edge once the visible dots are full, so the dot
stops moving. `SmoothDotIndicator` shows a limited window of dots and, by
default, **moves the active dot one slot and then slides the whole row**, so
every page change looks the same — on page 2 or on page 99.

## Install

```yaml
dependencies:
  carousel_slider_dots: ^1.0.0
```

```dart
import 'package:carousel_slider_dots/carousel_slider_dots.dart';
```

## Quick start

```dart
SmoothCarousel(
  items: [Image.asset('a.png'), Image.asset('b.png'), Image.asset('c.png')],
  options: const CarouselOptions(height: 180, autoPlay: true),
  indicator: const CarouselIndicatorOptions(),
)
```

Lazy pages:

```dart
SmoothCarousel.builder(
  itemCount: 100,
  itemBuilder: (context, index, realIndex) => MyCard(index),
  options: const CarouselOptions(height: 160, enableInfiniteScroll: false),
  indicator: const CarouselIndicatorOptions(),
)
```

## Carousel options

| Option | Default | Description |
| --- | --- | --- |
| `height` | `null` | Fixed height. When `null`, `aspectRatio` is used. |
| `aspectRatio` | `16 / 9` | Width / height ratio. |
| `viewportFraction` | `0.8` | Part of the viewport each page fills. |
| `initialPage` | `0` | First page shown. |
| `enableInfiniteScroll` | `true` | Loop endlessly. |
| `animateToClosest` | `true` | Controller takes the shortest way in infinite mode. |
| `reverse` | `false` | Reverse page order. |
| `autoPlay` | `false` | Advance pages automatically. |
| `autoPlayInterval` | `4s` | Time between auto play steps. |
| `autoPlayAnimationDuration` | `800ms` | Auto play animation duration. |
| `autoPlayCurve` | `Curves.fastOutSlowIn` | Auto play animation curve. |
| `enlargeCenterPage` | `false` | Make the center page bigger. |
| `enlargeStrategy` | `scale` | `scale`, `height` or `zoom`. |
| `enlargeFactor` | `0.3` | How much smaller side pages are. |
| `onPageChanged` | `null` | `(index, reason)` — reason is `timed`, `manual` or `controller`. |
| `onScrolled` | `null` | Fractional page position on every scroll update. |
| `scrollPhysics` | `null` | Custom physics. |
| `pageSnapping` | `true` | Snap to whole pages. |
| `scrollDirection` | `horizontal` | Horizontal or vertical. |
| `pauseAutoPlayOnTouch` | `true` | Pause while touched. |
| `pauseAutoPlayOnManualNavigate` | `true` | Pause while swiping, restart interval after navigation. |
| `pauseAutoPlayInFiniteScroll` | `false` | Stop at the last page of a finite carousel. |
| `pageViewKey` | `null` | `PageStorageKey` for the `PageView`. |
| `disableCenter` | `false` | Do not wrap pages in `Center`. |
| `padEnds` | `true` | Allow first / last page to be centered. |
| `clipBehavior` | `Clip.hardEdge` | Clip of the `PageView`. |

`SmoothCarousel` also takes `disableGesture` to turn off swiping.

## Controller

```dart
final controller = SmoothCarouselController();

SmoothCarousel(items: items, controller: controller);

controller.nextPage();
controller.previousPage(duration: const Duration(milliseconds: 500));
controller.animateToPage(3, curve: Curves.easeOut);
controller.jumpToPage(0);
controller.startAutoPlay();
controller.stopAutoPlay();
controller.currentIndex;
await controller.onReady;
```

## Indicator

```dart
indicator: CarouselIndicatorOptions(
  isDotEnable: true, // false hides the dots and removes their space
  position: IndicatorPosition.onItem, // bottom, top, left, right, overlay, onItem
  alignment: Alignment.bottomCenter,
  spacing: 12,
  enableTap: true,
  style: SmoothDotIndicatorStyle(
    maxVisibleDots: 7,
    dotWidth: 7,
    dotHeight: 7,
    activeDotWidth: 18,
    spacing: 5,
    activeColor: Colors.blue,
    inactiveColor: Colors.grey,
    activeGradient: LinearGradient(colors: [Colors.purple, Colors.orange]),
    scrollMode: DotScrollMode.stepThenSlide,
    edgeDotScale: 0.6,
    duration: Duration(milliseconds: 300),
    curve: Curves.easeInOutCubic,
  ),
),
```

### Place the dots anywhere

| Where | Code |
| --- | --- |
| Below the carousel (default) | `position: IndicatorPosition.bottom` |
| Above the carousel | `position: IndicatorPosition.top` |
| Left / right of the carousel | `position: IndicatorPosition.left` / `.right` + `style: SmoothDotIndicatorStyle(axis: Axis.vertical)` |
| On the card, bottom center | `position: IndicatorPosition.onItem` |
| On the card, top center | `position: IndicatorPosition.onItem, alignment: Alignment.topCenter` |
| On the card, right side | `position: IndicatorPosition.onItem, alignment: Alignment.centerRight` + vertical axis |
| On the card, left side | `position: IndicatorPosition.onItem, alignment: Alignment.centerLeft` + vertical axis |
| Over the whole carousel | `position: IndicatorPosition.overlay` + any `alignment` |

`onItem` puts the dots inside the current, centered page; `overlay` uses the
whole carousel width, including the side pages. `spacing` is the distance from
the edge, `padding` adds extra space around the dots. For `top` / `bottom`
the alignment picks start, center or end; for `left` / `right` it picks top,
center or bottom.

```dart
indicator: const CarouselIndicatorOptions(
  position: IndicatorPosition.onItem,
  alignment: Alignment.bottomCenter,
  spacing: 12,
  style: SmoothDotIndicatorStyle(
    activeColor: Colors.white,
    inactiveColor: Colors.white54,
  ),
),
```

### Show or hide the dots

`isDotEnable: false` builds nothing for the indicator, so the carousel takes
only its own height (the `spacing` gap is removed too). Toggle it at runtime
without changing any other option:

```dart
indicator: CarouselIndicatorOptions(isDotEnable: showDots),
```

`SmoothDotIndicator` has the same flag and becomes a `SizedBox.shrink()`.

### Scroll modes

| Mode | Behaviour |
| --- | --- |
| `stepThenSlide` (default) | The active dot moves one slot, then the row slides. Every page change looks the same. |
| `slideWithActive` | The row slides with the active dot, which stays at the edge. |
| `centered` | The active dot stays in the middle and the row slides under it. |

### All style options

`maxVisibleDots`, `dotWidth`, `dotHeight`, `activeDotWidth`,
`activeDotHeight`, `spacing`, `activeColor`, `inactiveColor`,
`activeGradient`, `inactiveGradient`, `borderRadius`, `activeBorder`,
`inactiveBorder`, `activeShadows`, `inactiveShadows`, `duration`, `curve`,
`slideDelay`, `scrollMode`, `edgeDotScale`, `axis`, `dotBuilder`.

### Custom dots

```dart
style: SmoothDotIndicatorStyle(
  dotWidth: 14,
  dotHeight: 14,
  activeDotWidth: 14,
  dotBuilder: (context, index, isActive) => Icon(
    isActive ? Icons.star : Icons.star_border,
    size: 14,
  ),
),
```

Or replace the indicator completely:

```dart
indicator: CarouselIndicatorOptions(
  builder: (context, activeIndex, count) => Text('${activeIndex + 1} / $count'),
),
```

### Use the indicator with any PageView

```dart
SmoothDotIndicator(
  count: 50,
  activeIndex: currentPage,
  onDotTap: (index) => pageController.animateToPage(
    index,
    duration: const Duration(milliseconds: 400),
    curve: Curves.easeInOut,
  ),
)
```

## Example

See the [example](example/lib/main.dart) app for every feature in action.

## License

MIT
