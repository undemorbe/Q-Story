import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/di/service_locator.dart';
import '../stores/qr_store.dart';
import '../../../../core/l10n/app_localizations.dart';

class QrGeneratorView extends StatefulWidget {
  const QrGeneratorView({super.key});

  @override
  State<QrGeneratorView> createState() => _QrGeneratorViewState();
}

class _QrGeneratorViewState extends State<QrGeneratorView> {
  final QrStore _store = getIt<QrStore>();
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: 'Enter Data',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: const Icon(Icons.check),
                onPressed: () {
                  if (_controller.text.isNotEmpty) {
                    _store.setGeneratedData(_controller.text);
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Center(
              child: Observer(
                builder: (_) {
                  if (_store.generatedData == null) {
                    return Text(l10n.generateQr);
                  }
                  return QrImageView(
                    data: _store.generatedData!,
                    version: QrVersions.auto,
                    size: 200.0,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
