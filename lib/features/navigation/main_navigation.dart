import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/constants/app_colors.dart';
import '../favorite/favorite_screen.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';
import '../search/search_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int index = 0;

  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();

    pages = [
      HomeScreen(
        onChangeTab: (value) {
          setState(() {
            if (value < 0) {
              index = 0;
            } else if (value > 3) {
              index = 3;
            } else {
              index = value;
            }
          });
        },
      ),
      const SearchScreen(),
      const FavoriteScreen(),
      const ProfileScreen(),
    ];
  }

  void changeTab(int value) {
    setState(() {
      index = value;
    });
  }

  void openAi() {
    Navigator.pushNamed(
      context,
      AppRoutes.aiRecommendation,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: pages[index],
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          height: 92,
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
          decoration: BoxDecoration(
            color: AppColors.paper,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(26),
            ),
            border: Border(
              top: BorderSide(
                color: AppColors.spiceBrown.withOpacity(0.24),
                width: 2,
              ),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 16,
                offset: Offset(0, -6),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: _BottomItem(
                  label: 'Beranda',
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home_rounded,
                  selected: index == 0,
                  onTap: () => changeTab(0),
                ),
              ),
              Expanded(
                child: _BottomItem(
                  label: 'Peta',
                  icon: Icons.map_outlined,
                  selectedIcon: Icons.map_rounded,
                  selected: index == 1,
                  onTap: () => changeTab(1),
                ),
              ),
              _AiButton(
                onTap: openAi,
              ),
              Expanded(
                child: _BottomItem(
                  label: 'Favorit',
                  icon: Icons.favorite_border_rounded,
                  selectedIcon: Icons.favorite_rounded,
                  selected: index == 2,
                  onTap: () => changeTab(2),
                ),
              ),
              Expanded(
                child: _BottomItem(
                  label: 'Profil',
                  icon: Icons.person_outline_rounded,
                  selectedIcon: Icons.person_rounded,
                  selected: index == 3,
                  onTap: () => changeTab(3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AiButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AiButton({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 58,
      height: double.infinity,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: AppColors.ribbonGradient,
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                border: Border.all(
                  color: Colors.white,
                  width: 2.2,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x22000000),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'AI',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.spiceBrown,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final bool selected;
  final VoidCallback onTap;

  const _BottomItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.spiceBrown : AppColors.muted;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(
          horizontal: 2,
          vertical: 5,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.cream : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: selected
              ? Border.all(
                  color: AppColors.spiceBrown.withOpacity(0.22),
                  width: 1.2,
                )
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected ? selectedIcon : icon,
              color: color,
              size: selected ? 24 : 22,
            ),
            const SizedBox(height: 3),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 10.5,
                  fontWeight: selected ? FontWeight.w900 : FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}