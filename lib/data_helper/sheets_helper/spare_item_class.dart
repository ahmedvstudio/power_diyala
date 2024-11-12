class SpareItem {
  final String name;
  final String code;
  int quantity;
  String usage;
  String where;

  SpareItem({
    required this.name,
    required this.code,
    required this.quantity,
    required this.usage,
    required this.where,
  });

  // Add a copyWith method
  SpareItem copyWith({
    String? name,
    String? code,
    int? quantity,
    String? usage,
    String? where,
  }) {
    return SpareItem(
      name: name ?? this.name,
      code: code ?? this.code,
      quantity: quantity ?? this.quantity,
      usage: usage ?? this.usage,
      where: where ?? this.where,
    );
  }
}
