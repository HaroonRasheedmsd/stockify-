class Supplier {
  final int? id;
  final String name;
  final String phone;
  final String company;
  final String address;

  Supplier({
    this.id,
    required this.name,
    required this.phone,
    required this.company,
    required this.address,
  });

  Supplier copyWith({
    int? id,
    String? name,
    String? phone,
    String? company,
    String? address,
  }) {
    return Supplier(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      company: company ?? this.company,
      address: address ?? this.address,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'company': company,
      'address': address,
    };
  }

  factory Supplier.fromMap(Map<String, dynamic> map) {
    return Supplier(
      id: map['id'] as int?,
      name: map['name'] as String,
      phone: map['phone'] as String,
      company: map['company'] as String,
      address: map['address'] as String,
    );
  }
}
