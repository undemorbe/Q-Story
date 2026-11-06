import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/theme_ext.dart';
import '../../../../core/util/geo.dart';
import '../../domain/entities/place.dart';
import 'place_labels.dart';

/// A place with its distance and direction from the user.
class NearbyItem {
  const NearbyItem(this.place, this.distanceM, this.bearingDeg);
  final Place place;
  final double distanceM;
  final double bearingDeg;

  /// Sorts [places] by distance from ([lat], [lon]); keeps the closest [limit].
  static List<NearbyItem> build(Iterable<Place> places, double lat, double lon, {int limit = 100}) {
    final items = [
      for (final p in places)
        NearbyItem(p, Geo.distanceM(lat, lon, p.lat, p.lon), Geo.bearingDeg(lat, lon, p.lat, p.lon)),
    ]..sort((a, b) => a.distanceM.compareTo(b.distanceM));
    return items.length > limit ? items.sublist(0, limit) : items;
  }
}

/// Bottom-sheet list of places, closest first.
class NearbyList extends StatelessWidget {
  const NearbyList({
    super.key,
    required this.items,
    required this.visitedIds,
    required this.onOpen,
    this.fromMyLocation = true,
    this.scrollController,
  });

  final List<NearbyItem> items;
  final Set<String> visitedIds;
  final ValueChanged<Place> onOpen;

  /// False when distances are measured from the map centre (no GPS fix).
  final bool fromMyLocation;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 12, 4),
        child: Row(children: [
          Icon(Icons.format_list_bulleted, color: context.gold, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(l.nearbyTitle(items.length), style: theme.textTheme.titleMedium)),
        ]),
      ),
      if (!fromMyLocation)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(l.nearbyFromMapCenter, style: theme.textTheme.labelSmall?.copyWith(color: context.dim)),
        ),
      const Divider(height: 16),
      Expanded(
        child: items.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(l.nearbyEmpty, textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
                ),
              )
            : ListView.separated(
                controller: scrollController,
                itemCount: items.length,
                separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
                itemBuilder: (context, i) {
                  final it = items[i];
                  final p = it.place;
                  final visited = visitedIds.contains(p.id);
                  return ListTile(
                    key: ValueKey(p.id),
                    onTap: () => onOpen(p),
                    leading: CircleAvatar(
                      backgroundColor: p.source.color.withValues(alpha: 0.18),
                      foregroundColor: p.source.color,
                      child: Icon(p.category.icon, size: 20),
                    ),
                    title: Text(p.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text(
                      [p.category.label(l), if (p.yearLabel != null) p.yearLabel!, p.source.label(l)].join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                      if (visited) ...[
                        Icon(Icons.check_circle, size: 16, color: context.gold, semanticLabel: l.visited),
                        const SizedBox(width: 6),
                      ],
                      Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Transform.rotate(
                          angle: it.bearingDeg * math.pi / 180,
                          child: Icon(Icons.navigation, size: 16, color: context.dim),
                        ),
                        Text(l.distance(it.distanceM), style: theme.textTheme.labelSmall),
                      ]),
                    ]),
                  );
                },
              ),
      ),
    ]);
  }
}
