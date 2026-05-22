class Sale {
  final int? id;
  final int? customerId;
  final String date;
  final double total;
  final double discount;
  final double tax;
  
  // Helper field (not stored in sales table directly but resolved in joins)
  final String? customerName;

  Sale({
    this.id,
    this.customerId,
    required this.date,
    required this.total,
    required this.discount,
    required this.tax,
    this.customerName,
  });

  Sale copyWith({
    int? id,
    int? customerId,
    String? date,
    double? total,
    double? discount,
    double? tax,
    String? customerName,
  }) {
    return Sale(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      date: date ?? this.date,
      total: total ?? this.total,
      discount: discount ?? this.discount,
      tax: tax ?? this.tax,
      customerName: customerName ?? this.customerName,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customer_id': customerId,
      'date': date,
      'total': total,
      'discount': discount,
      'tax': tax,
    };
  }

  factory Sale.fromMap(Map<String, dynamic> map, {String? customerName}) {
    return Sale(
      id: map['id'] as int?,
      customerId: map['customer_id'] as int?,
      date: map['date'] as String,
      total: (map['total'] as num).toDouble(),
      discount: (map['discount'] as num).toDouble(),
      tax: (map['tax'] as num).toDouble(),
      customerName: customerName ?? map['customer_name'] as String?,
    );
  }
}
