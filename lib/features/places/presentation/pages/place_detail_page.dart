import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/gothic_widgets.dart';
import '../../../../core/theme/theme_ext.dart';
import '../../../../core/util/geo.dart';
import '../../../../core/util/result.dart';
import '../../../activity/domain/entities/activity.dart';
import '../../../activity/presentation/stores/journal_store.dart';
import '../../../activity/presentation/stores/tracking_store.dart';
import '../../../favorites/presentation/stores/favorites_store.dart';
import '../../../reports/presentation/pages/report_sheet.dart';
import '../../domain/entities/place.dart';
import '../../domain/entities/place_source.dart';
import '../../domain/services/qr_payload_parser.dart';
import '../stores/places_store.dart';
import '../widgets/place_labels.dart';

class PlaceDetailPage extends StatefulWidget {
  const PlaceDetailPage({super.key, required this.place, this.fetchDetails = true});

  final Place place;

  /// When false the given [place] is shown as is (e.g. already resolved).
  final bool fetchDetails;

  @override
  State<PlaceDetailPage> createState() => _PlaceDetailPageState();
}

class _PlaceDetailPageState extends State<PlaceDetailPage> {
  final PlacesStore _places = getIt<PlacesStore>();
  final JournalStore _journal = getIt<JournalStore>();
  final TrackingStore _tracking = getIt<TrackingStore>();
  final FavoritesStore _favorites = getIt<FavoritesStore>();

  late Place _place = widget.place;
  bool _loading = false;
  bool _loadFailed = false;

  @override
  void initState() {
    super.initState();
    _journal.log(ActivityEventType.view, place: _place);
    _places.remember(_place);
    if (widget.fetchDetails && _place.source.isRemote) _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final r = await _places.details(_place);
    if (!mounted) return;
    setState(() {
      _loading = false;
      switch (r) {
        case Ok(value: final p):
          // Keep coordinates from the list if the detail call lacks them.
          _place = p.hasLocation ? p : p.copyWith(lat: _place.lat, lon: _place.lon);
        case Err():
          _loadFailed = true;
      }
    });
  }

