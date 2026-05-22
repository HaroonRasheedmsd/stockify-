class Customer {
  final int? id;
  final String name;
  final String phone;
  final String address;

  Customer({
    this.id,
    required this.name,
    required this.phone,
    required this.address,
  });

  Customer copyWith({
    int? id,
    String? name,
    String? phone,
    String? address,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'address': address,
    };
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'] as int?,
      name: map['name'] as String,
      phone: map['phone'] as String,
      address: map['address'] as String,
    );
  }
}
