class SpareItem {
  final String name;
  final String code;
  double quantity; // Change from int to double
  String usage;
  String where;

  SpareItem({
    required this.name,
    required this.code,
    required this.quantity, // Update constructor
    required this.usage,
    required this.where,
  });

  // Update the copyWith method
  SpareItem copyWith({
    String? name,
    String? code,
    double? quantity, // Change from int? to double?
    String? usage,
    String? where,
  }) {
    return SpareItem(
      name: name ?? this.name,
      code: code ?? this.code,
      quantity: quantity ?? this.quantity, // Update here
      usage: usage ?? this.usage,
      where: where ?? this.where,
    );
  }
}
