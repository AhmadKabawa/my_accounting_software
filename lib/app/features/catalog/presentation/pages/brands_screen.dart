import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/access/permission_gate/permission_gate.dart';
import 'package:accounting_software/app/core/access/permissions.dart';
import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/core/foundation/config/app_config.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/core/localization/keys/catalog_ui_keys.dart';
import 'package:accounting_software/app/core/network/api_client_interface.dart';
import 'package:accounting_software/app/core/network/api_end_points.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icons.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_table/data_table.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_filter_bar/filter_bar.dart';
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
    setState(() { _loading = true; _error = null; });
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
      },
    );
    if (!mounted) return;
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
    if (saved == true) _load();
  }

  Future<void> _delete(Brand brand) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        content: Text(BrandsKeys.confirmDelete.ar),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(BrandsKeys.cancel.ar)),
          TextButton(onPressed: () => Navigator.pop(dialogContext, true), child: Text(BrandsKeys.delete.ar)),
        ],
      ),
    );
    if (yes != true) return;
    final result = await _api.delete(
      AppEndpoint('${BrandsEndpoint.collection.toStringPath()}?id=eq.${encodePathSegment(brand.id)}'),
      options: Options(headers: {'Prefer': 'return=minimal'}),
    );
    if (!mounted) return;
    result.when(success: (_) => _load(), failure: (_) => setState(() => _error = 'load'));
  }

  @override
  Widget build(BuildContext context) => ListPageTemplate(
      titleKey: BrandsKeys.title,
      count: _total,
      primaryAction: PermissionGate(
        permission: Permissions.masterData.manage,
        child: AppButton(BrandsKeys.add, icon: AppIcons.info, onPressed: () => _edit()),
      ),
      filterBar: FilterBar(
        searchController: _search,
        searchHintKey: BrandsKeys.searchHint,
        activeFilters: const [],
        onClearAll: () { _search.clear(); _page = 1; _load(); },
        onSearchChanged: (_) { _page = 1; _load(); },
      ),
      state: _loading ? AppPageState.loading : _error != null ? AppPageState.error : _brands.isEmpty ? AppPageState.empty : AppPageState.content,
      dataTable: AppDataTable<Brand>(
        columns: [
          DataTableColumn(labelKey: BrandsKeys.name, sortKey: 'name', priority: DataTableColumnPriority.primary, cellBuilder: (_, b) => AppText.raw(b.name)),
          DataTableColumn(labelKey: BrandsKeys.slug, sortKey: 'slug', cellBuilder: (_, b) => AppText.raw(b.slug)),
          DataTableColumn(labelKey: BrandsKeys.status, cellBuilder: (_, b) => AppText(b.isActive ? BrandsKeys.active : BrandsKeys.inactive)),
        ],
        rows: _brands,
        rowId: (b) => b.id,
        loading: _loading,
        errorKey: _error == null ? null : BrandsKeys.loadError,
        onRetry: _load,
        totalCount: _total,
        page: _page,
        pageSize: AppConfig.defaultPageSize,
        hasMore: _page * AppConfig.defaultPageSize < _total,
        onPageChanged: (page) { setState(() => _page = page); _load(); },
        rowActionsBuilder: (_, b) => PermissionGate(
          permission: Permissions.masterData.manage,
          child: Wrap(
          spacing: 4,
          children: [
            IconButton(tooltip: BrandsKeys.edit.ar, onPressed: () => _edit(b), icon: const Icon(Icons.edit_outlined)),
            IconButton(tooltip: BrandsKeys.delete.ar, onPressed: () => _delete(b), icon: const Icon(Icons.delete_outline)),
          ],
        ),
        ),
      ),
    );
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

  @override
  void initState() {
    super.initState();
    final b = widget.brand;
    _name = TextEditingController(text: b?.name ?? '');
    _slug = TextEditingController(text: b?.slug ?? '');
    _logo = TextEditingController(text: b?.logo ?? '');
    _description = TextEditingController(text: b?.description ?? '');
    _active = b?.isActive ?? true;
  }

  @override
  void dispose() {
    _name.dispose(); _slug.dispose(); _logo.dispose(); _description.dispose();
    super.dispose();
  }

  String _makeSlug(String value) => value.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-').replaceAll(RegExp(r'^-|-$'), '');

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    final body = {
      'name': _name.text.trim(),
      'slug': _slug.text.trim().isEmpty ? _makeSlug(_name.text) : _slug.text.trim(),
      'logo': _logo.text.trim().isEmpty ? null : _logo.text.trim(),
      'description': _description.text.trim().isEmpty ? null : _description.text.trim(),
      'is_active': _active,
    };
    final result = widget.brand == null
      ? await widget.api.post<dynamic>(BrandsEndpoint.collection, data: body, options: Options(headers: {'Prefer': 'return=representation'}))
      : await widget.api.patch<dynamic>(
          AppEndpoint('${BrandsEndpoint.collection.toStringPath()}?id=eq.${encodePathSegment(widget.brand!.id)}'),
          data: body,
          options: Options(headers: {'Prefer': 'return=representation'}),
        );
    if (!mounted) return;
    result.when(
      success: (_) => Navigator.of(context).pop(true),
      failure: (_) => setState(() => _saving = false),
    );
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.brand == null ? BrandsKeys.add.ar : BrandsKeys.edit.ar),
    content: SizedBox(
      width: 480,
      child: Form(
        key: _form,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(controller: _name, labelKey: BrandsKeys.name, validator: (v) => (v == null || v.trim().isEmpty) ? BrandsKeys.required.ar : null, onChanged: (v) { if (_slug.text.isEmpty) _slug.text = _makeSlug(v); }),
              context.ui.spacing.gap(AppSpacing.sm),
              AppTextField(controller: _slug, labelKey: BrandsKeys.slug),
              context.ui.spacing.gap(AppSpacing.sm),
              AppTextField(controller: _logo, labelKey: BrandsKeys.logo, keyboardType: TextInputType.url),
              context.ui.spacing.gap(AppSpacing.sm),
              AppTextField(controller: _description, labelKey: BrandsKeys.description, maxLines: 3),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(BrandsKeys.active.ar),
                value: _active,
                onChanged: (v) => setState(() => _active = v),
              ),
            ],
          ),
        ),
      ),
    ),
    actions: [
      TextButton(onPressed: _saving ? null : () => Navigator.pop(context, false), child: Text(BrandsKeys.cancel.ar)),
      AppButton(BrandsKeys.save, onPressed: _saving ? null : _save, isLoading: _saving),
    ],
  );
}
