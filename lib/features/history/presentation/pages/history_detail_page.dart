import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../../../core/di/service_locator.dart';
import '../../domain/entities/history_entity.dart';
import '../../../favorites/presentation/stores/favorites_store.dart';

class HistoryDetailPage extends StatelessWidget {
  final HistoryEntity entity;

  const HistoryDetailPage({super.key, required this.entity});

  @override
  Widget build(BuildContext context) {
    final FavoritesStore favoritesStore = getIt<FavoritesStore>();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300.0,
            floating: false,
            pinned: true,
            actions: [
              Observer(
                builder: (_) {
                  final isFavorite = favoritesStore.isFavorite(entity.id);
                  return IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : null,
                    ),
                    onPressed: () {
                      favoritesStore.toggleFavorite(entity.id);
                    },
                  );
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(entity.title),
              background: CachedNetworkImage(
                imageUrl: entity.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entity.subtitle,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  _buildTimeline(context),
                  const SizedBox(height: 16),
                  Text(
                    entity.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  ExpansionTile(
                    title: const Text('Detailed Information'),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Here goes more detailed information about ${entity.title}. '
                          'This section expands to show comprehensive historical data, '
                          'context, and significance.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text(
                    'Resources',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  _buildResourcesList(context),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.calendar_today),
            const SizedBox(width: 8),
            Text(
              entity.yearRange,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResourcesList(BuildContext context) {
    final resources = [
      'Wikipedia Entry',
      'Historical Archives',
      'Academic Papers',
      'Museum Collections',
    ];

    return Column(
      children: resources
          .map((resource) => ListTile(
                leading: const Icon(Icons.link),
                title: Text(resource),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // Open link
                },
              ))
          .toList(),
    );
  }
}
