import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../res/colors.dart';
import '../../res/theme.dart';

enum Type {
  buy,
  move;
}

class CustomViewPager<T> extends StatelessWidget {
  final _boxHeight = 130.0;
  final _pageController = PageController();
  final _currentPageNotifier = ValueNotifier<int>(0);

  // icon 에 맞는 타입을 지정
  final Type type;

  // 리스트 정보
  final List<PageItem<T>> items;

  // click event. 커스텀 Funtion
  final Function(T) onPressed;

  // 해당 카드뷰의 타이틀 지정
  final String title;

  CustomViewPager({
    Key? key,
    required this.title,
    required this.items,
    required this.type,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = <Widget>[];
    children.add(_buildTitleView());

    if (items.isEmpty) {
      children.add(_buildEmptyView());
    } else {
      children.add(_buildPageView());
      children.add(_buildPageIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  _buildTitleView() {
    return Container(
        margin: const EdgeInsets.only(bottom: 10),
        child: Text(title, style: AppThemes.titleTextTheme));
  }

  _buildEmptyView() {
    return SizedBox(
      height: _boxHeight + 8.0,
      child: const Center(
        child:
            Text('No items', style: TextStyle(color: AppColors.secondaryText)),
      ),
    );
  }

  _buildPageView() {
    return SizedBox(
      height: _boxHeight,
      child: PageView.builder(
          itemCount: items.length,
          itemBuilder: (BuildContext context, int index) {
            return SizedBox(
                width: double.infinity, child: _buildPageItemView(index));
          },
          controller: _pageController,
          onPageChanged: (int index) {
            _currentPageNotifier.value = index;
          }),
    );
  }

  _buildPageItemView(int index) {
    final PageItem item = items[index];
    final borderRadius = BorderRadius.circular(10.0);
    return Card(
        shape: RoundedRectangleBorder(borderRadius: borderRadius),
        child: InkWell(
          onTap: () => onPressed(item.data),
          borderRadius: borderRadius,
          child: Center(
            child: ListTile(
              title: Text(item.title, style: AppThemes.titleTextTheme),
              subtitle: Text(
                item.description,
                style: AppThemes.bodyPrimaryTextTheme,
              ),
              trailing: type == Type.buy
                  ? const Icon(Icons.shopping_cart_outlined,
                      color: AppColors.primaryColor)
                  : const Icon(Icons.keyboard_arrow_right,
                      color: AppColors.primaryColor),
            ),
          ),
        ));
  }

  _buildPageIndicator() {
    return Container(
        margin: const EdgeInsets.only(top: 10),
        width: double.infinity,
        alignment: Alignment.center,
        child: SmoothPageIndicator(
            controller: _pageController,
            count: items.length,
            effect: const ScrollingDotsEffect(
              activeDotColor: AppColors.primaryColor,
              activeStrokeWidth: 10,
              activeDotScale: 1.7,
              maxVisibleDots: 5,
              radius: 8,
              spacing: 10,
              dotHeight: 5,
              dotWidth: 5,
            )));
  }
}

class PageItem<T> {
  PageItem(
      {required this.title, required this.description, required this.data});

  final String title;
  final String description;
  final T data;
}
