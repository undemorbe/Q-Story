import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/di/service_locator.dart';
import '../../domain/entities/map_marker_entity.dart';
import '../stores/map_store.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapStore _store = getIt<MapStore>();
  final MapController _mapController = MapController();

  // Saint Petersburg coordinates
  static const LatLng _initialCenter = LatLng(59.9343, 30.3351);

  @override
  void initState() {
    super.initState();
    _store.loadMarkers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: _initialCenter,
              initialZoom: 13.0,
              // Enable zoom gestures and interaction
              interactionOptions: InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.qstory',
              ),
              Observer(
                builder: (_) {
                  return MarkerLayer(
                    markers: _store.markers.map((marker) {
                      return Marker(
                        point: LatLng(marker.latitude, marker.longitude),
                        width: 40,
                        height: 40,
                        child: GestureDetector(
                          onTap: () => _showMarkerInfo(context, marker),
                          child: Icon(
                            Icons.location_on,
                            color: marker.isCompleted ? Colors.green : Colors.red,
                            size: 40,
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
          Observer(
            builder: (_) {
              if (_store.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _mapController.move(_initialCenter, 13.0);
        },
        child: const Icon(Icons.my_location),
      ),
    );
  }

  void _showMarkerInfo(BuildContext context, MapMarkerEntity marker) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                marker.title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                marker.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: marker.isCompleted
                      ? null
                      : () {
                          _store.markAsCompleted(marker.id);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Отмечено как пройдено!')),
                          );
                        },
                  icon: Icon(
                    marker.isCompleted ? Icons.check : Icons.flag,
                  ),
                  label: Text(
                    marker.isCompleted ? 'Пройдено' : 'Отметить как пройдено',
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
