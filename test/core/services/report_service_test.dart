import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:qstory/core/services/report_service.dart';

// Mock for DotEnv to avoid NotInitializedError in tests
class MockDotEnv extends Mock implements DotEnv {}

void main() {
  late ReportService reportService;

  setUpAll(() async {
    // Initialize dotenv with test values
    dotenv.testLoad(fileInput: '''
SMTP_USER=test@example.com
SMTP_PASSWORD=test_password
SUPPORT_EMAIL=support@example.com
    ''');
  });

  setUp(() {
    reportService = ReportService();
  });

  group('ReportService', () {
    group('sendReport validation', () {
      test('rejects empty markerId', () async {
        expect(
          () => reportService.sendReport(
            markerId: '',
            markerTitle: 'Test',
            category: ReportCategory.vandalism,
            text: 'Test report',
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('rejects empty markerTitle', () async {
        expect(
          () => reportService.sendReport(
            markerId: '123',
            markerTitle: '',
            category: ReportCategory.vandalism,
            text: 'Test report',
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('rejects empty report text', () async {
        expect(
          () => reportService.sendReport(
            markerId: '123',
            markerTitle: 'Test',
            category: ReportCategory.vandalism,
            text: '',
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('rejects whitespace-only report text', () async {
        expect(
          () => reportService.sendReport(
            markerId: '123',
            markerTitle: 'Test',
            category: ReportCategory.vandalism,
            text: '   ',
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('rejects report text over 500 chars', () async {
        final longText = 'a' * 501;
        expect(
          () => reportService.sendReport(
            markerId: '123',
            markerTitle: 'Test',
            category: ReportCategory.vandalism,
            text: longText,
          ),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('getCategoryLabel', () {
      test('returns English labels for EN locale', () {
        expect(
          reportService.getCategoryLabel(ReportCategory.vandalism, 'en'),
          'Vandalism',
        );
        expect(
          reportService.getCategoryLabel(ReportCategory.misinformation, 'en'),
          'Misinformation',
        );
        expect(
          reportService.getCategoryLabel(ReportCategory.offensive, 'en'),
          'Offensive content',
        );
        expect(
          reportService.getCategoryLabel(ReportCategory.spam, 'en'),
          'Spam',
        );
        expect(
          reportService.getCategoryLabel(ReportCategory.copyright, 'en'),
          'Copyright violation',
        );
        expect(
          reportService.getCategoryLabel(ReportCategory.adult, 'en'),
          'Adult content',
        );
        expect(
          reportService.getCategoryLabel(ReportCategory.hate, 'en'),
          'Hate speech',
        );
        expect(
          reportService.getCategoryLabel(ReportCategory.fraud, 'en'),
          'Fraud',
        );
        expect(
          reportService.getCategoryLabel(ReportCategory.malware, 'en'),
          'Malware/Security threat',
        );
        expect(
          reportService.getCategoryLabel(ReportCategory.privacy, 'en'),
          'Privacy violation',
        );
        expect(
          reportService.getCategoryLabel(ReportCategory.invalid, 'en'),
          'Invalid information',
        );
        expect(
          reportService.getCategoryLabel(ReportCategory.other, 'en'),
          'Other',
        );
      });

      test('returns Russian labels for RU locale', () {
        expect(
          reportService.getCategoryLabel(ReportCategory.vandalism, 'ru'),
          'Вандализм',
        );
        expect(
          reportService.getCategoryLabel(ReportCategory.misinformation, 'ru'),
          'Дезинформация',
        );
        expect(
          reportService.getCategoryLabel(ReportCategory.offensive, 'ru'),
          'Оскорбительный контент',
        );
        expect(
          reportService.getCategoryLabel(ReportCategory.spam, 'ru'),
          'Спам',
        );
        expect(
          reportService.getCategoryLabel(ReportCategory.copyright, 'ru'),
          'Нарушение авторских прав',
        );
        expect(
          reportService.getCategoryLabel(ReportCategory.adult, 'ru'),
          'Взрослый контент',
        );
        expect(
          reportService.getCategoryLabel(ReportCategory.hate, 'ru'),
          'Разжигание ненависти',
        );
        expect(
          reportService.getCategoryLabel(ReportCategory.fraud, 'ru'),
          'Мошенничество',
        );
        expect(
          reportService.getCategoryLabel(ReportCategory.malware, 'ru'),
          'Вредоносное ПО/угроза',
        );
        expect(
          reportService.getCategoryLabel(ReportCategory.privacy, 'ru'),
          'Нарушение приватности',
        );
        expect(
          reportService.getCategoryLabel(ReportCategory.invalid, 'ru'),
          'Неверная информация',
        );
        expect(
          reportService.getCategoryLabel(ReportCategory.other, 'ru'),
          'Другое',
        );
      });
    });
  });
}
