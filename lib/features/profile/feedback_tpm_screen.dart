import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class FeedbackTpmScreen extends StatelessWidget {
  const FeedbackTpmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 32),
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
                const SizedBox(width: 46),
              ],
            ),
            const SizedBox(height: 24),

            const _IntroPanel(),

            const SizedBox(height: 24),

            const _GamePanel(
              label: 'Kesan',
              child: Padding(
                padding: EdgeInsets.fromLTRB(18, 38, 18, 20),
                child: Text(
                  'Mata kuliah TPM sangat membantu saya memahami pengembangan aplikasi mobile dari sisi UI, penyimpanan lokal, sensor, dan integrasi fitur perangkat.',
                  style: TextStyle(
                    color: AppColors.muted,
                    height: 1.55,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            const _GamePanel(
              label: 'Saran',
              child: Padding(
                padding: EdgeInsets.fromLTRB(18, 38, 18, 20),
                child: Text(
                  'Saran saya, praktikum dapat ditambah dengan studi kasus yang lebih bervariasi dan sesi review desain aplikasi.',
                  style: TextStyle(
                    color: AppColors.muted,
                    height: 1.55,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
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
        'Saran & Kesan',
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

class _IntroPanel extends StatelessWidget {
  const _IntroPanel();

  @override
  Widget build(BuildContext context) {
    return _GamePanel(
      label: 'TPM',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 38, 18, 20),
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
                Icons.rate_review_rounded,
                color: AppColors.spiceBrown,
                size: 34,
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Text(
                'Halaman ini berisi kesan dan saran terhadap mata kuliah TPM.',
                style: TextStyle(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w900,
                  height: 1.35,
                  fontSize: 15,
                ),
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

  const _SmallRoundButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.45 : 1,
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: AppColors.greenEnd,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 2.4,
            ),
            boxShadow: const [
              BoxShadow(
                color: AppColors.greenShadow,
                offset: Offset(0, 3),
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