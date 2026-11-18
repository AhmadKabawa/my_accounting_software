import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/localization/keys/common_keys.dart';
import 'package:accounting_software/app/core/localization/keys/message_keys.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_inline_banner/inline_banner.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';

enum MessageType { error, success, warning, info, loading }

/// نظام الرسائل الموحد (SnackBar / Dialog / Loading، وبانر داخل الشاشة).
///
/// - النص: مفتاح ترجمة `messageKey` (المفضل) أو `message` نص جاهز للتوافق.
///   الترجمة تتم وقت العرض فتحترم اللغة الحالية.
/// - **ممنوع تمرير نص الخادم أو نص استثناء إلى `message:`/`title:`** (R2 وقرار-76):
///   قد يحمل تفاصيل SQL أو أسماء جداول. المسار الآمن هو `Failure.messageKey`
///   (مفتاح مترجم من رمز الخطأ) أو [failureBanner]. التفاصيل التقنية تُسجَّل
///   في `ExceptionMapper` عبر `Logger`، ولا تُعرض.
/// - الألوان: `colors.error` للخطأ و`semanticColors` لـ success/warning/info.
/// - الأخطاء التي على المستخدم قراءتها كاملة (رفض قاعدة، تحقق) تُعرض داخل
///   النموذج بـ [failureBanner] لا بـ SnackBar زائل.
class MessageViewWidgets {
  MessageViewWidgets._();

  /// اسم مسار نوافذ الرسائل (Dialog/Loading) على الـ root navigator؛ به
  /// يعرف [hideMessage] أن أعلى مسار هو رسالة وليس صفحة أو نافذة أخرى.
  static const _routeName = 'message_view_widgets.dialog';
  static const _routeSettings = RouteSettings(name: _routeName);

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
        routeSettings: _routeSettings,
        builder: (dialogContext) => PopScope(
          canPop: false,
          child: Center(
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: dialogContext.ui.radius.xl,
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
        routeSettings: _routeSettings,
        builder: (dialogContext) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: dialogContext.ui.radius.xl,
          ),
          title: Row(
            children: [
              AppIcon(
                style.icon,
                size: AppIconSize.lg,
                color: style.background,
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

  /// يُخفي أعلى رسالة Dialog/Loading مفتوحة فقط.
  ///
  /// - لا يُغلق صفحة ولا نافذة ليست من هذا النظام: يفحص اسم أعلى مسار قبل
  ///   أن يُغلقه، فلا أثر له إن لم توجد رسالة (استدعاء مزدوج آمن).
  /// - يعمل على الـ root navigator كما يفعل `showDialog`، فيصل إلى النافذة
  ///   حتى من سياق داخل ShellRoute (navigator متداخل).
  /// - لا يمسّ SnackBar: تُخفيها مهلتها أو `ScaffoldMessenger`.
  static void hideMessage(BuildContext context) {
    final navigator = Navigator.maybeOf(context, rootNavigator: true);
    if (navigator == null) return;

    // `popUntil` يستدعي الـ predicate على أعلى مسار ولا يُغلق شيئاً إذا أعاد
    // true: نقرأ به اسم أعلى مسار دون أن نفترض أنه رسالة.
    var topIsMessage = false;
    navigator.popUntil((route) {
      topIsMessage = route.settings.name == _routeName;
      return true;
    });
    if (topIsMessage) navigator.pop();
  }

  /// بانر خطأ داخل النموذج لـ [failure] (C38)، ويفصل نوعين:
  ///
  /// - **تحقق/رفض قاعدة** (`ValidationFailure`، ومنه رموز `ERPnn`): عنوانه
  ///   [MessageKeys.validationTitle]، فالمستخدم يستطيع تصحيحه.
  /// - **عطل نظام** (شبكة، خادم، غير متوقع، تخزين): عنوانه
  ///   [MessageKeys.systemTitle]، والنص عام ومترجم.
  /// - غير ذلك (جلسة، صلاحية، غير موجود): بلا عنوان، النص وحده.
  ///
  /// النص دائماً `failure.messageKey` (مفتاح مترجم)، فلا يصل إلى الشاشة نص
  /// الخادم ولا SQL ولا أسماء جداول ولا رسالة استثناء.
  static InlineBanner failureBanner(
    Failure failure, {
    Key? key,
    VoidCallback? onDismiss,
  }) => InlineBanner(
    key: key,
    variant: InlineBannerVariant.error,
    titleKey: switch (failure) {
      ValidationFailure() => MessageKeys.validationTitle,
      NetworkFailure() ||
      ServerFailure() ||
      UnexpectedFailure() ||
      CacheFailure() => MessageKeys.systemTitle,
      _ => null,
    },
    messageKey: failure.messageKey,
    onDismiss: onDismiss,
  );

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
  final AppIconData icon;

  factory _MessageStyle.of(BuildContext context, MessageType type) {
    final colors = context.ui.theme.colors;
    final semantic = context.ui.theme.semanticColors;
    return switch (type) {
      MessageType.error => _MessageStyle(
        colors.error,
        colors.onError,
        AppIcons.error,
      ),
      MessageType.success => _MessageStyle(
        semantic.success,
        semantic.onSuccess,
        AppIcons.success,
      ),
      MessageType.warning => _MessageStyle(
        semantic.warning,
        semantic.onWarning,
        AppIcons.warning,
      ),
      MessageType.info || MessageType.loading => _MessageStyle(
        semantic.info,
        semantic.onInfo,
        AppIcons.info,
      ),
    };
  }
}
