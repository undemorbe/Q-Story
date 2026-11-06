import 'package:flutter/material.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/util/geo.dart';
import '../../domain/entities/place.dart';
import '../../domain/entities/place_source.dart';

extension PlaceCategoryUi on PlaceCategory {
  String label(AppLocalizations l) => switch (this) {
        PlaceCategory.monument => l.catMonument,
        PlaceCategory.memorial => l.catMemorial,
        PlaceCategory.building => l.catBuilding,
        PlaceCategory.religious => l.catReligious,
        PlaceCategory.museum => l.catMuseum,
        PlaceCategory.archaeology => l.catArchaeology,
        PlaceCategory.fortification => l.catFortification,
        PlaceCategory.photo => l.catPhoto,
        PlaceCategory.article => l.catArticle,
        PlaceCategory.other => l.catOther,
      };

  IconData get icon => switch (this) {
        PlaceCategory.monument => Icons.account_balance_outlined,
        PlaceCategory.memorial => Icons.local_florist_outlined,
        PlaceCategory.building => Icons.apartment_outlined,
        PlaceCategory.religious => Icons.church_outlined,
        PlaceCategory.museum => Icons.museum_outlined,
        PlaceCategory.archaeology => Icons.terrain_outlined,
        PlaceCategory.fortification => Icons.fort_outlined,
        PlaceCategory.photo => Icons.photo_camera_back_outlined,
        PlaceCategory.article => Icons.menu_book_outlined,
        PlaceCategory.other => Icons.place_outlined,
      };
}

extension PlaceSourceUi on PlaceSource {
  String label(AppLocalizations l) => this == PlaceSource.user ? l.sourceUser : title;

  String description(AppLocalizations l) => switch (this) {
        PlaceSource.pastvu => l.sourcePastvuDesc,
        PlaceSource.wikipedia => l.sourceWikipediaDesc,
        PlaceSource.wikidata => l.sourceWikidataDesc,
        PlaceSource.osm => l.sourceOsmDesc,
        PlaceSource.user => l.sourceUser,
      };

  /// Categorical identity colour. Validated (CVD ΔE ≥ 8, normal ΔE ≥ 15)
  /// against both theme surfaces; always shown next to a text label.
  Color get color => switch (this) {
        PlaceSource.wikipedia => const Color(0xFF3987E5),
        PlaceSource.pastvu => const Color(0xFFD95926),
        PlaceSource.wikidata => const Color(0xFF199E70),
        PlaceSource.osm => const Color(0xFFC98500),
        PlaceSource.user => const Color(0xFFD55181),
      };

  IconData get icon => switch (this) {
        PlaceSource.pastvu => Icons.photo_library_outlined,
        PlaceSource.wikipedia => Icons.article_outlined,
        PlaceSource.wikidata => Icons.account_balance_outlined,
        PlaceSource.osm => Icons.map_outlined,
        PlaceSource.user => Icons.person_pin_circle_outlined,
      };
}

extension L10nUnits on AppLocalizations {
  String distance(double m) => formatDistance(m, m: unitM, km: unitKm);
  String duration(Duration d) => formatDuration(d, h: unitH, min: unitMin, s: unitS);
}
