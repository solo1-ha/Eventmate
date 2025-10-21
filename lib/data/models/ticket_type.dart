/// Modèle pour un type de ticket
class TicketType {
  final String type;
  final double price;

  const TicketType({
    required this.type,
    required this.price,
  });

  /// Création depuis Map
  factory TicketType.fromMap(Map<String, dynamic> map) {
    return TicketType(
      type: map['type'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
    );
  }

  /// Conversion vers Map
  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'price': price,
    };
  }

  /// Prix formaté
  String get formattedPrice => '${price.toStringAsFixed(0)} GNF';

  @override
  String toString() => 'TicketType(type: $type, price: $price)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TicketType && other.type == type && other.price == price;
  }

  @override
  int get hashCode => type.hashCode ^ price.hashCode;

  TicketType copyWith({
    String? type,
    double? price,
  }) {
    return TicketType(
      type: type ?? this.type,
      price: price ?? this.price,
    );
  }
}
