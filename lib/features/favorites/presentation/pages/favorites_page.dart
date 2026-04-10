import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/service_locator.dart';
import '../../../history/domain/entities/history_entity.dart';
import '../stores/favorites_store.dart';
import '../../../history/presentation/widgets/history_card.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final FavoritesStore store = getIt<FavoritesStore>();

    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: Observer(
        builder: (_) {
          if (!store.hasFavorites) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No favorites yet'),
                ],
              ),
            );
          }

          final favoriteEvents = store.favoriteItems.map((item) {
            return HistoryEntity(
              id: item['id'] as String,
              title: item['title'] as String,
              subtitle: item['subtitle'] as String? ?? '',
              description: item['description'] as String? ?? '',
              imageUrl: item['imageUrl'] as String? ?? '',
              yearRange: item['yearRange'] as String? ?? '',
            );
          }).toList();

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: favoriteEvents.length,
            itemBuilder: (context, index) {
              final event = favoriteEvents[index];
              return HistoryCard(
                entity: event,
                onTap: () {
                  context.push('/history/${event.id}', extra: event);
                },
              );
            },
          );
        },
      ),
    );
  }
}
