class Purchase {
  final int? id;
  final int supplierId;
  final String date;
  final double total;

  // Helper fields resolved via joins
  final String? supplierName;

  Purchase({
    this.id,
    required this.supplierId,
    required this.date,
    required this.total,
    this.supplierName,
  });

  Purchase copyWith({
    int? id,
    int? supplierId,
    String? date,
    double? total,
    String? supplierName,
  }) {
    return Purchase(
      id: id ?? this.id,
      supplierId: supplierId ?? this.supplierId,
      date: date ?? this.date,
      total: total ?? this.total,
      supplierName: supplierName ?? this.supplierName,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'supplier_id': supplierId,
      'date': date,
      'total': total,
    };
  }

  factory Purchase.fromMap(Map<String, dynamic> map, {String? supplierName}) {
    return Purchase(
      id: map['id'] as int?,
      supplierId: map['supplier_id'] as int,
      date: map['date'] as String,
      total: (map['total'] as num).toDouble(),
      supplierName: supplierName ?? map['supplier_name'] as String?,
    );
  }
}
