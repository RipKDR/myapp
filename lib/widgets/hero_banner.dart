import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/gamification_controller.dart';
import '../controllers/settings_controller.dart';

class HeroBanner extends StatelessWidget {
  final String title;
  final String subtitle;
  const HeroBanner({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final reduceMotion = context.select<SettingsController, bool>((s) => s.reduceMotion);
    final points = context.select<GamificationController, int>((g) => g.points);
    final streak = context.select<GamificationController, int>((g) => g.streakDays);
    final gradient = LinearGradient(
      colors: [scheme.primary, scheme.tertiary],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    final banner = Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Icon(Icons.auto_awesome, size: 48, color: scheme.onPrimary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: scheme.onPrimary, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: scheme.onPrimary.withOpacity(0.95)),
                ),
                const SizedBox(height: 8),
                Text('Streak $streak • $points pts', style: TextStyle(color: scheme.onPrimary)),
              ],
            ),
          ),
        ],
      ),
    );

    if (reduceMotion) return banner;
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0.95, end: 1.0),
      curve: Curves.easeOutBack,
      builder: (context, v, child) => Transform.scale(scale: v, child: child),
      child: banner,
    );
  }
}

