import 'dart:typed_data';

import 'package:share_plus/share_plus.dart';

/// Opens the system share sheet. Behind an interface so pages can be tested.
abstract interface class ShareService {
  Future<void> shareText(String text, {String? subject});

  Future<void> shareFile(Uint8List bytes, {required String fileName, required String mimeType, String? subject});
}

class SystemShareService implements ShareService {
  const SystemShareService();

  @override
  Future<void> shareText(String text, {String? subject}) =>
      SharePlus.instance.share(ShareParams(text: text, subject: subject));

  @override
  Future<void> shareFile(Uint8List bytes, {required String fileName, required String mimeType, String? subject}) =>
      SharePlus.instance.share(
        ShareParams(
          files: [XFile.fromData(bytes, mimeType: mimeType, name: fileName)],
          fileNameOverrides: [fileName],
          subject: subject,
        ),
      );
}
