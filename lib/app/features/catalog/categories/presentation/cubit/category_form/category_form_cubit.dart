import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/validation/app_validator.dart';
import 'package:accounting_software/app/core/foundation/validation/slug.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/state_management/base_cubit.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/flash_messages.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/message_view_widgets.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/entity/category.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/entity/category_draft.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/entity/category_node.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/entity/category_tree.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/failures/category_failures.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/failures/category_failure_keys.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/usecase/create_category_use_case.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/usecase/update_category_use_case.dart';
import 'package:accounting_software/app/features/catalog/categories/presentation/cubit/category_form/category_form_effect.dart';
import 'package:accounting_software/app/features/catalog/categories/presentation/cubit/category_form/category_form_state.dart';
import 'package:accounting_software/app/features/catalog/categories/presentation/localization/categories_keys.dart';

class CategoryFormCubit
    extends BaseCubit<CategoryFormState, CategoryFormEffect> {
  CategoryFormCubit({
    required CreateCategoryUseCase createCategory,
    required UpdateCategoryUseCase updateCategory,
    required FlashMessages flashMessages,
    Category? category,
    CategoryTree? tree,
    int? initialParentId,
  }) : _createCategory = createCategory,
       _updateCategory = updateCategory,
       _flashMessages = flashMessages,
       _category = category,
       _tree = tree,
       _initialParentId = initialParentId ?? category?.parentId,
       super(
         CategoryFormState(
           parentId: initialParentId ?? category?.parentId,
           name: category?.name ?? '',
           slug: category?.slug ?? '',
           description: category?.description ?? '',
           image: category?.image ?? '',
           sortOrder: '${category?.sortOrder ?? 0}',
           slugManuallyEdited: category != null,
           isActive: category?.isActive ?? true,
         ),
       ) {
    _initialState = state;
    _revalidate();
  }

  final CreateCategoryUseCase _createCategory;
  final UpdateCategoryUseCase _updateCategory;
  final FlashMessages _flashMessages;
  final Category? _category;
  final CategoryTree? _tree;
  final int? _initialParentId;
  late final CategoryFormState _initialState;

  CategoryTree? get tree => _tree;

  /// Used by CrudEditorDialog in addition to its text-controller dirty check.
  bool get parentChanged => state.parentId != _initialParentId;

  bool get activeChanged => state.isActive != (_category?.isActive ?? true);

  /// Restores the feature-owned values when the shared editor resets.
  void reset() {
    if (isClosed) return;
    emit(_initialState.copyWith(errors: _validate(_initialState)));
  }

  /// Available parent rows with full paths; the edited category and its
  /// descendants are excluded to prevent a local cycle.
  late final List<CategoryNode> _parentOptions = _buildParentOptions();

  List<CategoryNode> get parentOptions => _parentOptions;

  List<CategoryNode> _buildParentOptions() {
    final tree = _tree;
    if (tree == null) return const [];
    final excluded = _category == null
        ? const <int>{}
        : {...tree.descendantIds(_category.id), _category.id};
    return tree
        .visible(expandedIds: tree.parentIds)
        .where((node) => !excluded.contains(node.id))
        .toList(growable: false);
  }

  String parentOptionLabel(CategoryNode node) =>
      [...node.ancestors, node.category.name].join(' › ');

  void setParent(int? parentId) {
    if (parentId != null && _category != null) {
      if (parentId == _category.id ||
          (_tree?.descendantIds(_category.id).contains(parentId) ?? false)) {
        return;
      }
    }
    _emit(state.copyWith(parentId: parentId, clearParent: parentId == null));
  }

  void nameChanged(String value) {
    final slug = state.slugManuallyEdited ? state.slug : Slug.from(value);
    _emit(state.copyWith(name: value, slug: slug));
  }

  void slugChanged(String value) =>
      _emit(state.copyWith(slug: value, slugManuallyEdited: true));

  void regenerateSlug() => _emit(
    state.copyWith(slug: Slug.from(state.name), slugManuallyEdited: false),
  );

  void descriptionChanged(String value) =>
      _emit(state.copyWith(description: value));

  void imageChanged(String value) => _emit(state.copyWith(image: value));

  void activeChanged(bool value) => _emit(state.copyWith(isActive: value));

  void sortOrderChanged(String value) =>
      _emit(state.copyWith(sortOrder: value));

  void _emit(CategoryFormState next) {
    if (isClosed) return;
    emit(next.copyWith(errors: _validate(next)));
  }

  void _revalidate() => emit(state.copyWith(errors: _validate(state)));

  Map<String, String?> _validate(CategoryFormState value) => {
    'name': AppValidator.validate(
      value.name,
      [ValidationRule.required, ValidationRule.maxLength],
      params: {ValidationRule.maxLength: 150},
      customKeys: {
        ValidationRule.required: CategoriesKeys.required,
        ValidationRule.maxLength: CategoriesKeys.nameTooLong,
      },
    ),
    'slug': AppValidator.validate(
      value.slug,
      [
        ValidationRule.required,
        ValidationRule.maxLength,
        ValidationRule.pattern,
      ],
      params: {
        ValidationRule.maxLength: 150,
        ValidationRule.pattern: Slug.pattern,
      },
      customKeys: {
        ValidationRule.required: CategoriesKeys.required,
        ValidationRule.maxLength: CategoriesKeys.slugTooLong,
        ValidationRule.pattern: CategoriesKeys.slugFormat,
      },
    ),
    'image': value.image.length > 500 ? CategoriesKeys.imageTooLong.tr() : null,
    'sortOrder': value.sortOrder.trim().isEmpty
        ? null
        : AppValidator.validate(
            value.sortOrder,
            [ValidationRule.pattern],
            params: {ValidationRule.pattern: RegExp(r'^\d+$')},
            customKeys: {
              ValidationRule.pattern: CategoriesKeys.sortOrderFormat,
            },
          ),
  };

  Future<void> save() async {
    if (state.saving || isClosed) return;
    final errors = _validate(state);
    if (errors.values.any((message) => message != null)) {
      emit(state.copyWith(errors: errors));
      return;
    }

    emit(state.copyWith(saving: true, errors: errors));
    final value = state;
    final draft = CategoryDraft(
      parentId: value.parentId,
      name: value.name.trim(),
      slug: value.slug.trim(),
      description: value.description.trim().isEmpty
          ? null
          : value.description.trim(),
      image: value.image.trim().isEmpty ? null : value.image.trim(),
      sortOrder: int.tryParse(value.sortOrder.trim()) ?? 0,
      isActive: _category == null || value.isActive != _category!.isActive
          ? value.isActive
          : null,
    );
    final result = _category == null
        ? await _createCategory(draft)
        : await _updateCategory(
            UpdateCategoryParams(id: _category.id, draft: draft),
          );
    if (isClosed) return;

    result.fold(
      (failure) {
        final messageKey = _messageKey(failure);
        final fieldErrors = _validate(state);
        if (failure is CategorySlugTakenFailure) {
          fieldErrors['slug'] = CategoryFailureKeys.slugTaken.tr();
        }
        emit(state.copyWith(saving: false, errors: fieldErrors));
        emitEffect(CategorySaveFailedEffect(messageKey));
      },
      (category) {
        emitEffect(CategorySavedEffect(category));
        _flashMessages.post(CategoriesKeys.saved, MessageType.success);
        emit(state.copyWith(saving: false));
      },
    );
  }

  AppKey _messageKey(Failure failure) => switch (failure) {
    CategorySlugTakenFailure() => CategoryFailureKeys.slugTaken,
    CategoryInvalidParentFailure() => CategoryFailureKeys.invalidParent,
    _ => failure.messageKey,
  };
}
