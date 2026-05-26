import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/gothic_widgets.dart';
import '../../../../core/theme/theme_ext.dart';
import '../../domain/entities/daily_fact_entity.dart';
import '../stores/daily_fact_store.dart';

class DailyHistoryPage extends StatefulWidget {
  const DailyHistoryPage({super.key});

  @override
  State<DailyHistoryPage> createState() => _DailyHistoryPageState();
}

class _DailyHistoryPageState extends State<DailyHistoryPage> {
  final DailyFactStore _store = getIt<DailyFactStore>();

  @override
  void initState() {
    super.initState();
    _store.loadDailyFact();
  }

  Future<void> _openWikipedia(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Scaffold(
      appBar: AppBar(title: const Text('История дня')),
      body: Observer(
        builder: (_) {
          return RefreshIndicator(
            color: context.gold,
            onRefresh: () => _store.loadDailyFact(force: true),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                _DateHeader(date: now),
                const SizedBox(height: 16),
                const GothicDivider(),
                const SizedBox(height: 16),
                _buildBody(context),
                const SizedBox(height: 24),
                _buildActions(context),
                const SizedBox(height: 24),
                _SourceFooter(factsCount: _store.facts.length),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_store.isLoading && _store.currentFact == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 64),
        child: Center(
          child: CircularProgressIndicator(color: context.gold),
        ),
      );
    }

    if (_store.errorMessage != null && _store.currentFact == null) {
      return _ErrorCard(message: _store.errorMessage!);
    }

    final fact = _store.currentFact;
    if (fact == null) {
      return const _EmptyCard();
    }

    return _FactCard(fact: fact, onOpenLink: _openWikipedia);
  }

  Widget _buildActions(BuildContext context) {
    final canRefresh = !_store.isLoading;
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: canRefresh ? () => _store.nextFact() : null,
            icon: const Icon(Icons.auto_awesome, size: 18),
            label: const Text('Другой факт'),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed:
                canRefresh ? () => _store.loadDailyFact(force: true) : null,
            icon: _store.isLoading
                ? SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: context.gold),
                  )
                : const Icon(Icons.refresh, size: 18),
            label: Text(_store.isLoading ? 'Загрузка…' : 'Обновить'),
          ),
        ),
      ],
    );
  }
}

// ─── Date header ─────────────────────────────────────────────────────────────

class _DateHeader extends StatelessWidget {
  final DateTime date;
  const _DateHeader({required this.date});

  static const _months = [
    'Января', 'Февраля', 'Марта', 'Апреля', 'Мая', 'Июня',
    'Июля', 'Августа', 'Сентября', 'Октября', 'Ноября', 'Декабря'
  ];

  @override
  Widget build(BuildContext context) {
    final gold = context.gold;
    return Column(
      children: [
        Text(
          '— ✦ ◆ ✦ —',
          style: TextStyle(
            color: gold.withValues(alpha: 0.55),
            fontSize: 16,
            letterSpacing: 4,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          '${date.day} ${_months[date.month - 1]}',
          style: GoogleFonts.cinzelDecorative(
            color: gold,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          'события дня в истории России',
          style: GoogleFonts.crimsonText(
            color: context.onBg,
            fontSize: 14,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}

// ─── Fact card ───────────────────────────────────────────────────────────────

class _FactCard extends StatelessWidget {
  final DailyFactEntity fact;
  final Future<void> Function(String) onOpenLink;

  const _FactCard({required this.fact, required this.onOpenLink});

  @override
  Widget build(BuildContext context) {
    final gold = context.gold;
    return GothicCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (fact.imageUrl != null)
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(2)),
              child: AspectRatio(
                aspectRatio: 16 / 10,
                child: CachedNetworkImage(
                  imageUrl: fact.imageUrl!,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    color: context.surfaceVar,
                    child: Center(
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: gold),
                    ),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    color: context.surfaceVar,
                    child: Icon(Icons.image_not_supported_outlined,
                        color: context.outlineClr, size: 32),
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: context.goldContainer,
                        border: Border.all(color: gold, width: 1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Text(
                        fact.year.toString(),
                        style: GoogleFonts.cinzel(
                          color: gold,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        fact.era.toUpperCase(),
                        style: GoogleFonts.cinzel(
                          color: gold.withValues(alpha: 0.8),
                          fontSize: 10,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  fact.text,
                  style: GoogleFonts.crimsonText(
                    color: context.onBg,
                    fontSize: 17,
                    height: 1.55,
                  ),
                ),
                if (fact.pageExtract != null &&
                    fact.pageExtract!.trim().isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Container(height: 1, color: context.outlineVar),
                  const SizedBox(height: 14),
                  Text(
                    fact.pageExtract!,
                    style: GoogleFonts.crimsonText(
                      color: context.onBg.withValues(alpha: 0.85),
                      fontSize: 14,
                      height: 1.5,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                if (fact.wikipediaUrl != null) ...[
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () => onOpenLink(fact.wikipediaUrl!),
                      icon: const Icon(Icons.open_in_new, size: 14),
                      label: const Text('Открыть в Wikipedia'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── States ──────────────────────────────────────────────────────────────────

class _EmptyCard extends StatelessWidget {
  const _EmptyCard();

  @override
  Widget build(BuildContext context) {
    return GothicCard(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      child: Column(
        children: [
          Text('◆',
              style: TextStyle(color: context.outlineClr, fontSize: 28)),
          const SizedBox(height: 12),
          Text(
            'На этот день нет фактов из истории России или СССР.',
            style: GoogleFonts.crimsonText(
              color: context.onBg,
              fontSize: 16,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return GothicCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(Icons.cloud_off, color: context.errorClr, size: 36),
          const SizedBox(height: 12),
          Text(
            message,
            style: GoogleFonts.crimsonText(
              color: context.onBg,
              fontSize: 15,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SourceFooter extends StatelessWidget {
  final int factsCount;
  const _SourceFooter({required this.factsCount});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        factsCount > 0
            ? 'Источник: Wikipedia · доступно фактов: $factsCount'
            : 'Источник: Wikipedia',
        style: GoogleFonts.cinzel(
          color: context.onBg.withValues(alpha: 0.5),
          fontSize: 10,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}
