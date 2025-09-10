import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../ui/components/app_scaffold.dart';
import '../../../ui/components/buttons.dart';
import '../../../ui/theme/tokens/spacing.dart';
import '../../../ui/theme/tokens/colors.dart';
import '../controllers/provider_controller.dart';
import '../models/ndis_provider.dart';

/// Provider Detail Screen
/// Comprehensive view of a single NDIS provider
class ProviderDetailScreen extends StatelessWidget {

  const ProviderDetailScreen({super.key, required this.provider});
  final NDISProvider provider;

  @override
  Widget build(final BuildContext context) => AppScaffold(
      title: provider.displayName,
      actions: [
        Consumer<ProviderController>(
          builder: (final context, final controller, final child) {
            return IconButton(
              icon: Icon(
                provider.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: provider.isFavorite ? NDISColors.error : null,
              ),
              onPressed: () => controller.toggleFavorite(provider.id),
              tooltip: provider.isFavorite
                  ? 'Remove from favorites'
                  : 'Add to favorites',
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () => _shareProvider(final context),
          tooltip: 'Share provider',
        ),
      ],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(NDISSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProviderHeader(final context),
            const SizedBox(height: NDISSpacing.xl),
            _buildContactSection(final context),
            const SizedBox(height: NDISSpacing.xl),
            _buildServicesSection(final context),
            const SizedBox(height: NDISSpacing.xl),
            _buildLocationSection(final context),
            const SizedBox(height: NDISSpacing.xl),
            _buildAccessibilitySection(context),
            const SizedBox(height: NDISSpacing.xl),
            _buildRegistrationSection(final context),
            const SizedBox(height: NDISSpacing.xl),
            _buildActionButtons(final context),
          ],
        ),
      ),
    );

