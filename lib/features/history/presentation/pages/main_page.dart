import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/service_locator.dart';
import '../stores/history_store.dart';
import '../widgets/history_card.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final TextEditingController _searchController = TextEditingController();
  final HistoryStore _historyStore = getIt<HistoryStore>();

  @override
  void initState() {
    super.initState();
    _historyStore.loadHistory();
    _searchController.addListener(_filterEvents);
  }

  void _filterEvents() {
    _historyStore.filterHistory(_searchController.text);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: true,
            expandedHeight: 120,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('QStory History'),
              centerTitle: true,
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search events...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Observer(
            builder: (_) {
              if (_historyStore.isLoading) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (_historyStore.errorMessage != null) {
                return SliverFillRemaining(
                  child: Center(child: Text('Error: ${_historyStore.errorMessage}')),
                );
              }

              if (_historyStore.filteredList.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(child: Text('No events found')),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final event = _historyStore.filteredList[index];
                      return HistoryCard(
                        entity: event,
                        onTap: () {
                          context.push('/history/${event.id}', extra: event);
                        },
                      );
                    },
                    childCount: _historyStore.filteredList.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
