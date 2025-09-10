import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ndis_provider.dart';

/// NDIS Provider Service
/// Handles fetching provider data from NDIS datasets and web scraping
class NDISProviderService {

  NDISProviderService({
    final http.Client? httpClient,
    final SharedPreferences? prefs,
  }) : _httpClient = httpClient ?? http.Client(),
       _prefs = prefs ?? throw 
  static const String _baseUrl = 'https://dataresearch.ndis.gov.au';
  static const String _providerFinderUrl = 'https://www.ndis.gov.au/participants/working-providers/find-registered-provider/provider-finder';
  static const String _cacheKey = 'ndis_providers_cache';
  static const String _lastUpdateKey = 'ndis_providers_last_update';
  static const Duration _cacheExpiry = Duration(hours: 24);

  final http.Client _httpClient;
  final SharedPreferences _prefs;ArgumentError('SharedPreferences is required'final final final final final );

  /// Search for providers with filters
  Future<ProviderSearchResult> searchProviders({
    final ProviderSearchFilters? filters,
    final int page = 1,
    final int pageSize = 20,
  }) async {
    try {
      // Try to get cached data first
      final cachedProviders = await _getCachedProviders();
      
      if (cachedProviders.isNotEmpty) {
        return _filterAndPaginateProviders(
          cachedProviders,
          filters ?? const ProviderSearchFilters(),
          page,
          pageSize,
        );
      }

      // If no cache, fetch fresh data
      final providers = await _fetchProvidersFromAPI();
      await _cacheProviders(providers);
      
      return _filterAndPaginateProviders(
        providers,
        filters ?? const ProviderSearchFilters(),
        page,
        pageSize,
      );
    } catch (e) {
      // Fallback to cached data if available
      final cachedProviders = await _getCachedProviders();
      if (cachedProviders.isNotEmpty) {
        return _filterAndPaginateProviders(
          cachedProviders,
          filters ?? const ProviderSearchFilters(),
          page,
          pageSize,
        );
      }
      
      // If no cache available, return empty result
      return ProviderSearchResult(
        providers: [],
        totalCount: 0,
        currentPage: page,
        totalPages: 0,
        hasMore: false,
        searchTimestamp: DateTime.now(),
      );
    }
  }

