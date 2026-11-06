import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/theme_ext.dart';
import '../../domain/entities/place.dart';
import 'place_labels.dart';

class PlaceCard extends StatelessWidget {
  const PlaceCard({super.key, required this.place, required this.onTap, this.visited = false});

  final Place place;
  final VoidCallback onTap;
  final bool visited;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Material(
      color: context.surfaceClr,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: BorderSide(color: visited ? context.gold : context.outlineVar),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Expanded(
            child: Stack(fit: StackFit.expand, children: [
              if (place.imageUrl != null)
                CachedNetworkImage(
                  imageUrl: place.imageUrl!,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => _placeholder(context),
                  placeholder: (_, __) => _placeholder(context),
                )
              else
                _placeholder(context),
              Positioned(
                top: 6,
                left: 6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(3)),
                  child: Icon(place.source.icon, size: 14, color: Colors.white),
                ),
              ),
              if (visited)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Icon(Icons.check_circle, color: context.gold, size: 20),
                ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(place.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cinzel(fontSize: 13, fontWeight: FontWeight.w600, color: context.onBg)),
              const SizedBox(height: 4),
              Text(
                [place.category.label(l), if (place.yearLabel != null) place.yearLabel!].join(' · '),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(color: context.dim),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _placeholder(BuildContext context) =>
      Container(color: context.surfaceVar, child: Icon(place.category.icon, color: context.gold, size: 36));
}