  Widget _buildProviderHeader(final BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(NDISSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(NDISSpacing.radiusMd),
                  ),
                  child: Icon(
                    _getProviderIcon(),
                    color: theme.colorScheme.onPrimaryContainer,
                    size: NDISSpacing.iconLg,
                  ),
                ),
                const SizedBox(width: NDISSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        provider.displayName,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (provider.businessName != null &&
                          provider.businessName != provider.name)
                        Text(
                          provider.businessName!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      if (provider.registrationNumber != null)
                        Text(
                          'Registration: ${provider.registrationNumber}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if (provider.description != null) ...[
              const SizedBox(height: NDISSpacing.md),
              Text(provider.description!, style: theme.textTheme.bodyMedium),
            ],
            if (provider.rating != null) ...[
              const SizedBox(height: NDISSpacing.md),
              Row(
                children: [
                  const Icon(
                    Icons.star,
                    size: NDISSpacing.iconSm,
                    color: NDISColors.tertiary,
                  ),
                  const SizedBox(width: NDISSpacing.xs),
                  Text(
                    provider.rating!.toStringAsFixed(1),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: NDISSpacing.sm),
                  Text(
                    '(${provider.reviewCount} reviews)',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildContactSection(final BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(NDISSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contact Information',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: NDISSpacing.md),
            if (provider.phone != null)
              _buildContactItem(
                final context,
                icon: Icons.phone,
                title: 'Phone',
                subtitle: provider.phone!,
                onTap: () => _launchPhone(provider.phone!),
              ),
            if (provider.email != null)
              _buildContactItem(
                final context,
                icon: Icons.email,
                title: 'Email',
                subtitle: provider.email!,
                onTap: () => _launchEmail(provider.email!),
              ),
            if (provider.website != null)
              _buildContactItem(
                final context,
                icon: Icons.language,
                title: 'Website',
                subtitle: provider.website!,
                onTap: () => _launchWebsite(provider.website!),
              ),
            if (provider.fax != null)
              _buildContactItem(
                final context,
                icon: Icons.fax,
                title: 'Fax',
                subtitle: provider.fax!,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesSection(final BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(NDISSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Services & Support',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: NDISSpacing.md),
            if (provider.serviceTypes.isNotEmpty) ...[
              Text(
                'Service Types',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: NDISSpacing.sm),
              Wrap(
                spacing: NDISSpacing.sm,
                runSpacing: NDISSpacing.sm,
                children: provider.serviceTypes.map((final type) => Chip(
                    label: Text(type),
                    backgroundColor: theme.colorScheme.primaryContainer,
                    labelStyle: TextStyle(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  )).toList(),
              ),
              const SizedBox(height: NDISSpacing.md),
            ],
            if (provider.supportCategories.isNotEmpty) ...[
              Text(
                'Support Categories',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: NDISSpacing.sm),
              Wrap(
                spacing: NDISSpacing.sm,
                runSpacing: NDISSpacing.sm,
                children: provider.supportCategories.map((final category) => Chip(
                    label: Text(category),
                    backgroundColor: theme.colorScheme.secondaryContainer,
                    labelStyle: TextStyle(
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                  )).toList(),
              ),
              const SizedBox(height: NDISSpacing.md),
            ],
            if (provider.disabilityTypes.isNotEmpty) ...[
              Text(
                'Disability Types',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: NDISSpacing.sm),
              Wrap(
                spacing: NDISSpacing.sm,
                runSpacing: NDISSpacing.sm,
                children: provider.disabilityTypes.map((final type) => Chip(
                    label: Text(type),
                    backgroundColor: theme.colorScheme.tertiaryContainer,
                    labelStyle: TextStyle(
                      color: theme.colorScheme.onTertiaryContainer,
                    ),
                  )).toList(),
              ),
              const SizedBox(height: NDISSpacing.md),
            ],
            if (provider.ageGroups.isNotEmpty) ...[
              Text(
                'Age Groups',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: NDISSpacing.sm),
              Wrap(
                spacing: NDISSpacing.sm,
                runSpacing: NDISSpacing.sm,
                children: provider.ageGroups.map((final age) => Chip(
                    label: Text(age),
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  )).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection(final BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(NDISSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Location & Service Areas',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: NDISSpacing.md),
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: NDISSpacing.iconSm,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: NDISSpacing.sm),
                Expanded(
                  child: Text(
                    provider.fullAddress,
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
            if (provider.serviceAreas.isNotEmpty) ...[
              const SizedBox(height: NDISSpacing.md),
              Text(
                'Service Areas',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: NDISSpacing.sm),
              Wrap(
                spacing: NDISSpacing.sm,
                runSpacing: NDISSpacing.sm,
                children: provider.serviceAreas.map((final area) => Chip(
                    label: Text(area),
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  )).toList(),
              ),
            ],
            const SizedBox(height: NDISSpacing.md),
            _buildServiceDeliveryOptions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceDeliveryOptions(final BuildContext context) {
    final theme = Theme.of(context);
    final options = <String>[];

    if (provider.isRemoteService) options.add('Remote Services');
    if (provider.isHomeVisits) options.add('Home Visits');
    if (provider.isGroupService) options.add('Group Services');
    if (provider.isIndividualService) options.add('Individual Services');

    if (options.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Service Delivery Options',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: NDISSpacing.sm),
        Wrap(
          spacing: NDISSpacing.sm,
          runSpacing: NDISSpacing.sm,
          children: options.map((final option) => Chip(
              label: Text(option),
              backgroundColor: theme.colorScheme.primaryContainer,
              labelStyle: TextStyle(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            )).toList(),
        ),
      ],
    );
  }

  Widget _buildAccessibilitySection(final BuildContext context) {
    final theme = Theme.of(context);
    final accessibilityFeatures = <String>[];

    if (provider.isCulturallyAppropriate) {
      accessibilityFeatures.add('Culturally Appropriate');
    }
    if (provider.isLgbtiFriendly) accessibilityFeatures.add('LGBTI+ Friendly');
    if (provider.isAboriginalTorresStraitIslander) {
      accessibilityFeatures.add('Aboriginal & Torres Strait Islander');
    }

    if (accessibilityFeatures.isEmpty && provider.languages.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(NDISSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Accessibility & Inclusion',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: NDISSpacing.md),
            if (accessibilityFeatures.isNotEmpty) ...[
              Text(
                'Accessibility Features',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: NDISSpacing.sm),
              Wrap(
                spacing: NDISSpacing.sm,
                runSpacing: NDISSpacing.sm,
                children: accessibilityFeatures.map((final feature) => Chip(
                    label: Text(feature),
                    backgroundColor: theme.colorScheme.secondaryContainer,
                    labelStyle: TextStyle(
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                  )).toList(),
              ),
              const SizedBox(height: NDISSpacing.md),
            ],
            if (provider.languages.isNotEmpty) ...[
              Text(
                'Languages',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: NDISSpacing.sm),
              Wrap(
                spacing: NDISSpacing.sm,
                runSpacing: NDISSpacing.sm,
                children: provider.languages.map((final language) => Chip(
                    label: Text(language),
                    backgroundColor: theme.colorScheme.tertiaryContainer,
                    labelStyle: TextStyle(
                      color: theme.colorScheme.onTertiaryContainer,
                    ),
                  )).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRegistrationSection(final BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(NDISSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Registration Information',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: NDISSpacing.md),
            if (provider.registrationStatus != null)
              _buildInfoRow(
                context,
                'Status',
                provider.registrationStatus!,
                provider.isRegistered ? NDISColors.success : NDISColors.error,
              ),
            if (provider.registrationDate != null)
              _buildInfoRow(
                context,
                'Registered Since',
                _formatDate(provider.registrationDate!),
              ),
            if (provider.expiryDate != null)
              _buildInfoRow(
                context,
                'Expires',
                _formatDate(provider.expiryDate!),
              ),
            if (provider.abn != null)
              _buildInfoRow(context, 'ABN', provider.abn!),
            if (provider.acn != null)
              _buildInfoRow(context, 'ACN', provider.acn!),
            if (provider.ndisRegistrationGroup != null)
              _buildInfoRow(
                context,
                'Registration Group',
                provider.ndisRegistrationGroup!,
              ),
            if (provider.qualityAndSafeguardsCommission != null)
              _buildInfoRow(
                context,
                'Quality & Safeguards',
                provider.qualityAndSafeguardsCommission!,
              ),
            if (provider.lastAuditDate != null)
              _buildInfoRow(
                context,
                'Last Audit',
                _formatDate(provider.lastAuditDate!),
              ),
            if (provider.auditStatus != null)
              _buildInfoRow(context, 'Audit Status', provider.auditStatus!),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(final BuildContext context) => Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: PrimaryButton(
            text: 'Contact Provider',
            onPressed: () => _showContactOptions(context),
          ),
        ),
        const SizedBox(height: NDISSpacing.md),
        SizedBox(
          width: double.infinity,
          child: SecondaryButton(
            text: 'Get Directions',
            onPressed: () => _showComingSoon(context, 'Directions'),
          ),
        ),
        const SizedBox(height: NDISSpacing.md),
        SizedBox(
          width: double.infinity,
          child: SecondaryButton(
            text: 'Write Review',
            onPressed: () => _showComingSoon(context, 'Review system'),
          ),
        ),
      ],
    );

  Widget _buildContactItem(
    final BuildContext context, {
    required final IconData icon,
    required final String title,
    required final String subtitle,
    final VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: onTap,
      trailing: onTap != null
          ? const Icon(Icons.arrow_forward_ios, size: 16)
          : null,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildInfoRow(
    final BuildContext context,
    final String label,
    final String value, [
    final Color? valueColor,
  ]) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: NDISSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: valueColor,
                fontWeight: valueColor != null ? FontWeight.w500 : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getProviderIcon() {
    if (provider.serviceTypes.contains('Physiotherapy')) {
      return Icons.medical_services;
    } else if (provider.serviceTypes.contains('Occupational Therapy')) {
      return Icons.accessible;
    } else if (provider.serviceTypes.contains('Speech Therapy')) {
      return Icons.record_voice_over;
    } else if (provider.serviceTypes.contains('Support Work')) {
      return Icons.people;
    } else if (provider.serviceTypes.contains('Plan Management')) {
      return Icons.account_balance;
    } else if (provider.serviceTypes.contains('Support Coordination')) {
      return Icons.support_agent;
    } else {
      return Icons.business;
    }
  }

  String _formatDate(final DateTime date) => '${date.day}/${date.month}/${date.year}';

  Future<void> _launchPhone(final String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchEmail(final String email) async {
    final uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchWebsite(final String website) async {
    final uri = Uri.parse(
      website.startsWith('http') ? website : 'https://$website',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _shareProvider(final BuildContext context) {
    _showComingSoon(context, 'Sharing functionality');
  }

  void _showContactOptions(final BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: _buildContactBottomSheet,
    );
  }

  Widget _buildContactBottomSheet(final BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(NDISSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contact ${provider.displayName}',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: NDISSpacing.lg),
          if (provider.phone != null)
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('Call'),
              subtitle: Text(provider.phone!),
              onTap: () {
                Navigator.of(context).pop();
                _launchPhone(provider.phone!);
              },
            ),
          if (provider.email != null)
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Email'),
              subtitle: Text(provider.email!),
              onTap: () {
                Navigator.of(context).pop();
                _launchEmail(provider.email!);
              },
            ),
          if (provider.website != null)
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('Website'),
              subtitle: Text(provider.website!),
              onTap: () {
                Navigator.of(context).pop();
                _launchWebsite(provider.website!);
              },
            ),
          ListTile(
            leading: const Icon(Icons.message),
            title: const Text('Send Message'),
            subtitle: const Text('Send a secure message'),
            onTap: () {
              Navigator.of(context).pop();
              _showComingSoon(context, 'Messaging system');
            },
          ),
          const SizedBox(height: NDISSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: SecondaryButton(
              text: 'Close',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(final BuildContext context, final String feature) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$feature coming soon!')));
  }
}
