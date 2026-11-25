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
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_icon_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_dashed_border/app_dashed_border.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_image_upload/app_image_upload_zone_content.dart';
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

/// Shared clickable image zone, picker, validator, uploader and preview.
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
    if (files.isEmpty || _cubit.state.isBusy) return;
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
        final actionKey = hasImage
            ? widget.labels.replace
            : widget.labels.upload;
        final errorKey = switch (state) {
          ImageUploadFailed(:final messageKey) => messageKey,
          _ => null,
        };
        final radius = AppRadius.md.circular(context);
        final zone = AppDashedBorder(
          color: _isHovering ? colors.primary : colors.outline,
          fill: _isHovering
              ? colors.primary.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: radius,
          child: Stack(
            children: [
              Semantics(
                button: true,
                enabled: !busy,
                label: actionKey.tr(context: context),
                excludeSemantics: true,
                child: Material(
                  color: Colors.transparent,
                  borderRadius: radius,
                  child: InkWell(
                    onTap: busy ? null : _cubit.pickAndUpload,
                    borderRadius: radius,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: AppComponentSize.imageDropZoneMinHeight.of(
                          context,
                        ),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: Padding(
                          padding: context.ui.padding.all(AppSpacing.lg),
                          child: Center(
                            child: AppImageUploadZoneContent(
                              busy: busy,
                              hasImage: hasImage,
                              supportsDrop: supportsDrop,
                              isHovering: _isHovering,
                              imageUrl: _displayedValue,
                              label: widget.label,
                              policy: widget.policy,
                              uploadLabel: widget.labels.upload,
                              replaceLabel: widget.labels.replace,
                              dropHint: widget.labels.dropHint,
                              previewSize: widget.previewSize,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (hasImage)
                PositionedDirectional(
                  top: context.ui.spacing.value(AppSpacing.sm),
                  end: context.ui.spacing.value(AppSpacing.sm),
                  child: AppIconButton(
                    AppIcons.delete,
                    tooltipKey: widget.labels.remove,
                    size: AppButtonSize.small,
                    onPressed: busy ? null : _remove,
                  ),
                ),
            ],
          ),
        );
        Widget content = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppText(widget.labels.sectionTitle, type: AppTextType.titleSmall),
            context.ui.spacing.gap(AppSpacing.sm),
            zone,
            if (errorKey != null) ...[
              context.ui.spacing.gap(AppSpacing.sm),
              InlineBanner(
                messageKey: errorKey,
                variant: InlineBannerVariant.error,
              ),
            ],
          ],
        );
        if (supportsDrop) {
          content = FileDropTarget(
            adapter:
                widget.dropTargetAdapter ??
                const DesktopFileDropTargetAdapter(),
            onFilesDropped: _onDropped,
            onHover: (hovering) {
              if (_isHovering != hovering && mounted) {
                setState(() => _isHovering = hovering);
              }
            },
            child: content,
          );
        }
        return content;
      },
    );
  }
}
