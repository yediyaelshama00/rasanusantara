import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app/routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/time_converter.dart';
import '../../core/widgets/recipe_card.dart';
import '../../data/local/session_helper.dart';
import '../../data/models/cooking_schedule_model.dart';
import '../../data/models/recipe_model.dart';
import '../../data/repositories/recipe_repository.dart';
import '../../data/services/notification_service.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen>
    with SingleTickerProviderStateMixin {
  final repository = RecipeRepository();

  late final TabController tabController;

  List<Recipe> favorites = [];
  List<CookingSchedule> schedules = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final userId = await SessionHelper.instance.getUserId();

    if (userId == null) {
      if (!mounted) return;

      setState(() {
        favorites = [];
        schedules = [];
        loading = false;
      });

      return;
    }

    await repository.cleanupExpiredSchedules(userId);

    final fav = await repository.getFavoriteRecipes(userId);
    final scheduleData = await repository.getSchedules(userId);

    if (!mounted) return;

    setState(() {
      favorites = fav;
      schedules = scheduleData;
      loading = false;
    });
  }

  Future<void> _removeFavorite(Recipe recipe) async {
    final userId = await SessionHelper.instance.getUserId();

    if (userId == null || recipe.id == null) return;

    await repository.toggleFavorite(userId, recipe.id!);
    await _load();
  }

  Future<void> _deleteSchedule(CookingSchedule schedule) async {
    if (schedule.id == null) return;

    await NotificationService.instance.cancel(schedule.recipeId);
    await repository.deleteSchedule(schedule.id!);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
              child: Column(
                children: [
                  const _TopTitle(),
                  const SizedBox(height: 16),
                  _HeaderPanel(
                    favoriteCount: favorites.length,
                    scheduleCount: schedules.length,
                  ),
                  const SizedBox(height: 22),
                  _GameTabBar(controller: tabController),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: loading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.ivory,
                      ),
                    )
                  : TabBarView(
                      controller: tabController,
                      children: [
                        _buildFavoriteTab(),
                        _buildScheduleTab(),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteTab() {
    if (favorites.isEmpty) {
      return const Padding(
        padding: EdgeInsets.fromLTRB(18, 10, 18, 28),
        child: _EmptyGamePanel(
          label: 'Favorit',
          icon: Icons.favorite_border_rounded,
          title: 'Belum ada favorit',
          message: 'Tambahkan resep favorit dari halaman detail resep.',
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      color: AppColors.spiceBrown,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
        itemCount: favorites.length,
        itemBuilder: (_, index) {
          final recipe = favorites[index];

          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _RecipePanelWrapper(
              child: RecipeCard(
                recipe: recipe,
                favorite: true,
                onFavorite: () => _removeFavorite(recipe),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.detail,
                    arguments: recipe,
                  ).then((_) => _load());
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildScheduleTab() {
    if (schedules.isEmpty) {
      return const Padding(
        padding: EdgeInsets.fromLTRB(18, 10, 18, 28),
        child: _EmptyGamePanel(
          label: 'Jadwal',
          icon: Icons.event_available_rounded,
          title: 'Belum ada jadwal',
          message: 'Tekan Mulai Masak di detail resep untuk membuat jadwal.',
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      color: AppColors.spiceBrown,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
        itemCount: schedules.length,
        itemBuilder: (_, index) {
          final item = schedules[index];
          final date = DateTime.tryParse(item.cookingTime);

          return _ScheduleCard(
            schedule: item,
            date: date,
            onDelete: () => _deleteSchedule(item),
          );
        },
      ),
    );
  }
}

class _TopTitle extends StatelessWidget {
  const _TopTitle();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Rencana Masak',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.darkBrown,
          fontSize: 31,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.8,
        ),
      ),
    );
  }
}

class _HeaderPanel extends StatelessWidget {
  final int favoriteCount;
  final int scheduleCount;

  const _HeaderPanel({
    required this.favoriteCount,
    required this.scheduleCount,
  });

  @override
  Widget build(BuildContext context) {
    return _GamePanel(
      label: 'Koleksi Saya',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 36, 18, 18),
        child: Row(
          children: [
            Container(
              width: 66,
              height: 66,
              decoration: BoxDecoration(
                color: AppColors.cream,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.spiceBrown,
                  width: 2.4,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x24000000),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(
                Icons.favorite_rounded,
                color: AppColors.spiceBrown,
                size: 34,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Resep pilihanmu tersimpan di sini',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.ink,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    '$favoriteCount favorit • $scheduleCount jadwal masak',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontWeight: FontWeight.w800,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GameTabBar extends StatelessWidget {
  final TabController controller;

  const _GameTabBar({
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.spiceBrown,
          width: 2.4,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: TabBar(
        controller: controller,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerHeight: 0,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.spiceBrown,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 13,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 13,
        ),
        indicator: BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.ribbonGradient,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(19),
          border: Border.all(
            color: AppColors.ribbonShadow,
            width: 1.2,
          ),
        ),
        tabs: const [
          Tab(
            icon: Icon(Icons.favorite_rounded, size: 19),
            text: 'Favorit',
          ),
          Tab(
            icon: Icon(Icons.event_note_rounded, size: 19),
            text: 'Jadwal',
          ),
        ],
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final CookingSchedule schedule;
  final DateTime? date;
  final VoidCallback onDelete;

  const _ScheduleCard({
    required this.schedule,
    required this.date,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final recipe = schedule.recipe;
    final now = DateTime.now();

    final isUrgent = date != null && date!.difference(now).inHours < 2;
    final timeZones = date != null ? TimeConverter.convertShort(date!) : null;

    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.paper,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isUrgent ? AppColors.terracotta : AppColors.spiceBrown,
            width: 2.5,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x24000000),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: -14,
              left: 14,
              right: 14,
              child: _Ribbon(
                label: isUrgent ? 'Segera Masak' : 'Jadwal Masak',
                danger: isUrgent,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 32, 16, 14),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: isUrgent
                              ? AppColors.terracotta.withOpacity(0.13)
                              : AppColors.cream,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isUrgent
                                ? AppColors.terracotta
                                : AppColors.spiceBrown,
                            width: 2.2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            recipe?.emoji ?? '🍲',
                            style: const TextStyle(fontSize: 31),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              recipe?.name ?? 'Resep',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                                color: AppColors.ink,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              date == null
                                  ? schedule.cookingTime
                                  : DateFormat('EEEE, dd MMM yyyy • HH:mm')
                                      .format(date!),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.muted,
                                fontWeight: FontWeight.w700,
                                fontSize: 12.5,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  isUrgent
                                      ? Icons.notifications_active_rounded
                                      : Icons.notifications_outlined,
                                  size: 15,
                                  color: isUrgent
                                      ? AppColors.terracotta
                                      : AppColors.muted,
                                ),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    isUrgent
                                        ? 'Kurang dari 2 jam lagi!'
                                        : 'Notifikasi terjadwal',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: isUrgent
                                          ? AppColors.terracotta
                                          : AppColors.muted,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      _DeleteButton(onTap: onDelete),
                    ],
                  ),
                  if (timeZones != null) ...[
                    const SizedBox(height: 14),
                    Divider(
                      height: 1,
                      thickness: 1.4,
                      color: AppColors.spiceBrown.withOpacity(0.20),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: timeZones.entries.map((entry) {
                        return Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.cream,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: AppColors.spiceBrown.withOpacity(0.22),
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  entry.key,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.spiceBrown,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  entry.value,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.ink,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeleteButton extends StatelessWidget {
  final VoidCallback onTap;

  const _DeleteButton({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.terracotta.withOpacity(0.12),
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.terracotta.withOpacity(0.55),
            width: 1.8,
          ),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: AppColors.terracotta,
          size: 22,
        ),
      ),
    );
  }
}

class _RecipePanelWrapper extends StatelessWidget {
  final Widget child;

  const _RecipePanelWrapper({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: AppColors.spiceBrown,
          width: 2.4,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _EmptyGamePanel extends StatelessWidget {
  final String label;
  final IconData icon;
  final String title;
  final String message;

  const _EmptyGamePanel({
    required this.label,
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return _GamePanel(
      label: label,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 52, 18, 36),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 74,
              height: 74,
              decoration: BoxDecoration(
                color: AppColors.cream,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.spiceBrown,
                  width: 2.4,
                ),
              ),
              child: Icon(
                icon,
                color: AppColors.spiceBrown,
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.ink,
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.muted,
                fontWeight: FontWeight.w800,
                height: 1.45,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GamePanel extends StatelessWidget {
  final String label;
  final Widget child;

  const _GamePanel({
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.paper,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: AppColors.spiceBrown,
            width: 2.8,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x26000000),
              blurRadius: 14,
              offset: Offset(0, 7),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            child,
            Positioned(
              top: -15,
              left: 14,
              right: 14,
              child: _Ribbon(label: label),
            ),
          ],
        ),
      ),
    );
  }
}

class _Ribbon extends StatelessWidget {
  final String label;
  final bool danger;

  const _Ribbon({
    required this.label,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(minWidth: 112),
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 7,
        ),
        decoration: BoxDecoration(
          gradient: danger
              ? const LinearGradient(
                  colors: [
                    AppColors.terracotta,
                    AppColors.danger,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )
              : LinearGradient(
                  colors: AppColors.ribbonGradient,
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: danger ? AppColors.danger : AppColors.ribbonShadow,
            width: 1.2,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x24000000),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}