import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:accounting_software/app/core/foundation/validation/hex_color.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_icon_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_color_swatch/app_color_swatch.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text_field/app_text_field.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_color_picker/app_color_picker_keys.dart';
export 'app_color_picker_keys.dart';

class AppColorPicker extends StatefulWidget {
  const AppColorPicker({
    super.key,
    required this.value,
    required this.onChanged,
    this.presets = const [
      '#000000',
      '#FFFFFF',
      '#808080',
      '#F57C21',
      '#228B22',
      '#05AD9D',
      '#800080',
      '#000080',
    ],
  });
  final String? value;
  final ValueChanged<String?> onChanged;
  final List<String> presets;
  @override
  State<AppColorPicker> createState() => _AppColorPickerState();
}

class _AppColorPickerState extends State<AppColorPicker> {
  static const _size = 220.0, _hueHeight = 24.0;
  static const _alphaLength = 9, _rgbLength = 7;
  final _controller = TextEditingController();
  double _hue = 0, _sat = 1, _val = 1;
  String? _alpha;
  bool _manual = false;
  Color get _color => HSVColor.fromAHSV(1, _hue, _sat, _val).toColor();
  @override
  void initState() {
    super.initState();
    _sync(widget.value);
  }

  @override
  void didUpdateWidget(covariant AppColorPicker old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) _sync(widget.value);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _hex(Color color) {
    final argb = color.toARGB32();
    final red = ((argb >> 16) & 0xff).toRadixString(16).padLeft(2, '0');
    final green = ((argb >> 8) & 0xff).toRadixString(16).padLeft(2, '0');
    final blue = (argb & 0xff).toRadixString(16).padLeft(2, '0');
    return '#$red$green$blue'.toUpperCase();
  }
  void _sync(String? input) {
    final h = HexColor.normalize(input);
    _manual = false;
    if (h == null || !HexColor.isValid(h)) {
      _alpha = null;
      _controller.text = '';
      return;
    }
    _alpha = h.length == _alphaLength ? h.substring(_rgbLength) : null;
    final hsv = HSVColor.fromColor(Color(HexColor.toArgb(h)!));
    _hue = hsv.hue;
    _sat = hsv.saturation;
    _val = hsv.value;
    _controller.text = h.substring(0, _rgbLength);
  }

  String _output() => _manual
      ? _hex(_color)
      : _alpha == null
      ? _hex(_color)
      : '${_hex(_color)}$_alpha';
  void _emit() {
    widget.onChanged(_output());
    _controller.text = _hex(_color);
  }

  void _manualHex(String text) {
    final h = HexColor.normalize(text.startsWith('#') ? text : '#$text');
    if (h == null || !HexColor.isValid(h)) return;
    _manual = true;
    _alpha = null;
    final hsv = HSVColor.fromColor(Color(HexColor.toArgb(h)!));
    setState(() {
      _hue = hsv.hue;
      _sat = hsv.saturation;
      _val = hsv.value;
    });
    widget.onChanged(h.substring(0, _rgbLength));
  }

  void _sv(Offset p) {
    setState(() {
      _sat = (p.dx / _size).clamp(0.0, 1.0);
      _val = (1 - p.dy / _size).clamp(0.0, 1.0);
    });
    _emit();
  }

  void _setHue(double x) {
    setState(() => _hue = (x / _size * 360).clamp(0.0, 360.0));
    _emit();
  }

  void _preset(String hex) {
    if (!HexColor.isValid(hex)) return;
    _sync(hex);
    setState(() {});
    widget.onChanged(HexColor.normalize(hex));
  }

  @override
  Widget build(BuildContext context) {
    final ui = context.ui;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          label: AppColorPickerKeys.sv.tr(context: context),
          slider: true,
          child: GestureDetector(
            onPanDown: (e) => _sv(e.localPosition),
            onPanUpdate: (e) => _sv(e.localPosition),
            child: SizedBox(
              width: _size,
              height: _size,
              child: CustomPaint(
                painter: _SvPainter(_hue, _sat, _val),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ),
        ui.spacing.gap(AppSpacing.md),
        Semantics(
          label: AppColorPickerKeys.hue.tr(context: context),
          slider: true,
          child: GestureDetector(
            onPanDown: (e) => _setHue(e.localPosition.dx),
            onPanUpdate: (e) => _setHue(e.localPosition.dx),
            child: SizedBox(
              width: _size,
              height: _hueHeight,
              child: CustomPaint(
                painter: _HuePainter(_hue),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ),
        ui.spacing.gap(AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: AppTextField(
                controller: _controller,
                labelKey: AppColorPickerKeys.hex,
                textDirection: TextDirection.ltr,
                onChanged: _manualHex,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[#0-9a-fA-F]')),
                ],
              ),
            ),
            ui.spacing.gap(AppSpacing.sm),
            AppColorSwatch(hex: widget.value, size: AppIconSize.lg),
            AppIconButton(
              AppIcons.copy,
              tooltipKey: AppColorPickerKeys.copy,
              onPressed: widget.value == null
                  ? null
                  : () => Clipboard.setData(ClipboardData(text: widget.value!)),
            ),
          ],
        ),
        if (widget.value == null) AppText(AppColorPickerKeys.noColor),
        if (widget.presets.isNotEmpty) ...[
          ui.spacing.gap(AppSpacing.md),
          AppText(AppColorPickerKeys.presets),
          Wrap(
            spacing: ui.spacing.value(AppSpacing.sm),
            runSpacing: ui.spacing.value(AppSpacing.sm),
            children: [
              for (final p in widget.presets.where(HexColor.isValid))
                AppColorSwatch(
                  hex: p,
                  onTap: () => _preset(p),
                  semanticLabel: p,
                  selected:
                      HexColor.normalize(widget.value) == HexColor.normalize(p),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _SvPainter extends CustomPainter {
  const _SvPainter(this.h, this.s, this.v);
  final double h, s, v;
  static const white = Color(0xFFFFFFFF), black = Color(0xFF000000);
  @override
  void paint(Canvas c, Size z) {
    final r = Offset.zero & z;
    c.drawRect(r, Paint()..color = HSVColor.fromAHSV(1, h, 1, 1).toColor());
    c.drawRect(
      r,
      Paint()
        ..shader = const LinearGradient(
          colors: [white, Color(0x00FFFFFF)],
        ).createShader(r),
    );
    c.drawRect(
      r,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x00000000), black],
        ).createShader(r),
    );
    c.drawCircle(
      Offset(s * z.width, (1 - v) * z.height),
      8,
      Paint()
        ..color = white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(_SvPainter o) => h != o.h || s != o.s || v != o.v;
}

class _HuePainter extends CustomPainter {
  const _HuePainter(this.h);
  final double h;
  static const colors = [
    Color(0xFFFF0000),
    Color(0xFFFFFF00),
    Color(0xFF00FF00),
    Color(0xFF00FFFF),
    Color(0xFF0000FF),
    Color(0xFFFF00FF),
    Color(0xFFFF0000),
  ];
  @override
  void paint(Canvas c, Size z) {
    final r = Offset.zero & z;
    c.drawRect(
      r,
      Paint()..shader = const LinearGradient(colors: colors).createShader(r),
    );
    c.drawCircle(
      Offset(h / 360 * z.width, z.height / 2),
      8,
      Paint()
        ..color = const Color(0xFFFFFFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(_HuePainter o) => h != o.h;
}
