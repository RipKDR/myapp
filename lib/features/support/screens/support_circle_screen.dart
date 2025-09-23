import 'package:flutter/material.dart';
import '../../../ui/components/app_scaffold.dart';
import '../../../ui/components/buttons.dart';
import '../../../ui/components/empty_states.dart';
import '../../../app/router.dart';

/// Support Circle Screen
/// Manage family, carers, and support network
class SupportCircleScreen extends StatefulWidget {
  const SupportCircleScreen({super.key});

  @override
  State<SupportCircleScreen> createState() => _SupportCircleScreenState();
}

class _SupportCircleScreenState extends State<SupportCircleScreen> {
  String _selectedFilter = 'All';

  @override
  Widget build(final BuildContext context) => AppScaffold(
      title: 'Support Circle',
      actions: [
        IconButton(
          icon: const Icon(Icons.person_add),
          onPressed: _invitePerson,
        ),
      ],
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: _buildSupportCircleList(),
          ),
        ],
      ),
    );

  Widget _buildFilterChips() {
    final filters = ['All', 'Family', 'Carers', 'Friends', 'Professionals'];
    
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (final context, final index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (final selected) {
                setState(() => _selectedFilter = filter);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildSupportCircleList() {
    final people = _getFilteredPeople();
    
    if (people.isEmpty) {
      return EmptyState(
        icon: Icons.people_outline,
        title: 'No support people yet',
        description: 'Add family members, carers, and friends to your support circle.',
        action: PrimaryButton(
          text: 'Invite Someone',
          onPressed: _invitePerson,
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: people.length,
      itemBuilder: (final context, final index) {
        final person = people[index];
        return _buildPersonCard(person);
      },
    );
  }

  Widget _buildPersonCard(final Map<String, dynamic> person) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: _getRoleColor(person['role']).withOpacity(0.1),
                  child: Text(
                    person['name'].split(' ').map((final n) => n[0]).join(),
                    style: TextStyle(
                      color: _getRoleColor(person['role']),
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                ),
                if (person['isOnline'])
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.colorScheme.surface,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    person['name'],
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    person['role'],
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (person['relationship'] != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      person['relationship'],
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _PermissionChip(
                        label: 'View Plan',
                        hasPermission: person['permissions']['viewPlan'],
                      ),
                      const SizedBox(width: 8),
                      _PermissionChip(
                        label: 'Messages',
                        hasPermission: person['permissions']['messages'],
                      ),
                      const SizedBox(width: 8),
                      _PermissionChip(
                        label: 'Emergency',
                        hasPermission: person['permissions']['emergency'],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (final value) => _handlePersonAction(value, person),
              itemBuilder: (final context) => [
                const PopupMenuItem(
                  value: 'message',
                  child: ListTile(
                    leading: Icon(Icons.message),
                    title: Text('Send Message'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'call',
                  child: ListTile(
                    leading: Icon(Icons.phone),
                    title: Text('Call'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'permissions',
                  child: ListTile(
                    leading: Icon(Icons.security),
                    title: Text('Manage Permissions'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'remove',
                  child: ListTile(
                    leading: Icon(Icons.remove_circle, color: Colors.red),
                    title: Text('Remove', style: TextStyle(color: Colors.red)),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _PermissionChip({required final String label, required final bool hasPermission}) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: hasPermission 
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: hasPermission 
              ? theme.colorScheme.onPrimaryContainer
              : theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredPeople() {
    final allPeople = [
      {
        'name': 'John Smith',
        'role': 'Family',
        'relationship': 'Father',
        'isOnline': true,
        'permissions': {
          'viewPlan': true,
          'messages': true,
          'emergency': true,
        },
      },
      {
        'name': 'Mary Smith',
        'role': 'Family',
        'relationship': 'Mother',
        'isOnline': false,
        'permissions': {
          'viewPlan': true,
          'messages': true,
          'emergency': true,
        },
      },
      {
        'name': 'Sarah Johnson',
        'role': 'Carers',
        'relationship': 'Primary Carer',
        'isOnline': true,
        'permissions': {
          'viewPlan': true,
          'messages': true,
          'emergency': true,
        },
      },
      {
        'name': 'Mike Wilson',
        'role': 'Carers',
        'relationship': 'Support Worker',
        'isOnline': false,
        'permissions': {
          'viewPlan': false,
          'messages': true,
          'emergency': false,
        },
      },
      {
        'name': 'Emma Davis',
        'role': 'Professionals',
        'relationship': 'NDIS Planner',
        'isOnline': false,
        'permissions': {
          'viewPlan': true,
          'messages': true,
          'emergency': false,
        },
      },
      {
        'name': 'David Brown',
        'role': 'Friends',
        'relationship': 'Close Friend',
        'isOnline': true,
        'permissions': {
          'viewPlan': false,
          'messages': true,
          'emergency': true,
        },
      },
    ];
    
    if (_selectedFilter == 'All') {
      return allPeople;
    }
    
    return allPeople.where((final person) => person['role'] == _selectedFilter).toList();
  }

  Color _getRoleColor(final String role) {
    final theme = Theme.of(context);
    
    switch (role) {
      case 'Family':
        return theme.colorScheme.primary;
      case 'Carers':
        return theme.colorScheme.secondary;
      case 'Professionals':
        return theme.colorScheme.tertiary;
      case 'Friends':
        return Colors.purple;
      default:
        return theme.colorScheme.onSurfaceVariant;
    }
  }

  void _invitePerson() {
    showDialog(
      context: context,
      builder: (final context) => AlertDialog(
        title: const Text('Invite to Support Circle'),
        content: const Text('Invite someone to join your support circle feature coming soon.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _handlePersonAction(final String action, final Map<String, dynamic> person) {
    switch (action) {
      case 'message':
        context.pushMessages();
        break;
      case 'call':
        _showComingSoon('Phone calling');
        break;
      case 'permissions':
        _showPermissionsDialog(person);
        break;
      case 'remove':
        _showRemoveConfirmation(person);
        break;
    }
  }

  void _showPermissionsDialog(final Map<String, dynamic> person) {
    showDialog(
      context: context,
      builder: (final context) => AlertDialog(
        title: Text('Permissions for ${person['name']}'),
        content: const Text('Permission management feature coming soon.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showRemoveConfirmation(final Map<String, dynamic> person) {
    showDialog(
      context: context,
      builder: (final context) => AlertDialog(
        title: const Text('Remove from Support Circle'),
        content: Text('Are you sure you want to remove ${person['name']} from your support circle?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showComingSoon('Remove person');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(final String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature feature coming soon!'),
      ),
    );
  }
}
