import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/navigation_provider.dart';
import '../widgets/custom_bottom_nav.dart';
import 'manage_screen.dart';
import 'sell_screen.dart';
import 'summary_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final PageController _pageController;

  static const _screens = [SellScreen(), SummaryScreen(), ManageScreen()];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationProvider>(
      builder: (context, nav, _) {
        if (_pageController.hasClients &&
            _pageController.page?.round() != nav.currentIndex) {
          _pageController.animateToPage(
            nav.currentIndex,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
          );
        }

        return Scaffold(
          body: PageView(
            controller: _pageController,
            onPageChanged: nav.setIndex,
            children: _screens,
          ),
          bottomNavigationBar: const CustomBottomNav(),
        );
      },
    );
  }
}
