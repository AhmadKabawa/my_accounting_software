class AttributeUnitChoice {
  const AttributeUnitChoice({
    required this.id,
    required this.name,
    required this.symbol,
    required this.isActive,
  });

  final int id;
  final String name;
  final String symbol;
  final bool isActive;
}

class AttributeOptionSetChoice {
  const AttributeOptionSetChoice({
    required this.id,
    required this.name,
    required this.code,
    required this.isActive,
  });

  final int id;
  final String name;
  final String code;
  final bool isActive;
}
