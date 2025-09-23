import 'package:json_annotation/json_annotation.dart';

part 'ndis_provider.g.dart';

/// NDIS Provider Model
/// Represents a registered NDIS provider with comprehensive information
@JsonSerializable()
class NDISProvider {

  const NDISProvider({
    required this.id,
    required this.name,
    this.businessName,
    this.abn,
    this.acn,
    this.registrationNumber,
    this.registrationStatus,
    this.registrationDate,
    this.expiryDate,
    this.serviceTypes = const [],
    this.supportCategories = const [],
    this.disabilityTypes = const [],
    this.ageGroups = const [],
    this.location,
    this.contact,
    this.languages = const [],
    this.isCulturallyAppropriate = false,
    this.isLgbtiFriendly = false,
    this.isAboriginalTorresStraitIslander = false,
    this.description,
    this.specializations = const [],
    this.rating,
    this.reviewCount,
    this.isFavorite = false,
    required this.lastUpdated,
    this.website,
    this.email,
    this.phone,
    this.fax,
    this.address,
    this.suburb,
    this.state,
    this.postcode,
    this.country,
    this.latitude,
    this.longitude,
    this.serviceAreas = const [],
    this.isRemoteService = false,
    this.isHomeVisits = false,
    this.isGroupService = false,
    this.isIndividualService = false,
    this.ndisRegistrationGroup,
    this.qualityAndSafeguardsCommission,
    this.lastAuditDate,
    this.auditStatus,
  });

  factory NDISProvider.fromJson(final Map<String, dynamic> json) =>
      _$NDISProviderFromJson(json);
  final String id;
  final String name;
  final String? businessName;
  final String? abn;
  final String? acn;
  final String? registrationNumber;
  final String? registrationStatus;
  final DateTime? registrationDate;
  final DateTime? expiryDate;
  final List<String> serviceTypes;
  final List<String> supportCategories;
  final List<String> disabilityTypes;
  final List<String> ageGroups;
  final NDISProviderLocation? location;
  final NDISProviderContact? contact;
  final List<String> languages;
  final bool isCulturallyAppropriate;
  final bool isLgbtiFriendly;
  final bool isAboriginalTorresStraitIslander;
  final String? description;
  final List<String> specializations;
  final double? rating;
  final int? reviewCount;
  final bool isFavorite;
  final DateTime lastUpdated;
  final String? website;
  final String? email;
  final String? phone;
  final String? fax;
  final String? address;
  final String? suburb;
  final String? state;
  final String? postcode;
  final String? country;
  final double? latitude;
  final double? longitude;
  final List<String> serviceAreas;
  final bool isRemoteService;
  final bool isHomeVisits;
  final bool isGroupService;
  final bool isIndividualService;
  final String? ndisRegistrationGroup;
  final String? qualityAndSafeguardsCommission;
  final DateTime? lastAuditDate;
  final String? auditStatus;

  Map<String, dynamic> toJson() => _$NDISProviderToJson(this);

  NDISProvider copyWith({
    final String? id,
    final String? name,
    final String? businessName,
    final String? abn,
    final String? acn,
    final String? registrationNumber,
    final String? registrationStatus,
    final DateTime? registrationDate,
    final DateTime? expiryDate,
    final List<String>? serviceTypes,
    final List<String>? supportCategories,
    final List<String>? disabilityTypes,
    final List<String>? ageGroups,
    final NDISProviderLocation? location,
    final NDISProviderContact? contact,
    final List<String>? languages,
    final bool? isCulturallyAppropriate,
    final bool? isLgbtiFriendly,
    final bool? isAboriginalTorresStraitIslander,
    final String? description,
    final List<String>? specializations,
    final double? rating,
    final int? reviewCount,
    final bool? isFavorite,
    final DateTime? lastUpdated,
    final String? website,
    final String? email,
    final String? phone,
    final String? fax,
    final String? address,
    final String? suburb,
    final String? state,
    final String? postcode,
    final String? country,
    final double? latitude,
    final double? longitude,
    final List<String>? serviceAreas,
    final bool? isRemoteService,
    final bool? isHomeVisits,
    final bool? isGroupService,
    final bool? isIndividualService,
    final String? ndisRegistrationGroup,
    final String? qualityAndSafeguardsCommission,
    final DateTime? lastAuditDate,
    final String? auditStatus,
  }) => NDISProvider(
      id: id ?? this.id,
      name: name ?? this.name,
      businessName: businessName ?? this.businessName,
      abn: abn ?? this.abn,
      acn: acn ?? this.acn,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      registrationStatus: registrationStatus ?? this.registrationStatus,
      registrationDate: registrationDate ?? this.registrationDate,
      expiryDate: expiryDate ?? this.expiryDate,
      serviceTypes: serviceTypes ?? this.serviceTypes,
      supportCategories: supportCategories ?? this.supportCategories,
      disabilityTypes: disabilityTypes ?? this.disabilityTypes,
      ageGroups: ageGroups ?? this.ageGroups,
      location: location ?? this.location,
      contact: contact ?? this.contact,
      languages: languages ?? this.languages,
      isCulturallyAppropriate: isCulturallyAppropriate ?? this.isCulturallyAppropriate,
      isLgbtiFriendly: isLgbtiFriendly ?? this.isLgbtiFriendly,
      isAboriginalTorresStraitIslander: isAboriginalTorresStraitIslander ?? this.isAboriginalTorresStraitIslander,
      description: description ?? this.description,
      specializations: specializations ?? this.specializations,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isFavorite: isFavorite ?? this.isFavorite,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      website: website ?? this.website,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      fax: fax ?? this.fax,
      address: address ?? this.address,
      suburb: suburb ?? this.suburb,
      state: state ?? this.state,
      postcode: postcode ?? this.postcode,
      country: country ?? this.country,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      serviceAreas: serviceAreas ?? this.serviceAreas,
      isRemoteService: isRemoteService ?? this.isRemoteService,
      isHomeVisits: isHomeVisits ?? this.isHomeVisits,
      isGroupService: isGroupService ?? this.isGroupService,
      isIndividualService: isIndividualService ?? this.isIndividualService,
      ndisRegistrationGroup: ndisRegistrationGroup ?? this.ndisRegistrationGroup,
      qualityAndSafeguardsCommission: qualityAndSafeguardsCommission ?? this.qualityAndSafeguardsCommission,
      lastAuditDate: lastAuditDate ?? this.lastAuditDate,
      auditStatus: auditStatus ?? this.auditStatus,
    );

