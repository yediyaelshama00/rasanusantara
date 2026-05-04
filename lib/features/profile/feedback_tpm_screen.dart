import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class FeedbackTpmScreen extends StatelessWidget {
  const FeedbackTpmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saran & Kesan TPM')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.cream,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.line),
            ),
            child: const Text(
              'Halaman ini berisi kesan dan saran terhadap mata kuliah TPM.',
              style: TextStyle(
                color: AppColors.spiceBrown,
                fontWeight: FontWeight.w700,
                height: 1.4,
              ),
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'Kesan',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 18,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Mata kuliah TPM sangat membantu saya memahami pengembangan aplikasi mobile dari sisi UI, penyimpanan lokal, sensor, dan integrasi fitur perangkat.',
            style: TextStyle(
              color: AppColors.muted,
              height: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'Saran',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 18,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Saran saya, praktikum dapat ditambah dengan studi kasus yang lebih bervariasi dan sesi review desain aplikasi.',
            style: TextStyle(
              color: AppColors.muted,
              height: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}