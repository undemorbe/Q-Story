import '../constants/app_info.dart';
import 'mail_launcher.dart';

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

/// Lets users report a wrong or harmful place through their email client.
class ReportService {
  ReportService(this._mail, {this.supportEmail = AppInfo.supportEmail});

  final MailLauncher _mail;
  final String supportEmail;

  static const int maxLength = 500;

  String getCategoryLabel(ReportCategory category, String languageCode) {
    final ru = languageCode == 'ru';
    return switch (category) {
      ReportCategory.vandalism => ru ? 'Вандализм' : 'Vandalism',
      ReportCategory.misinformation => ru ? 'Дезинформация' : 'Misinformation',
      ReportCategory.offensive => ru ? 'Оскорбительный контент' : 'Offensive content',
      ReportCategory.spam => ru ? 'Спам' : 'Spam',
      ReportCategory.copyright => ru ? 'Нарушение авторских прав' : 'Copyright violation',
      ReportCategory.adult => ru ? 'Взрослый контент' : 'Adult content',
      ReportCategory.hate => ru ? 'Разжигание ненависти' : 'Hate speech',
      ReportCategory.fraud => ru ? 'Мошенничество' : 'Fraud',
      ReportCategory.malware => ru ? 'Вредоносное ПО/угроза' : 'Malware/Security threat',
      ReportCategory.privacy => ru ? 'Нарушение приватности' : 'Privacy violation',
      ReportCategory.invalid => ru ? 'Неверная информация' : 'Invalid information',
      ReportCategory.other => ru ? 'Другое' : 'Other',
    };
  }

  /// Builds the report body. The category is always in English so the
  /// maintainers get consistent reports regardless of UI language.
  String buildBody({
    required String markerId,
    required String markerTitle,
    required ReportCategory category,
    required String text,
    DateTime? now,
  }) =>
      '''
Report
======
Place ID: $markerId
Title: $markerTitle
Category: ${getCategoryLabel(category, 'en')}
Created: ${(now ?? DateTime.now()).toIso8601String()}

$text

—
${AppInfo.name} ${AppInfo.version}
''';

  /// Throws [ArgumentError] on invalid input and [MailUnavailableException]
  /// if no email app is available.
  Future<void> sendReport({
    required String markerId,
    required String markerTitle,
    required ReportCategory category,
    required String text,
  }) async {
    final t = text.trim(), id = markerId.trim(), title = markerTitle.trim();
    if (id.isEmpty) throw ArgumentError('Marker ID cannot be empty');
    if (title.isEmpty) throw ArgumentError('Marker title cannot be empty');
    if (t.isEmpty) throw ArgumentError('Report text cannot be empty');
    if (t.length > maxLength) throw ArgumentError('Report text cannot exceed $maxLength characters');

    final ok = await _mail.compose(
      to: supportEmail,
      subject: '${AppInfo.name} report: $title',
      body: buildBody(markerId: id, markerTitle: title, category: category, text: t),
    );
    if (!ok) throw MailUnavailableException(supportEmail);
  }
}
