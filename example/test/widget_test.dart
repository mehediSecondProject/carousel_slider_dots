import 'package:flutter_test/flutter_test.dart';

import 'package:carousel_slider_dots_example/main.dart';

void main() {
  testWidgets('demo app builds', (tester) async {
    await tester.pumpWidget(const DemoApp());
    expect(find.text('Carousel Slider Dots'), findsOneWidget);
  });
}
