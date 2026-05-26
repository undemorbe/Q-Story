import 'dart:async';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailService {
  late final String _smtpHost;
  late final int _smtpPort;
  late final String _smtpUser;
  late final String _smtpPassword;
  late final String _supportEmail;
  late final String _supportSubject;

  EmailService() {
    _smtpHost = dotenv.get('SMTP_HOST', fallback: 'smtp.gmail.com');
    _smtpPort = int.parse(dotenv.get('SMTP_PORT', fallback: '465'));
    _smtpUser = dotenv.get('SMTP_USER', fallback: '');
    _smtpPassword = dotenv.get('SMTP_PASSWORD', fallback: '');
    _supportEmail = dotenv.get('SUPPORT_EMAIL', fallback: '');
    _supportSubject = dotenv.get('SUPPORT_SUBJECT', fallback: 'Support Message');
  }

  /// Validates and sends a support message via email
  ///
  /// Throws [ArgumentError] if:
  /// - Message is empty or contains only whitespace
  /// - Message exceeds 500 characters
  ///
  /// Throws general exception with descriptive message if SMTP sending fails
  Future<void> sendSupportMessage(String message) async {
    // Trim whitespace
    final trimmedMessage = message.trim();

    // Validate: empty or whitespace-only
    if (trimmedMessage.isEmpty) {
      throw ArgumentError('Message cannot be empty');
    }

    // Validate: max 500 characters
    if (trimmedMessage.length > 500) {
      throw ArgumentError('Message cannot exceed 500 characters');
    }

    // Build email body with timestamp
    final timestamp = DateTime.now().toIso8601String();
    final emailBody = '''
User Support Message
====================
Received: $timestamp

Message:
$trimmedMessage
''';

    try {
      // Create SMTP server connection
      final smtpServer = gmailSaslXoauth2(_smtpUser, _smtpPassword);

      // Build email
      final email = Message()
        ..from = Address(_smtpUser)
        ..recipients.add(_supportEmail)
        ..subject = _supportSubject
        ..text = emailBody;

      // Send email
      await send(email, smtpServer);
    } on MailerException catch (e) {
      // Handle mailer-specific exceptions
      if (e.toString().contains('connection')) {
        throw Exception('Network error. Check internet connection.');
      } else if (e.toString().contains('auth') || e.toString().contains('authentication')) {
        throw Exception('Email service misconfigured');
      } else {
        throw Exception('Failed to send message');
      }
    } on SocketException catch (_) {
      // Handle socket/network errors
      throw Exception('Network error. Check internet connection.');
    } on TimeoutException catch (_) {
      // Handle timeout errors
      throw Exception('Request timeout');
    } catch (e) {
      // Generic error handler
      throw Exception('Failed to send message');
    }
  }
}
