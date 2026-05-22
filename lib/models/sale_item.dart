class SaleItem {
  final int? id;
  final int? saleId;
  final int productId;
  final int quantity;
  final double price;

  // Helper fields resolved via joins
  final String? productName;

  SaleItem({
    this.id,
    this.saleId,
    required this.productId,
    required this.quantity,
    required this.price,
    this.productName,
  });

  SaleItem copyWith({
    int? id,
    int? saleId,
    int? productId,
    int? quantity,
    double? price,
    String? productName,
  }) {
    return SaleItem(
      id: id ?? this.id,
      saleId: saleId ?? this.saleId,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      productName: productName ?? this.productName,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sale_id': saleId,
      'product_id': productId,
      'quantity': quantity,
      'price': price,
    };
  }

  factory SaleItem.fromMap(Map<String, dynamic> map, {String? productName}) {
    return SaleItem(
      id: map['id'] as int?,
      saleId: map['sale_id'] as int?,
      productId: map['product_id'] as int,
      quantity: map['quantity'] as int,
      price: (map['price'] as num).toDouble(),
      productName: productName ?? map['product_name'] as String?,
    );
  }
}
