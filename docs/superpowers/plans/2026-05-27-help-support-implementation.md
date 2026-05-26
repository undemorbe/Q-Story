# Help & Support Email Feature Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement email sending for user support messages from ProfilePage via bottom sheet, using SMTP via mailer package.

**Architecture:** EmailService singleton handles SMTP configuration and sending. HelpSupportSheet bottom sheet provides UI for message composition with loading/error/success states. Integration via ProfilePage Help & Support ListTile.

**Tech Stack:** mailer ^6.1.1, flutter_dotenv ^5.1.0, MobX for state (existing)

---

## File Structure

**New Files:**
- `lib/core/services/email_service.dart` - SMTP email sending service
- `lib/features/profile/presentation/pages/help_support_sheet.dart` - Bottom sheet UI
- `test/core/services/email_service_test.dart` - EmailService tests
- `test/features/profile/presentation/pages/help_support_sheet_test.dart` - Widget tests
- `.env.example` - Template for SMTP config

**Modified Files:**
- `pubspec.yaml` - Add mailer, flutter_dotenv
- `.gitignore` - Add .env
- `lib/main.dart` - Load .env before app
- `lib/core/di/service_locator.dart` - Register EmailService singleton
- `lib/features/profile/presentation/pages/profile_page.dart` - Wire Help & Support onTap
- `lib/core/l10n/app_localizations_en.arb` - Add localization keys (and other locales)

---

## Task 1: Add Dependencies to pubspec.yaml

**Files:**
- Modify: `pubspec.yaml`

- [ ] **Step 1: Add mailer and flutter_dotenv packages**

Open `pubspec.yaml` and add under `dependencies:` section:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  
  # ... existing packages ...
  
  # Email
  mailer: ^6.1.1
  flutter_dotenv: ^5.1.0
```

- [ ] **Step 2: Run pub get**

```bash
flutter pub get
```

Expected: Both packages downloaded without errors.

- [ ] **Step 3: Verify in pubspec.lock**

```bash
grep -A 2 "mailer\|flutter_dotenv" pubspec.lock | head -20
```

Expected: Both packages listed with correct versions.

- [ ] **Step 4: Commit**

```bash
git add pubspec.yaml pubspec.lock
git commit -m "deps: add mailer and flutter_dotenv for email support"
```

---

## Task 2: Create .env Configuration Files

**Files:**
- Create: `.env.example`
- Create: `.env` (user-created, not committed)
- Modify: `.gitignore`

- [ ] **Step 1: Create .env.example template**

Create file `/.env.example`:

```
# SMTP Configuration for Email Service
SMTP_HOST=smtp.gmail.com
SMTP_PORT=465
SMTP_USER=your-email@gmail.com
SMTP_PASSWORD=your-app-password

# Support Contact Details
SUPPORT_EMAIL=stankovb08@gmail.com
SUPPORT_SUBJECT=QStory App Support
```

- [ ] **Step 2: Add .env to .gitignore**

Open `.gitignore` and add:

```
# Environment variables
.env
.env.local
.env.*.local
```

- [ ] **Step 3: Create .env file locally**

Create file `/.env` with actual SMTP credentials (Gmail App Password recommended):

```
SMTP_HOST=smtp.gmail.com
SMTP_PORT=465
SMTP_USER=stankovb08@gmail.com
SMTP_PASSWORD=<your-gmail-app-password>
SUPPORT_EMAIL=stankovb08@gmail.com
SUPPORT_SUBJECT=QStory App Support
```

**Note:** This file is local-only, never commit it.

- [ ] **Step 4: Commit .env.example and .gitignore**

```bash
git add .env.example .gitignore
git commit -m "chore: add .env template and gitignore"
```

---

## Task 3: Create EmailService with Unit Tests

**Files:**
- Create: `lib/core/services/email_service.dart`
- Create: `test/core/services/email_service_test.dart`

- [ ] **Step 1: Write failing test for successful email send**

Create file `test/core/services/email_service_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:qstory/core/services/email_service.dart';

