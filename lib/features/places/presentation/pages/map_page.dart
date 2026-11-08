import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobx/mobx.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/services/motion_sensors.dart';
import '../../../../core/theme/gothic_widgets.dart';
import '../../../../core/theme/theme_ext.dart';
import '../../../../core/util/geo.dart';
import '../../../activity/domain/entities/activity.dart';
import '../../../activity/presentation/stores/journal_store.dart';
import '../../../activity/presentation/stores/tracking_store.dart';
import '../../../settings/presentation/stores/settings_store.dart';
import '../../domain/entities/place.dart';
import '../../domain/entities/place_source.dart';
import '../stores/places_store.dart';
import '../widgets/map_widgets.dart';
import '../widgets/nearby_list.dart';
import '../widgets/place_labels.dart';
import 'add_place_page.dart';
import '../../../../core/theme/app_fonts.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final PlacesStore _places = getIt<PlacesStore>();
  final TrackingStore _tracking = getIt<TrackingStore>();
  final JournalStore _journal = getIt<JournalStore>();
  final SettingsStore _settings = getIt<SettingsStore>();
  final MapController _map = MapController();

  /// Saint Petersburg — sensible default for a Russian history app.
  static const LatLng _fallbackCenter = LatLng(59.9343, 30.3351);

  final List<ReactionDisposer> _disposers = [];
  bool _mapReady = false;
  bool _locating = false;
  bool _movedAway = false;
  String? _dismissedNearbyId;

  @override
  void initState() {
    super.initState();
    _disposers
      ..add(reaction<GeoFix?>((_) => _tracking.position, _onPosition))
      ..add(
        reaction<Hunt?>((_) => _tracking.lastFoundHunt, (h) {
          if (h != null && mounted) _showFound(h);
        }),
      );
  }

  @override
  void dispose() {
    for (final d in _disposers) {
      d();
    }
    _map.dispose();
    super.dispose();
  }

  Future<void> _onMapReady() async {
    _mapReady = true;
    final pos = _tracking.latLng;
    if (pos != null) {
      _map.move(pos, 15);
      unawaited(_places.loadAround(pos.latitude, pos.longitude));
    } else {
      unawaited(_places.loadAround(_fallbackCenter.latitude, _fallbackCenter.longitude));
    }
    if (_settings.autoTracking && !_tracking.isTracking) {
      final access = await _tracking.start();
      _reportAccess(access);
    } else if (pos == null) {
      await _locate();
    }
  }

  void _onPosition(GeoFix? fix) {
    if (fix == null || !_mapReady) return;
    final p = LatLng(fix.lat, fix.lon);
    if (_tracking.followUser) {
      _map.move(p, math.max(_map.camera.zoom, 15));
    }
    if (_places.shouldReload(fix.lat, fix.lon) && _tracking.followUser) {
      _places.loadAround(fix.lat, fix.lon);
    }
  }

  Future<void> _locate() async {
    if (_locating) return;
    setState(() => _locating = true);
    final fix = _tracking.isTracking ? _tracking.position : await _tracking.locateOnce();
    if (!mounted) return;
    setState(() => _locating = false);
    if (fix == null) {
      _reportAccess(_tracking.access ?? LocationAccess.denied);
      return;
    }
    _tracking.setFollowUser(true);
    _map.move(LatLng(fix.lat, fix.lon), 16);
    unawaited(_places.loadAround(fix.lat, fix.lon));
    setState(() => _movedAway = false);
  }

  void _reportAccess(LocationAccess a) {
    if (!mounted || a == LocationAccess.granted) return;
    final l = AppLocalizations.of(context)!;
    final (msg, action) = switch (a) {
      LocationAccess.serviceDisabled => (l.locationDisabled, _tracking.openLocationSettings),
      LocationAccess.deniedForever => (l.locationDeniedForever, _tracking.openAppSettings),
      _ => (l.locationDenied, null),
    };
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        action: action == null ? null : SnackBarAction(label: l.openSettings, onPressed: action),
      ),
    );
  }

  Future<void> _toggleTracking() async {
    if (_tracking.isTracking) {
      await _tracking.stop();
    } else {
      _reportAccess(await _tracking.start());
    }
  }

  void _searchHere() {
    final c = _map.camera.center;
    _places.loadAround(c.latitude, c.longitude, force: true);
    setState(() => _movedAway = false);
  }

  void _onMapEvent(MapEvent e) {
    if (e is MapEventMoveStart && e.source != MapEventSource.mapController) {
      _tracking.setFollowUser(false);
    }
    if (e is MapEventMoveEnd && _places.lastLat != null) {
      final c = _map.camera.center;
      final far =
          Geo.distanceM(c.latitude, c.longitude, _places.lastLat!, _places.lastLon!) > _settings.searchRadiusM * 0.6;
      if (far != _movedAway) setState(() => _movedAway = far);
    }
  }

  // ─── Build ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final top = MediaQuery.paddingOf(context).top;
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _map,
            options: MapOptions(
              initialCenter: _tracking.latLng ?? _fallbackCenter,
              initialZoom: 14,
              onMapReady: _onMapReady,
              onMapEvent: _onMapEvent,
              interactionOptions: const InteractionOptions(flags: InteractiveFlag.all & ~InteractiveFlag.rotate),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'io.github.undemorbe.qstory',
              ),
              Observer(
                builder: (_) {
                  final pts = _tracking.track.toList();
                  if (pts.length < 2) return const SizedBox.shrink();
                  return PolylineLayer(
                    polylines: [
                      Polyline(points: pts, strokeWidth: 5, color: const Color(0xFF3D8BFF).withValues(alpha: 0.75)),
                    ],
                  );
                },
              ),
              Observer(
                builder: (_) {
                  final h = _tracking.activeHunt;
                  final me = _tracking.latLng;
                  if (h == null || me == null) return const SizedBox.shrink();
                  return PolylineLayer(
                    polylines: [
                      Polyline(
                        points: [me, LatLng(h.targetLat, h.targetLon)],
                        strokeWidth: 3,
                        color: context.gold,
                        pattern: StrokePattern.dashed(segments: const [10, 8]),
                      ),
                    ],
                  );
                },
              ),
              Observer(
                builder: (_) {
                  final visited = _journal.visitedIds;
                  final targetId = _tracking.activeHunt?.placeId;
                  final markers = _places.filtered
                      .map(
                        (p) => Marker(
                          key: ValueKey(p.id),
                          point: LatLng(p.lat, p.lon),
                          width: PlacePin.width,
                          height: PlacePin.height,
                          alignment: Alignment.topCenter,
                          child: GestureDetector(
                            onTap: () => _showPreview(p),
                            child: PlacePin(place: p, visited: visited.contains(p.id), isTarget: p.id == targetId),
                          ),
                        ),
                      )
                      .toList();
                  return MarkerClusterLayerWidget(
                    options: MarkerClusterLayerOptions(
                      maxClusterRadius: 55,
                      size: const Size(44, 44),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(50),
                      markers: markers,
                      builder: (ctx, ms) => ClusterBubble(count: ms.length),
                    ),
                  );
                },
              ),
              Observer(
                builder: (_) {
                  final me = _tracking.latLng;
                  if (me == null) return const SizedBox.shrink();
                  return MarkerLayer(
                    markers: [
                      Marker(
                        point: me,
                        width: 64,
                        height: 64,
                        child: UserLocationDot(
                          headingDeg: _tracking.position?.headingDeg,
                          tracking: _tracking.isTracking,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const RichAttributionWidget(
                alignment: AttributionAlignment.bottomLeft,
                attributions: [TextSourceAttribution('OpenStreetMap contributors')],
              ),
            ],
          ),
          Positioned(
            top: top + 8,
            left: 12,
            right: 12,
            child: _TopBar(store: _places, onFilters: _openFilters),
          ),
          Positioned(
            top: top + 64,
            left: 12,
            right: 72,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StatusStrip(store: _places),
                const SizedBox(height: 8),
                _TrackingPill(tracking: _tracking, onTap: _toggleTracking),
                if (_movedAway) ...[
                  const SizedBox(height: 8),
                  ActionChip(
                    avatar: const Icon(Icons.travel_explore, size: 18),
                    label: Text(l.searchHere),
                    onPressed: _searchHere,
                  ),
                ],
              ],
            ),
          ),
          Positioned(
            left: 12,
            right: 72,
            bottom: 12,
            child: Observer(
              builder: (_) {
                if (_tracking.activeHunt != null) return _HuntBanner(tracking: _tracking);
                final me = _tracking.position;
                if (me == null) return const SizedBox.shrink();
                final near = _places.nearestWithin(me.lat, me.lon, _settings.geofenceRadiusM.toDouble());
                if (near == null || _journal.isVisited(near.id) || near.id == _dismissedNearbyId) {
                  return const SizedBox.shrink();
                }
                return _NearbyBanner(
                  place: near,
                  onVisit: () async {
                    await _journal.recordVisit(near, VisitMethod.manual);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.markedVisited)));
                    }
                  },
                  onOpen: () => context.push('/place', extra: near),
                  onDismiss: () => setState(() => _dismissedNearbyId = near.id),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Observer(
        builder: (_) => Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GothicFab(
              icon: _tracking.isTracking ? Icons.directions_walk : Icons.directions_walk_outlined,
              active: _tracking.isTracking,
              tooltip: _tracking.isTracking ? l.stopTracking : l.startTracking,
              onPressed: _toggleTracking,
            ),
            const SizedBox(height: 10),
            GothicFab(
              icon: _tracking.followUser ? Icons.navigation : Icons.my_location,
              active: _tracking.followUser && _tracking.position != null,
              busy: _locating,
              tooltip: l.followMe,
              onPressed: _locate,
            ),
            const SizedBox(height: 10),
            GothicFab(small: true, icon: Icons.add, onPressed: () => _zoom(1)),
            const SizedBox(height: 6),
            GothicFab(small: true, icon: Icons.remove, onPressed: () => _zoom(-1)),
            const SizedBox(height: 10),
            GothicFab(icon: Icons.format_list_bulleted, tooltip: l.nearbyAction, onPressed: _openNearby),
            const SizedBox(height: 10),
            GothicFab(icon: Icons.refresh, tooltip: l.refreshAction, busy: _places.isLoading, onPressed: _searchHere),
            const SizedBox(height: 10),
            GothicFab(icon: Icons.add_location_alt_outlined, tooltip: l.addMyPlace, onPressed: _addPlace),
          ],
        ),
      ),
    );
  }

  void _zoom(double delta) {
    _map.move(_map.camera.center, (_map.camera.zoom + delta).clamp(3, 19));
  }

  Future<void> _addPlace() async {
    final c = _tracking.latLng ?? _map.camera.center;
    await Navigator.of(context).push<Place>(MaterialPageRoute(builder: (_) => AddPlacePage(initial: c)));
  }

  void _openFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _FiltersSheet(store: _places, enabled: _settings.enabledSources.toSet()),
    );
  }

  void _openNearby() {
    final me = _tracking.position;
    final center = _mapReady ? _map.camera.center : _fallbackCenter;
    final lat = me?.lat ?? center.latitude;
    final lon = me?.lon ?? center.longitude;
    final items = NearbyItem.build(_places.filtered, lat, lon);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.92,
        builder: (ctx, controller) => NearbyList(
          items: items,
          visitedIds: _journal.visitedIds.toSet(),
          fromMyLocation: me != null,
          scrollController: controller,
          onOpen: (p) {
            Navigator.pop(ctx);
            context.push('/place', extra: p);
          },
        ),
      ),
    );
  }

  void _showPreview(Place p) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => _PlacePreview(place: p, tracking: _tracking, journal: _journal),
    );
  }

  Future<void> _showFound(Hunt h) async {
    final l = AppLocalizations.of(context)!;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Icon(Icons.emoji_events_outlined, color: context.gold, size: 40),
        title: Text(l.huntFoundTitle, textAlign: TextAlign.center),
        content: Text(
          l.huntFoundBody(h.placeTitle, '${h.steps}', l.distance(h.distanceM), l.duration(h.duration(DateTime.now()))),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.go('/stats');
            },
            child: Text(l.statsOpen),
          ),
          FilledButton(onPressed: () => Navigator.pop(ctx), child: Text(l.ok)),
        ],
      ),
    );
    _tracking.dismissFoundHunt();
  }
}

