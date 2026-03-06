import 'package:flutter/material.dart';
import 'qr_generator_view.dart';
import 'qr_scanner_view.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../settings/presentation/pages/settings_sheet.dart';

class QrHomePage extends StatelessWidget {
  const QrHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.appTitle),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => const SettingsSheet(),
                );
              },
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(icon: const Icon(Icons.qr_code), text: l10n.generateQr),
              Tab(icon: const Icon(Icons.camera_alt), text: l10n.scanQr),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            QrGeneratorView(),
            QrScannerView(),
          ],
        ),
      ),
    );
  }
}