void main() {
  group('EmailService', () {
    late EmailService service;

    setUpAll(() async {
      // Load .env for tests
      await dotenv.load(fileName: '.env');
    });

    setUp(() {
      service = EmailService();
    });

    test('sendSupportMessage sends email successfully', () async {
      const message = 'This is a test support message';
      
      // Should not throw
      await service.sendSupportMessage(message);
    });

    test('sendSupportMessage trims whitespace', () async {
      const message = '  Test message  ';
      
      // Should not throw
      await service.sendSupportMessage(message);
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
```

- [ ] **Step 2: Run test to verify it fails**

```bash
flutter test test/core/services/email_service_test.dart -v
```

Expected: FAIL - class 'EmailService' not found

- [ ] **Step 3: Create EmailService implementation**

Create file `lib/core/services/email_service.dart`:

```dart
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
    _smtpPort = int.parse(
      dotenv.get('SMTP_PORT', fallback: '465'),
    );
    _smtpUser = dotenv.get('SMTP_USER', fallback: '');
    _smtpPassword = dotenv.get('SMTP_PASSWORD', fallback: '');
    _supportEmail = dotenv.get('SUPPORT_EMAIL', fallback: 'support@qstory.com');
    _supportSubject = dotenv.get('SUPPORT_SUBJECT', fallback: 'QStory Support');
  }

  /// Send support message via email
  ///
  /// Validates message: non-empty, max 500 chars
  /// Throws [ArgumentError] if validation fails
  /// Throws [Exception] on SMTP/network errors
  Future<void> sendSupportMessage(String message) async {
    // Validate input
    final trimmed = message.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('Message cannot be empty');
    }
    if (trimmed.length > 500) {
      throw ArgumentError('Message cannot exceed 500 characters');
    }

    // Create SMTP server
    final smtpServer = gmailSaslXoauth2(_smtpUser, _smtpPassword);

    // Build email
    final emailMessage = Message()
      ..from = Address(_smtpUser)
      ..recipients.add(_supportEmail)
      ..subject = _supportSubject
      ..text = '''
Support Message from QStory App
Sent: ${DateTime.now().toIso8601String()}

Message:
$trimmed
''';

    try {
      // Send email
      await send(emailMessage, smtpServer);
    } on MailerException catch (e) {
      if (e.toString().contains('Authentication')) {
        throw Exception('Email service misconfigured');
      }
      if (e.toString().contains('connection')) {
        throw Exception('Network error. Check internet connection.');
      }
      throw Exception('Failed to send message');
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }
}

// Gmail using SASL XOAUTH2
SmtpServer gmailSaslXoauth2(String email, String accessToken) {
  return SmtpServer(
    'smtp.gmail.com',
    port: 465,
    username: email,
    password: accessToken,
    ssl: true,
    allowInsecure: false,
  );
}
```

- [ ] **Step 4: Run tests**

```bash
flutter test test/core/services/email_service_test.dart -v
```

Expected: 5 tests PASS (trim, empty, whitespace, 500+ chars, success)

**Note:** Success test will attempt real SMTP send. If .env not configured, it will fail - that's expected for now.

- [ ] **Step 5: Commit EmailService and tests**

```bash
git add lib/core/services/email_service.dart test/core/services/email_service_test.dart
git commit -m "feat: add EmailService for SMTP email sending with validation"
```

---

## Task 4: Register EmailService in ServiceLocator

**Files:**
- Modify: `lib/core/di/service_locator.dart`

- [ ] **Step 1: Check current ServiceLocator content**

```bash
head -30 lib/core/di/service_locator.dart
```

- [ ] **Step 2: Add EmailService registration**

Open `lib/core/di/service_locator.dart` and find the `void setupServiceLocator()` function. Add EmailService registration:

```dart
void setupServiceLocator() {
  // ... existing registrations ...

  // Services
  getIt.registerSingleton<EmailService>(EmailService());
}
```

Make sure `EmailService` is imported at top:

```dart
import '../../core/services/email_service.dart';
```

- [ ] **Step 3: Verify file**

```bash
grep -n "EmailService" lib/core/di/service_locator.dart
```

Expected: Two lines - import and registerSingleton

- [ ] **Step 4: Commit**

```bash
git add lib/core/di/service_locator.dart
git commit -m "chore: register EmailService in service locator"
```

---

## Task 5: Initialize .env in main()

**Files:**
- Modify: `lib/main.dart`

- [ ] **Step 1: Check current main() signature**

```bash
head -20 lib/main.dart
```

- [ ] **Step 2: Add .env loading before app initialization**

In `main()` function, add at very start:

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: '.env');

  setupServiceLocator();
  // ... rest of main ...
}
```

- [ ] **Step 3: Verify main.dart imports**

```bash
grep "import.*dotenv" lib/main.dart
```

Expected: flutter_dotenv import present

- [ ] **Step 4: Test build**

```bash
flutter pub get && flutter analyze lib/main.dart
```

Expected: No errors

- [ ] **Step 5: Commit**

```bash
git add lib/main.dart
git commit -m "chore: load .env configuration in main()"
```

---

## Task 6: Create HelpSupportSheet Widget

**Files:**
- Create: `lib/features/profile/presentation/pages/help_support_sheet.dart`

- [ ] **Step 1: Create HelpSupportSheet with state management**

Create file `lib/features/profile/presentation/pages/help_support_sheet.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:qstory/core/di/service_locator.dart';
import 'package:qstory/core/services/email_service.dart';
import 'package:qstory/core/l10n/app_localizations.dart';

class HelpSupportSheet extends StatefulWidget {
  const HelpSupportSheet({super.key});

  @override
  State<HelpSupportSheet> createState() => _HelpSupportSheetState();
}

class _HelpSupportSheetState extends State<HelpSupportSheet> {
  final TextEditingController _messageController = TextEditingController();
  final EmailService _emailService = getIt<EmailService>();
  
  bool _isLoading = false;
  String? _errorMessage;
  bool _isSuccess = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _emailService.sendSupportMessage(message);
      
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
        _isSuccess = true;
      });

      // Show success snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.messageSent),
          duration: const Duration(seconds: 2),
        ),
      );

      // Auto-close sheet after 2 seconds
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
        _errorMessage = _getErrorMessage(e.toString());
      });
    }
  }

  String _getErrorMessage(String error) {
    if (error.contains('Network error')) {
      return 'Network error. Check internet connection.';
    }
    if (error.contains('misconfigured')) {
      return 'Email service misconfigured';
    }
    if (error.contains('timeout')) {
      return 'Request timeout';
    }
    return 'Failed to send message';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final messageLength = _messageController.text.length;
    final isMessageValid = messageLength > 0 && messageLength <= 500;

    return Container(
      padding: EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        top: 16.0,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with close button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.helpAndSupport,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              l10n.sendSupportMessage,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),

            // Text field
            TextField(
              controller: _messageController,
              enabled: !_isLoading,
              maxLines: 6,
              maxLength: 500,
              decoration: InputDecoration(
                hintText: l10n.enterMessage,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                counterText: '$messageLength/500',
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),

            // Error message
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red.shade900),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _sendMessage,
                      child: Text(l10n.send),
                    ),
                  ],
                ),
              )
            else if (_isLoading)
              Row(
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 12),
                  Text(l10n.sending ?? 'Sending...'),
                ],
              )
            else
              ElevatedButton(
                onPressed: isMessageValid ? _sendMessage : null,
                child: SizedBox(
                  width: double.infinity,
                  child: Text(
                    l10n.send,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Verify imports are available**

```bash
grep -E "class HelpSupportSheet|import" lib/features/profile/presentation/pages/help_support_sheet.dart | head -10
```

Expected: HelpSupportSheet class defined, imports present

- [ ] **Step 3: Check for analysis errors**

```bash
flutter analyze lib/features/profile/presentation/pages/help_support_sheet.dart
```

Expected: No errors (may warn about missing l10n keys - that's next task)

- [ ] **Step 4: Commit**

```bash
git add lib/features/profile/presentation/pages/help_support_sheet.dart
git commit -m "feat: add HelpSupportSheet bottom sheet UI with email sending"
```

---

## Task 7: Update ProfilePage to Wire Help & Support

**Files:**
- Modify: `lib/features/profile/presentation/pages/profile_page.dart`

- [ ] **Step 1: Add import for HelpSupportSheet**

At top of `profile_page.dart`, add:

```dart
import 'help_support_sheet.dart';
```

- [ ] **Step 2: Replace empty Help & Support onTap**

Find the Help & Support ListTile (around line 170-176). Replace empty `onTap: () {}` with:

```dart
ListTile(
  leading: const Icon(Icons.help_outline),
  title: Text(l10n.helpAndSupport),
  trailing: Icon(Icons.chevron_right,
      color: context.outlineClr),
  onTap: () {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const HelpSupportSheet()),
    );
  },
),
```

- [ ] **Step 3: Verify the change**

```bash
grep -A 8 "Help & Support\|help_outline" lib/features/profile/presentation/pages/profile_page.dart | head -15
```

Expected: onTap navigates to HelpSupportSheet

- [ ] **Step 4: Check for analysis errors**

```bash
flutter analyze lib/features/profile/presentation/pages/profile_page.dart
```

Expected: No errors

- [ ] **Step 5: Commit**

```bash
git add lib/features/profile/presentation/pages/profile_page.dart
git commit -m "feat: wire Help & Support to HelpSupportSheet"
```

---

## Task 8: Add Localization Strings

**Files:**
- Modify: `lib/core/l10n/app_localizations_en.arb` (and other locale files)

- [ ] **Step 1: Check current ARB structure**

```bash
head -30 lib/core/l10n/app_localizations_en.arb | grep -E '^\s*"'
```

- [ ] **Step 2: Add new localization keys to English ARB**

Open `lib/core/l10n/app_localizations_en.arb` and add these keys in the JSON object:

```json
{
  "helpAndSupport": "Help & Support",
  "sendSupportMessage": "Send us a message and we'll get back to you",
  "enterMessage": "Enter your message...",
  "send": "Send",
  "sending": "Sending...",
  "messageSent": "Message sent successfully",
  "networkError": "Network error. Check internet connection.",
  "serviceError": "Email service misconfigured",
  "timeoutError": "Request timeout",
  "sendError": "Failed to send message"
}
```

**Note:** Some keys like "send" and "helpAndSupport" may already exist - don't duplicate them.

- [ ] **Step 3: Add keys to Russian ARB**

Open `lib/core/l10n/app_localizations_ru.arb` and add Russian translations:

```json
{
  "helpAndSupport": "Помощь и поддержка",
  "sendSupportMessage": "Отправьте нам сообщение, и мы вам ответим",
  "enterMessage": "Введите сообщение...",
  "send": "Отправить",
  "sending": "Отправка...",
  "messageSent": "Сообщение отправлено успешно",
  "networkError": "Ошибка сети. Проверьте подключение к интернету.",
  "serviceError": "Служба электронной почты неправильно настроена",
  "timeoutError": "Timeout запроса",
  "sendError": "Не удалось отправить сообщение"
}
```

- [ ] **Step 4: Regenerate localization files**

```bash
flutter gen-l10n
```

Expected: No errors, new strings available in AppLocalizations

- [ ] **Step 5: Verify localization files were updated**

```bash
grep "messageSent\|sendSupportMessage" lib/gen_l10n/app_localizations_en.dart | head -5
```

Expected: New methods in generated file

- [ ] **Step 6: Commit**

```bash
git add lib/core/l10n/app_localizations_*.arb lib/gen_l10n/
git commit -m "i18n: add localization strings for help & support feature"
```

---

## Task 9: Create Widget Tests for HelpSupportSheet

**Files:**
- Create: `test/features/profile/presentation/pages/help_support_sheet_test.dart`

- [ ] **Step 1: Write widget tests**

Create file `test/features/profile/presentation/pages/help_support_sheet_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:qstory/core/di/service_locator.dart';
import 'package:qstory/core/services/email_service.dart';
import 'package:qstory/features/profile/presentation/pages/help_support_sheet.dart';

class MockEmailService extends Mock implements EmailService {}

void main() {
  group('HelpSupportSheet', () {
    late MockEmailService mockEmailService;

    setUpAll(() async {
      mockEmailService = MockEmailService();
      getIt.registerSingleton<EmailService>(mockEmailService);
    });

    tearDownAll(() async {
      getIt.reset();
    });

    testWidgets('renders sheet with title and description',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (_) => const HelpSupportSheet(),
                    );
                  },
                  child: const Text('Show Sheet'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Sheet'));
      await tester.pumpAndSettle();

      expect(find.text('Help & Support'), findsWidgets);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('send button disabled when message empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const HelpSupportSheet(),
          ),
        ),
      );

      final sendButton = find.widgetWithText(ElevatedButton, 'Send');
      expect(sendButton, findsOneWidget);
      
      // Button should be disabled (no text entered)
      final buttonWidget = tester.widget<ElevatedButton>(sendButton);
      expect(buttonWidget.onPressed, isNull);
    });

    testWidgets('send button enabled when message present',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const HelpSupportSheet(),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Test message');
      await tester.pumpAndSettle();

      final sendButton = find.widgetWithText(ElevatedButton, 'Send');
      final buttonWidget = tester.widget<ElevatedButton>(sendButton);
      expect(buttonWidget.onPressed, isNotNull);
    });

    testWidgets('shows loading spinner during send',
        (WidgetTester tester) async {
      when(mockEmailService.sendSupportMessage(any)).thenAnswer(
        (_) async {
          await Future.delayed(const Duration(milliseconds: 500));
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const HelpSupportSheet(),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Test message');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Send'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error message on send failure',
        (WidgetTester tester) async {
      when(mockEmailService.sendSupportMessage(any))
          .thenThrow(Exception('Network error'));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const HelpSupportSheet(),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Test message');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Send'));
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Failed to send message'), findsOneWidget);
    });

    testWidgets('shows retry button on error', (WidgetTester tester) async {
      when(mockEmailService.sendSupportMessage(any))
          .thenThrow(Exception('Test error'));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const HelpSupportSheet(),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Test message');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Send'));
      await tester.pumpAndSettle();

      expect(find.byType(ElevatedButton), findsWidgets);
    });

    testWidgets('message text preserved on error',
        (WidgetTester tester) async {
      when(mockEmailService.sendSupportMessage(any))
          .thenThrow(Exception('Test error'));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const HelpSupportSheet(),
          ),
        ),
      );

      const testMessage = 'My test message';
      await tester.enterText(find.byType(TextField), testMessage);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Send'));
      await tester.pumpAndSettle();

      expect(find.text(testMessage), findsOneWidget);
    });

    testWidgets('char counter shows message length',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const HelpSupportSheet(),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Test');
      await tester.pumpAndSettle();

      expect(find.text('4/500'), findsOneWidget);
    });
  });
}
```

- [ ] **Step 2: Run widget tests**

```bash
flutter test test/features/profile/presentation/pages/help_support_sheet_test.dart -v
```

Expected: All tests PASS

**Note:** Tests verify UI behavior, not actual email sending (mocked).

- [ ] **Step 3: Commit**

```bash
git add test/features/profile/presentation/pages/help_support_sheet_test.dart
git commit -m "test: add widget tests for HelpSupportSheet"
```

---

## Task 10: Manual Testing & Verification

**Files:**
- None (verification only)

- [ ] **Step 1: Run all tests**

```bash
flutter test
```

Expected: All tests PASS (existing + new)

- [ ] **Step 2: Check analysis**

```bash
flutter analyze
```

Expected: No errors or warnings related to email feature

- [ ] **Step 3: Build app**

```bash
flutter build apk --debug --target-platform android-arm64 2>&1 | tail -20
```

Or for iOS (if available):

```bash
flutter build ios --debug 2>&1 | tail -20
```

Expected: Build succeeds

- [ ] **Step 4: Run app and test manually**

```bash
flutter run
```

Steps to test:
1. Navigate to Profile page
2. Tap "Help & Support" button
3. Verify bottom sheet appears with title, description, text field
4. Type message into text field
5. Verify char counter shows "X/500"
6. Verify send button is enabled
7. Tap Send button
8. Verify loading spinner shows
9. **Expected result:** Spinner completes, snackbar shows "Message sent successfully", sheet closes after 2s
   - **If fails:** Check .env configured correctly, SMTP credentials valid, network connection active
10. Tap Help & Support again
11. Type message, leave empty
12. Verify Send button is disabled
13. Type message again, verify button enabled

- [ ] **Step 5: Test error scenarios (optional)**

Modify .env SMTP credentials to invalid value, repeat steps 1-9. Expected: Error message appears with Retry button.

- [ ] **Step 6: Final commit (if testing successful)**

```bash
git log --oneline | head -10
```

Expected: See help-support commits

---

## Summary of Changes

- ✅ Added `mailer` and `flutter_dotenv` dependencies
- ✅ Created `.env` configuration files
- ✅ Implemented `EmailService` with SMTP sending + validation
- ✅ Created `HelpSupportSheet` bottom sheet UI
- ✅ Registered `EmailService` in ServiceLocator
- ✅ Initialized `.env` in `main()`
- ✅ Wired ProfilePage Help & Support onTap
- ✅ Added localization strings (EN + RU)
- ✅ Created unit tests for EmailService
- ✅ Created widget tests for HelpSupportSheet

**Total: ~10 focused commits, ~8 new files, ~3 modified files**

---

## Plan complete and saved to `docs/superpowers/plans/2026-05-27-help-support-implementation.md`.

**Two execution options:**

**1. Subagent-Driven (recommended)** - I dispatch fresh subagent per task, review between tasks, fast iteration

**2. Inline Execution** - Execute tasks in this session using executing-plans, batch execution with checkpoints

Which approach?