import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../ui/components/app_scaffold.dart';
import '../../../ui/components/buttons.dart';
import '../../../ui/theme/tokens/spacing.dart';
import '../controllers/provider_controller.dart';
import '../models/ndis_provider.dart';

/// Provider Filters Screen
/// Screen for applying advanced filters to provider search
class ProviderFiltersScreen extends StatefulWidget {
  const ProviderFiltersScreen({super.key});

  @override
  State<ProviderFiltersScreen> createState() => _ProviderFiltersScreenState();
}

class _ProviderFiltersScreenState extends State<ProviderFiltersScreen> {
  late ProviderSearchFilters _filters;
  final List<String> _selectedServiceTypes = [];
  final List<String> _selectedSupportCategories = [];
  final List<String> _selectedDisabilityTypes = [];
  final List<String> _selectedAgeGroups = [];
  final List<String> _selectedLanguages = [];

  @override
  void initState() {
    super.initState();
    final controller = context.read<ProviderController>();
    _filters = controller.currentFilters;
    _selectedServiceTypes.addAll(_filters.serviceTypes);
    _selectedSupportCategories.addAll(_filters.supportCategories);
    _selectedDisabilityTypes.addAll(_filters.disabilityTypes);
    _selectedAgeGroups.addAll(_filters.ageGroups);
    _selectedLanguages.addAll(_filters.languages);
  }