  /// Get full address as a single string
  String get fullAddress {
    final parts = <String>[];
    if (address != null && address!.isNotEmpty) parts.add(address!);
    if (suburb != null && suburb!.isNotEmpty) parts.add(suburb!);
    if (state != null && state!.isNotEmpty) parts.add(state!);
    if (postcode != null && postcode!.isNotEmpty) parts.add(postcode!);
    return parts.join(', ');
  }

  /// Get display name (business name if available, otherwise name)
  String get displayName => businessName ?? name;

  /// Check if provider is currently registered
  bool get isRegistered {
    if (registrationStatus == null) return false;
    if (expiryDate == null) return true;
    return DateTime.now().isBefore(expiryDate!);
  }

  /// Get distance from user location (if available)
  double? getDistanceFrom(final double? userLat, final double? userLng) {
    if (latitude == null || longitude == null || userLat == null || userLng == null) {
      return null;
    }
    return _calculateDistance(userLat, userLng, latitude!, longitude!);
  }

  /// Calculate distance between two coordinates using Haversine formula
  double _calculateDistance(final double lat1, final double lng1, final double lat2, final double lng2) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLng = _degreesToRadians(lng2 - lng1);
    final double a = (dLat / 2).sin() * (dLat / 2).sin() +
        lat1.cos() * lat2.cos() * (dLng / 2).sin() * (dLng / 2).sin();
    final double c = 2 * a.sqrt().asin();
    return earthRadius * c;
  }

  double _degreesToRadians(final double degrees) => degrees * (3.14159265359 / 180);

  @override
  bool operator ==(final Object other) =>
      identical(this, other) ||
      other is NDISProvider && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'NDISProvider(id: $id, name: $name, businessName: $businessName)';
}

/// NDIS Provider Location Model
@JsonSerializable()
class NDISProviderLocation {

  const NDISProviderLocation({
    this.address,
    this.suburb,
    this.state,
    this.postcode,
    this.country,
    this.latitude,
    this.longitude,
    this.serviceAreas = const [],
  });

  factory NDISProviderLocation.fromJson(final Map<String, dynamic> json) =>
      _$NDISProviderLocationFromJson(json);
  final String? address;
  final String? suburb;
  final String? state;
  final String? postcode;
  final String? country;
  final double? latitude;
  final double? longitude;
  final List<String> serviceAreas;

  Map<String, dynamic> toJson() => _$NDISProviderLocationToJson(this);

  String get fullAddress {
    final parts = <String>[];
    if (address != null && address!.isNotEmpty) parts.add(address!);
    if (suburb != null && suburb!.isNotEmpty) parts.add(suburb!);
    if (state != null && state!.isNotEmpty) parts.add(state!);
    if (postcode != null && postcode!.isNotEmpty) parts.add(postcode!);
    return parts.join(', ');
  }
}

/// NDIS Provider Contact Model
@JsonSerializable()
class NDISProviderContact {

  const NDISProviderContact({
    this.phone,
    this.email,
    this.website,
    this.fax,
    this.mobile,
  });

  factory NDISProviderContact.fromJson(final Map<String, dynamic> json) =>
      _$NDISProviderContactFromJson(json);
  final String? phone;
  final String? email;
  final String? website;
  final String? fax;
  final String? mobile;

