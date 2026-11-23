import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/localization/keys/common_keys.dart';
import 'package:accounting_software/app/core/localization/keys/message_keys.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/engine/screen_engine.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_badge/app_badge_style.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_icon_button.dart';
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
/// - الألوان: خلفية هادئة ونص ملوّن من توكنات الحبات (`AppSaasColors`)، نفس
///   مصدر `AppBadge`. الخطأ لا يأخذ لون النجاح أبداً، والأيقونة تُعرض فعلاً.
/// - SnackBar: نص مختصر (3 أسطر)، أيقونة دلالية، زر إغلاق، وإجراء اختياري
///   ([showMessage] `actionKey` + `onAction`)، بعرض محدود على التابلت والديسكتوب.
///   الرسالة المكررة (نفس النص والنوع وهي ظاهرة) لا تُعرض مرتين.
/// - loading: Dialog حاجب مخصص للعمليات التي لا يصح معها التفاعل. حيث يمكن
///   مؤشر مضمّن (زر `isLoading`، `refreshing` في القوائم، هياكل Skeleton) يُفضَّل
///   ولا يُستعمل هذا الحاجب (قرار UI-04 في docs/design/UI_DECISIONS_LOG.md).
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
    AppKey? actionKey,
    VoidCallback? onAction,
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
                color: style.foreground,
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

    _showSnackBar(
      context,
      style: style,
      type: type,
      messageKey: messageKey,
      message: message,
      actionKey: actionKey,
      onAction: onAction,
    );
  }

  /// SnackBars currently queued or visible per messenger, by "type|text": a
  /// message already on screen is not queued again. Keyed by the messenger so
  /// state never leaks between apps or tests.
  static final Expando<Set<String>> _visibleSnacks = Expando('snacks');

  static void _showSnackBar(
    BuildContext context, {
    required _MessageStyle style,
    required MessageType type,
    required AppKey? messageKey,
    required String? message,
    required AppKey? actionKey,
    required VoidCallback? onAction,
  }) {
    final text = messageKey != null
        ? messageKey.tr(context: context)
        : (message ?? '');
    final id = '${type.name}|$text';
    final messenger = ScaffoldMessenger.of(context);
    final visible = _visibleSnacks[messenger] ??= <String>{};
    if (!visible.add(id)) return;
    final mobile = ScreenEngine.isMobile(context);
    final shape = RoundedRectangleBorder(
      borderRadius: AppSurfaceShape.tableBand.circular(context),
      side: BorderSide(
        color: style.foreground,
        width: AppBorderWidth.thin.of(context),
      ),
    );
    final hasAction = actionKey != null && onAction != null;

    final controller = messenger.showSnackBar(
      SnackBar(
        // The whole bar is one live region: announced when it appears.
        content: Semantics(
          liveRegion: true,
          container: true,
          child: Row(
            children: [
              ExcludeSemantics(
                child: AppIcon(
                  style.icon,
                  size: AppIconSize.md,
                  color: style.foreground,
                ),
              ),
              context.ui.spacing.gap(AppSpacing.sm),
              Expanded(
                child: AppText.raw(
                  text,
                  type: AppTextType.bodyMedium,
                  color: style.foreground,
                  maxLines: _snackMaxLines,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (hasAction)
                AppButton(
                  actionKey,
                  variant: AppButtonVariant.text,
                  size: AppButtonSize.small,
                  onPressed: () {
                    messenger.hideCurrentSnackBar();
                    onAction();
                  },
                ),
              AppIconButton(
                AppIcons.close,
                tooltipKey: MessageKeys.close,
                size: AppButtonSize.small,
                color: style.foreground,
                onPressed: messenger.hideCurrentSnackBar,
              ),
            ],
          ),
        ),
        backgroundColor: style.background,
        behavior: SnackBarBehavior.floating,
        // Mobile: even margins. Desktop: a compact message aligned to
        // the directional end of the viewport (right in LTR, left in RTL).
        margin: mobile
            ? context.ui.padding.all(AppSpacing.md)
            : EdgeInsetsDirectional.only(
                start: (MediaQuery.sizeOf(context).width -
                        context.ui.size.width(AppComponentSize.snackBarWidth) -
                        context.ui.spacing.md)
                    .clamp(context.ui.spacing.md, double.infinity)
                    .toDouble(),
                end: context.ui.spacing.md,
                bottom: context.ui.spacing.md,
              ),
        shape: shape,
        elevation: 0,
      ),
    );
    controller.closed.whenComplete(() => visible.remove(id));
  }

  static const _snackMaxLines = 3;

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

/// ألوان وأيقونة كل نوع رسالة (غير loading). [background] هادئة و[foreground]
/// للنص والأيقونة والحد؛ كلاهما من توكنات الحبات (فاتح وداكن).
class _MessageStyle {
  const _MessageStyle(this.background, this.foreground, this.icon);

  final Color background;
  final Color foreground;
  final AppIconData icon;

  factory _MessageStyle.of(BuildContext context, MessageType type) {
    final (tone, icon) = switch (type) {
      MessageType.error => (AppBadgeTone.error, AppIcons.error),
      MessageType.success => (AppBadgeTone.success, AppIcons.success),
      MessageType.warning => (AppBadgeTone.warning, AppIcons.warning),
      MessageType.info ||
      MessageType.loading => (AppBadgeTone.info, AppIcons.info),
    };
    final (foreground, background) = AppBadgeStyle.toneColors(context, tone);
    return _MessageStyle(background, foreground, icon);
  }
}
