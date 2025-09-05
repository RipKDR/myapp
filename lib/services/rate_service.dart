class RateService {
  static const _rates = {
    'Physio': 180.0,
    'OT': 190.0,
    'Support Worker': 65.0,
    'Speech': 180.0,
  };

  static List<Map<String, dynamic>> compare(String category) {
    final typical = _rates[category] ?? 0.0;
    // Mock nearby offers
    final offers = [
      {'provider': 'FlexCare', 'rate': typical - 5},
      {'provider': 'CareCo', 'rate': typical + 2},
    ];
    return offers
        .map((o) => {
              'provider': o['provider'],
              'rate': o['rate'],
              'saving': (typical - (o['rate'] as double)),
            })
        .toList();
  }
}

