import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/foundation/image/image_policy.dart';
import 'package:accounting_software/app/core/foundation/image/image_upload.dart';
import 'package:accounting_software/app/core/foundation/image/image_upload_cubit.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/platform/file_drop/file_drop_target.dart';
import 'package:accounting_software/app/core/platform/image_picker/file_picker_image_picker.dart';
import 'package:accounting_software/app/core/platform/image_picker/image_picker_port.dart';
import 'package:accounting_software/app/core/platform/platform_capabilities.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_inline_banner/inline_banner.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_logo_thumb/app_logo_thumb.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';

class AppImageUploadFieldLabels {
  const AppImageUploadFieldLabels({
    required this.sectionTitle,
    required this.upload,
    required this.replace,
    required this.remove,
    required this.dropHint,
  });

  final AppKey sectionTitle;
  final AppKey upload;
  final AppKey replace;
  final AppKey remove;
  final AppKey dropHint;
}

/// Shared image picker, validator, uploader and responsive preview for editors.
class AppImageUploadField extends StatefulWidget {
  const AppImageUploadField({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
    required this.policy,
    required this.uploader,
    required this.labels,
    required this.previewSize,
    this.picker,
    this.dropTargetAdapter,
    this.onBusyChanged,
  });

  final String? value;
  final ValueChanged<String?> onChanged;
  final String label;
  final ImagePolicy policy;
  final ImageUploader uploader;
  final AppImageUploadFieldLabels labels;
  final AppLogoSize previewSize;
  final ImagePickerPort? picker;
  final FileDropTargetAdapter? dropTargetAdapter;
  final ValueChanged<bool>? onBusyChanged;

  @override
  State<AppImageUploadField> createState() => _AppImageUploadFieldState();
}

class _AppImageUploadFieldState extends State<AppImageUploadField> {
  late final ImageUploadCubit _cubit;
  bool _isHovering = false;
  bool _wasBusy = false;
  String? _displayedValue;

  @override
  void initState() {
    super.initState();
    _displayedValue = widget.value;
    _cubit = ImageUploadCubit(
      picker: widget.picker ?? const FilePickerImagePicker(),
      policy: widget.policy,
      uploader: widget.uploader,
    );
  }

