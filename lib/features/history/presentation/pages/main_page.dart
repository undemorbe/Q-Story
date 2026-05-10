import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
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
              title: Text(
                'Chronicles',
                style: GoogleFonts.cinzelDecorative(
                  color: AppColors.primaryGold,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.surfaceVariant, AppColors.background],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Center(
                  child: Text(
                    '✦   ◆   ✦',
                    style: TextStyle(
                      color: AppColors.primaryGold.withValues(alpha: 0.3),
                      fontSize: 18,
                      letterSpacing: 8,
                    ),
                  ),
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                child: TextField(
                  controller: _searchController,
                  style: GoogleFonts.crimsonText(
                      color: AppColors.onBackground, fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'Search the chronicles...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    hintStyle: GoogleFonts.crimsonText(
                        color: const Color(0xFF8A7A60),
                        fontSize: 16,
                        fontStyle: FontStyle.italic),
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
                  child: Center(
                    child: Text(
                      'Error: ${_historyStore.errorMessage}',
                      style: GoogleFonts.crimsonText(
                          color: AppColors.error, fontSize: 16),
                    ),
                  ),
                );
              }

              if (_historyStore.filteredList.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '◆',
                          style: TextStyle(
                            color: AppColors.outline,
                            fontSize: 32,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No records found',
                          style: GoogleFonts.cinzel(
                              color: AppColors.onSurface, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
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
