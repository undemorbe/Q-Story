import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/service_locator.dart';
import '../../../history/domain/entities/history_entity.dart';
import '../stores/favorites_store.dart';
import '../../../history/presentation/widgets/history_card.dart';

// Dummy Data (Shared with MainPage for now - ideally should be in a Repository)
final List<HistoryEntity> _allEvents = [
  const HistoryEntity(
    id: '1',
    title: 'Industrial Revolution',
    subtitle: 'Transition to new manufacturing processes',
    description: 'The Industrial Revolution was the transition to new manufacturing processes in Great Britain, continental Europe, and the United States.',
    imageUrl: 'https://picsum.photos/id/1/400/300',
    yearRange: '1760 - 1840',
  ),
  const HistoryEntity(
    id: '2',
    title: 'French Revolution',
    subtitle: 'Period of radical political and societal change',
    description: 'The French Revolution was a period of radical political and societal change in France that began with the Estates General of 1789 and ended with the formation of the French Consulate in November 1799.',
    imageUrl: 'https://picsum.photos/id/10/400/300',
    yearRange: '1789 - 1799',
  ),
  const HistoryEntity(
    id: '3',
    title: 'American Civil War',
    subtitle: 'Civil war in the United States',
    description: 'The American Civil War was a civil war in the United States between the Union and the Confederacy.',
    imageUrl: 'https://picsum.photos/id/20/400/300',
    yearRange: '1861 - 1865',
  ),
  const HistoryEntity(
    id: '4',
    title: 'Moon Landing',
    subtitle: 'First manned mission to land on the Moon',
    description: 'Apollo 11 was the American spaceflight that first landed humans on the Moon. Commander Neil Armstrong and lunar module pilot Buzz Aldrin.',
    imageUrl: 'https://picsum.photos/id/30/400/300',
    yearRange: '1969',
  ),
];

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

          final favoriteEvents = _allEvents
              .where((event) => store.isFavorite(event.id))
              .toList();

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
