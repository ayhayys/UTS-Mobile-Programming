import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import 'home_page.dart';
import 'matches_page.dart';
import 'placeholder_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const _items = [
    _NavItem('Home', Icons.home_rounded, Icons.home_outlined),
    _NavItem('Matches', Icons.sports_soccer_rounded, Icons.sports_soccer_outlined),
    _NavItem('Following', Icons.star_rounded, Icons.star_border_rounded),
    _NavItem('News', Icons.newspaper_rounded, Icons.newspaper_outlined),
    _NavItem('Profile', Icons.person_rounded, Icons.person_outline_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomePage(onViewAll: () => setState(() => _index = 1)),
      const MatchesPage(),
      const PlaceholderPage(title: 'Following', icon: Icons.star_border_rounded),
      const PlaceholderPage(title: 'News', icon: Icons.newspaper_outlined),
      const PlaceholderPage(title: 'Profile', icon: Icons.person_outline_rounded),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          margin: const EdgeInsets.fromLTRB(14, 0, 14, 10),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(24),
                blurRadius: 18,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              for (var i = 0; i < _items.length; i++)
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _index = i),
                    borderRadius: BorderRadius.circular(18),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            i == _index ? _items[i].activeIcon : _items[i].icon,
                            size: 26,
                            color: i == _index ? AppColors.accent : AppColors.ink,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _items[i].label,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight:
                                  i == _index ? FontWeight.w800 : FontWeight.w500,
                              color: i == _index
                                  ? AppColors.accent
                                  : AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final String label;
  final IconData activeIcon;
  final IconData icon;
  const _NavItem(this.label, this.activeIcon, this.icon);
}
