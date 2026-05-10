import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/history_entity.dart';

class HistoryCard extends StatelessWidget {
  final HistoryEntity entity;
  final VoidCallback onTap;

  const HistoryCard({
    super.key,
    required this.entity,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.outline, width: 1),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(2)),
                    child: CachedNetworkImage(
                      imageUrl: entity.imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: (context, url) => Container(
                        color: AppColors.surfaceVariant,
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: AppColors.surfaceVariant,
                        child: const Icon(Icons.image_outlined,
                            color: AppColors.outline, size: 32),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entity.yearRange,
                        style: GoogleFonts.cinzel(
                          color: AppColors.primaryGold,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        entity.title,
                        style: GoogleFonts.cinzel(
                          color: AppColors.onBackground,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        entity.subtitle,
                        style: GoogleFonts.crimsonText(
                            color: AppColors.onSurface, fontSize: 13),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Positioned(
              top: 4,
              left: 4,
              child: Text('✦',
                  style: TextStyle(
                      color: AppColors.primaryGold, fontSize: 7, height: 1)),
            ),
            const Positioned(
              top: 4,
              right: 4,
              child: Text('✦',
                  style: TextStyle(
                      color: AppColors.primaryGold, fontSize: 7, height: 1)),
            ),
            const Positioned(
              bottom: 4,
              left: 4,
              child: Text('✦',
                  style: TextStyle(
                      color: AppColors.primaryGold, fontSize: 7, height: 1)),
            ),
            const Positioned(
              bottom: 4,
              right: 4,
              child: Text('✦',
                  style: TextStyle(
                      color: AppColors.primaryGold, fontSize: 7, height: 1)),
            ),
          ],
        ),
      ),
    );
  }
}
