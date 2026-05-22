class InventoryTransaction {
  final int? id;
  final int productId;
  final String type; // 'IN' or 'OUT'
  final int quantity;
  final String date;
  final String reason; // 'Restock', 'Sale', 'Manual', etc.

  // Helper fields resolved via joins
  final String? productName;

  InventoryTransaction({
    this.id,
    required this.productId,
    required this.type,
    required this.quantity,
    required this.date,
    required this.reason,
    this.productName,
  });

  InventoryTransaction copyWith({
    int? id,
    int? productId,
    String? type,
    int? quantity,
    String? date,
    String? reason,
    String? productName,
  }) {
    return InventoryTransaction(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      type: type ?? this.type,
      quantity: quantity ?? this.quantity,
      date: date ?? this.date,
      reason: reason ?? this.reason,
      productName: productName ?? this.productName,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_id': productId,
      'type': type,
      'quantity': quantity,
      'date': date,
      'reason': reason,
    };
  }

  factory InventoryTransaction.fromMap(Map<String, dynamic> map, {String? productName}) {
    return InventoryTransaction(
      id: map['id'] as int?,
      productId: map['product_id'] as int,
      type: map['type'] as String,
      quantity: map['quantity'] as int,
      date: map['date'] as String,
      reason: map['reason'] as String,
      productName: productName ?? map['product_name'] as String?,
    );
  }
}
