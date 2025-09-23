class ProviderLocation { // 1.0-5.0
  ProviderLocation({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.waitMinutes,
    required this.accessible,
    this.rating = 4.0,
  });
  final String id;
  final String name;
  final double lat;
  final double lng;
  final int waitMinutes;
  final bool accessible;
  final double rating;

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'lat': lat,
        'lng': lng,
        'waitMinutes': waitMinutes,
        'accessible': accessible,
      };

  static ProviderLocation fromMap(final Map<String, dynamic> m) => ProviderLocation(
        id: m['id'] as String,
        name: m['name'] as String,
        lat: (m['lat'] as num).toDouble(),
        lng: (m['lng'] as num).toDouble(),
        waitMinutes: (m['waitMinutes'] as num).toInt(),
        accessible: (m['accessible'] as bool) == true,
        rating: (m['rating'] as num?)?.toDouble() ?? 4.0,
      );
}
