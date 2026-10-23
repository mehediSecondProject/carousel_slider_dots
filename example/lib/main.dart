import 'package:flutter/material.dart';
import 'package:carousel_slider_dots/carousel_slider_dots.dart';

void main() => runApp(const DemoApp());

class DemoApp extends StatelessWidget {
  const DemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Carousel Slider Dots',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo),
      home: const DemoPage(),
    );
  }
}

const List<Color> _colors = [
  Color(0xFF5C6BC0),
  Color(0xFF26A69A),
  Color(0xFFEF5350),
  Color(0xFFFFA726),
  Color(0xFFAB47BC),
  Color(0xFF42A5F5),
];

Widget _card(int index) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 6),
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: _colors[index % _colors.length],
      borderRadius: BorderRadius.circular(16),
    ),
    child: Text(
      'Item $index',
      style: const TextStyle(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

class DemoPage extends StatefulWidget {
  const DemoPage({super.key});

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  final SmoothCarouselController _controller = SmoothCarouselController();
  final PageController _pageController = PageController();
  int _pageViewIndex = 0;
  bool _isDotEnable = true;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _section(String title, Widget child) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Text(title, style: Theme.of(context).textTheme.titleMedium),
          ),
          child,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Carousel Slider Dots')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          _section(
            '100 items · step-then-slide dots',
            Column(
              children: [
                SmoothCarousel.builder(
                  itemCount: 100,
                  itemBuilder: (context, index, realIndex) => _card(index),
                  options: const CarouselOptions(
                    height: 160,
                    enableInfiniteScroll: false,
                  ),
                  indicator: CarouselIndicatorOptions(
                    isDotEnable: _isDotEnable,
                  ),
                ),
                SwitchListTile(
                  title: const Text('isDotEnable'),
                  value: _isDotEnable,
                  onChanged: (value) => setState(() => _isDotEnable = value),
                ),
              ],
            ),
          ),
          _section(
            'Auto play · infinite · enlarged center · dots on the card',
            SmoothCarousel.builder(
              itemCount: 12,
              itemBuilder: (context, index, realIndex) => _card(index),
              options: const CarouselOptions(
                height: 180,
                autoPlay: true,
                autoPlayInterval: Duration(seconds: 2),
                enlargeCenterPage: true,
                enlargeStrategy: CenterPageEnlargeStrategy.zoom,
              ),
              indicator: const CarouselIndicatorOptions(
                position: IndicatorPosition.onItem,
                alignment: Alignment.bottomCenter,
                style: SmoothDotIndicatorStyle(
                  maxVisibleDots: 5,
                  activeColor: Colors.white,
                  inactiveColor: Colors.white54,
                  edgeDotScale: 0.6,
                ),
              ),
            ),
          ),
          _section(
            'Controller · centered dots · gradient',
            Column(
              children: [
                SmoothCarousel.builder(
                  itemCount: 30,
                  controller: _controller,
                  itemBuilder: (context, index, realIndex) => _card(index),
                  options: const CarouselOptions(
                    height: 140,
                    viewportFraction: 0.9,
                  ),
                  indicator: const CarouselIndicatorOptions(
                    style: SmoothDotIndicatorStyle(
                      scrollMode: DotScrollMode.centered,
                      dotWidth: 9,
                      dotHeight: 9,
                      activeDotWidth: 26,
                      activeGradient: LinearGradient(
                        colors: [Colors.purple, Colors.orange],
                      ),
                      edgeDotScale: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () => _controller.previousPage(),
                    ),
                    TextButton(
                      onPressed: () => _controller.animateToPage(0),
                      child: const Text('First'),
                    ),
                    TextButton(
                      onPressed: () => _controller.animateToPage(29),
                      child: const Text('Last'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: () => _controller.nextPage(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _section(
            'Vertical carousel · vertical dots on the right',
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SmoothCarousel.builder(
                itemCount: 20,
                itemBuilder: (context, index, realIndex) => _card(index),
                options: const CarouselOptions(
                  height: 220,
                  scrollDirection: Axis.vertical,
                  viewportFraction: 0.7,
                  enlargeCenterPage: true,
                ),
                indicator: const CarouselIndicatorOptions(
                  position: IndicatorPosition.right,
                  style: SmoothDotIndicatorStyle(axis: Axis.vertical),
                ),
              ),
            ),
          ),
          _section(
            'Custom dot builder',
            SmoothCarousel.builder(
              itemCount: 15,
              itemBuilder: (context, index, realIndex) => _card(index),
              options: const CarouselOptions(height: 120),
              indicator: CarouselIndicatorOptions(
                style: SmoothDotIndicatorStyle(
                  dotWidth: 14,
                  dotHeight: 14,
                  activeDotWidth: 14,
                  spacing: 8,
                  dotBuilder: (context, index, isActive) => Icon(
                    isActive ? Icons.star : Icons.star_border,
                    size: 14,
                    color: Colors.amber,
                  ),
                ),
              ),
            ),
          ),
          _section(
            'Indicator alone with a regular PageView',
            Column(
              children: [
                SizedBox(
                  height: 120,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: 50,
                    onPageChanged: (index) =>
                        setState(() => _pageViewIndex = index),
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _card(index),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SmoothDotIndicator(
                  count: 50,
                  activeIndex: _pageViewIndex,
                  onDotTap: (index) => _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
