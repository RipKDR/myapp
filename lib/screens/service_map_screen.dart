import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../widgets/feature_guard.dart';
import '../core/feature_flags.dart';
import '../services/provider_directory_service.dart';
import '../services/ai_personalization_service.dart';

class ServiceMapScreen extends StatefulWidget {
  const ServiceMapScreen({super.key});

  @override
  State<ServiceMapScreen> createState() => _ServiceMapScreenState();
}

class _ServiceMapScreenState extends State<ServiceMapScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  final Set<Marker> _markers = {};
  double _waitFilter = 60; // minutes
  bool _accessibleOnly = false;
  double _minRating = 3.5;
  final AIPersonalizationService _ai = AIPersonalizationService();
  bool _showSuggestion = false;
  String? _suggestionText;

  static const CameraPosition _sydney = CameraPosition(
    target: LatLng(-33.8688, 151.2093),
    zoom: 11,
  );

  @override
  void initState() {
    super.initState();
    _loadProviders();
    _loadSuggestion();
  }

  Future<void> _loadProviders() async {
    final list = await ProviderDirectoryService.listProviders();
    final filtered = list.where(
      (p) =>
          p.waitMinutes <= _waitFilter &&
          (!_accessibleOnly || p.accessible) &&
          p.rating >= _minRating,
    );
    setState(() {
      _markers.clear();
      for (final p in filtered) {
        _markers.add(
          Marker(
            markerId: MarkerId(p.id),
            position: LatLng(p.lat, p.lng),
            infoWindow: InfoWindow(
              title: p.name,
              snippet:
                  '⭐ ${p.rating.toStringAsFixed(1)} • ~${p.waitMinutes}m • ${p.accessible ? 'Accessible' : 'Limited'}',
            ),
          ),
        );
      }
    });
  }

  Future<void> _loadSuggestion() async {
    try {
      await _ai.initialize();
      final suggestAccessible =
          _ai.adaptiveSettings['accessibility_enhanced'] == true;
      if (mounted && suggestAccessible && !_accessibleOnly) {
        setState(() {
          _showSuggestion = true;
          _suggestionText = 'Tip: Filter accessible providers only';
        });
      }
    } catch (_) {
      // keep UI clean on failure
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Service Map')),
      body: FeatureGuard(
        tier: FeatureTier.free,
        child: Column(
          children: [
            if (_showSuggestion && _suggestionText != null) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.withOpacity(0.12)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.tips_and_updates,
                          size: 16, color: Colors.blue),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(_suggestionText!,
                              style: Theme.of(context).textTheme.bodySmall)),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _accessibleOnly = true;
                            _showSuggestion = false;
                          });
                          _loadProviders();
                        },
                        child: const Text('Apply'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            _Filters(
              wait: _waitFilter,
              accessibleOnly: _accessibleOnly,
              minRating: _minRating,
              onChanged: (w, a, r) {
                setState(() {
                  _waitFilter = w;
                  _accessibleOnly = a;
                  _minRating = r;
                });
                _loadProviders();
              },
            ),
            Expanded(
              child: FeatureFlags.isMapsEnabled
                  ? GoogleMap(
                      initialCameraPosition: _sydney,
                      myLocationButtonEnabled: true,
                      myLocationEnabled: false,
                      markers: _markers,
                      onMapCreated: (c) => _controller.complete(c),
                    )
                  : _MapsDisabledFallback(
                      onEnableHelp: () => _showMapsSetupHelp(context)),
            ),
          ],
        ),
      ),
    );
  }

  void _showMapsSetupHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enable Google Maps'),
        content: const Text(
            'Google Maps is disabled. Provide a Maps API key and launch with\n\n'
            '--dart-define=GOOGLE_MAPS_ENABLED=true\n\n'
            'Then add your key in AndroidManifest.xml and Info.plist as per README.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );
  }
}

class _Filters extends StatelessWidget {
  final double wait;
  final bool accessibleOnly;
  final double minRating;
  final void Function(double wait, bool accessibleOnly, double rating)
      onChanged;
  const _Filters(
      {required this.wait,
      required this.accessibleOnly,
      required this.minRating,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.filter_alt_outlined),
                const SizedBox(width: 8),
                Text('Filters', style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Max wait time'),
                Expanded(
                  child: Slider(
                    min: 10,
                    max: 120,
                    divisions: 11,
                    value: wait,
                    label: '${wait.round()}m',
                    onChanged: (v) => onChanged(v, accessibleOnly, minRating),
                  ),
                ),
                SizedBox(width: 48, child: Text('${wait.round()}m')),
              ],
            ),
            Row(
              children: [
                const Text('Min rating'),
                Expanded(
                  child: Slider(
                    min: 1.0,
                    max: 5.0,
                    divisions: 8,
                    value: minRating,
                    label: minRating.toStringAsFixed(1),
                    onChanged: (v) => onChanged(wait, accessibleOnly, v),
                  ),
                ),
                SizedBox(width: 48, child: Text(minRating.toStringAsFixed(1))),
              ],
            ),
            SwitchListTile(
              value: accessibleOnly,
              onChanged: (v) => onChanged(wait, v, minRating),
              title: const Text('Accessible venues only'),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }
}

class _MapsDisabledFallback extends StatelessWidget {
  final VoidCallback onEnableHelp;
  const _MapsDisabledFallback({required this.onEnableHelp});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.map_outlined, size: 48),
            const SizedBox(height: 12),
            const Text('Map unavailable',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            const Text(
              'Google Maps is not configured for this build. You can still browse providers using the list below.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: onEnableHelp,
              icon: const Icon(Icons.help_outline),
              label: const Text('How to enable'),
            )
          ],
        ),
      ),
    );
  }
}
