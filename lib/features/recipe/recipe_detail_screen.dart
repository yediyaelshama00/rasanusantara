import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_converter.dart';
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

  Recipe get recipe {
    return ModalRoute.of(context)!.settings.arguments as Recipe;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (loadedFavorite) return;
    loadedFavorite = true;

    _loadFavorite();
  }

  String _errorMessage(Object error) {
    final text = error.toString();

    if (text.startsWith('Exception: ')) {
      return text.replaceFirst('Exception: ', '');
    }

    return text.replaceAll('Exception: ', '');
  }

  void _showSnack(String message, {bool danger = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: danger ? AppColors.terracotta : null,
      ),
    );
  }

  Future<void> _loadFavorite() async {
    final id = await SessionHelper.instance.getUserId();

    if (id == null || recipe.id == null) {
      if (!mounted) return;

      setState(() {
        userId = id;
        favorite = false;
      });

      return;
    }

    final isFav = await repository.isFavorite(id, recipe.id!);

    if (!mounted) return;

    setState(() {
      userId = id;
      favorite = isFav;
    });
  }

  Future<void> _toggleFavorite() async {
    if (favoriteLoading) return;

    final id = userId ?? await SessionHelper.instance.getUserId();

    if (id == null || recipe.id == null) {
      _showSnack('User tidak ditemukan. Silakan login ulang.', danger: true);
      return;
    }

    setState(() {
      favoriteLoading = true;
    });

    try {
      await repository.toggleFavorite(id, recipe.id!);
      await _loadFavorite();

      _showSnack(
        favorite
            ? 'Resep ditambahkan ke favorit.'
            : 'Resep dihapus dari favorit.',
      );
    } catch (e) {
      _showSnack(_errorMessage(e), danger: true);
    } finally {
      if (mounted) {
        setState(() {
          favoriteLoading = false;
        });
      }
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.spiceBrown,
              onPrimary: Colors.white,
              surface: AppColors.paper,
              onSurface: AppColors.ink,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.spiceBrown,
              onPrimary: Colors.white,
              surface: AppColors.paper,
              onSurface: AppColors.ink,
            ),
          ),
          child: child!,
        );
      },
    );

    if (time == null || !mounted) return;

    final schedule = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    if (schedule.isBefore(now.add(const Duration(minutes: 1)))) {
      _showSnack(
        'Pilih waktu yang akan datang, minimal 1 menit dari sekarang.',
        danger: true,
      );
      return;
    }

    final id = userId ?? await SessionHelper.instance.getUserId();

    if (id == null || recipe.id == null) {
      _showSnack('User tidak ditemukan. Silakan login ulang.', danger: true);
      return;
    }

    setState(() {
      scheduleLoading = true;
    });

    try {
      await repository.addSchedule(
        id,
        recipe.id!,
        schedule,
        'Reminder memasak ${recipe.name}',
      );

      await NotificationService.instance.showSavedConfirmation(
        recipe.name,
        schedule,
      );

      await NotificationService.instance.scheduleReminder(
        id: recipe.id!,
        recipeName: recipe.name,
        cookingTime: schedule,
      );

      _showSnack(
        'Jadwal disimpan: ${DateFormat('dd MMM yyyy, HH:mm').format(schedule)}',
      );
    } catch (e) {
      _showSnack(_errorMessage(e), danger: true);
    } finally {
      if (mounted) {
        setState(() {
          scheduleLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentRecipe = recipe;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 34),
          children: [
            Row(
              children: [
                _SmallRoundButton(
                  icon: Icons.arrow_back_rounded,
                  onTap: () => Navigator.pop(context),
                ),
                const Expanded(
                  child: _TopTitle(),
                ),
                _SmallRoundButton(
                  icon: favorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  danger: favorite,
                  onTap: favoriteLoading ? null : _toggleFavorite,
                ),
              ],
            ),
            const SizedBox(height: 22),
            _HeroRecipePanel(recipe: currentRecipe),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _InfoTile(
                    icon: Icons.timer_outlined,
                    title: '${currentRecipe.cookTimeMinutes} menit',
                    subtitle: 'Waktu masak',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InfoTile(
                    icon: Icons.local_fire_department_outlined,
                    title: currentRecipe.difficulty,
                    subtitle: 'Kesulitan',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 54,
              child: ElevatedButton.icon(
                onPressed: scheduleLoading ? null : _pickSchedule,
                icon: scheduleLoading
                    ? const SizedBox(
                        width: 19,
                        height: 19,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.3,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.calendar_month_rounded),
                label: Text(
                  scheduleLoading ? 'Menyimpan Jadwal...' : 'Mulai Masak',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.greenEnd,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.greenEnd.withOpacity(0.45),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: const BorderSide(
                      color: AppColors.greenShadow,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _GamePanel(
              label: 'Bahan-bahan',
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 38, 18, 18),
                child: _BulletText(text: currentRecipe.ingredients),
              ),
            ),
            const SizedBox(height: 24),
            _GamePanel(
              label: 'Langkah Masak',
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 38, 18, 18),
                child: _NumberedText(text: currentRecipe.steps),
              ),
            ),
            const SizedBox(height: 24),
            _CostPanel(recipe: currentRecipe),
          ],
        ),
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
        'Detail Resep',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.darkBrown,
          fontSize: 30,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.8,
        ),
      ),
    );
  }
}

