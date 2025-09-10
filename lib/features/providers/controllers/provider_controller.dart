import 'package:flutter/foundation.dart';
import '../models/ndis_provider.dart';
import '../services/ndis_provider_service.dart';

/// Provider Controller
/// Manages provider state and business logic
class ProviderController extends ChangeNotifier {

  ProviderController({required final NDISProviderService providerService})
      : _providerService = providerService;
  final NDISProviderService _providerService;

  // State
  List<NDISProvider> _providers = [];
  List<NDISProvider> _favoriteProviders = [];
  NDISProvider? _selectedProvider;
  ProviderSearchFilters _currentFilters = const ProviderSearchFilters();
  ProviderSearchResult? _lastSearchResult;
  
  bool _isLoading = false;
  bool _isSearching = false;
  String? _error;
  String? _searchQuery;
  int _currentPage = 1;
  bool _hasMore = false;

  // Getters
  List<NDISProvider> get providers => _providers;
  List<NDISProvider> get favoriteProviders => _favoriteProviders;
  NDISProvider? get selectedProvider => _selectedProvider;
  ProviderSearchFilters get currentFilters => _currentFilters;
  ProviderSearchResult? get lastSearchResult => _lastSearchResult;
  
  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  String? get error => _error;
  String? get searchQuery => _searchQuery;
  int get currentPage => _currentPage;
  bool get hasMore => _hasMore;
  
  bool get hasActiveFilters => _currentFilters.hasActiveFilters;
  int get totalResults => _lastSearchResult?.totalCount ?? 0;

