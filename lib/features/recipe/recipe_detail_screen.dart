import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_converter.dart';
import '../../core/widgets/primary_button.dart';
import '../../data/local/session_helper.dart';
import '../../data/models/recipe_model.dart';
import '../../data/repositories/recipe_repository.dart';
import '../../data/services/notification_service.dart';

class RecipeDetailScreen extends StatefulWidget {
  const RecipeDetailScreen({super.key});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  final repository = RecipeRepository();
  bool favorite = false;
  int? userId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadFavorite();
  }

  Recipe get recipe => ModalRoute.of(context)!.settings.arguments as Recipe;

  Future<void> _loadFavorite() async {
    final id = await SessionHelper.instance.getUserId();
    if (id == null || recipe.id == null) return;
    final isFav = await repository.isFavorite(id, recipe.id!);
    if (!mounted) return;
    setState(() {
      userId = id;
      favorite = isFav;
    });
  }

  Future<void> _toggleFavorite() async {
    if (userId == null || recipe.id == null) return;
    await repository.toggleFavorite(userId!, recipe.id!);
    await _loadFavorite();
  }

  Future<void> _pickSchedule() async {
    final now = DateTime.now();

    final date = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      initialDate: now,
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null || !mounted) return;

    final schedule = DateTime(
      date.year, date.month, date.day, time.hour, time.minute,
    );

    // Validasi: tolak jika waktu sudah lewat atau kurang dari 1 menit
    if (schedule.isBefore(now.add(const Duration(minutes: 1)))) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih waktu yang akan datang, minimal 1 menit dari sekarang'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (userId == null || recipe.id == null) return;

    await repository.addSchedule(
      userId!, recipe.id!, schedule,
      'Reminder memasak ${recipe.name}',
    );

    // Notifikasi konfirmasi langsung
    await NotificationService.instance.showSavedConfirmation(
      recipe.name, schedule,
    );

    // Notifikasi terjadwal saat waktu masak tiba
    await NotificationService.instance.scheduleReminder(
      id: recipe.id!,
      recipeName: recipe.name,
      cookingTime: schedule,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Jadwal disimpan: ${DateFormat('dd MMM yyyy, HH:mm').format(schedule)}',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            actions: [
              IconButton(
                onPressed: _toggleFavorite,
                icon: Icon(
                  favorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: favorite ? AppColors.terracotta : AppColors.ink,
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.spiceBrown, AppColors.terracotta, AppColors.turmeric],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(right: 26, bottom: 22, child: Text(recipe.emoji, style: const TextStyle(fontSize: 116))),
                    Positioned(left: 22, bottom: 28, right: 150, child: Text(recipe.name, style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w900, letterSpacing: -1.2))),
                    Positioned(left: 22, bottom: 105, child: _WhitePill(text: recipe.province)),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: _InfoTile(icon: Icons.timer_outlined, title: '${recipe.cookTimeMinutes} menit', subtitle: 'Waktu masak')),
                      const SizedBox(width: 10),
                      Expanded(child: _InfoTile(icon: Icons.local_fire_department_outlined, title: recipe.difficulty, subtitle: 'Kesulitan')),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(recipe.description, style: const TextStyle(color: AppColors.muted, fontSize: 15, height: 1.55, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 24),
                  PrimaryButton(text: 'Mulai Masak', icon: Icons.calendar_month_rounded, onPressed: _pickSchedule),
                  const SizedBox(height: 26),
                  _Section(title: 'Bahan-bahan', child: _BulletText(text: recipe.ingredients)),
                  _Section(title: 'Langkah memasak', child: _NumberedText(text: recipe.steps)),
                  // Estimasi biaya dengan live rate
                  _Section(
                    title: 'Estimasi biaya bahan',
                    child: FutureBuilder<Map<String, String>>(
                      future: CurrencyConverter.convertFromIdr(recipe.estimatedCost),
                      builder: (context, snap) {
                        final conversions = snap.data ??
                            CurrencyConverter.convertFromIdrSync(recipe.estimatedCost);
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Keterangan porsi
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.cream,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.people_outline_rounded, size: 15, color: AppColors.spiceBrown),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Estimasi untuk ±4 porsi',
                                    style: const TextStyle(
                                      color: AppColors.spiceBrown,
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: conversions.entries
                                  .map((e) => _MiniCard(title: e.key, value: e.value))
                                  .toList(),
                            ),
                            const SizedBox(height: 8),
                            // Indikator live rate
                            Row(
                              children: [
                                Icon(
                                  CurrencyConverter.isUsingLiveRate
                                      ? Icons.wifi_rounded
                                      : Icons.wifi_off_rounded,
                                  size: 13,
                                  color: CurrencyConverter.isUsingLiveRate
                                      ? AppColors.leaf
                                      : AppColors.muted,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  CurrencyConverter.isUsingLiveRate
                                      ? 'Kurs live dari Frankfurter API'
                                      : 'Menggunakan kurs estimasi',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: CurrencyConverter.isUsingLiveRate
                                        ? AppColors.leaf
                                        : AppColors.muted,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget pendukung tidak berubah — tetap sama
class _WhitePill extends StatelessWidget {
  final String text;
  const _WhitePill({required this.text});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _InfoTile({required this.icon, required this.title, required this.subtitle});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.line)),
      child: Row(
        children: [
          Container(width: 42, height: 42, decoration: BoxDecoration(color: AppColors.cream, borderRadius: BorderRadius.circular(16)), child: Icon(icon, color: AppColors.spiceBrown)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.ink)),
              const SizedBox(height: 3),
              Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.muted, fontWeight: FontWeight.w600)),
            ]),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.ink)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _BulletText extends StatelessWidget {
  final String text;
  const _BulletText({required this.text});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: text.split('\n').map((line) => Padding(
        padding: const EdgeInsets.only(bottom: 9),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(padding: EdgeInsets.only(top: 4), child: Icon(Icons.eco_rounded, size: 16, color: AppColors.leaf)),
            const SizedBox(width: 10),
            Expanded(child: Text(line, style: const TextStyle(color: AppColors.ink, fontWeight: FontWeight.w600, height: 1.35))),
          ],
        ),
      )).toList(),
    );
  }
}

class _NumberedText extends StatelessWidget {
  final String text;
  const _NumberedText({required this.text});
  @override
  Widget build(BuildContext context) {
    final items = text.split('\n');
    return Column(
      children: List.generate(items.length, (index) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 28, height: 28, decoration: const BoxDecoration(color: AppColors.cream, shape: BoxShape.circle), child: Center(child: Text('${index + 1}', style: const TextStyle(color: AppColors.spiceBrown, fontWeight: FontWeight.w900)))),
            const SizedBox(width: 12),
            Expanded(child: Text(items[index], style: const TextStyle(color: AppColors.ink, fontWeight: FontWeight.w600, height: 1.35))),
          ],
        ),
      )),
    );
  }
}

class _MiniCard extends StatelessWidget {
  final String title;
  final String value;
  const _MiniCard({required this.title, required this.value});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.line)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(color: AppColors.muted, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(color: AppColors.ink, fontWeight: FontWeight.w900, fontSize: 17)),
      ]),
    );
  }
}