  @override
  void didUpdateWidget(covariant AppImageUploadField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) _displayedValue = widget.value;
  }

  @override
  void dispose() {
    if (_wasBusy) widget.onBusyChanged?.call(false);
    unawaited(_cubit.close());
    super.dispose();
  }

  Future<void> _onDropped(List<PickedImage> files) async {
    if (files.isEmpty) return;
    final file = files.first;
    await _cubit.upload(
      ImageUpload(
        bytes: file.bytes,
        fileName: file.fileName,
        mimeType: file.mimeType,
      ),
    );
  }

  void _remove() {
    if (_cubit.state.isBusy) return;
    setState(() => _displayedValue = null);
    widget.onChanged(null);
    _cubit.reset();
  }

  void _onStateChanged(BuildContext context, ImageUploadState state) {
    if (state case ImageUploadUploaded(:final url)) {
      widget.onChanged(url);
      if (mounted) setState(() => _displayedValue = url);
    }
    final busy = state.isBusy;
    if (busy != _wasBusy) {
      _wasBusy = busy;
      widget.onBusyChanged?.call(busy);
    }
  }

  @override
  Widget build(BuildContext context) {
    final supportsDrop = PlatformCapabilities.supportsFileDrop;
    final colors = context.ui.theme.colors;

    return BlocConsumer<ImageUploadCubit, ImageUploadState>(
      bloc: _cubit,
      listener: _onStateChanged,
      builder: (context, state) {
        final busy = state.isBusy;
        final hasImage = _displayedValue?.trim().isNotEmpty == true;
        final messageKey = switch (state) {
          ImageUploadFailed(:final messageKey) => messageKey,
          _ => null,
        };
        final preview = AppLogoThumb(
          url: _displayedValue,
          label: widget.label,
          size: widget.previewSize,
          fallbackIcon: AppIcons.image,
        );
        final controls = Wrap(
          spacing: context.ui.spacing.sm,
          runSpacing: context.ui.spacing.sm,
          children: [
            AppButton(
              hasImage ? widget.labels.replace : widget.labels.upload,
              size: AppButtonSize.small,
              icon: AppIcons.upload,
              isLoading: busy,
              onPressed: busy ? null : _cubit.pickAndUpload,
            ),
            if (hasImage)
              AppButton(
                widget.labels.remove,
                size: AppButtonSize.small,
                variant: AppButtonVariant.text,
                icon: AppIcons.delete,
                onPressed: busy ? null : _remove,
              ),
          ],
        );
        final narrow = context.ui.screen.isMobile;
        final previewAndActions = narrow
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  preview,
                  context.ui.spacing.gap(AppSpacing.md),
                  controls,
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  preview,
                  context.ui.spacing.gap(AppSpacing.lg, axis: Axis.horizontal),
                  Expanded(child: controls),
                ],
              );

        Widget content = _DashedBorder(
          color: _isHovering ? colors.primary : colors.outline,
          fill: _isHovering
              ? colors.primary.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: AppRadius.md.circular(context),
          child: Padding(
            padding: context.ui.padding.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppText(
                  widget.labels.sectionTitle,
                  type: AppTextType.titleSmall,
                ),
                context.ui.spacing.gap(AppSpacing.md),
                previewAndActions,
                if (supportsDrop) ...[
                  context.ui.spacing.gap(AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppIcon(
                        AppIcons.upload,
                        size: AppIconSize.sm,
                        color: _isHovering
                            ? colors.primary
                            : colors.onSurfaceVariant,
                      ),
                      context.ui.spacing.gap(
                        AppSpacing.sm,
                        axis: Axis.horizontal,
                      ),
                      Flexible(
                        child: AppText(
                          widget.labels.dropHint,
                          type: AppTextType.bodySmall,
                          color: _isHovering
                              ? colors.primary
                              : colors.onSurfaceVariant,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ],
                if (messageKey != null) ...[
                  context.ui.spacing.gap(AppSpacing.sm),
                  InlineBanner(
                    messageKey: messageKey,
                    variant: InlineBannerVariant.error,
                  ),
                ],
              ],
            ),
          ),
        );

        if (supportsDrop) {
          content = FileDropTarget(
            child: content,
            adapter:
                widget.dropTargetAdapter ??
                const DesktopFileDropTargetAdapter(),
            onFilesDropped: _onDropped,
            onHover: (hovering) {
              if (_isHovering != hovering && mounted) {
                setState(() => _isHovering = hovering);
              }
            },
          );
        }

        return Semantics(
          container: true,
          label: widget.labels.sectionTitle.tr(context: context),
          child: content,
        );
      },
    );
  }
}

/// A dashed rounded outline: the usual "drop files here" look.
class _DashedBorder extends StatelessWidget {
  const _DashedBorder({
    required this.color,
    required this.fill,
    required this.borderRadius,
    required this.child,
  });

  final Color color;
  final Color fill;
  final BorderRadius borderRadius;
  final Widget child;

  @override
  Widget build(BuildContext context) => CustomPaint(
    foregroundPainter: _DashedPainter(color, borderRadius),
    child: DecoratedBox(
      decoration: BoxDecoration(color: fill, borderRadius: borderRadius),
      child: child,
    ),
  );
}

class _DashedPainter extends CustomPainter {
  const _DashedPainter(this.color, this.borderRadius);

  static const _stroke = 1.5, _dash = 6.0, _gap = 4.0;
  final Color color;
  final BorderRadius borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = borderRadius.toRRect(Offset.zero & size).deflate(_stroke / 2);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = _stroke;
    for (final metric in (Path()..addRRect(rrect)).computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + _dash), paint);
        distance += _dash + _gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedPainter old) =>
      old.color != color || old.borderRadius != borderRadius;
}
