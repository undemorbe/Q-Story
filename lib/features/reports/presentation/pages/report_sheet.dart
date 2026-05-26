import 'package:flutter/material.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/services/report_service.dart';

class ReportSheet extends StatefulWidget {
  final String markerId;
  final String markerTitle;

  const ReportSheet({
    super.key,
    required this.markerId,
    required this.markerTitle,
  });

  @override
  State<ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends State<ReportSheet> {
  late final TextEditingController _textController;
  late final ValueNotifier<int> _textLengthNotifier;
  late final ReportService _reportService;

  ReportCategory? _selectedCategory;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _textLengthNotifier = ValueNotifier<int>(0);
    _reportService = getIt<ReportService>();
  }

  @override
  void dispose() {
    _textLengthNotifier.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
                l10n.report,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Read-only marker info section
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ID: ${widget.markerId}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.markerTitle,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Category dropdown
          DropdownButtonFormField<ReportCategory>(
            initialValue: _selectedCategory,
            decoration: InputDecoration(
              labelText: l10n.reportCategory,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            items: ReportCategory.values
                .map((cat) => DropdownMenuItem(
                      value: cat,
                      child: Text(
                        _reportService.getCategoryLabel(
                          cat,
                          Localizations.localeOf(context).languageCode,
                        ),
                      ),
                    ))
                .toList(),
            onChanged: _isLoading ? null : (value) {
              setState(() => _selectedCategory = value);
            },
          ),
          const SizedBox(height: 16),

          // Report text field
          TextField(
            controller: _textController,
            enabled: !_isLoading,
            maxLength: 500,
            maxLines: 5,
            minLines: 3,
            decoration: InputDecoration(
              hintText: l10n.reportText,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              counterText: '',
            ),
            onChanged: (text) {
              _textLengthNotifier.value = text.length;
            },
          ),
          ValueListenableBuilder<int>(
            valueListenable: _textLengthNotifier,
            builder: (context, textLength, _) {
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '$textLength/500',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              );
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
                    onPressed: _retryReport,
                    child: Text(l10n.retry),
                  ),
                ],
              ),
            ),

          // Send button
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: (_isLoading ||
                          _selectedCategory == null ||
                          _textController.text.trim().isEmpty)
                      ? null
                      : _sendReport,
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

  Future<void> _sendReport() async {
    final l10n = AppLocalizations.of(context)!;
    final category = _selectedCategory!;
    final categoryLabel = _reportService.getCategoryLabel(
      category,
      Localizations.localeOf(context).languageCode,
    );
    final text = _textController.text.trim();

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.reportConfirmTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${l10n.reportCategory}: $categoryLabel'),
            const SizedBox(height: 12),
            Text(text, maxLines: 3, overflow: TextOverflow.ellipsis),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.send),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _reportService.sendReport(
        markerId: widget.markerId,
        markerTitle: widget.markerTitle,
        category: category,
        text: text,
      );

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.reportSent),
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
        if (e is Exception) {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        } else {
          _errorMessage = 'An unexpected error occurred';
        }
      });
    }
  }

  Future<void> _retryReport() async {
    setState(() {
      _errorMessage = null;
    });
    await _sendReport();
  }
}
