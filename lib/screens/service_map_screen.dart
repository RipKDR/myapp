import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../widgets/feature_guard.dart';
import '../core/feature_flags.dart';
import '../services/provider_directory_service.dart';

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

  static const CameraPosition _sydney = CameraPosition(
    target: LatLng(-33.8688, 151.2093),
    zoom: 11,
  );

  @override
  void initState() {
    super.initState();
    _loadProviders();
  }

  Future<void> _loadProviders() async {
    final list = await ProviderDirectoryService.listProviders();
    final filtered = list.where(
      (p) => p.waitMinutes <= _waitFilter && (!_accessibleOnly || p.accessible) && p.rating >= _minRating,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Service Map')),
      body: FeatureGuard(
        tier: FeatureTier.free,
        child: Column(
          children: [
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
              child: GoogleMap(
                initialCameraPosition: _sydney,
                myLocationButtonEnabled: true,
                myLocationEnabled: false,
                markers: _markers,
                onMapCreated: (c) => _controller.complete(c),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Filters extends StatelessWidget {
  final double wait;
  final bool accessibleOnly;
  final double minRating;
  final void Function(double wait, bool accessibleOnly, double rating) onChanged;
  const _Filters({required this.wait, required this.accessibleOnly, required this.minRating, required this.onChanged});

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

