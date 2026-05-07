import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_converter.dart';
import '../../core/widgets/recipe_image.dart';
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
  bool favoriteLoading = false;
  bool scheduleLoading = false;

  int? userId;
  bool loadedFavorite = false;

  Recipe get recipe => ModalRoute.of(context)!.settings.arguments as Recipe;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (loadedFavorite) return;
    loadedFavorite = true;
    _loadFavorite();
  }

  String _errorMessage(Object error) {
    final text = error.toString();
    if (text.startsWith('Exception: ')) return text.replaceFirst('Exception: ', '');
    return text.replaceAll('Exception: ', '');
  }

  void _showSnack(String message, {bool danger = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: danger ? AppColors.terracotta : null,
    ));
  }

  Future<void> _loadFavorite() async {
    final id = await SessionHelper.instance.getUserId();
    if (id == null || recipe.id == null) {
      if (!mounted) return;
      setState(() { userId = id; favorite = false; });
      return;
    }
    final isFav = await repository.isFavorite(id, recipe.id!);
    if (!mounted) return;
    setState(() { userId = id; favorite = isFav; });
  }

  Future<void> _toggleFavorite() async {
    if (favoriteLoading) return;
    final id = userId ?? await SessionHelper.instance.getUserId();
    if (id == null || recipe.id == null) {
      _showSnack('User tidak ditemukan. Silakan login ulang.', danger: true);
      return;
    }
    setState(() => favoriteLoading = true);
    try {
      await repository.toggleFavorite(id, recipe.id!);
      await _loadFavorite();
      _showSnack(favorite ? 'Resep ditambahkan ke favorit.' : 'Resep dihapus dari favorit.');
    } catch (e) {
      _showSnack(_errorMessage(e), danger: true);
    } finally {
      if (mounted) setState(() => favoriteLoading = false);
    }
  }

  Future<void> _pickSchedule() async {
    if (scheduleLoading) return;
    final now = DateTime.now();

    final date = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      initialDate: now,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.spiceBrown, onPrimary: Colors.white,
            surface: AppColors.paper, onSurface: AppColors.ink,
          ),
        ),
        child: child!,
      ),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context, initialTime: TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.spiceBrown, onPrimary: Colors.white,
            surface: AppColors.paper, onSurface: AppColors.ink,
          ),
        ),
        child: child!,
      ),
    );
    if (time == null || !mounted) return;

    final schedule = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    if (schedule.isBefore(now.add(const Duration(minutes: 1)))) {
      _showSnack('Pilih waktu yang akan datang, minimal 1 menit dari sekarang.', danger: true);
      return;
    }

    final id = userId ?? await SessionHelper.instance.getUserId();
    if (id == null || recipe.id == null) {
      _showSnack('User tidak ditemukan. Silakan login ulang.', danger: true);
      return;
    }

    setState(() => scheduleLoading = true);
    try {
      await repository.addSchedule(id, recipe.id!, schedule, 'Reminder memasak ${recipe.name}');
      await NotificationService.instance.showSavedConfirmation(recipe.name, schedule);
      await NotificationService.instance.scheduleReminder(
          id: recipe.id!, recipeName: recipe.name, cookingTime: schedule);
      _showSnack('Jadwal disimpan: ${DateFormat('dd MMM yyyy, HH:mm').format(schedule)}');
    } catch (e) {
      _showSnack(_errorMessage(e), danger: true);
    } finally {
      if (mounted) setState(() => scheduleLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = recipe;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // ── Hero banner — gambar penuh di atas ───────────────────
            _HeroBanner(
              recipe: r,
              favorite: favorite,
              favoriteLoading: favoriteLoading,
              onBack: () => Navigator.pop(context),
              onFavorite: _toggleFavorite,
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 34),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info tiles
                  Row(children: [
                    Expanded(child: _InfoTile(
                        icon: Icons.timer_outlined,
                        title: '${r.cookTimeMinutes} menit',
                        subtitle: 'Waktu masak')),
                    const SizedBox(width: 12),
                    Expanded(child: _InfoTile(
                        icon: Icons.local_fire_department_outlined,
                        title: r.difficulty,
                        subtitle: 'Kesulitan')),
                  ]),
                  const SizedBox(height: 20),

                  // Tombol jadwal
                  SizedBox(
                    height: 54, width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: scheduleLoading ? null : _pickSchedule,
                      icon: scheduleLoading
                          ? const SizedBox(width: 19, height: 19,
                              child: CircularProgressIndicator(strokeWidth: 2.3, color: Colors.white))
                          : const Icon(Icons.calendar_month_rounded),
                      label: Text(scheduleLoading ? 'Menyimpan Jadwal...' : 'Mulai Masak',
                          style: const TextStyle(fontWeight: FontWeight.w900)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.greenEnd,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: AppColors.greenEnd.withOpacity(0.45),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                          side: const BorderSide(color: AppColors.greenShadow, width: 1.5),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),

                  // Bahan
                  _GamePanel(
                    label: 'Bahan-bahan',
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 38, 18, 18),
                      child: _BulletText(text: r.ingredients),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Langkah
                  _GamePanel(
                    label: 'Langkah Masak',
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 38, 18, 18),
                      child: _NumberedText(text: r.steps),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Biaya
                  _CostPanel(recipe: r),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Hero banner — gambar lebar penuh dengan overlay gradient ─────────────────
class _HeroBanner extends StatelessWidget {
  final Recipe recipe;
  final bool favorite;
  final bool favoriteLoading;
  final VoidCallback onBack;
  final VoidCallback onFavorite;

  const _HeroBanner({
    required this.recipe,
    required this.favorite,
    required this.favoriteLoading,
    required this.onBack,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.spiceBrown.withOpacity(0.35), width: 2),
        ),
      ),
      child: Stack(
        children: [
          // Gambar penuh
          RecipeImage(
            imagePath: recipe.imagePath,
            width: double.infinity,
            height: 260,
            fit: BoxFit.cover,
          ),

          // Gradient overlay bawah → atas agar teks terbaca
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.72),
                    Colors.black.withOpacity(0.08),
                  ],
                ),
              ),
            ),
          ),

          // Tombol back & favorit di atas
          Positioned(
            top: 12, left: 14, right: 14,
            child: Row(
              children: [
                _IconOverlayButton(
                    icon: Icons.arrow_back_rounded, onTap: onBack),
                const Spacer(),
                _IconOverlayButton(
                  icon: favorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  onTap: favoriteLoading ? null : onFavorite,
                  active: favorite,
                ),
              ],
            ),
          ),

          // Teks nama + lokasi di bawah gambar
          Positioned(
            bottom: 16, left: 16, right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Province badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.spiceBrown.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(recipe.province,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900)),
                ),
                const SizedBox(height: 8),
                Text(
                  recipe.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                    letterSpacing: -0.6,
                    shadows: [Shadow(color: Colors.black54, blurRadius: 8)],
                  ),
                ),
                const SizedBox(height: 6),
                Row(children: [
                  const Icon(Icons.location_on_outlined, size: 14, color: Colors.white70),
                  const SizedBox(width: 4),
                  Text('${recipe.province} • ${recipe.island}',
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 12.5, fontWeight: FontWeight.w700)),
                ]),
                const SizedBox(height: 8),
                Text(recipe.description,
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.white60, fontSize: 12.5,
                        fontWeight: FontWeight.w600, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IconOverlayButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool active;

  const _IconOverlayButton({required this.icon, required this.onTap, this.active = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.45 : 1,
        child: Container(
          width: 42, height: 42,
          decoration: BoxDecoration(
            color: active
                ? AppColors.terracotta.withOpacity(0.85)
                : Colors.black.withOpacity(0.40),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.55), width: 1.5),
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
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
    return _GamePanel(
      label: subtitle,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 34, 14, 14),
        child: Column(children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(color: AppColors.cream, shape: BoxShape.circle,
                border: Border.all(color: AppColors.spiceBrown, width: 2)),
            child: Icon(icon, color: AppColors.spiceBrown, size: 26),
          ),
          const SizedBox(height: 10),
          Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.ink, fontSize: 14)),
        ]),
      ),
    );
  }
}

