import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../ui/components/app_scaffold.dart';
import '../../../ui/components/buttons.dart';
import '../../../ui/components/forms.dart';
import '../../../ui/components/empty_states.dart';
import '../../../ui/theme/tokens/spacing.dart';
import '../../../ui/theme/tokens/colors.dart';
import '../controllers/provider_controller.dart';
import '../models/ndis_provider.dart';
import 'provider_detail_screen.dart';
import 'provider_filters_screen.dart';

/// Provider Search Screen
/// Main screen for searching and browsing NDIS providers
class ProviderSearchScreen extends StatefulWidget {
  const ProviderSearchScreen({super.key});

  @override
  State<ProviderSearchScreen> createState() => _ProviderSearchScreenState();
}

class _ProviderSearchScreenState extends State<ProviderSearchScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _scrollController.addListener(_onScroll);
    
    // Initialize provider controller
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProviderController>().initialize();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<ProviderController>().loadMoreProviders();
    }
  }

  @override
  Widget build(final BuildContext context) => AppScaffold(
      title: 'Find Providers',
      actions: [
        IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: _showFilters,
          tooltip: 'Filter providers',
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _refreshData,
          tooltip: 'Refresh data',
        ),
      ],
      body: Column(
        children: [
          _buildSearchAndFilters(),
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'All Providers'),
              Tab(text: 'Favorites'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildProvidersList(),
                _buildFavoritesList(),
              ],
            ),
          ),
        ],
      ),
    );

  Widget _buildSearchAndFilters() => Consumer<ProviderController>(
      builder: (final context, final controller, final child) => Padding(
          padding: const EdgeInsets.all(NDISSpacing.lg),
          child: Column(
            children: [
              SearchField(
                controller: _searchController,
                hint: 'Search providers, services, or locations...',
                onChanged: (final query) {
                  controller.updateSearchQuery(query);
                  _performSearch();
                },
                onSubmitted: (_) => _performSearch(),
              ),
              const SizedBox(height: NDISSpacing.md),
              _buildActiveFilters(controller),
            ],
          ),
        ),
    );

  Widget _buildActiveFilters(final ProviderController controller) {
    if (!controller.hasActiveFilters) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: NDISSpacing.md,
        vertical: NDISSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(NDISSpacing.radiusMd),
      ),
      child: Row(
        children: [
          Icon(
            Icons.filter_alt,
            size: NDISSpacing.iconSm,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: NDISSpacing.sm),
          Expanded(
            child: Text(
              'Filters active',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              controller.clearSearch();
              _searchController.clear();
            },
            child: Text(
              'Clear',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProvidersList() => Consumer<ProviderController>(
      builder: (final context, final controller, final child) {
        if (controller.isLoading && controller.providers.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.error != null) {
          return _buildErrorState(controller);
        }

        if (controller.providers.isEmpty) {
          return _buildEmptyState(controller);
        }

        return RefreshIndicator(
          onRefresh: controller.refreshProviderData,
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(NDISSpacing.lg),
            itemCount: controller.providers.length + (controller.hasMore ? 1 : 0),
            itemBuilder: (final context, final index) {
              if (index >= controller.providers.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(NDISSpacing.lg),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final provider = controller.providers[index];
              return _buildProviderCard(provider, controller);
            },
          ),
        );
      },
    );

  Widget _buildFavoritesList() => Consumer<ProviderController>(
      builder: (final context, final controller, final child) {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.favoriteProviders.isEmpty) {
          return EmptyState(
            icon: Icons.favorite_border,
            title: 'No favorite providers',
            description: 'Add providers to your favorites to see them here.',
            action: SecondaryButton(
              text: 'Browse Providers',
              onPressed: () => _tabController.animateTo(0),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshProviderData,
          child: ListView.builder(
            padding: const EdgeInsets.all(NDISSpacing.lg),
            itemCount: controller.favoriteProviders.length,
            itemBuilder: (final context, final index) {
              final provider = controller.favoriteProviders[index];
              return _buildProviderCard(provider, controller);
            },
          ),
        );
      },
    );

  Widget _buildProviderCard(final NDISProvider provider, final ProviderController controller) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: NDISSpacing.md),
      child: InkWell(
        onTap: () => _navigateToProviderDetail(provider),
        borderRadius: BorderRadius.circular(NDISSpacing.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(NDISSpacing.lg),
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
                      borderRadius: BorderRadius.circular(NDISSpacing.radiusSm),
                    ),
                    child: Icon(
                      _getProviderIcon(provider),
                      color: theme.colorScheme.onPrimaryContainer,
                      size: NDISSpacing.iconMd,
                    ),
                  ),
                  const SizedBox(width: NDISSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          provider.displayName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (provider.businessName != null && provider.businessName != provider.name)
                          Text(
                            provider.businessName!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      provider.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: provider.isFavorite ? NDISColors.error : null,
                    ),
                    onPressed: () => controller.toggleFavorite(provider.id),
                    tooltip: provider.isFavorite ? 'Remove from favorites' : 'Add to favorites',
                  ),
                ],
              ),
              const SizedBox(height: NDISSpacing.md),
              if (provider.serviceTypes.isNotEmpty)
                Wrap(
                  spacing: NDISSpacing.xs,
                  runSpacing: NDISSpacing.xs,
                  children: provider.serviceTypes.take(3).map((final type) => Chip(
                      label: Text(
                        type,
                        style: theme.textTheme.labelSmall,
                      ),
                      backgroundColor: theme.colorScheme.secondaryContainer,
                      labelStyle: TextStyle(
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                    )).toList(),
                ),
              const SizedBox(height: NDISSpacing.sm),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: NDISSpacing.iconSm,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: NDISSpacing.xs),
                  Expanded(
                    child: Text(
                      provider.fullAddress,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              if (provider.rating != null) ...[
                const SizedBox(height: NDISSpacing.sm),
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
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: NDISSpacing.sm),
                    Text(
                      '(${provider.reviewCount} reviews)',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: NDISSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: SecondaryButton(
                      text: 'View Details',
                      onPressed: () => _navigateToProviderDetail(provider),
                    ),
                  ),
                  const SizedBox(width: NDISSpacing.sm),
                  Expanded(
                    child: PrimaryButton(
                      text: 'Contact',
                      onPressed: () => _contactProvider(provider),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(final ProviderController controller) => EmptyState(
      icon: Icons.error_outline,
      title: 'Error loading providers',
      description: controller.error ?? 'An unexpected error occurred.',
      action: Column(
        children: [
          PrimaryButton(
            text: 'Retry',
            onPressed: controller.refreshProviderData,
          ),
          const SizedBox(height: NDISSpacing.sm),
          SecondaryButton(
            text: 'Clear Error',
            onPressed: controller.clearError,
          ),
        ],
      ),
    );

  Widget _buildEmptyState(final ProviderController controller) => EmptyState(
      icon: Icons.search_off,
      title: 'No providers found',
      description: controller.hasActiveFilters
          ? 'Try adjusting your search criteria or filters.'
          : 'No providers are currently available.',
      action: controller.hasActiveFilters
          ? SecondaryButton(
              text: 'Clear Filters',
              onPressed: () {
                controller.clearSearch();
                _searchController.clear();
              },
            )
          : PrimaryButton(
              text: 'Refresh',
              onPressed: controller.refreshProviderData,
            ),
    );

  IconData _getProviderIcon(final NDISProvider provider) {
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

  void _performSearch() {
    context.read<ProviderController>().searchProviders();
  }

  void _showFilters() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (final context) => const ProviderFiltersScreen(),
      ),
    );
  }

  void _refreshData() {
    context.read<ProviderController>().refreshProviderData();
  }

  void _navigateToProviderDetail(final NDISProvider provider) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (final context) => ProviderDetailScreen(provider: provider),
      ),
    );
  }

  void _contactProvider(final NDISProvider provider) {
    showModalBottomSheet(
      context: context,
      builder: (final context) => _buildContactBottomSheet(provider),
    );
  }

  Widget _buildContactBottomSheet(final NDISProvider provider) {
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
                _showComingSoon('Phone calling');
              },
            ),
          if (provider.email != null)
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Email'),
              subtitle: Text(provider.email!),
              onTap: () {
                Navigator.of(context).pop();
                _showComingSoon('Email integration');
              },
            ),
          if (provider.website != null)
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('Website'),
              subtitle: Text(provider.website!),
              onTap: () {
                Navigator.of(context).pop();
                _showComingSoon('Website opening');
              },
            ),
          ListTile(
            leading: const Icon(Icons.message),
            title: const Text('Send Message'),
            subtitle: const Text('Send a secure message'),
            onTap: () {
              Navigator.of(context).pop();
              _showComingSoon('Messaging system');
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

  void _showComingSoon(final String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature feature coming soon!')),
    );
  }
}
