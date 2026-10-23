## 1.0.1

* Renamed the example app package id to `com.carousel`.

## 1.0.0

* Initial release.
* `SmoothCarousel` and `SmoothCarousel.builder` with auto play, infinite
  scroll, enlarged center page (scale, height and zoom strategies), vertical
  direction, reverse, page snapping, custom physics and touch / manual pause.
* `SmoothCarouselController` with next, previous, jump, animate and
  start / stop auto play.
* `SmoothDotIndicator` with a limited window of dots that slides smoothly,
  three scroll modes, edge dot scaling, gradients, borders, shadows,
  vertical axis, tap to navigate and a custom dot builder.
* Indicator placement below, above, left, right, over the whole carousel or
  on the current card (`IndicatorPosition.onItem`) with any alignment.
* `isDotEnable` on `CarouselIndicatorOptions` and `SmoothDotIndicator` to
  hide the dots and remove their space.
