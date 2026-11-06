import '../constants/app_info.dart';
import 'mail_launcher.dart';

/// Sends support messages through the user's email client.
class EmailService {
  EmailService(this._mail, {this.supportEmail = AppInfo.supportEmail});

  final MailLauncher _mail;
  final String supportEmail;

  static const int maxLength = 500;

  /// Throws [ArgumentError] for an empty or too long message and
  /// [MailUnavailableException] when no email app is installed.
  Future<void> sendSupportMessage(String message) async {
    final trimmed = message.trim();
    if (trimmed.isEmpty) throw ArgumentError('Message cannot be empty');
    if (trimmed.length > maxLength) throw ArgumentError('Message cannot exceed $maxLength characters');

    final ok = await _mail.compose(
      to: supportEmail,
      subject: '${AppInfo.name} support',
      body: '$trimmed\n\n—\n${AppInfo.name} ${AppInfo.version}',
    );
    if (!ok) throw MailUnavailableException(supportEmail);
  }
}
