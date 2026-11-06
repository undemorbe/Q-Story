import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/theme_ext.dart';
import '../../../activity/presentation/stores/journal_store.dart';
import '../../../places/presentation/widgets/place_card.dart';
import '../stores/favorites_store.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = getIt<FavoritesStore>();
    final journal = getIt<JournalStore>();
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l.favoritesTitle)),
      body: Observer(builder: (_) {
        if (!store.hasFavorites) {
          return Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.favorite_outline, size: 64, color: context.outlineClr),
              const SizedBox(height: 16),
              Text(l.noFavoritesYet, style: GoogleFonts.cinzel(color: context.onBg, fontSize: 14)),
            ]),
          );
        }
        final visited = journal.visitedIds;
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 220,
            childAspectRatio: 0.78,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: store.items.length,
          itemBuilder: (context, i) {
            final p = store.items[i];
            return PlaceCard(
              place: p,
              visited: visited.contains(p.id),
              onTap: () => context.push('/place', extra: p),
            );
          },
        );
      }),
    );
  }
}
