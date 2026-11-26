# CAT-08 — Integration impact

## 1. Existing consumers
- Units are referenced by product_variants.unit_id and attributes.unit_id.
- Option sets are referenced by attributes.option_set_id and product_type_option_sets.
- Options are referenced by product_option_values and variant_option_values.
- Attributes are referenced by product_type_attributes and product_attribute_values.

## 2. Navigation
- Add Units, Option Sets, and Attributes as destinations within the existing Catalog shell branch.
- Keep the Catalog hub as the entry point; do not add a second shell tab.
- Route names and paths must be declared in each feature's routes file, included in route_registry, protected by authenticated route guards, and wired in app_go_router.
- The hub cards must navigate to the corresponding feature routes.

## 3. Authorization
- UI access is a presentation gate only. All mutations and reads remain protected by backend permissions and RLS.
- Use the existing master-data management permission; do not infer permissions from role labels.
- Add route guards for authenticated navigation. Do not treat route hiding as authorization.

## 4. Cross-feature selection contracts
- Unit picker consumers need active units only, with stable IDs and labels; CAT-08 owns unit CRUD, not product variant behavior.
- Attribute editor may query units and option sets through the feature's existing read-only picker data sources; do not import another feature's data or presentation layer.
- Attribute type=option requires option_set_id; all other types must clear and omit option_set_id.
- Attribute type=number may show the unit picker; other types clear/omit unit_id unless the approved API contract explicitly allows it.

## 5. Destructive and schema-sensitive behavior
- Unit delete is blocked when product_variants or attributes reference it; unknown counts are treated as unsafe.
- Option-set delete is blocked when it has options or product type references; option delete is not offered until option-value usage is verified.
- Attribute delete is blocked when product_type_attributes reference it.
- Lock selection_type/data_type after usage to protect stored values. Backend constraints remain authoritative.
- Map 23503 to in-use feedback, 23505 to duplicate feedback, 23514 to invalid relationship/type feedback; preserve the underlying Failure contract.

## 6. API/backend dependencies
- Confirm embedded relationship counts for units, option_sets and attributes under RLS.
- Confirm exact PostgREST payload and response shapes for nested options and picker lookups.
- Confirm stable error codes/constraints for duplicate, FK usage and ERP27/ERP28 business rules.
- Confirm whether option deletion can safely query all value tables or must remain unavailable.
- Add server-side aggregate endpoints/RPC only if the current API cannot provide complete counts independently of pagination.

## 7. Tests required
- Repository request body excludes unit conversion fields.
- Model mapping handles null/unknown usage counts conservatively.
- Option order is stable by sort_order then name.
- Attribute option_set_id invariant is enforced in both directions.
- Changing attribute type clears incompatible unit/option-set selections.
- Used or unknown-usage records cannot be destructively deleted.
- Routes resolve inside the Catalog branch and remain protected.
- Responsive widget tests cover 360/600/900/1200 widths, RTL/LTR and light/dark themes.
