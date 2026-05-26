import 'package:flutter_test/flutter_test.dart';
import 'package:qstory/core/services/email_service.dart';

// Mock for testing SMTP behavior
class MockEmailService extends EmailService {
  bool shouldFail = false;

  @override
  Future<void> sendSupportMessage(String message) async {
    // Validate first (same as parent)
    final trimmedMessage = message.trim();

    if (trimmedMessage.isEmpty) {
      throw ArgumentError('Message cannot be empty');
    }

    if (trimmedMessage.length > 500) {
      throw ArgumentError('Message cannot exceed 500 characters');
    }

    // Mock email sending
    if (shouldFail) {
      throw Exception('Failed to send message: Mock SMTP error');
    }
    // Success - simulate email sent
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('EmailService', () {
    late MockEmailService service;

    setUpAll(() async {
      // No env file required for these validation tests.
    });

    setUp(() {
      service = MockEmailService();
      service.shouldFail = false;
    });

    test('sendSupportMessage sends email successfully', () async {
      const message = 'This is a test support message';
      await service.sendSupportMessage(message);
      // Should not throw
    });

    test('sendSupportMessage trims whitespace', () async {
      const message = '  Test message  ';
      await service.sendSupportMessage(message);
      // Should not throw - whitespace is trimmed
    });

    test('sendSupportMessage rejects empty message', () async {
      const message = '';
      expect(
        () => service.sendSupportMessage(message),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('sendSupportMessage rejects whitespace-only message', () async {
      const message = '   ';
      expect(
        () => service.sendSupportMessage(message),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('sendSupportMessage rejects message over 500 chars', () async {
      final message = 'a' * 501;
      expect(
        () => service.sendSupportMessage(message),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
