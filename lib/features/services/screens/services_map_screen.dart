import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../ui/components/app_scaffold.dart';
import '../../../ui/components/buttons.dart';
import '../../../ui/components/forms.dart';
import '../../../ui/components/empty_states.dart';
import '../../../app/router.dart';
import '../../providers/controllers/provider_controller.dart';
import '../../providers/models/ndis_provider.dart';
import '../../providers/screens/provider_detail_screen.dart';

/// Services Map Screen
/// Find and contact NDIS service providers
class ServicesMapScreen extends StatefulWidget {
  const ServicesMapScreen({super.key});

  @override
  State<ServicesMapScreen> createState() => _ServicesMapScreenState();
}

class _ServicesMapScreenState extends State<ServicesMapScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  String _selectedCategory = 'All';
  final bool _showNDISProviders = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Initialize provider controller
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProviderController>().initialize();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) => AppScaffold(
    title: 'Find Services',
    body: Column(
      children: [
        _buildSearchAndFilters(),
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'List'),
            Tab(text: 'Map'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [_buildServicesList(), _buildMapView()],
          ),
        ),
      ],
    ),
  );

  Widget _buildSearchAndFilters() => Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        SearchField(
          hint: 'Search services...',
          onChanged: (final query) => setState(() => _searchQuery = query),
        ),
        const SizedBox(height: 12),
        _buildCategoryFilter(),
      ],
    ),
  );

  Widget _buildCategoryFilter() {
    final categories = [
      'All',
      'Physiotherapy',
      'Occupational Therapy',
      'Speech Therapy',
      'Support Work',
    ];

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (final context, final index) {
          final category = categories[index];
          final isSelected = _selectedCategory == category;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (final selected) {
                setState(() => _selectedCategory = category);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildServicesList() {
    final services = _getFilteredServices();

    if (services.isEmpty) {
      return EmptyState(
        icon: Icons.location_off,
        title: 'No services found',
        description: 'Try adjusting your search or filters.',
        action: SecondaryButton(
          text: 'Clear Filters',
          onPressed: () {
            setState(() {
              _searchQuery = '';
              _selectedCategory = 'All';
            });
          },
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: services.length,
      itemBuilder: (final context, final index) {
        final service = services[index];
        return _buildServiceCard(service);
      },
    );
  }

  Widget _buildServiceCard(final Map<String, dynamic> service) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    service['icon'],
                    color: theme.colorScheme.onPrimaryContainer,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service['name'],
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        service['category'],
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.favorite_border),
                  onPressed: () => _toggleFavorite(service),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    service['address'],
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.star, size: 16, color: Colors.amber),
                const SizedBox(width: 4),
                Text(
                  service['rating'].toString(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '(${service['reviews']} reviews)',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                Text(
                  service['distance'],
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    text: 'View Details',
                    onPressed: () => _showServiceDetails(service),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PrimaryButton(
                    text: 'Contact',
                    onPressed: () => _contactService(service),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapView() => EmptyState(
    icon: Icons.map,
    title: 'Map View Coming Soon',
    description:
        'Interactive map with service locations will be available in a future update.',
    action: SecondaryButton(
      text: 'Use List View',
      onPressed: () => _tabController.animateTo(0),
    ),
  );

  List<Map<String, dynamic>> _getFilteredServices() {
    final allServices = [
      {
        'name': 'ABC Physiotherapy',
        'category': 'Physiotherapy',
        'address': '123 Health St, Melbourne VIC 3000',
        'rating': 4.8,
        'reviews': 124,
        'distance': '2.3 km',
        'icon': Icons.medical_services,
        'phone': '03 1234 5678',
        'email': 'info@abcphysio.com.au',
        'isFavorite': false,
      },
      {
        'name': 'XYZ Occupational Therapy',
        'category': 'Occupational Therapy',
        'address': '456 Care Ave, Melbourne VIC 3000',
        'rating': 4.6,
        'reviews': 89,
        'distance': '1.8 km',
        'icon': Icons.accessible,
        'phone': '03 9876 5432',
        'email': 'contact@xyzot.com.au',
        'isFavorite': true,
      },
      {
        'name': 'DEF Speech Therapy',
        'category': 'Speech Therapy',
        'address': '789 Communication Rd, Melbourne VIC 3000',
        'rating': 4.9,
        'reviews': 156,
        'distance': '3.1 km',
        'icon': Icons.record_voice_over,
        'phone': '03 5555 1234',
        'email': 'hello@defspeech.com.au',
        'isFavorite': false,
      },
      {
        'name': 'GHI Support Services',
        'category': 'Support Work',
        'address': '321 Support St, Melbourne VIC 3000',
        'rating': 4.7,
        'reviews': 203,
        'distance': '4.2 km',
        'icon': Icons.people,
        'phone': '03 7777 8888',
        'email': 'support@ghiservices.com.au',
        'isFavorite': false,
      },
    ];

    var filtered = allServices;

    // Filter by category
    if (_selectedCategory != 'All') {
      filtered = filtered
          .where((final service) => service['category'] == _selectedCategory)
          .toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((final service) {
        final name = service['name'].toString().toLowerCase();
        final category = service['category'].toString().toLowerCase();
        final query = _searchQuery.toLowerCase();
        return name.contains(query) || category.contains(query);
      }).toList();
    }

    return filtered;
  }

  void _toggleFavorite(final Map<String, dynamic> service) {
    setState(() {
      service['isFavorite'] = !service['isFavorite'];
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          service['isFavorite']
              ? 'Added to favorites'
              : 'Removed from favorites',
        ),
      ),
    );
  }

  void _showServiceDetails(final Map<String, dynamic> service) {
    showDialog(
      context: context,
      builder: (final context) => AlertDialog(
        title: Text(service['name']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Category: ${service['category']}'),
            Text('Address: ${service['address']}'),
            Text('Phone: ${service['phone']}'),
            Text('Email: ${service['email']}'),
            Text(
              'Rating: ${service['rating']} (${service['reviews']} reviews)',
            ),
            Text('Distance: ${service['distance']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _contactService(service);
            },
            child: const Text('Contact'),
          ),
        ],
      ),
    );
  }

  void _contactService(final Map<String, dynamic> service) {
    showDialog(
      context: context,
      builder: (final context) => AlertDialog(
        title: Text('Contact ${service['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('Call'),
              subtitle: Text(service['phone']),
              onTap: () {
                Navigator.of(context).pop();
                _showComingSoon('Phone calling');
              },
            ),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Email'),
              subtitle: Text(service['email']),
              onTap: () {
                Navigator.of(context).pop();
                _showComingSoon('Email integration');
              },
            ),
            ListTile(
              leading: const Icon(Icons.message),
              title: const Text('Send Message'),
              subtitle: const Text('Send a secure message'),
              onTap: () {
                Navigator.of(context).pop();
                context.pushMessages();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
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
}
