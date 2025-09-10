import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/gamification_controller.dart';
import '../controllers/settings_controller.dart';

class ConfettiBanner extends StatefulWidget {
  const ConfettiBanner({super.key});
  @override
  State<ConfettiBanner> createState() => _ConfettiBannerState();
}

class _ConfettiBannerState extends State<ConfettiBanner> {
  late ConfettiController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    final g = context.watch<GamificationController>();
    final settings = context.watch<SettingsController>();
    final badge = g.lastBadge;
    if (badge != null) {
      if (!settings.reduceMotion) {
        _controller.play();
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final snack = SnackBar(content: Text('Badge unlocked: $badge'));
        ScaffoldMessenger.of(context).showSnackBar(snack);
        g.clearLastBadge();
      });
    }
    if (settings.reduceMotion) return const SizedBox.shrink();
    return Align(
      alignment: Alignment.topCenter,
      child: ConfettiWidget(
        confettiController: _controller,
        blastDirectionality: BlastDirectionality.explosive,
        numberOfParticles: 20,
      ),
    );
  }
}

