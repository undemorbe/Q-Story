import 'package:flutter/material.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/services/email_service.dart';

class HelpSupportSheet extends StatefulWidget {
  const HelpSupportSheet({super.key});

  @override
  State<HelpSupportSheet> createState() => _HelpSupportSheetState();
}

class _HelpSupportSheetState extends State<HelpSupportSheet> {
  late final TextEditingController _messageController;
  late final EmailService _emailService;

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _emailService = getIt<EmailService>();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();

    if (message.isEmpty) {
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.enterMessage;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _emailService.sendSupportMessage(message);

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.messageSent),
          backgroundColor: Colors.green,
        ),
      );

      // Auto-close sheet after 2 seconds
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _retryMessage() async {
    setState(() {
      _errorMessage = null;
    });
    await _sendMessage();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final messageLength = _messageController.text.length;

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
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
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Description
          Text(
            l10n.sendSupportMessage,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),

          // Text field
          TextField(
            controller: _messageController,
            enabled: !_isLoading,
            maxLength: 500,
            maxLines: 5,
            minLines: 3,
            decoration: InputDecoration(
              hintText: l10n.enterMessage,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              counterText: '$messageLength/500',
            ),
            onChanged: (_) {
              setState(() {});
            },
          ),
          const SizedBox(height: 16),

          // Error message
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: Colors.red[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _retryMessage,
                    child: Text(l10n.retry),
                  ),
                ],
              ),
            ),

          // Send button and loading indicator
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: (_isLoading || _messageController.text.trim().isEmpty)
                      ? null
                      : _sendMessage,
                  child: _isLoading
                      ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.blue[700]!,
                      ),
                    ),
                  )
                      : Text(l10n.send),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