  /// Initialize the controller
  Future<void> initialize() async {
    _setLoading(true);
    try {
      await _loadFavoriteProviders();
      await searchProviders();
    } catch (e) {
      _setError('Failed to initialize providers: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Search for providers with filters
  Future<void> searchProviders({
    final ProviderSearchFilters? filters,
    final bool resetPage = true,
  }) async {
    if (resetPage) {
      _currentPage = 1;
    }

    _setSearching(true);
    _setError(null);

    try {
      final searchFilters = filters ?? _currentFilters;
      _currentFilters = searchFilters;
      _searchQuery = searchFilters.query;

      final result = await _providerService.searchProviders(
        filters: searchFilters,
        page: _currentPage,
      );

      _lastSearchResult = result;
      _hasMore = result.hasMore;

      if (resetPage) {
        _providers = result.providers;
      } else {
        _providers.addAll(result.providers);
      }

      notifyListeners();
    } catch (e) {
      _setError('Search failed: $e');
    } finally {
      _setSearching(false);
    }
  }

  /// Load more providers (pagination)
  Future<void> loadMoreProviders() async {
    if (!_hasMore || _isSearching) return;

    _currentPage++;
    await searchProviders(resetPage: false);
  }

  /// Clear search and filters
  void clearSearch() {
    _currentFilters = const ProviderSearchFilters();
    _searchQuery = null;
    _currentPage = 1;
    _providers.clear();
    _lastSearchResult = null;
    _hasMore = false;
    notifyListeners();
  }

  /// Update search query
  void updateSearchQuery(final String query) {
    _searchQuery = query;
    _currentFilters = _currentFilters.copyWith(query: query.isEmpty ? null : query);
    notifyListeners();
  }

  /// Update location filter
  void updateLocationFilter(final String? location) {
    _currentFilters = _currentFilters.copyWith(location: location);
    notifyListeners();
  }

  /// Update service type filters
  void updateServiceTypeFilters(final List<String> serviceTypes) {
    _currentFilters = _currentFilters.copyWith(serviceTypes: serviceTypes);
    notifyListeners();
  }

  /// Update support category filters
  void updateSupportCategoryFilters(final List<String> supportCategories) {
    _currentFilters = _currentFilters.copyWith(supportCategories: supportCategories);
    notifyListeners();
  }

  /// Update disability type filters
  void updateDisabilityTypeFilters(final List<String> disabilityTypes) {
    _currentFilters = _currentFilters.copyWith(disabilityTypes: disabilityTypes);
    notifyListeners();
  }

  /// Update age group filters
  void updateAgeGroupFilters(final List<String> ageGroups) {
    _currentFilters = _currentFilters.copyWith(ageGroups: ageGroups);
    notifyListeners();
  }

  /// Update accessibility filters
  void updateAccessibilityFilters({
    final bool? isCulturallyAppropriate,
    final bool? isLgbtiFriendly,
    final bool? isAboriginalTorresStraitIslander,
  }) {
    _currentFilters = _currentFilters.copyWith(
      isCulturallyAppropriate: isCulturallyAppropriate,
      isLgbtiFriendly: isLgbtiFriendly,
      isAboriginalTorresStraitIslander: isAboriginalTorresStraitIslander,
    );
    notifyListeners();
  }

  /// Update service delivery filters
  void updateServiceDeliveryFilters({
    final bool? isRemoteService,
    final bool? isHomeVisits,
    final bool? isGroupService,
    final bool? isIndividualService,
  }) {
    _currentFilters = _currentFilters.copyWith(
      isRemoteService: isRemoteService,
      isHomeVisits: isHomeVisits,
      isGroupService: isGroupService,
      isIndividualService: isIndividualService,
    );
    notifyListeners();
  }

  /// Update language filters
  void updateLanguageFilters(final List<String> languages) {
    _currentFilters = _currentFilters.copyWith(languages: languages);
    notifyListeners();
  }

  /// Update rating filter
  void updateRatingFilter(final double? minRating) {
    _currentFilters = _currentFilters.copyWith(minRating: minRating);
    notifyListeners();
  }

  /// Toggle favorites filter
  void toggleFavoritesFilter() {
    final showOnlyFavorites = _currentFilters.showOnlyFavorites != true;
    _currentFilters = _currentFilters.copyWith(showOnlyFavorites: showOnlyFavorites);
    notifyListeners();
  }

  /// Get provider by ID
  Future<NDISProvider?> getProviderById(final String id) async {
    try {
      return await _providerService.getProviderById(id);
    } catch (e) {
      _setError('Failed to get provider: $e');
      return null;
    }
  }

  /// Select a provider
  void selectProvider(final NDISProvider provider) {
    _selectedProvider = provider;
    notifyListeners();
  }

  /// Clear selected provider
  void clearSelectedProvider() {
    _selectedProvider = null;
    notifyListeners();
  }

  /// Toggle provider favorite status
  Future<void> toggleFavorite(final String providerId) async {
    try {
      await _providerService.toggleFavorite(providerId);
      
      // Update local state
      _providers = _providers.map((final provider) {
        if (provider.id == providerId) {
          return provider.copyWith(isFavorite: !provider.isFavorite);
        }
        return provider;
      }).toList();

      if (_selectedProvider?.id == providerId) {
        _selectedProvider = _selectedProvider!.copyWith(
          isFavorite: !_selectedProvider!.isFavorite,
        );
      }

      await _loadFavoriteProviders();
      notifyListeners();
    } catch (e) {
      _setError('Failed to update favorite: $e');
    }
  }

  /// Load favorite providers
  Future<void> _loadFavoriteProviders() async {
    try {
      _favoriteProviders = await _providerService.getFavoriteProviders();
    } catch (e) {
      // Handle error silently for favorites
    }
  }

  /// Refresh provider data
  Future<void> refreshProviderData() async {
    _setLoading(true);
    try {
      await _providerService.refreshProviderData();
      await searchProviders();
    } catch (e) {
      _setError('Failed to refresh data: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Check if cache is expired
  bool get isCacheExpired => _providerService.isCacheExpired;

  /// Get available service types from current providers
  List<String> getAvailableServiceTypes() {
    final serviceTypes = <String>{};
    for (final provider in _providers) {
      serviceTypes.addAll(provider.serviceTypes);
    }
    return serviceTypes.toList()..sort();
  }

  /// Get available support categories from current providers
  List<String> getAvailableSupportCategories() {
    final categories = <String>{};
    for (final provider in _providers) {
      categories.addAll(provider.supportCategories);
    }
    return categories.toList()..sort();
  }

  /// Get available disability types from current providers
  List<String> getAvailableDisabilityTypes() {
    final types = <String>{};
    for (final provider in _providers) {
      types.addAll(provider.disabilityTypes);
    }
    return types.toList()..sort();
  }

  /// Get available age groups from current providers
  List<String> getAvailableAgeGroups() {
    final ageGroups = <String>{};
    for (final provider in _providers) {
      ageGroups.addAll(provider.ageGroups);
    }
    return ageGroups.toList()..sort();
  }

  /// Get available languages from current providers
  List<String> getAvailableLanguages() {
    final languages = <String>{};
    for (final provider in _providers) {
      languages.addAll(provider.languages);
    }
    return languages.toList()..sort();
  }

  /// Get providers near a location
  List<NDISProvider> getProvidersNearLocation({
    required final double latitude,
    required final double longitude,
    final double radiusKm = 50.0,
  }) => _providers.where((final provider) {
      if (provider.latitude == null || provider.longitude == null) return false;
      
      final distance = provider.getDistanceFrom(latitude, longitude);
      return distance != null && distance <= radiusKm;
    }).toList()
      ..sort((final a, final b) {
        final distanceA = a.getDistanceFrom(latitude, longitude) ?? double.infinity;
        final distanceB = b.getDistanceFrom(latitude, longitude) ?? double.infinity;
        return distanceA.compareTo(distanceB);
      });

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Set loading state
  void _setLoading(final bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Set searching state
  void _setSearching(final bool searching) {
    _isSearching = searching;
    notifyListeners();
  }

  /// Set error
  void _setError(final String? error) {
    _error = error;
    notifyListeners();
  }

  @override
  void dispose() {
    _providerService.dispose();
    super.dispose();
  }
}
