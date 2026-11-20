import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/access/permission_gate/permission_gate.dart';
import 'package:accounting_software/app/core/access/permissions.dart';
import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/core/foundation/config/app_config.dart';
import 'package:accounting_software/app/core/network/api_client_interface.dart';
import 'package:accounting_software/app/core/network/api_end_points.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icons.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_table/data_table.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_filter_bar/filter_bar.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_image/app_image.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_inline_banner/inline_banner.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_page_template/app_page_templates.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text_field/app_text_field.dart';
import 'package:accounting_software/app/features/catalog/data/brands_endpoint.dart';
import 'package:accounting_software/app/features/catalog/domain/brand.dart';
import 'package:accounting_software/app/features/catalog/presentation/localization/brands_keys.dart';
import 'package:dio/dio.dart';

class BrandsScreen extends StatefulWidget {
  const BrandsScreen({super.key});

  @override
  State<BrandsScreen> createState() => _BrandsScreenState();
}

class _BrandsScreenState extends State<BrandsScreen> {
  final _api = sl<IApiClient>();
  final _search = TextEditingController();
  List<Brand> _brands = [];
  bool _loading = true;
  String? _error;
  int _page = AppConfig.defaultPage;
  int _total = 0;
  String _status = 'all';
  int _requestVersion = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final requestVersion = ++_requestVersion;
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await _api.getPaginated<Brand>(
      BrandsEndpoint.collection,
      fromJson: Brand.fromJson,
      page: _page,
      limit: AppConfig.defaultPageSize,
      queryParameters: {
        'select': BrandsEndpoint.select,
        'order': 'name.asc',
        if (_search.text.trim().isNotEmpty)
          'or': '(name.ilike.%${_search.text.trim()}%,slug.ilike.%${_search.text.trim()}%)',
        if (_status == 'active') 'is_active': 'eq.true',
        if (_status == 'inactive') 'is_active': 'eq.false',
      },
    );
    if (!mounted || requestVersion != _requestVersion) return;
    result.when(
      success: (data) => setState(() {
        _brands = data.items;
        _total = data.totalCount;
        _loading = false;
      }),
      failure: (_) => setState(() {
        _error = 'load';
        _loading = false;
      }),
    );
  }

  Future<void> _edit([Brand? brand]) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => _BrandEditor(brand: brand, api: _api),
    );
    if (saved == true && mounted) _load();
  }

  Future<void> _delete(Brand brand) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        content: AppText(BrandsKeys.confirmDelete),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: AppText(BrandsKeys.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: AppText(BrandsKeys.delete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final result = await _api.delete(
      AppEndpoint(
        '${BrandsEndpoint.collection.toStringPath()}?id=eq.${encodePathSegment(brand.id)}',
      ),
      options: Options(headers: {'Prefer': 'return=minimal'}),
    );
    if (!mounted) return;
    result.when(
      success: (_) => _load(),
      failure: (_) => setState(() => _error = 'delete'),
    );
  }

  void _changeStatus(String? value) {
    final next = value ?? 'all';
    if (_status == next) return;
    setState(() {
      _status = next;
      _page = 1;
    });
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final activeFilters = <FilterBarFilter>[
      if (_status != 'all')
        FilterBarFilter(
          id: 'status',
          label: BrandsKeys.status,
          value: _status == 'active'
              ? BrandsKeys.active.tr(context: context)
              : BrandsKeys.inactive.tr(context: context),
          onRemove: () => _changeStatus('all'),
        ),
    ];

    return ListPageTemplate(
      titleKey: BrandsKeys.title,
      count: _total,
      primaryAction: PermissionGate(
        permission: Permissions.masterData.manage,
        child: AppButton(
          BrandsKeys.add,
          icon: AppIcons.add,
          onPressed: () => _edit(),
        ),
      ),
      filterBar: FilterBar(
        searchController: _search,
        searchHintKey: BrandsKeys.searchHint,
        activeFilters: activeFilters,
        filterControls: [
          SizedBox(
            width: 190,
            child: InputDecorator(
              decoration: InputDecoration(
                label: AppText(BrandsKeys.status),
                isDense: true,
                border: const OutlineInputBorder(),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _status,
                  isExpanded: true,
                  isDense: true,
                  items: [
                    DropdownMenuItem(
                      value: 'all',
                      child: AppText(BrandsKeys.allStatuses),
                    ),
                    DropdownMenuItem(
                      value: 'active',
                      child: AppText(BrandsKeys.active),
                    ),
                    DropdownMenuItem(
                      value: 'inactive',
                      child: AppText(BrandsKeys.inactive),
                    ),
                  ],
                  onChanged: _changeStatus,
                ),
              ),
            ),
          ),
        ],
        onClearAll: () {
          _search.clear();
          setState(() {
            _status = 'all';
            _page = 1;
          });
          _load();
        },
        onApply: _load,
        onSearchChanged: (_) {
          _page = 1;
          _load();
        },
      ),
      state: _loading
          ? AppPageState.loading
          : _error != null
              ? AppPageState.error
              : AppPageState.content,
      dataTable: AppDataTable<Brand>(
        columns: [
          DataTableColumn(
            labelKey: BrandsKeys.logo,
            priority: DataTableColumnPriority.secondary,
            cellBuilder: (_, brand) => brand.logo == null || brand.logo!.isEmpty
                ? const AppIcon(AppIcons.brokenImage)
                : AppImage.network(
                    brand.logo!,
                    width: 40,
                    height: 40,
                    shape: AppImageShape.rounded,
                    borderRadius: 8,
                    semanticsLabel: brand.name,
                  ),
          ),
          DataTableColumn(
            labelKey: BrandsKeys.name,
            sortKey: 'name',
            priority: DataTableColumnPriority.primary,
            cellBuilder: (_, brand) => AppText.raw(brand.name),
          ),
          DataTableColumn(
            labelKey: BrandsKeys.slug,
            sortKey: 'slug',
            cellBuilder: (_, brand) => AppText.raw(brand.slug),
          ),
          DataTableColumn(
            labelKey: BrandsKeys.status,
            cellBuilder: (_, brand) => AppText(
              brand.isActive ? BrandsKeys.active : BrandsKeys.inactive,
            ),
          ),
        ],
        rows: _brands,
        rowId: (brand) => brand.id,
        loading: _loading,
        errorKey: _error == null
            ? null
            : _error == 'delete'
                ? BrandsKeys.deleteError
                : BrandsKeys.loadError,
        onRetry: _load,
        totalCount: _total,
        page: _page,
        pageSize: AppConfig.defaultPageSize,
        hasMore: _page * AppConfig.defaultPageSize < _total,
        onPageChanged: (page) {
          setState(() => _page = page);
          _load();
        },
        rowActionsBuilder: (_, brand) => PermissionGate(
          permission: Permissions.masterData.manage,
          child: Wrap(
            spacing: 4,
            children: [
              IconButton(
                tooltip: BrandsKeys.edit.tr(context: context),
                onPressed: () => _edit(brand),
                icon: const Icon(Icons.edit_outlined),
              ),
              IconButton(
                tooltip: BrandsKeys.delete.tr(context: context),
                onPressed: () => _delete(brand),
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BrandEditor extends StatefulWidget {
  const _BrandEditor({required this.api, this.brand});

  final IApiClient api;
  final Brand? brand;

  @override
  State<_BrandEditor> createState() => _BrandEditorState();
}

class _BrandEditorState extends State<_BrandEditor> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _slug;
  late final TextEditingController _logo;
  late final TextEditingController _description;
  bool _active = true;
  bool _saving = false;
  bool _saveFailed = false;
  AppKey _saveErrorKey = BrandsKeys.saveError;

  @override
  void initState() {
    super.initState();
    final brand = widget.brand;
    _name = TextEditingController(text: brand?.name ?? '');
    _slug = TextEditingController(text: brand?.slug ?? '');
    _logo = TextEditingController(text: brand?.logo ?? '');
    _description = TextEditingController(text: brand?.description ?? '');
    _active = brand?.isActive ?? true;
  }

  @override
  void dispose() {
    _name.dispose();
    _slug.dispose();
    _logo.dispose();
    _description.dispose();
    super.dispose();
  }

  String _makeSlug(String value) => value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _saveFailed = false;
    });

    final body = {
      'name': _name.text.trim(),
      'slug': _slug.text.trim(),
      'logo': _logo.text.trim().isEmpty ? null : _logo.text.trim(),
      'description': _description.text.trim().isEmpty
          ? null
          : _description.text.trim(),
      'is_active': _active,
    };

    final result = widget.brand == null
        ? await widget.api.post<dynamic>(
            BrandsEndpoint.collection,
            data: body,
            options: Options(
              headers: {'Prefer': 'return=representation'},
            ),
          )
        : await widget.api.patch<dynamic>(
            AppEndpoint(
              '${BrandsEndpoint.collection.toStringPath()}?id=eq.${encodePathSegment(widget.brand!.id)}',
            ),
            data: body,
            options: Options(
              headers: {'Prefer': 'return=representation'},
            ),
          );

    if (!mounted) return;
    result.when(
      success: (_) => Navigator.of(context).pop(true),
      failure: (exception) => setState(() {
        _saving = false;
        _saveFailed = true;
        _saveErrorKey = exception.statusCode == 409
            ? BrandsKeys.duplicateError
            : BrandsKeys.saveError;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final slugIsEmpty = _slug.text.trim().isEmpty;
    return AlertDialog(
      title: AppText(widget.brand == null ? BrandsKeys.add : BrandsKeys.edit),
      content: SizedBox(
        width: 480,
        child: Form(
          key: _form,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_saveFailed) ...[
                  InlineBanner(
                    messageKey: _saveErrorKey,
                    variant: InlineBannerVariant.error,
                  ),
                  context.ui.spacing.gap(AppSpacing.sm),
                ],
                AppTextField(
                  controller: _name,
                  labelKey: BrandsKeys.name,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? BrandsKeys.required.tr(context: context)
                      : value.trim().length > 150
                          ? BrandsKeys.nameTooLong.tr(context: context)
                          : null,
                  onChanged: (value) {
                    if (_slug.text.isEmpty) {
                      final generated = _makeSlug(value);
                      if (generated.isNotEmpty) _slug.text = generated;
                    }
                    if (_saveFailed) setState(() => _saveFailed = false);
                  },
                ),
                context.ui.spacing.gap(AppSpacing.sm),
                AppTextField(
                  controller: _slug,
                  labelKey: BrandsKeys.slug,
                  validator: (value) {
                    final slug = value?.trim() ?? '';
                    if (slug.isEmpty) {
                      return BrandsKeys.slugRequired.tr(context: context);
                    }
                    if (!RegExp(r'^[a-z0-9]+(?:-[a-z0-9]+)*
                  onChanged: (_) {
                    if (_saveFailed) setState(() => _saveFailed = false);
                  },
                ),
                if (slugIsEmpty) ...[
                  context.ui.spacing.gap(AppSpacing.xs),
                  AppText(
                    BrandsKeys.slugHelp,
                    type: AppTextType.bodySmall,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ],
                context.ui.spacing.gap(AppSpacing.sm),
                AppTextField(
                  controller: _logo,
                  labelKey: BrandsKeys.logo,
                  keyboardType: TextInputType.url,
                  validator: (value) {
                    final url = value?.trim() ?? '';
                    if (url.isEmpty) return null;
                    final uri = Uri.tryParse(url);
                    if (uri == null ||
                        !uri.hasScheme ||
                        !['http', 'https'].contains(uri.scheme) ||
                        uri.host.isEmpty) {
                      return BrandsKeys.invalidLogoUrl.tr(context: context);
                    }
                    return null;
                  },
                  onChanged: (_) => setState(() {}),
                ),
                if (_logo.text.trim().isNotEmpty) ...[
                  context.ui.spacing.gap(AppSpacing.sm),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: AppImage.network(
                      _logo.text.trim(),
                      width: 76,
                      height: 76,
                      shape: AppImageShape.rounded,
                      borderRadius: 10,
                      semanticsLabel: BrandsKeys.logo.tr(context: context),
                    ),
                  ),
                ],
                context.ui.spacing.gap(AppSpacing.sm),
                AppTextField(
                  controller: _description,
                  labelKey: BrandsKeys.description,
                  maxLines: 3,
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: AppText(BrandsKeys.active),
                  value: _active,
                  onChanged: (value) => setState(() => _active = value),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context, false),
          child: AppText(BrandsKeys.cancel),
        ),
        AppButton(
          BrandsKeys.save,
          onPressed: _saving ? null : _save,
          isLoading: _saving,
        ),
      ],
    );
  }
}
).hasMatch(slug)) {
                      return BrandsKeys.slugFormat.tr(context: context);
                    }
                    return null;
                  },
                  onChanged: (_) {
                    if (_saveFailed) setState(() => _saveFailed = false);
                  },
                ),
                if (slugIsEmpty) ...[
                  context.ui.spacing.gap(AppSpacing.xs),
                  AppText(
                    BrandsKeys.slugHelp,
                    type: AppTextType.bodySmall,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ],
                context.ui.spacing.gap(AppSpacing.sm),
                AppTextField(
                  controller: _logo,
                  labelKey: BrandsKeys.logo,
                  keyboardType: TextInputType.url,
                  onChanged: (_) => setState(() {}),
                ),
                if (_logo.text.trim().isNotEmpty) ...[
                  context.ui.spacing.gap(AppSpacing.sm),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: AppImage.network(
                      _logo.text.trim(),
                      width: 76,
                      height: 76,
                      shape: AppImageShape.rounded,
                      borderRadius: 10,
                      semanticsLabel: BrandsKeys.logo.tr(context: context),
                    ),
                  ),
                ],
                context.ui.spacing.gap(AppSpacing.sm),
                AppTextField(
                  controller: _description,
                  labelKey: BrandsKeys.description,
                  maxLines: 3,
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: AppText(BrandsKeys.active),
                  value: _active,
                  onChanged: (value) => setState(() => _active = value),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context, false),
          child: AppText(BrandsKeys.cancel),
        ),
        AppButton(
          BrandsKeys.save,
          onPressed: _saving ? null : _save,
          isLoading: _saving,
        ),
      ],
    );
  }
}