  Future<void> _open(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final p = _place;
    final theme = Theme.of(context);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: p.imageUrl != null ? 320 : 120,
            pinned: true,
            actions: [
              Observer(builder: (_) {
                final fav = _favorites.isFavorite(p.id);
                return IconButton(
                  icon: Icon(fav ? Icons.favorite : Icons.favorite_border, color: fav ? context.blood : null),
                  onPressed: () => _favorites.toggle(p),
                );
              }),
              PopupMenuButton<String>(
                onSelected: (v) async {
                  switch (v) {
                    case 'qr':
                      _showQr(p);
                    case 'report':
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (_) => ReportSheet(markerId: p.id, markerTitle: p.title),
                      );
                    case 'delete':
                      await _places.deleteUserPlace(p);
                      if (context.mounted) context.pop();
                  }
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                      value: 'qr', child: ListTile(leading: const Icon(Icons.qr_code_2), title: Text(l.placeQrTitle))),
                  PopupMenuItem(
                      value: 'report',
                      child: ListTile(leading: const Icon(Icons.flag_outlined), title: Text(l.report))),
                  if (p.source == PlaceSource.user)
                    PopupMenuItem(
                        value: 'delete',
                        child: ListTile(leading: const Icon(Icons.delete_outline), title: Text(l.deletePlace))),
                ],
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: p.imageUrl == null
                  ? Container(color: context.surfaceVar, child: Icon(p.category.icon, size: 56, color: context.gold))
                  : Stack(fit: StackFit.expand, children: [
                      CachedNetworkImage(
                        imageUrl: p.imageUrl!,
                        fit: BoxFit.cover,
                        httpHeaders: const {'User-Agent': 'QStory/1.0 (+https://github.com/undemorbe/Q-Story)'},
                        placeholder: (_, __) => Container(color: context.surfaceVar),
                        errorWidget: (_, __, ___) => Container(
                            color: context.surfaceVar, child: Icon(p.category.icon, size: 56, color: context.gold)),
                      ),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.black45, Colors.transparent, Colors.black54],
                            stops: [0, 0.4, 1],
                          ),
                        ),
                      ),
                    ]),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Wrap(spacing: 8, runSpacing: 6, children: [
                  _tag(context, p.source.icon, p.source.label(l), p.source.color),
                  _tag(context, p.category.icon, p.category.label(l), context.gold),
                  if (p.yearLabel != null) _tag(context, Icons.history_edu, p.yearLabel!, context.gold),
                  Observer(
                      builder: (_) => _journal.visitedIds.contains(p.id)
                          ? _tag(context, Icons.check_circle, l.visitedBadge, context.gold)
                          : const SizedBox.shrink()),
                ]),
                const SizedBox(height: 14),
                Text(p.title,
                    style: GoogleFonts.cinzel(fontSize: 24, fontWeight: FontWeight.w700, color: context.onBg)),
                Observer(builder: (_) {
                  final me = _tracking.position;
                  if (me == null || !p.hasLocation) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(l.distanceFromYou(l.distance(Geo.distanceM(me.lat, me.lon, p.lat, p.lon))),
                        style: theme.textTheme.bodySmall),
                  );
                }),
                if (p.author != null) ...[
                  const SizedBox(height: 6),
                  Text('${l.authorLabel}: ${p.author}', style: theme.textTheme.bodySmall),
                ],
                const SizedBox(height: 16),
                _actions(context, l, p),
                const SizedBox(height: 20),
                const GothicDivider(),
                const SizedBox(height: 16),
                if (_loading) const LinearProgressIndicator(minHeight: 2),
                if (_loadFailed)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(l.detailsLoadError, style: TextStyle(color: context.blood)),
                  ),
                SelectableText(
                  p.body.isEmpty ? l.noDescription : p.body,
                  style: GoogleFonts.crimsonText(fontSize: 18, height: 1.5, color: context.onBg),
                ),
                if (p.url != null || p.links.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(l.linksLabel.toUpperCase(),
                      style: GoogleFonts.cinzel(color: context.gold, fontSize: 12, letterSpacing: 2)),
                  const SizedBox(height: 8),
                  if (p.url != null)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(p.source.icon, color: p.source.color),
                      title: Text(l.openSource(p.source.label(l))),
                      trailing: const Icon(Icons.open_in_new, size: 18),
                      onTap: () => _open(p.url!),
                    ),
                  for (final link in p.links)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.link),
                      title: Text(Uri.tryParse(link)?.host ?? link, maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: Text(link, maxLines: 1, overflow: TextOverflow.ellipsis),
                      onTap: () => _open(link),
                    ),
                ],
                const SizedBox(height: 16),
                if (p.source.isRemote)
                  Text(l.attribution(p.source.label(l), p.source.license),
                      style: theme.textTheme.labelSmall?.copyWith(color: context.dim)),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actions(BuildContext context, AppLocalizations l, Place p) {
    return Observer(builder: (_) {
      final visited = _journal.visitedIds.contains(p.id);
      final hunting = _tracking.activeHunt?.placeId == p.id;
      return Row(children: [
        if (p.hasLocation)
          Expanded(
            child: FilledButton.icon(
              icon: Icon(hunting ? Icons.explore : Icons.explore_outlined, size: 18),
              label: Text(hunting ? l.huntInProgress : l.startHunt, maxLines: 1, overflow: TextOverflow.ellipsis),
              onPressed: hunting || visited
                  ? null
                  : () async {
                      await _tracking.startHunt(p);
                      if (context.mounted) context.go('/map');
                    },
            ),
          ),
        if (p.hasLocation) const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton.icon(
            icon: Icon(visited ? Icons.check : Icons.flag_outlined, size: 18),
            label: Text(visited ? l.visitedBadge : l.markVisited, maxLines: 1, overflow: TextOverflow.ellipsis),
            onPressed: visited
                ? null
                : () async {
                    await _journal.recordVisit(p, VisitMethod.manual);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.markedVisited)));
                    }
                  },
          ),
        ),
      ]);
    });
  }

  Widget _tag(BuildContext context, IconData icon, String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: color.withValues(alpha: 0.7)),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(fontSize: 12, color: context.onBg)),
        ]),
      );

  void _showQr(Place p) {
    final l = AppLocalizations.of(context)!;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.placeQrTitle),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(12),
            child: QrImageView(data: QrPayloadParser.encode(p), size: 220),
          ),
          const SizedBox(height: 12),
          Text(l.placeQrHint, textAlign: TextAlign.center),
        ]),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l.close))],
      ),
    );
  }
}
