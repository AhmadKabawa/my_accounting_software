import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/access/extensions/access_extension.dart';
import 'package:accounting_software/app/core/localization/keys/common_keys.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/engine/screen_engine.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_table/data_table.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_data_section.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_list_config.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_labels.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/entity/category_list_query.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/entity/category_node.dart';
import 'package:accounting_software/app/features/catalog/categories/presentation/cubit/categories_list/categories_list_cubit.dart';
import 'package:accounting_software/app/features/catalog/categories/presentation/dialogs/category_editor_launcher.dart';
import 'package:accounting_software/app/features/catalog/categories/presentation/localization/categories_keys.dart';
import 'package:accounting_software/app/features/catalog/categories/presentation/widgets/categories_flat_results_note.dart';
import 'package:accounting_software/app/features/catalog/categories/presentation/widgets/categories_tree_toolbar.dart';
import 'package:accounting_software/app/features/catalog/categories/presentation/widgets/category_card.dart';
import 'package:accounting_software/app/features/catalog/categories/presentation/widgets/category_details_panel.dart';
import 'package:accounting_software/app/features/catalog/categories/presentation/widgets/category_identity.dart';
import 'package:accounting_software/app/features/catalog/categories/presentation/widgets/category_status_badge.dart';

const categoriesCrudLabels = CrudLabels(
  edit: CategoriesKeys.edit,
  duplicate: CategoriesKeys.duplicate,
  delete: CategoriesKeys.delete,
  activate: CategoriesKeys.activate,
  deactivate: CategoriesKeys.deactivate,
  deleteConfirmationTitle: CategoriesKeys.delete,
  deleteConfirmationMessage: CategoriesKeys.deleteMessage,
  deactivateConfirmationTitle: CategoriesKeys.deactivateTitle,
  deactivateConfirmationMessage: CategoriesKeys.deactivateMessage,
);

