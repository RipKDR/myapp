import 'package:flutter/material.dart';
import '../core/feature_flags.dart';
import '../services/purchase_service.dart';

class FeatureGuard extends StatefulWidget {
  const FeatureGuard({super.key, required this.tier, required this.child});
  final FeatureTier tier;
  final Widget child;

  @override
  State<FeatureGuard> createState() => _FeatureGuardState();
}

class _FeatureGuardState extends State<FeatureGuard> {
  late bool _unlocked = FeatureFlags.allow(widget.tier);

  @override
  Widget build(final BuildContext context) => _unlocked ? widget.child : _Paywall(onUnlocked: () => setState(() => _unlocked = true));
}

class _Paywall extends StatelessWidget {
  const _Paywall({required this.onUnlocked});
  final VoidCallback onUnlocked;
  @override
  Widget build(final BuildContext context) => Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.workspace_premium, size: 64),
            const SizedBox(height: 12),
            Text('Premium Feature', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            const Text('Upgrade to access advanced AI insights and automation.'),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (final context) => AlertDialog(
                    title: const Text('Upgrade'),
                    content: const Text('Enable premium locally for demo?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                      FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Unlock')),
                    ],
                  ),
                );
                if (ok ?? false) {
                  await PurchaseService.unlockForDemo();
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Premium unlocked (demo)')));
                  onUnlocked();
                }
              },
              icon: const Icon(Icons.shopping_cart_checkout),
              label: const Text('Upgrade'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () async {
                await PurchaseService.buyPremium();
              },
              icon: const Icon(Icons.store),
              label: const Text('Buy on store'),
            ),
          ],
        ),
      ),
    );
}
