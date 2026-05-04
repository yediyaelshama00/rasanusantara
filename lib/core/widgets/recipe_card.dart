import 'package:flutter/material.dart';
import '../../data/models/recipe_model.dart';
import '../constants/app_colors.dart';

class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final bool compact;
  final bool favorite;

  const RecipeCard({
    super.key,
    required this.recipe,
    this.onTap,
    this.onFavorite,
    this.compact = false,
    this.favorite = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.line),
          boxShadow: [
            BoxShadow(
              color: AppColors.darkBrown.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: compact ? 76 : 92,
              height: compact ? 76 : 92,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.cream, Color(0xFFFFE1AB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Center(child: Text(recipe.emoji, style: TextStyle(fontSize: compact ? 36 : 42))),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.ink),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${recipe.province} • ${recipe.cookTimeMinutes} menit',
                    style: const TextStyle(fontSize: 12.5, color: AppColors.muted, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 9),
                  Wrap(
                    spacing: 7,
                    runSpacing: 7,
                    children: [
                      _Pill(text: recipe.difficulty, icon: Icons.local_fire_department_outlined),
                      _Pill(text: recipe.island, icon: Icons.map_outlined),
                    ],
                  ),
                ],
              ),
            ),
            if (onFavorite != null)
              IconButton(
                onPressed: onFavorite,
                icon: Icon(favorite ? Icons.favorite : Icons.favorite_border, color: favorite ? AppColors.terracotta : AppColors.muted),
              ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final IconData icon;

  const _Pill({required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.spiceBrown),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(fontSize: 11, color: AppColors.spiceBrown, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
