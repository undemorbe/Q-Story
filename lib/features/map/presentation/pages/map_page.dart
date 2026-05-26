import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/gothic_widgets.dart';
import '../../../../core/theme/theme_ext.dart';
import '../../domain/entities/map_marker_entity.dart';
import '../stores/map_store.dart';
import 'create_marker_page.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapStore _store = getIt<MapStore>();
  final MapController _mapController = MapController();

  static const LatLng _initialCenter = LatLng(59.9343, 30.3351);

  @override
  void initState() {
    super.initState();
    _store.loadMarkers();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh markers every time the page is visited
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
              interactionOptions: InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.qstory',
              ),
              Observer(
                builder: (_) {
                  return MarkerLayer(
                    markers: _store.markers.map((marker) {
                      return Marker(
                        point: LatLng(marker.lat, marker.lon),
                        width: 52,
                        height: 62,
                        alignment: Alignment.bottomCenter,
                        child: GestureDetector(
                          onTap: () => _showMarkerInfo(context, marker),
                          child: _GothicMarker(
                              isCompleted: marker.isCompleted),
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
          // Legend
          const Positioned(
            top: 56,
            right: 16,
            child: _MapLegend(),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _GothicFab(
            heroTag: 'refresh',
            icon: Icons.refresh,
            onPressed: () {
              _store.loadMarkers();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Обновление карты...')),
              );
            },
          ),
          const SizedBox(height: 12),
          _GothicFab.small(
            heroTag: 'zoomIn',
            icon: Icons.add,
            onPressed: () {
              _mapController.move(
                _mapController.camera.center,
                _mapController.camera.zoom + 1,
              );
            },
          ),
          const SizedBox(height: 8),
          _GothicFab.small(
            heroTag: 'zoomOut',
            icon: Icons.remove,
            onPressed: () {
              _mapController.move(
                _mapController.camera.center,
                _mapController.camera.zoom - 1,
              );
            },
          ),
          const SizedBox(height: 12),
          _GothicFab(
            heroTag: 'myLocation',
            icon: Icons.my_location,
            onPressed: () {
              _mapController.move(_initialCenter, 13.0);
            },
          ),
          const SizedBox(height: 12),
          _GothicFab(
            heroTag: 'createMarker',
            icon: Icons.add_location_alt_outlined,
            onPressed: _openCreateMarker,
          ),
        ],
      ),
    );
  }

  Future<void> _openCreateMarker() async {
    final center = _mapController.camera.center;
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => CreateMarkerPage(
          initialLat: center.latitude,
          initialLon: center.longitude,
        ),
      ),
    );
    if (created == true && mounted) {
      _store.loadMarkers();
    }
  }

  void _showMarkerInfo(BuildContext context, MapMarkerEntity marker) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        final color = marker.isCompleted ? context.gold : context.blood;
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    marker.isCompleted ? '✦' : '◆',
                    style: TextStyle(color: color, fontSize: 16),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      marker.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const GothicDivider(),
              const SizedBox(height: 8),
              Text(
                marker.compressedDescription,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: marker.isCompleted
                    ? OutlinedButton.icon(
                        onPressed: null,
                        icon: const Icon(Icons.check, size: 16),
                        label: const Text('Пройдено'),
                      )
                    : ElevatedButton.icon(
                        onPressed: () {
                          _store.markAsCompleted(marker.id);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Отмечено как пройдено!')),
                          );
                        },
                        icon: const Icon(Icons.flag, size: 16),
                        label: const Text('Отметить как пройдено'),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Gothic Pin Marker ───────────────────────────────────────────────────────

class _GothicMarker extends StatelessWidget {
  final bool isCompleted;

  const _GothicMarker({required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    final color = isCompleted ? context.gold : context.blood;
    final bgColor =
        isCompleted ? context.goldContainer : context.bloodContainer;

    return SizedBox(
      width: 52,
      height: 62,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          // Glow halo
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.45),
                  blurRadius: 14,
                  spreadRadius: 3,
                ),
              ],
            ),
          ),
          // Pin head — gothic square with ornaments
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: bgColor,
              border: Border.all(color: color, width: 1.5),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  isCompleted ? '✦' : '◆',
                  style: TextStyle(
                    color: color,
                    fontSize: 20,
                    height: 1,
                  ),
                ),
                Positioned(
                  top: 3,
                  left: 3,
                  child: Text('·',
                      style: TextStyle(
                          color: color.withValues(alpha: 0.5),
                          fontSize: 9,
                          height: 1)),
                ),
                Positioned(
                  top: 3,
                  right: 3,
                  child: Text('·',
                      style: TextStyle(
                          color: color.withValues(alpha: 0.5),
                          fontSize: 9,
                          height: 1)),
                ),
                Positioned(
                  bottom: 3,
                  left: 3,
                  child: Text('·',
                      style: TextStyle(
                          color: color.withValues(alpha: 0.5),
                          fontSize: 9,
                          height: 1)),
                ),
                Positioned(
                  bottom: 3,
                  right: 3,
                  child: Text('·',
                      style: TextStyle(
                          color: color.withValues(alpha: 0.5),
                          fontSize: 9,
                          height: 1)),
                ),
              ],
            ),
          ),
          // Spike
          Positioned(
            bottom: 0,
            child: CustomPaint(
              size: const Size(14, 18),
              painter: _SpikePainter(color: color, bgColor: bgColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpikePainter extends CustomPainter {
  final Color color;
  final Color bgColor;

  const _SpikePainter({required this.color, required this.bgColor});

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = bgColor
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeJoin = StrokeJoin.miter;

    final path = ui.Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(_SpikePainter old) =>
      old.color != color || old.bgColor != bgColor;
}

// ─── Map Legend ──────────────────────────────────────────────────────────────

class _MapLegend extends StatelessWidget {
  const _MapLegend();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: context.surfaceClr,
        border: Border.all(color: context.outlineClr, width: 1),
        borderRadius: BorderRadius.circular(2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.15),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _LegendItem(
            symbol: '✦',
            color: context.gold,
            label: 'Пройдено',
          ),
          const SizedBox(height: 6),
          _LegendItem(
            symbol: '◆',
            color: context.blood,
            label: 'Не пройдено',
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final String symbol;
  final Color color;
  final String label;

  const _LegendItem({
    required this.symbol,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(symbol,
            style: TextStyle(color: color, fontSize: 12, height: 1)),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.cinzel(color: context.onBg, fontSize: 10),
        ),
      ],
    );
  }
}

// ─── Gothic FAB ──────────────────────────────────────────────────────────────

class _GothicFab extends StatelessWidget {
  final String heroTag;
  final IconData icon;
  final VoidCallback onPressed;
  final bool _small;

  const _GothicFab({
    required this.heroTag,
    required this.icon,
    required this.onPressed,
  }) : _small = false;

  const _GothicFab.small({
    required this.heroTag,
    required this.icon,
    required this.onPressed,
  }) : _small = true;

  @override
  Widget build(BuildContext context) {
    final size = _small ? 36.0 : 48.0;
    final iconSize = _small ? 18.0 : 22.0;
    final gold = context.gold;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: context.surfaceClr,
          border: Border.all(color: context.outlineClr, width: 1),
          borderRadius: BorderRadius.circular(3),
          boxShadow: [
            BoxShadow(
              color: gold.withValues(alpha: 0.15),
              blurRadius: 8,
            ),
          ],
        ),
        child: Center(
          child: Icon(icon, color: gold, size: iconSize),
        ),
      ),
    );
  }
}