class _CostPanel extends StatelessWidget {
  final Recipe recipe;
  const _CostPanel({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return _GamePanel(
      label: 'Estimasi Biaya',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 38, 18, 20),
        child: FutureBuilder<Map<String, String>>(
          future: CurrencyConverter.convertFromIdr(recipe.estimatedCost),
          builder: (context, snap) {
            final conversions = snap.data ??
                CurrencyConverter.convertFromIdrSync(recipe.estimatedCost);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(color: AppColors.cream,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.spiceBrown.withOpacity(0.22))),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.people_outline_rounded, size: 16, color: AppColors.spiceBrown),
                    SizedBox(width: 6),
                    Text('Estimasi untuk ±4 porsi',
                        style: TextStyle(color: AppColors.spiceBrown,
                            fontSize: 12.5, fontWeight: FontWeight.w900)),
                  ]),
                ),
                const SizedBox(height: 14),
                Wrap(spacing: 10, runSpacing: 10,
                  children: conversions.entries
                      .map((e) => _MiniCard(title: e.key, value: e.value))
                      .toList(),
                ),
                const SizedBox(height: 12),
                Row(children: [
                  Icon(
                    CurrencyConverter.isUsingLiveRate ? Icons.wifi_rounded : Icons.wifi_off_rounded,
                    size: 14,
                    color: CurrencyConverter.isUsingLiveRate ? AppColors.leaf : AppColors.muted,
                  ),
                  const SizedBox(width: 6),
                  Expanded(child: Text(
                    CurrencyConverter.isUsingLiveRate
                        ? 'Kurs live dari Frankfurter API'
                        : 'Menggunakan kurs estimasi',
                    style: TextStyle(
                      fontSize: 11.5, fontWeight: FontWeight.w800,
                      color: CurrencyConverter.isUsingLiveRate ? AppColors.leaf : AppColors.muted,
                    ),
                  )),
                ]),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _BulletText extends StatelessWidget {
  final String text;
  const _BulletText({required this.text});

  @override
  Widget build(BuildContext context) {
    final items = text.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    return Column(
      children: items.map((line) => Padding(
        padding: const EdgeInsets.only(bottom: 11),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 26, height: 26,
            decoration: BoxDecoration(color: AppColors.cream, shape: BoxShape.circle,
                border: Border.all(color: AppColors.spiceBrown.withOpacity(0.28))),
            child: const Icon(Icons.eco_rounded, size: 15, color: AppColors.leaf),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(line,
              style: const TextStyle(color: AppColors.ink, fontWeight: FontWeight.w700,
                  height: 1.42, fontSize: 14))),
        ]),
      )).toList(),
    );
  }
}

