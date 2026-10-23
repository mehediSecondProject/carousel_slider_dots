import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:carousel_slider_dots/carousel_slider_dots.dart';

Widget _wrap(Widget child) => MaterialApp(
  home: Scaffold(
    body: Center(child: SizedBox(width: 400, child: child)),
  ),
);

// Left edge of a dot, relative to the indicator.
double _dotLeft(WidgetTester tester, int index) {
  final Finder indicator = find.byType(SmoothDotIndicator);
  final Finder dot = find.descendant(
    of: indicator,
    matching: find.byKey(ValueKey<int>(index)),
  );
  return tester.getTopLeft(dot).dx - tester.getTopLeft(indicator).dx;
}

void main() {
  group('SmoothDotIndicator', () {
    const SmoothDotIndicatorStyle style = SmoothDotIndicatorStyle(
      maxVisibleDots: 5,
      dotWidth: 10,
      activeDotWidth: 20,
      spacing: 0,
    );

    Widget indicator(int active, {SmoothDotIndicatorStyle s = style}) => _wrap(
      Center(
        child: SmoothDotIndicator(count: 20, activeIndex: active, style: s),
      ),
    );

    testWidgets('sizes itself to the visible dots', (tester) async {
      await tester.pumpWidget(indicator(0));
      // 5 dots of 10 plus 10 extra for the active one.
      expect(tester.getSize(find.byType(SmoothDotIndicator)).width, 60);
    });

    testWidgets('stepThenSlide moves the dot, then slides the row', (
      tester,
    ) async {
      await tester.pumpWidget(indicator(3));
      await tester.pumpAndSettle();
      expect(_dotLeft(tester, 3), 30); // slot 3, row not moved

      await tester.pumpWidget(indicator(4));
      await tester.pump(const Duration(milliseconds: 310));
      // Step: the active dot reached the last slot.
      expect(_dotLeft(tester, 4), 40);

      await tester.pumpAndSettle();
      // Slide: one free slot is kept ahead of the active dot.
      expect(_dotLeft(tester, 4), 30);
    });

    testWidgets('slideWithActive pins the dot to the last slot', (
      tester,
    ) async {
      const s = SmoothDotIndicatorStyle(
        maxVisibleDots: 5,
        dotWidth: 10,
        activeDotWidth: 20,
        spacing: 0,
        scrollMode: DotScrollMode.slideWithActive,
      );
      await tester.pumpWidget(indicator(10, s: s));
      await tester.pumpAndSettle();
      expect(_dotLeft(tester, 10), 40);
    });

    testWidgets('centered keeps the active dot in the middle', (tester) async {
      const s = SmoothDotIndicatorStyle(
        maxVisibleDots: 5,
        dotWidth: 10,
        activeDotWidth: 20,
        spacing: 0,
        scrollMode: DotScrollMode.centered,
      );
      await tester.pumpWidget(indicator(10, s: s));
      await tester.pumpAndSettle();
      expect(_dotLeft(tester, 10), 20);
    });

    testWidgets('last page puts the active dot in the last slot', (
      tester,
    ) async {
      await tester.pumpWidget(indicator(19));
      await tester.pumpAndSettle();
      expect(_dotLeft(tester, 19), 40);
    });

    testWidgets('isDotEnable false takes no space', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const Center(
            child: SmoothDotIndicator(
              count: 5,
              activeIndex: 0,
              isDotEnable: false,
            ),
          ),
        ),
      );
      expect(tester.getSize(find.byType(SmoothDotIndicator)), Size.zero);
      expect(find.byType(AnimatedPositioned), findsNothing);
    });

    testWidgets('reports dot taps', (tester) async {
      int? tapped;
      await tester.pumpWidget(
        _wrap(
          SmoothDotIndicator(
            count: 5,
            activeIndex: 0,
            style: const SmoothDotIndicatorStyle(dotWidth: 20, dotHeight: 20),
            onDotTap: (index) => tapped = index,
          ),
        ),
      );
      await tester.tap(find.byKey(const ValueKey<int>(3)));
      expect(tapped, 3);
    });
  });

  group('SmoothCarousel', () {
    Widget carousel({
      SmoothCarouselController? controller,
      CarouselOptions options = const CarouselOptions(height: 100),
      CarouselPageChangedCallback? onChanged,
    }) {
      return _wrap(
        SmoothCarousel.builder(
          itemCount: 5,
          controller: controller,
          itemBuilder: (context, index, realIndex) => Text('Item $index'),
          options: options.copyWith(onPageChanged: onChanged),
          indicator: const CarouselIndicatorOptions(),
        ),
      );
    }

    testWidgets('isDotEnable false removes the indicator and its spacing', (
      tester,
    ) async {
      Widget build(bool enabled) => _wrap(
        SmoothCarousel.builder(
          itemCount: 5,
          itemBuilder: (context, index, realIndex) => Text('Item $index'),
          options: const CarouselOptions(height: 100),
          indicator: CarouselIndicatorOptions(isDotEnable: enabled),
        ),
      );

      await tester.pumpWidget(build(true));
      expect(find.byType(SmoothDotIndicator), findsOneWidget);
      expect(tester.getSize(find.byType(SmoothCarousel)).height, 119);

      await tester.pumpWidget(build(false));
      expect(find.byType(SmoothDotIndicator), findsNothing);
      expect(tester.getSize(find.byType(SmoothCarousel)).height, 100);
    });

    testWidgets('onItem places the dots inside the current page', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          SmoothCarousel.builder(
            itemCount: 5,
            itemBuilder: (context, index, realIndex) => Text('Item $index'),
            // 400 wide, page = 0.5 * 400 = 200, centered: x 100..300.
            options: const CarouselOptions(height: 100, viewportFraction: 0.5),
            indicator: const CarouselIndicatorOptions(
              position: IndicatorPosition.onItem,
              alignment: Alignment.bottomRight,
              spacing: 10,
            ),
          ),
        ),
      );
      final Rect carousel = tester.getRect(find.byType(SmoothCarousel));
      final Rect dots = tester.getRect(find.byType(SmoothDotIndicator));
      expect(carousel.height, 100);
      expect(dots.right - carousel.left, 290);
      expect(carousel.bottom - dots.bottom, 10);
    });

    testWidgets('right position honours the vertical alignment', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          SmoothCarousel.builder(
            itemCount: 5,
            itemBuilder: (context, index, realIndex) => Text('Item $index'),
            options: const CarouselOptions(height: 100),
            indicator: const CarouselIndicatorOptions(
              position: IndicatorPosition.right,
              alignment: Alignment.topRight,
              style: SmoothDotIndicatorStyle(axis: Axis.vertical),
            ),
          ),
        ),
      );
      final Rect carousel = tester.getRect(find.byType(SmoothCarousel));
      final Rect dots = tester.getRect(find.byType(SmoothDotIndicator));
      expect(dots.top, carousel.top);
    });

    testWidgets('builds pages and the indicator', (tester) async {
      await tester.pumpWidget(carousel());
      expect(find.text('Item 0'), findsOneWidget);
      expect(find.byType(SmoothDotIndicator), findsOneWidget);
    });

    testWidgets('controller navigation reports the controller reason', (
      tester,
    ) async {
      final controller = SmoothCarouselController();
      final reasons = <CarouselPageChangedReason>[];
      final pages = <int>[];
      await tester.pumpWidget(
        carousel(
          controller: controller,
          onChanged: (index, reason) {
            pages.add(index);
            reasons.add(reason);
          },
        ),
      );

      controller.nextPage();
      await tester.pumpAndSettle();
      expect(controller.currentIndex, 1);

      controller.animateToPage(4);
      await tester.pumpAndSettle();
      expect(controller.currentIndex, 4);
      expect(pages.last, 4);
      expect(reasons.toSet(), {CarouselPageChangedReason.controller});
    });

    testWidgets('infinite scroll wraps from the last to the first page', (
      tester,
    ) async {
      final controller = SmoothCarouselController();
      await tester.pumpWidget(
        carousel(
          controller: controller,
          options: const CarouselOptions(height: 100, initialPage: 4),
        ),
      );
      controller.nextPage();
      await tester.pumpAndSettle();
      expect(controller.currentIndex, 0);
    });

    testWidgets('finite carousel stops at the last page', (tester) async {
      final controller = SmoothCarouselController();
      await tester.pumpWidget(
        carousel(
          controller: controller,
          options: const CarouselOptions(
            height: 100,
            initialPage: 4,
            enableInfiniteScroll: false,
          ),
        ),
      );
      controller.nextPage();
      await tester.pumpAndSettle();
      expect(controller.currentIndex, 4);
    });

    testWidgets('auto play advances with the timed reason', (tester) async {
      final reasons = <CarouselPageChangedReason>[];
      await tester.pumpWidget(
        carousel(
          options: const CarouselOptions(
            height: 100,
            autoPlay: true,
            autoPlayInterval: Duration(seconds: 1),
          ),
          onChanged: (index, reason) => reasons.add(reason),
        ),
      );
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(reasons, [CarouselPageChangedReason.timed]);

      // Dispose to cancel the periodic timer.
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('user swipe reports the manual reason', (tester) async {
      final reasons = <CarouselPageChangedReason>[];
      await tester.pumpWidget(
        carousel(onChanged: (index, reason) => reasons.add(reason)),
      );
      await tester.fling(find.byType(PageView), const Offset(-300, 0), 1000);
      await tester.pumpAndSettle();
      expect(reasons, [CarouselPageChangedReason.manual]);
    });
    testWidgets('keeps the page when the indicator position changes', (
      tester,
    ) async {
      final controller = SmoothCarouselController();
      Widget build(IndicatorPosition position) => _wrap(
        SmoothCarousel.builder(
          itemCount: 5,
          controller: controller,
          itemBuilder: (context, index, realIndex) => Text('Item $index'),
          options: const CarouselOptions(height: 100),
          indicator: CarouselIndicatorOptions(position: position),
        ),
      );

      await tester.pumpWidget(build(IndicatorPosition.bottom));
      controller.jumpToPage(3);
      await tester.pumpAndSettle();

      await tester.pumpWidget(build(IndicatorPosition.right));
      await tester.pumpAndSettle();
      expect(controller.currentIndex, 3);
      expect(find.text('Item 3'), findsOneWidget);
    });
  });
}
