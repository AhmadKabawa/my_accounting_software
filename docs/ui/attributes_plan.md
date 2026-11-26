# CAT-08 Attributes — UI plan

- Screen: `/catalog/attributes`; `CrudListScreen` + feature-owned config; write permission `Permissions.masterData.manage`.
- List: server search by name/code; status, data type and filterable filters; stable name/id order; columns name+code, translated type, unit or option-set label, filterable state, linked product-type count, status.
- Stats: server total/active/inactive/filterable; stats errors do not block list.
- Editor: name ≤150, code ≤80, six translated data types, optional unit for number, required option set for option, filterable and active. `is_required`/`is_variant_option` stay hidden.
- Invariant: option_set_id is non-null iff data_type=option. Changing type clears unit_id and option_set_id. Unit and option-set lookup reads belong to Attributes; active choices for new assignments and current inactive choice retained during edit.
- Lock data_type and option_set_id when product_type_attributes or product_attribute_values count is positive/unknown; hide delete when used/unknown; FK 23503 offers deactivate.
- Duplicate=true, bulk=false, no details panel. Duplicate copies type/unit/set/filterable, resets active, and generates unique `-copy` code within 80 chars.
- Deactivation confirmation warns that ERP27 rejects new values; map ERP27/ERP28/23514/23505 to translated failure keys.
- Tests: model/count/lookup parsing; repository body/query/error and invariant tests; Cubit duplicate seed, filters, race/debounce and status; responsive RTL/LTR light/dark matrix.