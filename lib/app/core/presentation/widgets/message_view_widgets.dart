import 'package:flutter/material.dart';

enum MessageType { error, success, info, loading }

class   MessageViewWidgets {
  /// عرض رسالة عامة (SnackBar / Dialog / Loading)
  /// [context] : BuildContext
  /// [message] : نص الرسالة
  /// [title] : عنوان الرسالة (لـ Dialog)
  /// [type] : نوع الرسالة (error/success/info/loading)
  static void showMessage(
    BuildContext context, {
    required String message,
    String? title,
    MessageType type = MessageType.info,
    bool isDialog = false, // إذا أردت إظهار Dialog بدل SnackBar
  }) {
    final theme = Theme.of(context);

    switch (type) {
      case MessageType.error:
      case MessageType.success:
      case MessageType.info:
        if (isDialog) {
          // Dialog
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Icon(
                    type == MessageType.error
                        ? Icons.error_outline
                        : type == MessageType.success
                        ? Icons.check_circle_outline
                        : Icons.info_outline,
                    color: type == MessageType.error
                        ? theme.colorScheme.error
                        : type == MessageType.success
                        ? theme.colorScheme.secondary
                        : theme.colorScheme.primary,
                    size: 24,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title ?? type.name.toUpperCase(),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
              content: Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(fontSize: 16),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: type == MessageType.error
                        ? theme.colorScheme.error
                        : type == MessageType.success
                        ? theme.colorScheme.secondary
                        : theme.colorScheme.primary,
                  ),
                  child: Text(
                    'OK',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          );
        } else {
          // SnackBar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: type == MessageType.error
                      ? theme.colorScheme.onError
                      : type == MessageType.success
                      ? theme.colorScheme.onSecondary
                      : theme.colorScheme.onPrimary,
                  fontSize: 16,
                ),
              ),
              backgroundColor: type == MessageType.error
                  ? theme.colorScheme.error
                  : type == MessageType.success
                  ? theme.colorScheme.secondary
                  : theme.colorScheme.primary,
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
        break;

      case MessageType.loading:
        // Loading dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => WillPopScope(
            onWillPop: () async => false,
            child: Center(
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        color: theme.colorScheme.primary,
                      ),
                      if (message.isNotEmpty) ...[
                        SizedBox(height: 16),
                        Text(
                          message,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
        break;
    }
  }

  /// إغلاق أي Dialog أو Loading مفتوح
  static void hideMessage(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  static void hideKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }
}

 