  @override
  Widget build(final BuildContext context) => AppScaffold(
      title: 'Filter Providers',
      actions: [
        TextButton(
          onPressed: _clearAllFilters,
          child: const Text('Clear All'),
        ),
      ],
      body: Consumer<ProviderController>(
        builder: (final context, final controller, final child) => SingleChildScrollView(
            padding: const EdgeInsets.all(NDISSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLocationFilter(),
                const SizedBox(height: NDISSpacing.xl),
                _buildServiceTypesFilter(controller),
                const SizedBox(height: NDISSpacing.xl),
                _buildSupportCategoriesFilter(controller),
                const SizedBox(height: NDISSpacing.xl),
                _buildDisabilityTypesFilter(controller),
                const SizedBox(height: NDISSpacing.xl),
                _buildAgeGroupsFilter(controller),
                const SizedBox(height: NDISSpacing.xl),
                _buildAccessibilityFilters(),
                const SizedBox(height: NDISSpacing.xl),
                _buildServiceDeliveryFilters(),
                const SizedBox(height: NDISSpacing.xl),
                _buildLanguagesFilter(controller),
                const SizedBox(height: NDISSpacing.xl),
                _buildRatingFilter(),
                const SizedBox(height: NDISSpacing.xxl),
                _buildApplyButton(),
              ],
            ),
          ),
      ),
    );

  Widget _buildLocationFilter() => _buildFilterSection(
      title: 'Location',
      child: TextField(
        decoration: const InputDecoration(
          hintText: 'Enter suburb, city, or postcode',
          prefixIcon: Icon(Icons.location_on),
        ),
        onChanged: (final value) {
          setState(() {
            _filters = _filters.copyWith(location: value.isEmpty ? null : value);
          });
        },
      ),
    );

  Widget _buildServiceTypesFilter(final ProviderController controller) {
    final availableTypes = controller.getAvailableServiceTypes();
    
    return _buildFilterSection(
      title: 'Service Types',
      child: _buildMultiSelectChips(
        options: availableTypes,
        selected: _selectedServiceTypes,
        onChanged: (final selected) {
          setState(() {
            _selectedServiceTypes.clear();
            _selectedServiceTypes.addAll(selected);
            _filters = _filters.copyWith(serviceTypes: selected);
          });
        },
      ),
    );
  }

  Widget _buildSupportCategoriesFilter(final ProviderController controller) {
    final availableCategories = controller.getAvailableSupportCategories();
    
    return _buildFilterSection(
      title: 'Support Categories',
      child: _buildMultiSelectChips(
        options: availableCategories,
        selected: _selectedSupportCategories,
        onChanged: (final selected) {
          setState(() {
            _selectedSupportCategories.clear();
            _selectedSupportCategories.addAll(selected);
            _filters = _filters.copyWith(supportCategories: selected);
          });
        },
      ),
    );
  }

  Widget _buildDisabilityTypesFilter(final ProviderController controller) {
    final availableTypes = controller.getAvailableDisabilityTypes();
    
    return _buildFilterSection(
      title: 'Disability Types',
      child: _buildMultiSelectChips(
        options: availableTypes,
        selected: _selectedDisabilityTypes,
        onChanged: (final selected) {
          setState(() {
            _selectedDisabilityTypes.clear();
            _selectedDisabilityTypes.addAll(selected);
            _filters = _filters.copyWith(disabilityTypes: selected);
          });
        },
      ),
    );
  }

  Widget _buildAgeGroupsFilter(final ProviderController controller) {
    final availableAgeGroups = controller.getAvailableAgeGroups();
    
    return _buildFilterSection(
      title: 'Age Groups',
      child: _buildMultiSelectChips(
        options: availableAgeGroups,
        selected: _selectedAgeGroups,
        onChanged: (final selected) {
          setState(() {
            _selectedAgeGroups.clear();
            _selectedAgeGroups.addAll(selected);
            _filters = _filters.copyWith(ageGroups: selected);
          });
        },
      ),
    );
  }

  Widget _buildAccessibilityFilters() => _buildFilterSection(
      title: 'Accessibility & Inclusion',
      child: Column(
        children: [
          _buildCheckboxTile(
            title: 'Culturally Appropriate Services',
            subtitle: 'Services that are culturally sensitive and appropriate',
            value: _filters.isCulturallyAppropriate ?? false,
            onChanged: (final value) {
              setState(() {
                _filters = _filters.copyWith(
                  isCulturallyAppropriate: value ? true : null,
                );
              });
            },
          ),
          _buildCheckboxTile(
            title: 'LGBTI+ Friendly',
            subtitle: 'Services that are welcoming to LGBTI+ community',
            value: _filters.isLgbtiFriendly ?? false,
            onChanged: (final value) {
              setState(() {
                _filters = _filters.copyWith(
                  isLgbtiFriendly: value ? true : null,
                );
              });
            },
          ),
          _buildCheckboxTile(
            title: 'Aboriginal & Torres Strait Islander',
            subtitle: 'Services specifically for Aboriginal and Torres Strait Islander people',
            value: _filters.isAboriginalTorresStraitIslander ?? false,
            onChanged: (final value) {
              setState(() {
                _filters = _filters.copyWith(
                  isAboriginalTorresStraitIslander: value ? true : null,
                );
              });
            },
          ),
        ],
      ),
    );

  Widget _buildServiceDeliveryFilters() => _buildFilterSection(
      title: 'Service Delivery',
      child: Column(
        children: [
          _buildCheckboxTile(
            title: 'Remote Services',
            subtitle: 'Services delivered remotely (online, phone)',
            value: _filters.isRemoteService ?? false,
            onChanged: (final value) {
              setState(() {
                _filters = _filters.copyWith(
                  isRemoteService: value ? true : null,
                );
              });
            },
          ),
          _buildCheckboxTile(
            title: 'Home Visits',
            subtitle: 'Services delivered at your home',
            value: _filters.isHomeVisits ?? false,
            onChanged: (final value) {
              setState(() {
                _filters = _filters.copyWith(
                  isHomeVisits: value ? true : null,
                );
              });
            },
          ),
          _buildCheckboxTile(
            title: 'Group Services',
            subtitle: 'Services delivered in group settings',
            value: _filters.isGroupService ?? false,
            onChanged: (final value) {
              setState(() {
                _filters = _filters.copyWith(
                  isGroupService: value ? true : null,
                );
              });
            },
          ),
          _buildCheckboxTile(
            title: 'Individual Services',
            subtitle: 'One-on-one services',
            value: _filters.isIndividualService ?? false,
            onChanged: (final value) {
              setState(() {
                _filters = _filters.copyWith(
                  isIndividualService: value ? true : null,
                );
              });
            },
          ),
        ],
      ),
    );

  Widget _buildLanguagesFilter(final ProviderController controller) {
    final availableLanguages = controller.getAvailableLanguages();
    
    return _buildFilterSection(
      title: 'Languages',
      child: _buildMultiSelectChips(
        options: availableLanguages,
        selected: _selectedLanguages,
        onChanged: (final selected) {
          setState(() {
            _selectedLanguages.clear();
            _selectedLanguages.addAll(selected);
            _filters = _filters.copyWith(languages: selected);
          });
        },
      ),
    );
  }

  Widget _buildRatingFilter() => _buildFilterSection(
      title: 'Minimum Rating',
      child: Column(
        children: [
          Slider(
            value: _filters.minRating ?? 0.0,
            max: 5,
            divisions: 10,
            label: _filters.minRating?.toStringAsFixed(1) ?? 'Any',
            onChanged: (final value) {
              setState(() {
                _filters = _filters.copyWith(
                  minRating: value > 0.0 ? value : null,
                );
              });
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Any rating',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                '5.0 stars',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );

  Widget _buildFilterSection({
    required final String title,
    required final Widget child,
  }) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: NDISSpacing.md),
        child,
      ],
    );

  Widget _buildMultiSelectChips({
    required final List<String> options,
    required final List<String> selected,
    required final ValueChanged<List<String>> onChanged,
  }) {
    if (options.isEmpty) {
      return Text(
        'No options available',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      );
    }

    return Wrap(
      spacing: NDISSpacing.sm,
      runSpacing: NDISSpacing.sm,
      children: options.map((final option) {
        final isSelected = selected.contains(option);
        return FilterChip(
          label: Text(option),
          selected: isSelected,
          onSelected: (final selected) {
            final newSelection = List<String>.from(this.selected);
            if (selected) {
              newSelection.add(option);
            } else {
              newSelection.remove(option);
            }
            onChanged(newSelection);
          },
        );
      }).toList(),
    );
  }

  Widget _buildCheckboxTile({
    required final String title,
    required final String subtitle,
    required final bool value,
    required final ValueChanged<bool> onChanged,
  }) => CheckboxListTile(
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      value: value,
      onChanged: (final newValue) => onChanged(newValue ?? false),
      contentPadding: EdgeInsets.zero,
    );

  Widget _buildApplyButton() => SizedBox(
      width: double.infinity,
      child: PrimaryButton(
        text: 'Apply Filters',
        onPressed: _applyFilters,
      ),
    );

  void _applyFilters() {
    final controller = context.read<ProviderController>();
    controller.searchProviders(filters: _filters);
    Navigator.of(context).pop();
  }

  void _clearAllFilters() {
    setState(() {
      _filters = const ProviderSearchFilters();
      _selectedServiceTypes.clear();
      _selectedSupportCategories.clear();
      _selectedDisabilityTypes.clear();
      _selectedAgeGroups.clear();
      _selectedLanguages.clear();
    });
  }
}
