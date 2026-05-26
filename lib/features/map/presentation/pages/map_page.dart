import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/theme/gothic_widgets.dart';
import '../../../../core/theme/theme_ext.dart';
import '../../domain/entities/map_marker_entity.dart';
import '../stores/map_store.dart';
import '../../../reports/presentation/pages/report_sheet.dart';
import 'create_marker_page.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapStore _store = getIt<MapStore>();
  final LocationService _location = getIt<LocationService>();
  final MapController _mapController = MapController();

  /// Falls back to Saint Petersburg if user has not granted location yet.
  static const LatLng _fallbackCenter = LatLng(59.9343, 30.3351);

  LatLng? _userLocation;
  bool _locating = false;

  @override
  void initState() {
    super.initState();
    _store.loadMarkers();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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
              initialCenter: _fallbackCenter,
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
                  final list = _store.filteredMarkers;
                  final markers = list.map((m) => _buildMarker(m)).toList();
                  return MarkerClusterLayerWidget(
                    options: MarkerClusterLayerOptions(
                      maxClusterRadius: 60,
                      size: const Size(48, 48),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(50),
                      markers: markers,
                      builder: (ctx, clusterMarkers) =>
                          _ClusterBubble(count: clusterMarkers.length),
                    ),
                  );
                },
              ),
              if (_userLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _userLocation!,
                      width: 26,
                      height: 26,
                      child: const _UserDot(),
                    ),
                  ],
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
          const Positioned(
            top: 56,
            right: 16,
            child: _MapLegend(),
          ),
          Positioned(
            top: 56,
            left: 16,
            child: Observer(
              builder: (_) => _FilterBadge(
                count: _store.filteredMarkers.length,
                total: _store.markers.length,
                onTap: _openFilters,
              ),
            ),
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
                SnackBar(
                  content:
                      Text(AppLocalizations.of(context)!.refreshingMap),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _GothicFab(
            heroTag: 'filters',
            icon: Icons.filter_alt_outlined,
            onPressed: _openFilters,
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
            icon: _locating ? Icons.hourglass_empty : Icons.my_location,
            onPressed: _goToMyLocation,
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

  Marker _buildMarker(MapMarkerEntity marker) {
    return Marker(
      point: LatLng(marker.lat, marker.lon),
      width: 52,
      height: 62,
      alignment: Alignment.bottomCenter,
      child: GestureDetector(
        onTap: () => _showMarkerInfo(context, marker),
        child: _GothicMarker(isCompleted: marker.isCompleted),
      ),
    );
  }

  Future<void> _goToMyLocation() async {
    if (_locating) return;
    setState(() => _locating = true);
    final result = await _location.getCurrentPosition();
    if (!mounted) return;
    setState(() => _locating = false);

    final l10n = AppLocalizations.of(context)!;
    switch (result) {
      case LocationSuccess(point: final p):
        setState(() => _userLocation = p);
        _mapController.move(p, 15.0);
      case LocationServiceDisabled():
        _snack(l10n.locationDisabled);
      case LocationDenied():
        _snack(l10n.locationDenied);
      case LocationDeniedForever():
        _snack(l10n.locationDeniedForever);
      case LocationError(message: final m):
        _snack(l10n.locationError(m));
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _openCreateMarker() async {
    final center = _userLocation ?? _mapController.camera.center;
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

  void _openFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _FiltersSheet(store: _store),
    );
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
                        label: Text(
                            AppLocalizations.of(context)!.filterCompleted),
                      )
                    : ElevatedButton.icon(
                        onPressed: () {
                          _store.markAsCompleted(marker.id);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(AppLocalizations.of(context)!
                                    .markedAsCompleted)),
                          );
                        },
                        icon: const Icon(Icons.flag, size: 16),
                        label: Text(
                            AppLocalizations.of(context)!.markAsCompleted),
                      ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) => ReportSheet(
                        markerId: marker.id,
                        markerTitle: marker.title,
                      ),
                    );
                  },
                  icon: const Icon(Icons.flag_outlined, size: 16),
                  label: Text(AppLocalizations.of(context)!.report),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Cluster bubble ──────────────────────────────────────────────────────────

class _ClusterBubble extends StatelessWidget {
  final int count;
  const _ClusterBubble({required this.count});

  @override
  Widget build(BuildContext context) {
    final gold = context.gold;
    return Container(
      decoration: BoxDecoration(
        color: context.goldContainer,
        shape: BoxShape.circle,
        border: Border.all(color: gold, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: gold.withValues(alpha: 0.45),
            blurRadius: 14,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Text(
          '$count',
          style: GoogleFonts.cinzel(
            color: gold,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

// ─── User dot ────────────────────────────────────────────────────────────────

class _UserDot extends StatelessWidget {
  const _UserDot();

  @override
  Widget build(BuildContext context) {
    final color = context.gold;
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.6),
            blurRadius: 14,
            spreadRadius: 4,
          ),
        ],
      ),
    );
  }
}

// ─── Filter badge ────────────────────────────────────────────────────────────

class _FilterBadge extends StatelessWidget {
  final int count;
  final int total;
  final VoidCallback onTap;

  const _FilterBadge({
    required this.count,
    required this.total,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: context.surfaceClr,
          border: Border.all(color: context.outlineClr, width: 1),
          borderRadius: BorderRadius.circular(2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.filter_alt_outlined, color: context.gold, size: 14),
            const SizedBox(width: 6),
            Text(
              '$count / $total',
              style: GoogleFonts.cinzel(
                color: context.onBg,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Filters sheet ───────────────────────────────────────────────────────────

class _FiltersSheet extends StatelessWidget {
  final MapStore store;
  const _FiltersSheet({required this.store});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        child: Observer(
          builder: (_) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.filtersTitle,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                const GothicDivider(),
                const SizedBox(height: 12),
                _section(context, l10n.statusFilter),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _statusChip(
                        context, l10n.filterAll, MarkerStatusFilter.all),
                    _statusChip(context, l10n.filterCompleted,
                        MarkerStatusFilter.completed),
                    _statusChip(context, l10n.filterNotCompleted,
                        MarkerStatusFilter.notCompleted),
                  ],
                ),
                const SizedBox(height: 18),
                _section(context, l10n.typeField),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _typeChip(context, l10n.filterAll, null),
                    for (final t in store.availableTypes)
                      _typeChip(context, t, t),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(l10n.close),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _section(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.cinzel(
          color: context.gold,
          fontSize: 11,
          letterSpacing: 2,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _statusChip(
      BuildContext context, String label, MarkerStatusFilter value) {
    final selected = store.statusFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => store.setStatusFilter(value),
      selectedColor: context.goldContainer,
      labelStyle: TextStyle(
        color: selected ? context.gold : context.onBg,
        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(
          color: selected ? context.gold : context.outlineClr),
    );
  }

  Widget _typeChip(BuildContext context, String label, String? value) {
    final selected = store.typeFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => store.setTypeFilter(value),
      selectedColor: context.goldContainer,
      labelStyle: TextStyle(
        color: selected ? context.gold : context.onBg,
        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(
          color: selected ? context.gold : context.outlineClr),
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
                  style: TextStyle(color: color, fontSize: 20, height: 1),
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
            label: AppLocalizations.of(context)!.filterCompleted,
          ),
          const SizedBox(height: 6),
          _LegendItem(
            symbol: '◆',
            color: context.blood,
            label: AppLocalizations.of(context)!.filterNotCompleted,
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