class _HeroRecipePanel extends StatelessWidget {
  final Recipe recipe;

  const _HeroRecipePanel({
    required this.recipe,
  });

  @override
  Widget build(BuildContext context) {
    return _GamePanel(
      label: recipe.province,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 38, 18, 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.name,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.ink,
                      fontSize: 27,
                      fontWeight: FontWeight.w900,
                      height: 1.06,
                      letterSpacing: -0.8,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: AppColors.terracotta,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          '${recipe.province} • ${recipe.island}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    recipe.description,
                    maxLines: 8,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 13.5,
                      height: 1.45,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Container(
              width: 104,
              height: 104,
              decoration: BoxDecoration(
                color: AppColors.cream,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.spiceBrown,
                  width: 2.6,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x26000000),
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  recipe.emoji,
                  style: const TextStyle(fontSize: 58),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return _GamePanel(
      label: subtitle,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 34, 14, 14),
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.cream,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.spiceBrown,
                  width: 2,
                ),
              ),
              child: Icon(
                icon,
                color: AppColors.spiceBrown,
                size: 27,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                color: AppColors.ink,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CostPanel extends StatelessWidget {
  final Recipe recipe;

  const _CostPanel({
    required this.recipe,
  });

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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.cream,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.spiceBrown.withOpacity(0.22),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.people_outline_rounded,
                        size: 16,
                        color: AppColors.spiceBrown,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Estimasi untuk ±4 porsi',
                        style: TextStyle(
                          color: AppColors.spiceBrown,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: conversions.entries.map((entry) {
                    return _MiniCard(
                      title: entry.key,
                      value: entry.value,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      CurrencyConverter.isUsingLiveRate
                          ? Icons.wifi_rounded
                          : Icons.wifi_off_rounded,
                      size: 14,
                      color: CurrencyConverter.isUsingLiveRate
                          ? AppColors.leaf
                          : AppColors.muted,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        CurrencyConverter.isUsingLiveRate
                            ? 'Kurs live dari Frankfurter API'
                            : 'Menggunakan kurs estimasi',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: CurrencyConverter.isUsingLiveRate
                              ? AppColors.leaf
                              : AppColors.muted,
                        ),
                      ),
                    ),
                  ],
                ),
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

  const _BulletText({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final items = text
        .split('\n')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();

    return Column(
      children: items.map((line) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 11),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: AppColors.cream,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.spiceBrown.withOpacity(0.28),
                  ),
                ),
                child: const Icon(
                  Icons.eco_rounded,
                  size: 15,
                  color: AppColors.leaf,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  line,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w700,
                    height: 1.42,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _NumberedText extends StatelessWidget {
  final String text;

  const _NumberedText({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final items = text
        .split('\n')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();

    return Column(
      children: List.generate(items.length, (index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 13),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: AppColors.greenEnd,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.greenShadow,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  items[index],
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w700,
                    height: 1.42,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _MiniCard extends StatelessWidget {
  final String title;
  final String value;

  const _MiniCard({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 145,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.spiceBrown.withOpacity(0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.muted,
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.ink,
              fontWeight: FontWeight.w900,
              fontSize: 15.5,
            ),
          ),
        ],
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

  const _Ribbon({
    required this.label,
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
          gradient: LinearGradient(
            colors: AppColors.ribbonGradient,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.ribbonShadow,
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

class _SmallRoundButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool danger;

  const _SmallRoundButton({
    required this.icon,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = danger ? AppColors.terracotta : AppColors.greenEnd;
    final shadow = danger ? AppColors.danger : AppColors.greenShadow;

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.45 : 1,
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 2.4,
            ),
            boxShadow: [
              BoxShadow(
                color: shadow,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 23,
          ),
        ),
      ),
    );
  }
}