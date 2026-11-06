import 'package:url_launcher/url_launcher.dart';

/// Opens the user's own email client with a pre-filled message.
///
/// The app ships no SMTP credentials: anything embedded in an APK/IPA can be
/// extracted, so mail is always sent from the user's account via `mailto:`.
abstract interface class MailLauncher {
  /// Returns false if no email app could handle the request.
  Future<bool> compose({required String to, required String subject, required String body});
}

class UrlMailLauncher implements MailLauncher {
  @override
  Future<bool> compose({required String to, required String subject, required String body}) async {
    final uri = buildMailto(to: to, subject: subject, body: body);
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }
}

/// RFC 6068 `mailto:` URI. Uses `%20` for spaces (not `+`), which some
/// mail clients would otherwise show literally.
Uri buildMailto({required String to, required String subject, required String body}) {
  String enc(String s) => Uri.encodeComponent(s);
  return Uri.parse('mailto:$to?subject=${enc(subject)}&body=${enc(body)}');
}

class MailUnavailableException implements Exception {
  const MailUnavailableException(this.address);
  final String address;

  @override
  String toString() => 'No email app found. Please write to $address';
}
