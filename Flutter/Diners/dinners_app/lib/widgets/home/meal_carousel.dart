import 'package:flutter/material.dart';
import 'meal_card.dart';
import 'package:intl/intl.dart';

class MealCarousel extends StatefulWidget {
  final DateTime baseDate;

  const MealCarousel({
    super.key,
    required this.baseDate,
    required this.getMealsForDate,
  });
  final Map<String, String> Function(DateTime) getMealsForDate;

  

  @override
  State<MealCarousel> createState() => _MealCarouselState();
}

class _MealCarouselState extends State<MealCarousel>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  double _currentPage = 0.0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.9, initialPage: 7);
    _currentPage = 7.0;

    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page ?? _currentPage;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  DateTime getDateFromIndex(int index) {
    return widget.baseDate.add(Duration(days: index - 7));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 250,
          child: PageView.builder(
            controller: _pageController,
            itemCount: 15,
            itemBuilder: (context, index) {
              final date = getDateFromIndex(index);
              final meals = widget.getMealsForDate(date);
              final formattedDate = DateFormat.yMMMMEEEEd('fr_FR').format(date);

              return MealCard(
                date: formattedDate,
                lunch: meals['midi']?.isNotEmpty == true ? meals['midi']! : '-',
                dinner: meals['soir']?.isNotEmpty == true ? meals['soir']! : '-',
              );
            },
          ),
        ),
        const SizedBox(height: 1),
        SizedBox(
          height: 40,
          width: 160,
          child: AnimatedBuilder(
            animation: _pageController,
            builder: (context, child) {
              double progress = _currentPage - _currentPage.floor();

              return Stack(
                children: List.generate(7, (i) {
                  final double baseOffset = i.toDouble();
                  final double position = baseOffset - progress;
                  final double translateX = (position - 3) * 20;
                  final double distance = (position - 3).abs();
                  final double scale = 1.0 - distance.clamp(0.0, 1.0) * 0.4;

                  double opacity;
                  if (distance <= 1.0) {
                    opacity = 0.75 + (1.0 - distance) * 0.25;
                  } else if (distance <= 2.0) {
                    opacity = 0.5 * (2.0 - distance);
                  } else {
                    opacity = 0.0;
                  }

                  return Positioned(
                    left: 60 + translateX,
                    top: 12,
                    child: Opacity(
                      opacity: opacity.clamp(0.0, 1.0),
                      child: Transform.scale(
                        scale: scale,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              );
            },
          ),
        ),
      ],
    );
  }
}
