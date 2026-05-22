class Product {
  final int? id;
  final String name;
  final String barcode;
  final String category;
  final double purchasePrice;
  final double salePrice;
  final int quantity;
  final String rackLocation;
  final String description;

  Product({
    this.id,
    required this.name,
    required this.barcode,
    required this.category,
    required this.purchasePrice,
    required this.salePrice,
    required this.quantity,
    required this.rackLocation,
    required this.description,
  });

  Product copyWith({
    int? id,
    String? name,
    String? barcode,
    String? category,
    double? purchasePrice,
    double? salePrice,
    int? quantity,
    String? rackLocation,
    String? description,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      barcode: barcode ?? this.barcode,
      category: category ?? this.category,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      salePrice: salePrice ?? this.salePrice,
      quantity: quantity ?? this.quantity,
      rackLocation: rackLocation ?? this.rackLocation,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'barcode': barcode,
      'category': category,
      'purchase_price': purchasePrice,
      'sale_price': salePrice,
      'quantity': quantity,
      'rack_location': rackLocation,
      'description': description,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as int?,
      name: map['name'] as String,
      barcode: map['barcode'] as String,
      category: map['category'] as String,
      purchasePrice: (map['purchase_price'] as num).toDouble(),
      salePrice: (map['sale_price'] as num).toDouble(),
      quantity: map['quantity'] as int,
      rackLocation: map['rack_location'] as String,
      description: map['description'] as String,
    );
  }
}
