import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../app/routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/time_converter.dart';
import '../../core/widgets/empty_state.dart';
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
    if (userId == null) return;

    // Bersihkan jadwal yang sudah lewat dari DB
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
    await NotificationService.instance.cancel(schedule.recipeId);
    await repository.deleteSchedule(schedule.id!);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 18, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Favorit & Rencana',
                      style: TextStyle(fontSize: 27, fontWeight: FontWeight.w900, color: AppColors.ink, letterSpacing: -0.5)),
                  SizedBox(height: 8),
                  Text('Simpan resep pilihan dan jadwal memasakmu.',
                      style: TextStyle(color: AppColors.muted, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: AppColors.cream, borderRadius: BorderRadius.circular(22)),
                child: TabBar(
                  controller: tabController,
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerHeight: 0,
                  indicator: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
                  labelColor: AppColors.spiceBrown,
                  unselectedLabelColor: AppColors.muted,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w900),
                  tabs: const [Tab(text: 'Favorit'), Tab(text: 'Jadwal')],
                ),
              ),
            ),
            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      controller: tabController,
                      children: [
                        // Tab Favorit
                        favorites.isEmpty
                            ? const EmptyState(
                                title: 'Belum ada favorit',
                                message: 'Tambahkan resep favorit dari halaman detail resep.')
                            : RefreshIndicator(
                                onRefresh: _load,
                                child: ListView.builder(
                                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                                  itemCount: favorites.length,
                                  itemBuilder: (_, index) {
                                    final recipe = favorites[index];
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: RecipeCard(
                                        recipe: recipe,
                                        favorite: true,
                                        onFavorite: () => _removeFavorite(recipe),
                                        onTap: () => Navigator.pushNamed(
                                          context, AppRoutes.detail, arguments: recipe,
                                        ).then((_) => _load()),
                                      ),
                                    );
                                  },
                                ),
                              ),
                        // Tab Jadwal
                        schedules.isEmpty
                            ? const EmptyState(
                                title: 'Belum ada jadwal',
                                message: 'Tekan Mulai Masak di detail resep untuk membuat jadwal.')
                            : RefreshIndicator(
                                onRefresh: _load,
                                child: ListView.builder(
                                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
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

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isUrgent ? AppColors.terracotta.withValues(alpha: 0.4) : AppColors.line,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 62, height: 62,
                  decoration: BoxDecoration(
                    color: isUrgent
                        ? AppColors.terracotta.withValues(alpha: 0.1)
                        : AppColors.cream,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Center(child: Text(recipe?.emoji ?? '🍲', style: const TextStyle(fontSize: 30))),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe?.name ?? 'Resep',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.ink),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        date == null
                            ? schedule.cookingTime
                            : DateFormat('EEEE, dd MMM yyyy • HH:mm').format(date!),
                        style: const TextStyle(color: AppColors.muted, fontWeight: FontWeight.w600, fontSize: 12.5),
                      ),
                      const SizedBox(height: 8),
                      // Label notifikasi dinamis
                      Row(children: [
                        Icon(
                          isUrgent ? Icons.notifications_active_rounded : Icons.notifications_outlined,
                          size: 15,
                          color: isUrgent ? AppColors.terracotta : AppColors.muted,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isUrgent ? 'Kurang dari 2 jam lagi!' : 'Notifikasi terjadwal',
                          style: TextStyle(
                            color: isUrgent ? AppColors.terracotta : AppColors.muted,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ]),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.muted),
                ),
              ],
            ),
          ),
          // Konversi waktu — ini barulah berguna karena menunjukkan waktu jadwal di 4 zona
          if (timeZones != null) ...[
            Divider(height: 1, color: AppColors.line),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: timeZones.entries.map((e) => Expanded(
                  child: Column(
                    children: [
                      Text(e.key, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.spiceBrown)),
                      const SizedBox(height: 2),
                      Text(e.value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.ink)),
                    ],
                  ),
                )).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}