  /// Get provider by ID
  Future<NDISProvider?> getProviderById(final String id) async {
    final providers = await _getCachedProviders();
    try {
      return providers.firstWhere((final provider) => provider.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get favorite providers
  Future<List<NDISProvider>> getFavoriteProviders() async {
    final providers = await _getCachedProviders();
    return providers.where((final provider) => provider.isFavorite).toList();
  }

  /// Toggle provider favorite status
  Future<void> toggleFavorite(final String providerId) async {
    final providers = await _getCachedProviders();
    final updatedProviders = providers.map((final provider) {
      if (provider.id == providerId) {
        return provider.copyWith(isFavorite: !provider.isFavorite);
      }
      return provider;
    }).toList();
    
    await _cacheProviders(updatedProviders);
  }

  /// Refresh provider data from API
  Future<void> refreshProviderData() async {
    try {
      final providers = await _fetchProvidersFromAPI();
      await _cacheProviders(providers);
    } catch (e) {
      // Handle error - could show user notification
      rethrow;
    }
  }

  /// Check if cache is expired
  bool get isCacheExpired {
    final lastUpdate = _prefs.getString(_lastUpdateKey);
    if (lastUpdate == null) return true;
    
    final lastUpdateTime = DateTime.parse(lastUpdate);
    return DateTime.now().difference(lastUpdateTime) > _cacheExpiry;
  }

  /// Fetch providers from NDIS API/datasets
  Future<List<NDISProvider>> _fetchProvidersFromAPI() async {
    try {
      // First try to get from official NDIS datasets
      final datasetProviders = await _fetchFromNDISDatasets();
      if (datasetProviders.isNotEmpty) {
        return datasetProviders;
      }

      // Fallback to web scraping if datasets are not available
      return await _fetchFromWebScraping();
    } catch (e) {
      // Return sample data as fallback
      return _getSampleProviders();
    }
  }

  /// Fetch providers from official NDIS datasets
  Future<List<NDISProvider>> _fetchFromNDISDatasets() async {
    try {
      // Try to fetch from the active providers dataset
      final response = await _httpClient.get(
        Uri.parse('$_baseUrl/datasets/provider-datasets/active-providers.csv'),
        headers: {
          'User-Agent': 'NDIS Connect App/1.0',
          'Accept': 'text/csv',
        },
      );

      if (response.statusCode == 200) {
        return _parseCSVData(response.body);
      }
    } catch (e) {
      // Dataset not available or error occurred
    }

    return [];
  }

  /// Parse CSV data from NDIS datasets
  List<NDISProvider> _parseCSVData(final String csvData) {
    final lines = csvData.split('\n');
    if (lines.length < 2) return [];

    final headers = lines[0].split(',').map((final h) => h.trim()).toList();
    final providers = <NDISProvider>[];

    for (int i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      final values = _parseCSVLine(line);
      if (values.length != headers.length) continue;

      try {
        final provider = _createProviderFromCSV(headers, values);
        if (provider != null) {
          providers.add(provider);
        }
      } catch (e) {
        // Skip invalid rows
        continue;
      }
    }

    return providers;
  }

  /// Parse a single CSV line handling quoted values
  List<String> _parseCSVLine(final String line) {
    final result = <String>[];
    bool inQuotes = false;
    String current = '';

    for (int i = 0; i < line.length; i++) {
      final char = line[i];
      
      if (char == '"') {
        inQuotes = !inQuotes;
      } else if (char == ',' && !inQuotes) {
        result.add(current.trim());
        current = '';
      } else {
        current += char;
      }
    }
    
    result.add(current.trim());
    return result;
  }

  /// Create provider from CSV row data
  NDISProvider? _createProviderFromCSV(final List<String> headers, final List<String> values) {
    try {
      final data = <String, String>{};
      for (int i = 0; i < headers.length && i < values.length; i++) {
        data[headers[i]] = values[i];
      }

      final id = data['Provider ID'] ?? data['id'] ?? DateTime.now().millisecondsSinceEpoch.toString();
      final name = data['Provider Name'] ?? data['name'] ?? 'Unknown Provider';
      
      return NDISProvider(
        id: id,
        name: name,
        businessName: data['Business Name'],
        abn: data['ABN'],
        acn: data['ACN'],
        registrationNumber: data['Registration Number'],
        registrationStatus: data['Registration Status'],
        serviceTypes: _parseListField(data['Service Types']),
        supportCategories: _parseListField(data['Support Categories']),
        disabilityTypes: _parseListField(data['Disability Types']),
        ageGroups: _parseListField(data['Age Groups']),
        address: data['Address'],
        suburb: data['Suburb'],
        state: data['State'],
        postcode: data['Postcode'],
        country: data['Country'] ?? 'Australia',
        phone: data['Phone'],
        email: data['Email'],
        website: data['Website'],
        languages: _parseListField(data['Languages']),
        isCulturallyAppropriate: _parseBoolField(data['Culturally Appropriate']),
        isLgbtiFriendly: _parseBoolField(data['LGBTI Friendly']),
        isAboriginalTorresStraitIslander: _parseBoolField(data['Aboriginal Torres Strait Islander']),
        isRemoteService: _parseBoolField(data['Remote Service']),
        isHomeVisits: _parseBoolField(data['Home Visits']),
        isGroupService: _parseBoolField(data['Group Service']),
        isIndividualService: _parseBoolField(data['Individual Service']),
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Parse list field from CSV
  List<String> _parseListField(final String? value) {
    if (value == null || value.isEmpty) return [];
    return value.split(';').map((final s) => s.trim()).where((final s) => s.isNotEmpty).toList();
  }

  /// Parse boolean field from CSV
  bool _parseBoolField(final String? value) {
    if (value == null || value.isEmpty) return false;
    final lower = value.toLowerCase();
    return lower == 'yes' || lower == 'true' || lower == '1';
  }

  /// Fetch providers using web scraping (fallback method)
  Future<List<NDISProvider>> _fetchFromWebScraping() async {
    // This would implement web scraping of the NDIS Provider Finder
    // For now, return sample data
    return _getSampleProviders();
  }

  /// Get sample providers for development/testing
  List<NDISProvider> _getSampleProviders() => [
      NDISProvider(
        id: '1',
        name: 'ABC Disability Services',
        businessName: 'ABC Disability Services Pty Ltd',
        abn: '12345678901',
        registrationNumber: 'NDIS-001',
        registrationStatus: 'Active',
        serviceTypes: ['Support Coordination', 'Plan Management', 'Therapeutic Supports'],
        supportCategories: ['Core', 'Capacity Building'],
        disabilityTypes: ['Autism', 'Intellectual Disability', 'Physical Disability'],
        ageGroups: ['0-6', '7-17', '18-64', '65+'],
        address: '123 Health Street',
        suburb: 'Melbourne',
        state: 'VIC',
        postcode: '3000',
        country: 'Australia',
        latitude: -37.8136,
        longitude: 144.9631,
        phone: '03 1234 5678',
        email: 'info@abcdisability.com.au',
        website: 'https://www.abcdisability.com.au',
        languages: ['English', 'Mandarin', 'Arabic'],
        isCulturallyAppropriate: true,
        isLgbtiFriendly: true,
        isRemoteService: true,
        isHomeVisits: true,
        isGroupService: true,
        isIndividualService: true,
        description: 'Comprehensive disability services providing support coordination, plan management, and therapeutic supports.',
        specializations: ['Autism Support', 'Early Intervention', 'Community Access'],
        rating: 4.8,
        reviewCount: 124,
        lastUpdated: DateTime.now(),
      ),
      NDISProvider(
        id: '2',
        name: 'XYZ Therapy Services',
        businessName: 'XYZ Therapy Services',
        abn: '98765432109',
        registrationNumber: 'NDIS-002',
        registrationStatus: 'Active',
        serviceTypes: ['Physiotherapy', 'Occupational Therapy', 'Speech Therapy'],
        supportCategories: ['Core', 'Capacity Building'],
        disabilityTypes: ['Physical Disability', 'Intellectual Disability', 'Autism'],
        ageGroups: ['0-6', '7-17', '18-64'],
        address: '456 Care Avenue',
        suburb: 'Sydney',
        state: 'NSW',
        postcode: '2000',
        country: 'Australia',
        latitude: -33.8688,
        longitude: 151.2093,
        phone: '02 9876 5432',
        email: 'contact@xyztherapy.com.au',
        website: 'https://www.xyztherapy.com.au',
        languages: ['English', 'Spanish', 'Italian'],
        isCulturallyAppropriate: true,
        isAboriginalTorresStraitIslander: true,
        isRemoteService: true,
        isHomeVisits: true,
        isIndividualService: true,
        description: 'Specialized therapy services for children and adults with disabilities.',
        specializations: ['Pediatric Therapy', 'Sensory Integration', 'Communication Support'],
        rating: 4.6,
        reviewCount: 89,
        lastUpdated: DateTime.now(),
      ),
      NDISProvider(
        id: '3',
        name: 'Community Support Network',
        businessName: 'Community Support Network Inc',
        abn: '11223344556',
        registrationNumber: 'NDIS-003',
        registrationStatus: 'Active',
        serviceTypes: ['Support Work', 'Community Access', 'Respite Care'],
        supportCategories: ['Core'],
        disabilityTypes: ['Intellectual Disability', 'Autism', 'Mental Health'],
        ageGroups: ['7-17', '18-64', '65+'],
        address: '789 Community Road',
        suburb: 'Brisbane',
        state: 'QLD',
        postcode: '4000',
        country: 'Australia',
        latitude: -27.4698,
        longitude: 153.0251,
        phone: '07 5555 1234',
        email: 'support@communitynetwork.org.au',
        website: 'https://www.communitynetwork.org.au',
        languages: ['English', 'Vietnamese', 'Cantonese'],
        isCulturallyAppropriate: true,
        isLgbtiFriendly: true,
        isAboriginalTorresStraitIslander: true,
        isHomeVisits: true,
        isGroupService: true,
        isIndividualService: true,
        description: 'Community-based support services promoting independence and social inclusion.',
        specializations: ['Community Access', 'Life Skills Training', 'Social Support'],
        rating: 4.7,
        reviewCount: 203,
        lastUpdated: DateTime.now(),
      ),
      NDISProvider(
        id: '4',
        name: 'Specialized Care Solutions',
        businessName: 'Specialized Care Solutions Pty Ltd',
        abn: '55667788990',
        registrationNumber: 'NDIS-004',
        registrationStatus: 'Active',
        serviceTypes: ['Nursing', 'Personal Care', 'Assistive Technology'],
        supportCategories: ['Core', 'Capital'],
        disabilityTypes: ['Physical Disability', 'Acquired Brain Injury', 'Multiple Sclerosis'],
        ageGroups: ['18-64', '65+'],
        address: '321 Specialist Street',
        suburb: 'Perth',
        state: 'WA',
        postcode: '6000',
        country: 'Australia',
        latitude: -31.9505,
        longitude: 115.8605,
        phone: '08 7777 8888',
        email: 'care@specializedsolutions.com.au',
        website: 'https://www.specializedsolutions.com.au',
        languages: ['English', 'Greek', 'Macedonian'],
        isCulturallyAppropriate: true,
        isHomeVisits: true,
        isIndividualService: true,
        description: 'Specialized care services for adults with complex physical disabilities.',
        specializations: ['Complex Care', 'Assistive Technology', 'Rehabilitation'],
        rating: 4.9,
        reviewCount: 156,
        lastUpdated: DateTime.now(),
      ),
      NDISProvider(
        id: '5',
        name: 'Early Intervention Hub',
        businessName: 'Early Intervention Hub',
        abn: '99887766554',
        registrationNumber: 'NDIS-005',
        registrationStatus: 'Active',
        serviceTypes: ['Early Childhood Intervention', 'Family Support', 'Therapeutic Supports'],
        supportCategories: ['Core', 'Capacity Building'],
        disabilityTypes: ['Autism', 'Developmental Delay', 'Intellectual Disability'],
        ageGroups: ['0-6'],
        address: '654 Early Years Lane',
        suburb: 'Adelaide',
        state: 'SA',
        postcode: '5000',
        country: 'Australia',
        latitude: -34.9285,
        longitude: 138.6007,
        phone: '08 9999 0000',
        email: 'early@interventionhub.com.au',
        website: 'https://www.interventionhub.com.au',
        languages: ['English', 'Arabic', 'Hindi'],
        isCulturallyAppropriate: true,
        isLgbtiFriendly: true,
        isAboriginalTorresStraitIslander: true,
        isRemoteService: true,
        isHomeVisits: true,
        isGroupService: true,
        isIndividualService: true,
        description: 'Comprehensive early intervention services for children aged 0-6 years.',
        specializations: ['Early Intervention', 'Family-Centered Practice', 'Developmental Assessment'],
        rating: 4.8,
        reviewCount: 98,
        lastUpdated: DateTime.now(),
      ),
    ];

  /// Filter and paginate providers based on search criteria
  ProviderSearchResult _filterAndPaginateProviders(
    final List<NDISProvider> providers,
    final ProviderSearchFilters filters,
    final int page,
    final int pageSize,
  ) {
    var filteredProviders = providers;

    // Apply filters
    if (filters.query != null && filters.query!.isNotEmpty) {
      final query = filters.query!.toLowerCase();
      filteredProviders = filteredProviders.where((final provider) => provider.name.toLowerCase().contains(query) ||
               provider.businessName?.toLowerCase().contains(query) ?? false ||
               provider.serviceTypes.any((final type) => type.toLowerCase().contains(query)) ||
               provider.specializations.any((final spec) => spec.toLowerCase().contains(query))).toList();
    }

    if (filters.serviceTypes.isNotEmpty) {
      filteredProviders = filteredProviders.where((final provider) => provider.serviceTypes.any(filters.serviceTypes.contains)).toList();
    }

    if (filters.supportCategories.isNotEmpty) {
      filteredProviders = filteredProviders.where((final provider) => provider.supportCategories.any(filters.supportCategories.contains)).toList();
    }

    if (filters.disabilityTypes.isNotEmpty) {
      filteredProviders = filteredProviders.where((final provider) => provider.disabilityTypes.any(filters.disabilityTypes.contains)).toList();
    }

    if (filters.ageGroups.isNotEmpty) {
      filteredProviders = filteredProviders.where((final provider) => provider.ageGroups.any(filters.ageGroups.contains)).toList();
    }

    if (filters.isCulturallyAppropriate ?? false) {
      filteredProviders = filteredProviders.where((final provider) => provider.isCulturallyAppropriate).toList();
    }

    if (filters.isLgbtiFriendly ?? false) {
      filteredProviders = filteredProviders.where((final provider) => provider.isLgbtiFriendly).toList();
    }

    if (filters.isAboriginalTorresStraitIslander ?? false) {
      filteredProviders = filteredProviders.where((final provider) => provider.isAboriginalTorresStraitIslander).toList();
    }

    if (filters.isRemoteService ?? false) {
      filteredProviders = filteredProviders.where((final provider) => provider.isRemoteService).toList();
    }

    if (filters.isHomeVisits ?? false) {
      filteredProviders = filteredProviders.where((final provider) => provider.isHomeVisits).toList();
    }

    if (filters.isGroupService ?? false) {
      filteredProviders = filteredProviders.where((final provider) => provider.isGroupService).toList();
    }

    if (filters.isIndividualService ?? false) {
      filteredProviders = filteredProviders.where((final provider) => provider.isIndividualService).toList();
    }

    if (filters.languages.isNotEmpty) {
      filteredProviders = filteredProviders.where((final provider) => provider.languages.any(filters.languages.contains)).toList();
    }

    if (filters.minRating != null) {
      filteredProviders = filteredProviders.where((final provider) => provider.rating != null && provider.rating! >= filters.minRating!).toList();
    }

    if (filters.showOnlyFavorites ?? false) {
      filteredProviders = filteredProviders.where((final provider) => provider.isFavorite).toList();
    }

    // Sort by rating (highest first), then by name
    filteredProviders.sort((final a, final b) {
      if (a.rating != null && b.rating != null) {
        final ratingComparison = b.rating!.compareTo(a.rating!);
        if (ratingComparison != 0) return ratingComparison;
      }
      return a.name.compareTo(b.name);
    });

    // Paginate
    final totalCount = filteredProviders.length;
    final totalPages = (totalCount / pageSize).ceil();
    final startIndex = (page - 1) * pageSize;
    final endIndex = (startIndex + pageSize).clamp(0, totalCount);
    
    final paginatedProviders = filteredProviders.sublist(startIndex, endIndex);

    return ProviderSearchResult(
      providers: paginatedProviders,
      totalCount: totalCount,
      currentPage: page,
      totalPages: totalPages,
      hasMore: page < totalPages,
      searchTimestamp: DateTime.now(),
    );
  }

  /// Get cached providers
  Future<List<NDISProvider>> _getCachedProviders() async {
    try {
      final cachedData = _prefs.getString(_cacheKey);
      if (cachedData == null) return [];

      final List<dynamic> jsonList = jsonDecode(cachedData);
      return jsonList.map((final json) => NDISProvider.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Cache providers
  Future<void> _cacheProviders(final List<NDISProvider> providers) async {
    try {
      final jsonList = providers.map((final provider) => provider.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      
      await _prefs.setString(_cacheKey, jsonString);
      await _prefs.setString(_lastUpdateKey, DateTime.now().toIso8601String());
    } catch (e) {
      // Handle caching error
    }
  }

  /// Dispose resources
  void dispose() {
    _httpClient.close();
  }
}
