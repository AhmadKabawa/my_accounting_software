import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/localization/keys/common_keys.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';

enum MessageType { error, success, warning, info, loading }

/// نظام الرسائل الموحد (SnackBar / Dialog / Loading).
///
/// - النص: مفتاح ترجمة `messageKey` (المفضل) أو `message` نص جاهز للتوافق.
///   الترجمة تتم وقت العرض فتحترم اللغة الحالية.
/// - الألوان: `colors.error` للخطأ و`semanticColors` لـ success/warning/info.
class MessageViewWidgets {
  MessageViewWidgets._();

  /// عرض رسالة عامة.
  ///
  /// مرّر [messageKey] أو [message] (أحدهما على الأقل؛ يُفضَّل المفتاح).
  /// [title] / [titleKey] للعنوان في الـ Dialog فقط.
  /// [isDialog] لإظهار Dialog بدل SnackBar (لا ينطبق على loading).
  static void showMessage(
    BuildContext context, {
    AppKey? messageKey,
    String? message,
    AppKey? titleKey,
    String? title,
    MessageType type = MessageType.info,
    bool isDialog = false,
  }) {
    assert(
      messageKey != null || message != null,
      'MessageViewWidgets.showMessage needs messageKey or message',
    );

    final text = _text(messageKey, message, AppTextType.bodyLarge);

    if (type == MessageType.loading) {
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => PopScope(
          canPop: false,
          child: Center(
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: dialogContext.ui.radius.lg,
              ),
              child: Padding(
                padding: dialogContext.ui.padding.all(AppSpacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: dialogContext.ui.theme.colors.primary,
                    ),
                    if (messageKey != null ||
                        (message != null && message.isNotEmpty)) ...[
                      dialogContext.ui.spacing.gap(AppSpacing.md),
                      text,
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      return;
    }

    final style = _MessageStyle.of(context, type);

    if (isDialog) {
      showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: dialogContext.ui.radius.lg,
          ),
          title: Row(
            children: [
              Icon(
                style.icon,
                color: style.background,
                size: dialogContext.ui.icon.lg,
              ),
              if (titleKey != null || title != null) ...[
                dialogContext.ui.spacing.gap(AppSpacing.sm),
                Expanded(
                  child: _text(titleKey, title, AppTextType.titleMedium),
                ),
              ],
            ],
          ),
          content: text,
          actions: [
            AppButton(
              CommonKeys.ok,
              variant: type == MessageType.error
                  ? AppButtonVariant.danger
                  : AppButtonVariant.primary,
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
          ],
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: _text(
          messageKey,
          message,
          AppTextType.bodyMedium,
          color: style.foreground,
        ),
        backgroundColor: style.background,
        behavior: SnackBarBehavior.floating,
        margin: context.ui.padding.all(AppSpacing.md),
        shape: RoundedRectangleBorder(borderRadius: context.ui.radius.md),
      ),
    );
  }

  /// إغلاق أي Dialog أو Loading مفتوح.
  static void hideMessage(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  static void hideKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  static Widget _text(
    AppKey? key,
    String? raw,
    AppTextType type, {
    Color? color,
  }) => key != null
      ? AppText(key, type: type, color: color)
      : AppText.raw(raw ?? '', type: type, color: color);
}

/// ألوان وأيقونة كل نوع رسالة (غير loading).
class _MessageStyle {
  const _MessageStyle(this.background, this.foreground, this.icon);

  final Color background;
  final Color foreground;
  final IconData icon;

  factory _MessageStyle.of(BuildContext context, MessageType type) {
    final colors = context.ui.theme.colors;
    final semantic = context.ui.theme.semanticColors;
    return switch (type) {
      MessageType.error => _MessageStyle(
        colors.error,
        colors.onError,
        Icons.error_outline,
      ),
      MessageType.success => _MessageStyle(
        semantic.success,
        semantic.onSuccess,
        Icons.check_circle_outline,
      ),
      MessageType.warning => _MessageStyle(
        semantic.warning,
        semantic.onWarning,
        Icons.warning_amber_outlined,
      ),
      MessageType.info || MessageType.loading => _MessageStyle(
        semantic.info,
        semantic.onInfo,
        Icons.info_outline,
      ),
    };
  }
}