// ─── Top bar: search + filters ───────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({required this.store, required this.onFilters});
  final PlacesStore store;
  final VoidCallback onFilters;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Material(
      elevation: 4,
      color: context.surfaceClr,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: BorderSide(color: context.outlineClr),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Icon(Icons.search, color: context.gold, size: 20),
          Expanded(
            child: TextField(
              onChanged: store.setSearchQuery,
              decoration: InputDecoration(
                hintText: l.searchPlaces,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
              ),
            ),
          ),
          Observer(
            builder: (_) {
              final n = store.activeFilterCount;
              return IconButton(
                onPressed: onFilters,
                icon: Badge(
                  isLabelVisible: n > 0,
                  label: Text('$n'),
                  child: Icon(Icons.tune, color: context.gold),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StatusStrip extends StatelessWidget {
  const _StatusStrip({required this.store});
  final PlacesStore store;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Observer(
      builder: (_) {
        final chips = <Widget>[];
        if (store.isLoading) {
          chips.add(_chip(context, l.loadingPlaces, icon: Icons.hourglass_top));
        } else {
          chips.add(_chip(context, l.placesCount(store.filtered.length), icon: Icons.place_outlined));
        }
        if (store.fromCache) chips.add(_chip(context, l.offlineCache, icon: Icons.cloud_off, warn: true));
        if (store.failures.isNotEmpty) {
          chips.add(
            _chip(
              context,
              l.sourcesUnavailable(store.failures.keys.map((s) => s.label(l)).join(', ')),
              icon: Icons.warning_amber_rounded,
              warn: true,
            ),
          );
        }
        return Wrap(spacing: 6, runSpacing: 6, children: chips);
      },
    );
  }

  Widget _chip(BuildContext context, String text, {required IconData icon, bool warn = false}) {
    final color = warn ? context.blood : context.gold;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: context.surfaceClr.withValues(alpha: 0.95),
        border: Border.all(color: color.withValues(alpha: 0.6)),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: AppFonts.display(fontSize: 11, color: context.onBg),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrackingPill extends StatelessWidget {
  const _TrackingPill({required this.tracking, required this.onTap});
  final TrackingStore tracking;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Observer(
      builder: (_) {
        final on = tracking.isTracking;
        final color = on ? const Color(0xFF3D8BFF) : context.dim;
        return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: context.surfaceClr.withValues(alpha: 0.95),
              border: Border.all(color: color),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  on ? Icons.fiber_manual_record : Icons.pause_circle_outline,
                  size: 12,
                  color: on ? Colors.redAccent : color,
                ),
                const SizedBox(width: 6),
                Text(on ? l.trackingOn : l.trackingOff, style: TextStyle(fontSize: 12, color: context.onBg)),
                const SizedBox(width: 8),
                Icon(Icons.directions_walk, size: 14, color: context.gold),
                Text(
                  ' ${tracking.todaySteps}',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: context.onBg),
                ),
                if (on && tracking.sessionDistanceM > 0) ...[
                  const SizedBox(width: 8),
                  Icon(Icons.route, size: 14, color: context.gold),
                  Text(
                    ' ${l.distance(tracking.sessionDistanceM)}',
                    style: TextStyle(fontSize: 12, color: context.onBg),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HuntBanner extends StatelessWidget {
  const _HuntBanner({required this.tracking});
  final TrackingStore tracking;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Observer(
      builder: (_) {
        final h = tracking.activeHunt;
        if (h == null) return const SizedBox.shrink();
        final d = tracking.distanceToTargetM;
        final bearing = tracking.bearingToTargetDeg;
        final eta = tracking.huntEta;
        return GothicCard(
          padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
          child: Row(
            children: [
              Transform.rotate(
                angle: (bearing ?? 0) * math.pi / 180,
                child: Icon(Icons.navigation, color: context.gold, size: 30),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l.huntSearching(h.placeTitle),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      [
                        if (d != null) l.huntLeft(l.distance(d)),
                        '${h.steps} ${l.statsSteps.toLowerCase()}',
                        l.distance(h.distanceM),
                      ].join(' · '),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (eta != null && d != null && d > 0) ...[
                      const SizedBox(height: 2),
                      Text(
                        l.huntEta(l.duration(eta.duration), '${eta.steps}'),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: context.dim),
                      ),
                    ],
                  ],
                ),
              ),
              TextButton(onPressed: () => tracking.finishHunt(found: false), child: Text(l.huntGiveUp)),
            ],
          ),
        );
      },
    );
  }
}

class _NearbyBanner extends StatelessWidget {
  const _NearbyBanner({required this.place, required this.onVisit, required this.onOpen, required this.onDismiss});
  final Place place;
  final VoidCallback onVisit;
  final VoidCallback onOpen;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return GothicCard(
      padding: const EdgeInsets.fromLTRB(14, 10, 4, 10),
      child: Row(
        children: [
          Icon(Icons.near_me, color: context.gold),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: onOpen,
                  child: Text(l.nearPlace(place.title), maxLines: 2, overflow: TextOverflow.ellipsis),
                ),
                TextButton(
                  style: TextButton.styleFrom(padding: EdgeInsets.zero, visualDensity: VisualDensity.compact),
                  onPressed: onVisit,
                  child: Text(l.markVisited),
                ),
              ],
            ),
          ),
          IconButton(onPressed: onDismiss, icon: const Icon(Icons.close, size: 18)),
        ],
      ),
    );
  }
}