class _NumberedText extends StatelessWidget {
  final String text;
  const _NumberedText({required this.text});

  @override
  Widget build(BuildContext context) {
    final items = text.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    return Column(
      children: List.generate(items.length, (i) => Padding(
        padding: const EdgeInsets.only(bottom: 13),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 30, height: 30,
            decoration: BoxDecoration(color: AppColors.greenEnd, shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: const [BoxShadow(color: AppColors.greenShadow, offset: Offset(0, 2))]),
            child: Center(child: Text('${i + 1}',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900))),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(items[i],
              style: const TextStyle(color: AppColors.ink, fontWeight: FontWeight.w700,
                  height: 1.42, fontSize: 14))),
        ]),
      )),
    );
  }
}

class _MiniCard extends StatelessWidget {
  final String title;
  final String value;
  const _MiniCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) => Container(
    width: 145, padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: AppColors.cream, borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.spiceBrown.withOpacity(0.25))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, maxLines: 1, overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: AppColors.muted, fontWeight: FontWeight.w900, fontSize: 12)),
      const SizedBox(height: 6),
      Text(value, maxLines: 1, overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: AppColors.ink, fontWeight: FontWeight.w900, fontSize: 15.5)),
    ]),
  );
}

class _GamePanel extends StatelessWidget {
  final String label;
  final Widget child;
  const _GamePanel({required this.label, required this.child});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 18),
    child: Container(
      decoration: BoxDecoration(
        color: AppColors.paper, borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.spiceBrown, width: 2.8),
        boxShadow: const [BoxShadow(color: Color(0x26000000), blurRadius: 14, offset: Offset(0, 7))],
      ),
      child: Stack(clipBehavior: Clip.none, children: [
        child,
        Positioned(top: -15, left: 14, right: 14, child: _Ribbon(label: label)),
      ]),
    ),
  );
}

class _Ribbon extends StatelessWidget {
  final String label;
  const _Ribbon({required this.label});
  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      constraints: const BoxConstraints(minWidth: 112),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: AppColors.ribbonGradient,
            begin: Alignment.topCenter, end: Alignment.bottomCenter),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.ribbonShadow, width: 1.2),
        boxShadow: const [BoxShadow(color: Color(0x24000000), blurRadius: 8, offset: Offset(0, 3))],
      ),
      child: Text(label, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900)),
    ),
  );
}