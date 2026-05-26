# Help & Support Email Feature Design

**Date:** 2026-05-27  
**Feature:** Add user message sending via email to support contact  
**Scope:** Add bottom sheet UI + EmailService for SMTP email sending

## Overview

Enable users to send support messages directly from ProfilePage via bottom sheet. Messages sent to support email (from .env) using SMTP via mailer package.

## Architecture

### Components

1. **EmailService** (`lib/core/services/email_service.dart`)
   - Singleton service managing SMTP email sending
   - Configured via .env file (SMTP credentials, recipient, subject)
   - Error handling with meaningful user messages

2. **HelpSupportSheet** (`lib/features/profile/presentation/pages/help_support_sheet.dart`)
   - Bottom sheet UI for composing message
   - TextField for message input (multiline, max 500 chars)
   - Loading/error/success state management
   - Auto-close on success after 2s delay

3. **ProfilePage update** (`lib/features/profile/presentation/pages/profile_page.dart`)
   - Wire Help & Support ListTile onTap to open HelpSupportSheet

### Data Flow

```
User taps "Help & Support" 
  → showModalBottomSheet(HelpSupportSheet)
  → User types message, taps Send
  → HelpSupportSheet calls EmailService.sendSupportMessage(text)
  → Show loading spinner
  → EmailService sends SMTP email
  → Show success snackbar
  → Auto-close sheet (2s delay)
```

## Dependencies

### pubspec.yaml additions
- `mailer: ^6.1.1` - SMTP email sending
- `flutter_dotenv: ^5.1.0` - .env file loading

### Configuration (.env file)
```
SMTP_HOST=smtp.gmail.com
SMTP_PORT=465
SMTP_USER=your-email@gmail.com
SMTP_PASSWORD=your-app-password
SUPPORT_EMAIL=stankovb08@gmail.com
SUPPORT_SUBJECT=QStory App Support
```

Add `.env` to `.gitignore`. Create `.env.example` as template for team.

## EmailService Implementation

### Interface
```dart
Future<void> sendSupportMessage(String message) async
```

### Responsibilities
- Load SMTP config from .env (DotEnv)
- Validate message (trim, non-empty, max 500 chars)
- Build email with user message + timestamp
- Send via SMTP with mailer package
- Handle errors and throw appropriate exceptions

### Error Handling
- Network failures → "Network error. Check internet connection."
- Invalid credentials → "Email service misconfigured"
- Timeout (30s) → "Request timeout"
- Generic errors → "Failed to send message"

## HelpSupportSheet Implementation

### UI Layout
- Title: "Help & Support" (localized)
- Description text: "Send us a message and we'll get back to you"
- TextField: multiline, placeholder "Enter your message...", max 500 chars
- Char counter: "0/500"
- Send button: disabled when empty
- Close button: top-right X icon
- Error message area: red text, visible on error
- Retry button: visible on error

### State Management
- **Idle:** user typing, send button enabled/disabled
- **Loading:** spinner overlay, send button disabled
- **Success:** snackbar "Message sent successfully", auto-close after 2s
- **Error:** error message visible, retry button enabled, text preserved

### User Validation
- Empty string validation (disable button, show "Enter a message")
- Max 500 chars (TextField enforces, show counter)
- Trim whitespace before send
- No special validation needed (text-only)

## Testing

### Unit Tests (EmailService)
- Mock mailer, test success case
- Test error scenarios (network, invalid credentials, timeout)
- Test message validation
- Test .env loading

### Widget Tests (HelpSupportSheet)
- Render sheet correctly
- Send button disabled when empty
- Loading state shows spinner
- Success state shows snackbar
- Error state shows message + retry button
- Retry button works
- Auto-close on success works

## Service Locator Integration

Update `lib/core/di/service_locator.dart`:
```dart
getIt.registerSingleton<EmailService>(EmailService());
```

Initialize .env in `main()`:
```dart
await dotenv.load(fileName: ".env");
```

## Integration with ProfilePage

Replace empty onTap handler:
```dart
onTap: () {
  Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => const HelpSupportSheet()),
  );
},
```

## Files to Create/Modify

### Create
- `lib/core/services/email_service.dart`
- `lib/features/profile/presentation/pages/help_support_sheet.dart`
- `.env` (template)
- `.env.example` (template)

### Modify
- `pubspec.yaml` (add mailer, flutter_dotenv)
- `lib/core/di/service_locator.dart` (register EmailService)
- `lib/main.dart` (load .env)
- `lib/features/profile/presentation/pages/profile_page.dart` (wire onTap)

## Error Scenarios & Recovery

| Scenario | User Sees | Recovery |
|----------|-----------|----------|
| Empty message | Button disabled | Type message |
| Network error | Error message | Retry button |
| Invalid SMTP credentials | Error message | Retry (after fix) |
| Timeout | Error message | Retry button |
| Success | Success snackbar | Sheet closes auto |

## Localization

Use existing `l10n` for:
- Sheet title: "helpAndSupport" (already exists)
- Description: "sendSupportMessage" (new key)
- Placeholder: "enterMessage" (new key)
- Send button: "send" (likely exists)
- Success: "messageSent" (new key)
- Error messages: per error type (new keys)

## Out of Scope

- User authentication (no login required to send)
- Message history/storage (fire and forget)
- Attachment support
- Rich text formatting
- Multiple recipient selection
- Message drafts