// ─── Preview sheet ───────────────────────────────────────────────────────

class _PlacePreview extends StatelessWidget {
  const _PlacePreview({required this.place, required this.tracking, required this.journal});
  final Place place;
  final TrackingStore tracking;
  final JournalStore journal;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Observer(
          builder: (_) {
            final me = tracking.position;
            final dist = me == null ? null : Geo.distanceM(me.lat, me.lon, place.lat, place.lon);
            final visited = journal.visitedIds.contains(place.id);
            final hunting = tracking.activeHunt?.placeId == place.id;
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(place.source.icon, size: 16, color: place.source.color),
                    const SizedBox(width: 6),
                    Text(
                      '${place.source.label(l)} · ${place.category.label(l)}',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    const Spacer(),
                    if (visited) Chip(label: Text(l.visitedBadge), avatar: const Icon(Icons.check, size: 16)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(place.title, style: Theme.of(context).textTheme.titleLarge),
                if (place.yearLabel != null || dist != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    [
                      if (place.yearLabel != null) place.yearLabel!,
                      if (dist != null) l.distanceFromYou(l.distance(dist)),
                    ].join(' · '),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                const SizedBox(height: 8),
                const GothicDivider(),
                if (place.summary.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(place.summary, maxLines: 4, overflow: TextOverflow.ellipsis),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.menu_book_outlined, size: 18),
                        label: Text(l.details),
                        onPressed: () {
                          Navigator.pop(context);
                          context.push('/place', extra: place);
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton.icon(
                        icon: Icon(hunting ? Icons.explore : Icons.explore_outlined, size: 18),
                        label: Text(hunting ? l.huntInProgress : l.startHunt),
                        onPressed: hunting || visited
                            ? null
                            : () async {
                                Navigator.pop(context);
                                await tracking.startHunt(place);
                              },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  l.attribution(place.source.label(l), place.source.license),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(color: context.dim),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ─── Filters ─────────────────────────────────────────────────────────────

class _FiltersSheet extends StatelessWidget {
  const _FiltersSheet({required this.store, required this.enabled});
  final PlacesStore store;
  final Set<PlaceSource> enabled;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Observer(
          builder: (_) {
            final counts = store.countBySource;
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(l.filtersTitle, style: Theme.of(context).textTheme.titleLarge)),
                    TextButton(onPressed: store.resetFilters, child: Text(l.resetFilters)),
                  ],
                ),
                const GothicDivider(),
                const SizedBox(height: 12),
                _section(context, l.visitFilterLabel),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final (f, label) in [
                      (VisitFilter.all, l.filterAll),
                      (VisitFilter.visited, l.filterVisited),
                      (VisitFilter.notVisited, l.filterNotVisited),
                    ])
                      ChoiceChip(
                        label: Text(label),
                        selected: store.visitFilter == f,
                        onSelected: (_) => store.setVisitFilter(f),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                _section(context, l.sourcesLabel),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final s in PlaceSource.values.where(enabled.contains))
                      FilterChip(
                        avatar: Icon(s.icon, size: 16, color: s.color),
                        label: Text('${s.label(l)} (${counts[s] ?? 0})'),
                        selected: store.sourceFilter.contains(s),
                        onSelected: (_) => store.toggleSourceFilter(s),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                _section(context, l.categoryLabel),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(
                      label: Text(l.filterAll),
                      selected: store.categoryFilter == null,
                      onSelected: (_) => store.setCategoryFilter(null),
                    ),
                    for (final c in store.availableCategories)
                      ChoiceChip(
                        avatar: Icon(c.icon, size: 16),
                        label: Text(c.label(l)),
                        selected: store.categoryFilter == c,
                        onSelected: (_) => store.setCategoryFilter(c),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(onPressed: () => Navigator.pop(context), child: Text(l.close)),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _section(BuildContext context, String title) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      title.toUpperCase(),
      style: AppFonts.display(color: context.gold, fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.w600),
    ),
  );
}
