import 'package:flutter/material.dart';
import '../../../ui/components/app_scaffold.dart';
import '../../../ui/components/buttons.dart';
import '../../../ui/components/forms.dart';
import '../../../ui/components/empty_states.dart';

/// Claims Screen
/// Submit and track NDIS claims
class ClaimsScreen extends StatefulWidget {
  const ClaimsScreen({super.key});

  @override
  State<ClaimsScreen> createState() => _ClaimsScreenState();
}

class _ClaimsScreenState extends State<ClaimsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) => AppScaffold(
      title: 'Claims',
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'New Claim'),
              Tab(text: 'History'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildNewClaimTab(), _buildHistoryTab()],
            ),
          ),
        ],
      ),
    );

  Widget _buildNewClaimTab() => SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Submit a New Claim',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 24),
          _buildClaimForm(),
        ],
      ),
    );

  Widget _buildClaimForm() => Column(
      children: [
        const FormFieldX(
          label: 'Service Provider',
          hint: 'Enter provider name',
          prefixIcon: Icon(Icons.business),
        ),
        const SizedBox(height: 16),
        FormFieldX(
          label: 'Service Type',
          hint: 'Select service type',
          prefixIcon: const Icon(Icons.category),
          onTap: _showServiceTypeDialog,
        ),
        const SizedBox(height: 16),
        const FormFieldX(
          label: 'Amount',
          hint: 'Enter amount',
          prefixIcon: Icon(Icons.attach_money),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        DateFormField(
          label: 'Service Date',
          selectedDate: DateTime.now(),
          onDateSelected: (final date) {},
        ),
        const SizedBox(height: 16),
        const FormFieldX(
          label: 'Description',
          hint: 'Describe the service received',
          maxLines: 3,
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: SecondaryButton(
                text: 'Add Receipt',
                icon: Icons.receipt,
                onPressed: () => _showComingSoon('Receipt upload'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: PrimaryButton(
                text: 'Submit Claim',
                onPressed: _submitClaim,
                isFullWidth: true,
              ),
            ),
          ],
        ),
      ],
    );

  Widget _buildHistoryTab() {
    final claims = _getMockClaims();

    if (claims.isEmpty) {
      return EmptyState(
        icon: Icons.receipt_long,
        title: 'No claims yet',
        description: 'Your submitted claims will appear here.',
        action: PrimaryButton(
          text: 'Submit First Claim',
          onPressed: () => _tabController.animateTo(0),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: claims.length,
      itemBuilder: (final context, final index) {
        final claim = claims[index];
        return _buildClaimCard(claim);
      },
    );
  }

  Widget _buildClaimCard(final Map<String, dynamic> claim) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  claim['provider'],
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                _StatusChip(status: claim['status']),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              claim['service'],
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$${claim['amount'].toStringAsFixed(0)}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
                Text(
                  claim['date'],
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            if (claim['status'] == 'Pending') ...[
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: 0.6,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Processing...',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _StatusChip({required final String status}) {
    final theme = Theme.of(context);

    Color backgroundColor;
    Color textColor;

    switch (status) {
      case 'Approved':
        backgroundColor = theme.colorScheme.secondaryContainer;
        textColor = theme.colorScheme.onSecondaryContainer;
        break;
      case 'Pending':
        backgroundColor = theme.colorScheme.tertiaryContainer;
        textColor = theme.colorScheme.onTertiaryContainer;
        break;
      case 'Rejected':
        backgroundColor = theme.colorScheme.errorContainer;
        textColor = theme.colorScheme.onErrorContainer;
        break;
      default:
        backgroundColor = theme.colorScheme.surfaceContainerHighest;
        textColor = theme.colorScheme.onSurfaceVariant;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: theme.textTheme.labelSmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getMockClaims() => [
      {
        'provider': 'ABC Physiotherapy',
        'service': 'Physiotherapy Session',
        'amount': 150.0,
        'date': '2024-01-15',
        'status': 'Approved',
      },
      {
        'provider': 'XYZ Occupational Therapy',
        'service': 'OT Assessment',
        'amount': 200.0,
        'date': '2024-01-10',
        'status': 'Pending',
      },
      {
        'provider': 'DEF Support Services',
        'service': 'Personal Care',
        'amount': 85.0,
        'date': '2024-01-08',
        'status': 'Approved',
      },
    ];

  void _showServiceTypeDialog() {
    showDialog(
      context: context,
      builder: (final context) => AlertDialog(
        title: const Text('Select Service Type'),
        content: const Text('Service type selection coming soon.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(final String feature) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$feature feature coming soon!')));
  }

  void _submitClaim() {
    showDialog(
      context: context,
      builder: (final context) => AlertDialog(
        title: const Text('Claim Submitted'),
        content: const Text(
          'Your claim has been submitted successfully. You will receive a notification when it\'s processed.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _tabController.animateTo(1);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
