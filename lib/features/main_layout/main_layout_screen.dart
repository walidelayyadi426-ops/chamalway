import 'package:flutter/material.dart';
import '../../core/widgets/custom_bottom_nav.dart';
import '../home/home_screen.dart';
import '../search/search_screen.dart';
import '../favorites/favorites_screen.dart';
import '../profile/profile_screen.dart';

class MainLayoutScreen extends StatefulWidget {
  final int initialIndex;

  const MainLayoutScreen({super.key, this.initialIndex = 0});

  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen> {
  late int _currentIndex;

  final List<Widget> _screens = const [
    HomeScreen(),
    SearchScreen(),
    FavoritesScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