Widget buildCategoriesDataSection(
  CrudDataContext<CategoryNode, CategoryListQuery, CategoriesListCubit> data,
) => Builder(
  builder: (context) {
    final flows = data.flows;
    final canManage = context.can(data.permission) && flows != null;

    Widget buildPanel(
      CategoryNode node, {
      required double width,
      required VoidCallback close,
      required ValueChanged<int> selectChild,
    }) {
      void addChild() {
        if (!canManage) return;
        showCategoryEditor(
          context,
          tree: data.cubit.tree!,
          initialParentId: node.id,
        ).then((saved) {
          if (saved == true && context.mounted) {
            flows.onSaved(data.cubit, isNew: true);
          }
        });
      }

      return CategoryDetailsPanel(
        node: node,
        tree: data.cubit.tree,
        width: width,
        canManage: canManage,
        onClose: close,
        onSelectChild: selectChild,
        onEdit: canManage ? () => flows.edit(context, item: node) : null,
        onAddChild: canManage ? addChild : null,
        onToggleStatus: canManage
            ? () => flows.toggleStatus(context, node)
            : null,
        onDuplicate: canManage
            ? () => flows.edit(context, item: node, duplicate: true)
            : null,
        onDelete: canManage && node.canDelete
            ? () {
                flows!
                    .deleteItem(context, node)
                    .whenComplete(() => data.cubit.selectDetails(null));
              }
            : null,
      );
    }

    void openMobileDetails(CategoryNode initial) {
      final tree = data.cubit.tree;
      if (tree == null) return;
      var current = initial;
      final allNodes = tree.visible(expandedIds: tree.parentIds);
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (sheetContext) => StatefulBuilder(
          builder: (sheetContext, setSheetState) => SingleChildScrollView(
            child: buildPanel(
              current,
              width: MediaQuery.sizeOf(sheetContext).width,
              close: () => Navigator.of(sheetContext).pop(),
              selectChild: (id) {
                final next = allNodes.firstWhere(
                  (candidate) => candidate.id == id,
                );
                setSheetState(() => current = next);
              },
            ),
          ),
        ),
      );
    }

    final section =
        CrudDataSection<CategoryNode, CategoryListQuery, CategoriesListCubit>(
          data: data,
          columns: [
            DataTableColumn<CategoryNode>(
              labelKey: CategoriesKeys.categoryName,
              priority: DataTableColumnPriority.primary,
              flex: 3,
              cellBuilder: (_, node) => CategoryIdentity(
                node: node,
                onToggle: node.hasChildren
                    ? () => data.cubit.toggleExpanded(node.id)
                    : null,
                showPathForDeep: true,
              ),
            ),
            DataTableColumn<CategoryNode>(
              labelKey: CategoriesKeys.description,
              priority: DataTableColumnPriority.secondary,
              flex: 2,
              cellBuilder: (cellContext, node) => AppText.raw(
                node.category.description?.trim() ?? '',
                color: cellContext.ui.theme.colors.onSurfaceVariant,
                maxLines: 2,
              ),
            ),
            DataTableColumn<CategoryNode>(
              labelKey: CategoriesKeys.products,
              numeric: true,
              priority: DataTableColumnPriority.secondary,
              cellBuilder: (_, node) => node.category.productCount == null
                  ? const AppText(CommonKeys.noValue)
                  : AppText.raw(node.category.productCount.toString()),
            ),
            DataTableColumn<CategoryNode>(
              labelKey: CategoriesKeys.updatedAt,
              priority: DataTableColumnPriority.secondary,
              cellBuilder: (cellContext, node) =>
                  node.category.updatedAt == null
                  ? const AppText(CommonKeys.noValue)
                  : AppText.raw(
                      MaterialLocalizations.of(
                        cellContext,
                      ).formatShortDate(node.category.updatedAt!),
                    ),
            ),
          ],
          labels: categoriesCrudLabels,
          statusColumn: CrudStatusColumnConfig<CategoryNode>(
            labelKey: CategoriesKeys.status,
            isActive: (node) => node.category.isActive,
            badgeBuilder: (_, node) => CategoryStatusBadge(node.category),
          ),
          cardBuilder: (_, node) => CategoryCard(
            node: node,
            onToggle: node.hasChildren
                ? () => data.cubit.toggleExpanded(node.id)
                : null,
          ),
          gridBuilder: (_, node) => CategoryCard(node: node),
          onRowTap: (node) {
            if (ScreenEngine.isDesktop(context)) {
              data.cubit.selectDetails(node.id);
            } else {
              openMobileDetails(node);
            }
          },
          icon: AppIcons.catalog,
          emptyTitleKey: CategoriesKeys.empty,
          emptyDescriptionKey: CategoriesKeys.emptyDescription,
          noResultsTitleKey: CategoriesKeys.noResults,
          noResultsDescriptionKey: CategoriesKeys.noResultsDescription,
        );

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CategoriesTreeToolbar(
          enabled: data.cubit.tree != null,
          onExpandAll: data.cubit.expandAll,
          onCollapseAll: data.cubit.collapseAll,
        ),
        if (data.query.hasActiveFilters) const CategoriesFlatResultsNote(),
        section,
      ],
    );

    if (!ScreenEngine.isDesktop(context)) return content;
    return ValueListenableBuilder<int?>(
      valueListenable: data.cubit.selectedId,
      builder: (context, selectedId, _) {
        CategoryNode? selectedNode;
        for (final row in data.rows) {
          if (row.id == selectedId) {
            selectedNode = row;
            break;
          }
        }
        if (selectedId == null ||
            selectedNode == null ||
            data.cubit.tree == null) {
          return content;
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: content),
            buildPanel(
              selectedNode,
              width: AppComponentSize.cardWidth.of(context),
              close: () => data.cubit.selectDetails(null),
              selectChild: data.cubit.selectDetails,
            ),
          ],
        );
      },
    );
  },
);
