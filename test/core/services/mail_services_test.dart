import 'package:flutter_test/flutter_test.dart';
import 'package:qstory/core/services/email_service.dart';
import 'package:qstory/core/services/mail_launcher.dart';
import 'package:qstory/core/services/report_service.dart';

class FakeMail implements MailLauncher {
  FakeMail({this.result = true});
  final bool result;
  final calls = <Map<String, String>>[];

  @override
  Future<bool> compose({required String to, required String subject, required String body}) async {
    calls.add({'to': to, 'subject': subject, 'body': body});
    return result;
  }
}

void main() {
  group('buildMailto', () {
    test('encodes spaces as %20 and keeps unicode', () {
      final uri = buildMailto(to: 'a@b.c', subject: 'Привет мир', body: 'line 1\nline 2');
      final s = uri.toString();
      expect(s, startsWith('mailto:a@b.c?'));
      expect(s, isNot(contains('+')));
      expect(uri.queryParameters['subject'], 'Привет мир');
      expect(uri.queryParameters['body'], 'line 1\nline 2');
    });
  });

  group('EmailService', () {
    test('composes a trimmed message to the support address', () async {
      final mail = FakeMail();
      await EmailService(mail, supportEmail: 'x@y.z').sendSupportMessage('  hello  ');
      expect(mail.calls.single['to'], 'x@y.z');
      expect(mail.calls.single['body'], startsWith('hello'));
    });

    test('rejects empty and too long messages', () {
      final s = EmailService(FakeMail());
      expect(() => s.sendSupportMessage('   '), throwsArgumentError);
      expect(() => s.sendSupportMessage('a' * 501), throwsArgumentError);
    });

    test('throws MailUnavailableException when no email app', () {
      expect(
        () => EmailService(FakeMail(result: false)).sendSupportMessage('hi'),
        throwsA(isA<MailUnavailableException>()),
      );
    });
  });

  group('ReportService', () {
    test('labels are localized', () {
      final s = ReportService(FakeMail());
      expect(s.getCategoryLabel(ReportCategory.spam, 'ru'), 'Спам');
      expect(s.getCategoryLabel(ReportCategory.spam, 'en'), 'Spam');
      for (final c in ReportCategory.values) {
        expect(s.getCategoryLabel(c, 'ru'), isNotEmpty);
      }
    });

    test('body always uses English category and includes the place', () {
      final body = ReportService(FakeMail()).buildBody(
        markerId: 'osm:node/1',
        markerTitle: 'Памятник',
        category: ReportCategory.invalid,
        text: 'Wrong year',
        now: DateTime(2026, 1, 2),
      );
      expect(body, contains('osm:node/1'));
      expect(body, contains('Category: Invalid information'));
      expect(body, contains('Wrong year'));
    });

    test('validates input', () {
      final s = ReportService(FakeMail());
      Future<void> send({String id = 'a', String title = 'b', String text = 'c'}) =>
          s.sendReport(markerId: id, markerTitle: title, category: ReportCategory.other, text: text);
      expect(() => send(id: ' '), throwsArgumentError);
      expect(() => send(title: ''), throwsArgumentError);
      expect(() => send(text: ''), throwsArgumentError);
      expect(() => send(text: 'x' * 501), throwsArgumentError);
    });

    test('sends via mail launcher', () async {
      final mail = FakeMail();
      await ReportService(mail).sendReport(
        markerId: 'pastvu:1',
        markerTitle: 'Photo',
        category: ReportCategory.copyright,
        text: 'Not public domain',
      );
      expect(mail.calls.single['subject'], contains('Photo'));
    });
  });
}