  Map<String, dynamic> toJson() => _$NDISProviderContactToJson(this);
}

/// Provider Search Filters
@JsonSerializable()
class ProviderSearchFilters {

  const ProviderSearchFilters({
    this.query,
    this.location,
    this.serviceTypes = const [],
    this.supportCategories = const [],
    this.disabilityTypes = const [],
    this.ageGroups = const [],
    this.radius,
    this.isCulturallyAppropriate,
    this.isLgbtiFriendly,
    this.isAboriginalTorresStraitIslander,
    this.isRemoteService,
    this.isHomeVisits,
    this.isGroupService,
    this.isIndividualService,
    this.languages = const [],
    this.registrationStatus,
    this.minRating,
    this.showOnlyFavorites,
  });

  factory ProviderSearchFilters.fromJson(final Map<String, dynamic> json) =>
      _$ProviderSearchFiltersFromJson(json);
  final String? query;
  final String? location;
  final List<String> serviceTypes;
  final List<String> supportCategories;
  final List<String> disabilityTypes;
  final List<String> ageGroups;
  final double? radius; // in kilometers
  final bool? isCulturallyAppropriate;
  final bool? isLgbtiFriendly;
  final bool? isAboriginalTorresStraitIslander;
  final bool? isRemoteService;
  final bool? isHomeVisits;
  final bool? isGroupService;
  final bool? isIndividualService;
  final List<String> languages;
  final String? registrationStatus;
  final double? minRating;
  final bool? showOnlyFavorites;

  Map<String, dynamic> toJson() => _$ProviderSearchFiltersToJson(this);

  ProviderSearchFilters copyWith({
    final String? query,
    final String? location,
    final List<String>? serviceTypes,
    final List<String>? supportCategories,
    final List<String>? disabilityTypes,
    final List<String>? ageGroups,
    final double? radius,
    final bool? isCulturallyAppropriate,
    final bool? isLgbtiFriendly,
    final bool? isAboriginalTorresStraitIslander,
    final bool? isRemoteService,
    final bool? isHomeVisits,
    final bool? isGroupService,
    final bool? isIndividualService,
    final List<String>? languages,
    final String? registrationStatus,
    final double? minRating,
    final bool? showOnlyFavorites,
  }) => ProviderSearchFilters(
      query: query ?? this.query,
      location: location ?? this.location,
      serviceTypes: serviceTypes ?? this.serviceTypes,
      supportCategories: supportCategories ?? this.supportCategories,
      disabilityTypes: disabilityTypes ?? this.disabilityTypes,
      ageGroups: ageGroups ?? this.ageGroups,
      radius: radius ?? this.radius,
      isCulturallyAppropriate: isCulturallyAppropriate ?? this.isCulturallyAppropriate,
      isLgbtiFriendly: isLgbtiFriendly ?? this.isLgbtiFriendly,
      isAboriginalTorresStraitIslander: isAboriginalTorresStraitIslander ?? this.isAboriginalTorresStraitIslander,
      isRemoteService: isRemoteService ?? this.isRemoteService,
      isHomeVisits: isHomeVisits ?? this.isHomeVisits,
      isGroupService: isGroupService ?? this.isGroupService,
      isIndividualService: isIndividualService ?? this.isIndividualService,
      languages: languages ?? this.languages,
      registrationStatus: registrationStatus ?? this.registrationStatus,
      minRating: minRating ?? this.minRating,
      showOnlyFavorites: showOnlyFavorites ?? this.showOnlyFavorites,
    );

  /// Check if any filters are applied
  bool get hasActiveFilters => query != null ||
        location != null ||
        serviceTypes.isNotEmpty ||
        supportCategories.isNotEmpty ||
        disabilityTypes.isNotEmpty ||
        ageGroups.isNotEmpty ||
        radius != null ||
        isCulturallyAppropriate != null ||
        isLgbtiFriendly != null ||
        isAboriginalTorresStraitIslander != null ||
        isRemoteService != null ||
        isHomeVisits != null ||
        isGroupService != null ||
        isIndividualService != null ||
        languages.isNotEmpty ||
        registrationStatus != null ||
        minRating != null ||
        showOnlyFavorites ?? false;
}

/// Provider Search Result
@JsonSerializable()
class ProviderSearchResult {

  const ProviderSearchResult({
    required this.providers,
    required this.totalCount,
    required this.currentPage,
    required this.totalPages,
    required this.hasMore,
    this.nextPageToken,
    required this.searchTimestamp,
  });

  factory ProviderSearchResult.fromJson(final Map<String, dynamic> json) =>
      _$ProviderSearchResultFromJson(json);
  final List<NDISProvider> providers;
  final int totalCount;
  final int currentPage;
  final int totalPages;
  final bool hasMore;
  final String? nextPageToken;
  final DateTime searchTimestamp;

  Map<String, dynamic> toJson() => _$ProviderSearchResultToJson(this);
}
