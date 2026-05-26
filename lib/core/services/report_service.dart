import 'dart:async';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

enum ReportCategory {
  vandalism,
  misinformation,
  offensive,
  spam,
  copyright,
  adult,
  hate,
  fraud,
  malware,
  privacy,
  invalid,
  other,
}

class ReportService {
  late final String _smtpUser;
  late final String _smtpPassword;
  late final String _supportEmail;

  ReportService() {
    _smtpUser = dotenv.get('SMTP_USER', fallback: '');
    _smtpPassword = dotenv.get('SMTP_PASSWORD', fallback: '');
    _supportEmail = dotenv.get('SUPPORT_EMAIL', fallback: '');
  }

  /// Get localized category label for display
  String getCategoryLabel(ReportCategory category, String languageCode) {
    final isRussian = languageCode == 'ru';
    return switch (category) {
      ReportCategory.vandalism => isRussian ? 'Вандализм' : 'Vandalism',
      ReportCategory.misinformation => isRussian ? 'Дезинформация' : 'Misinformation',
      ReportCategory.offensive => isRussian ? 'Оскорбительный контент' : 'Offensive content',
      ReportCategory.spam => isRussian ? 'Спам' : 'Spam',
      ReportCategory.copyright => isRussian ? 'Нарушение авторских прав' : 'Copyright violation',
      ReportCategory.adult => isRussian ? 'Взрослый контент' : 'Adult content',
      ReportCategory.hate => isRussian ? 'Разжигание ненависти' : 'Hate speech',
      ReportCategory.fraud => isRussian ? 'Мошенничество' : 'Fraud',
      ReportCategory.malware => isRussian ? 'Вредоносное ПО/угроза' : 'Malware/Security threat',
      ReportCategory.privacy => isRussian ? 'Нарушение приватности' : 'Privacy violation',
      ReportCategory.invalid => isRussian ? 'Неверная информация' : 'Invalid information',
      ReportCategory.other => isRussian ? 'Другое' : 'Other',
    };
  }

  /// Validates and sends a report via email
  ///
  /// Throws [ArgumentError] if:
  /// - Marker ID is empty or contains only whitespace
  /// - Marker title is empty or contains only whitespace
  /// - Report text is empty or contains only whitespace
  /// - Report text exceeds 500 characters
  ///
  /// Throws general exception with descriptive message if SMTP sending fails
  Future<void> sendReport({
    required String markerId,
    required String markerTitle,
    required ReportCategory category,
    required String text,
  }) async {
    // Trim whitespace
    final trimmedText = text.trim();
    final trimmedId = markerId.trim();
    final trimmedTitle = markerTitle.trim();

    // Validate: empty fields
    if (trimmedId.isEmpty) {
      throw ArgumentError('Marker ID cannot be empty');
    }
    if (trimmedTitle.isEmpty) {
      throw ArgumentError('Marker title cannot be empty');
    }
    if (trimmedText.isEmpty) {
      throw ArgumentError('Report text cannot be empty');
    }

    // Validate: max 500 characters
    if (trimmedText.length > 500) {
      throw ArgumentError('Report text cannot exceed 500 characters');
    }

    // Build email body with timestamp
    final timestamp = DateTime.now().toIso8601String();
    final categoryLabel = getCategoryLabel(category, 'en'); // Use EN for email
    final emailBody = '''
Report Submission
=================
Marker/Card ID: $trimmedId
Title: $trimmedTitle
Category: $categoryLabel
Received: $timestamp

Report:
$trimmedText
''';

    try {
      // Create SMTP server connection
      final smtpServer = gmailSaslXoauth2(_smtpUser, _smtpPassword);

      // Build email
      final email = Message()
        ..from = Address(_smtpUser)
        ..recipients.add(_supportEmail)
        ..subject = 'User Report'
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
