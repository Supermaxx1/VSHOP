import 'package:cloud_firestore/cloud_firestore.dart';

class Customer {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String address;
  final String city;
  final String state;
  final String pincode;
  final double totalPurchases;
  final int totalOrders;
  final DateTime createdAt;
  final DateTime lastPurchase;
  final bool isActive;
  final String customerType; // 'regular', 'vip', 'wholesale'
  final double creditLimit;
  final double outstandingAmount;
  final String? notes;

  Customer({
    required this.id,
    required this.name,
    required this.phone,
    this.email = '',
    this.address = '',
    this.city = '',
    this.state = '',
    this.pincode = '',
    this.totalPurchases = 0.0,
    this.totalOrders = 0,
    required this.createdAt,
    DateTime? lastPurchase,
    this.isActive = true,
    this.customerType = 'regular',
    this.creditLimit = 0.0,
    this.outstandingAmount = 0.0,
    this.notes,
  }) : lastPurchase = lastPurchase ?? createdAt;

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'city': city,
      'state': state,
      'pincode': pincode,
      'totalPurchases': totalPurchases,
      'totalOrders': totalOrders,
      'createdAt': createdAt.toIso8601String(),
      'lastPurchase': lastPurchase.toIso8601String(),
      'isActive': isActive,
      'customerType': customerType,
      'creditLimit': creditLimit,
      'outstandingAmount': outstandingAmount,
      'notes': notes,
    };
  }

  // Create from Map (Firestore data)
  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      address: map['address'] ?? '',
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      pincode: map['pincode'] ?? '',
      totalPurchases: (map['totalPurchases'] ?? 0).toDouble(),
      totalOrders: map['totalOrders'] ?? 0,
      createdAt: DateTime.parse(map['createdAt']),
      lastPurchase: DateTime.parse(map['lastPurchase']),
      isActive: map['isActive'] ?? true,
      customerType: map['customerType'] ?? 'regular',
      creditLimit: (map['creditLimit'] ?? 0).toDouble(),
      outstandingAmount: (map['outstandingAmount'] ?? 0).toDouble(),
      notes: map['notes'],
    );
  }

  // Create from Firestore Document
  factory Customer.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data['id'] = doc.id;
    return Customer.fromMap(data);
  }

  // Create a copy with updated fields
  Customer copyWith({
    String? name,
    String? phone,
    String? email,
    String? address,
    String? city,
    String? state,
    String? pincode,
    double? totalPurchases,
    int? totalOrders,
    DateTime? lastPurchase,
    bool? isActive,
    String? customerType,
    double? creditLimit,
    double? outstandingAmount,
    String? notes,
  }) {
    return Customer(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      totalPurchases: totalPurchases ?? this.totalPurchases,
      totalOrders: totalOrders ?? this.totalOrders,
      createdAt: createdAt,
      lastPurchase: lastPurchase ?? this.lastPurchase,
      isActive: isActive ?? this.isActive,
      customerType: customerType ?? this.customerType,
      creditLimit: creditLimit ?? this.creditLimit,
      outstandingAmount: outstandingAmount ?? this.outstandingAmount,
      notes: notes ?? this.notes,
    );
  }

  // Helper getters
  bool get isVip => customerType == 'vip';
  bool get isWholesale => customerType == 'wholesale';
  bool get hasOutstanding => outstandingAmount > 0;
  bool get canPurchaseOnCredit => creditLimit > outstandingAmount;
  double get availableCredit => creditLimit - outstandingAmount;

  // Get customer loyalty level based on purchases
  String get loyaltyLevel {
    if (totalPurchases >= 100000) return 'Platinum';
    if (totalPurchases >= 50000) return 'Gold';
    if (totalPurchases >= 25000) return 'Silver';
    if (totalPurchases >= 10000) return 'Bronze';
    return 'Regular';
  }

  // Get average order value
  double get averageOrderValue {
    return totalOrders > 0 ? totalPurchases / totalOrders : 0.0;
  }

  // Check if customer is new (created within last 30 days)
  bool get isNewCustomer {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    return createdAt.isAfter(thirtyDaysAgo);
  }

  // Get full address string
  String get fullAddress {
    List<String> addressParts = [];
    if (address.isNotEmpty) addressParts.add(address);
    if (city.isNotEmpty) addressParts.add(city);
    if (state.isNotEmpty) addressParts.add(state);
    if (pincode.isNotEmpty) addressParts.add(pincode);
    return addressParts.join(', ');
  }

  // Get display name with customer type
  String get displayName {
    String suffix = '';
    if (isVip) suffix = ' (VIP)';
    if (isWholesale) suffix = ' (Wholesale)';
    return name + suffix;
  }

  // Validation methods
  bool get hasValidPhone {
    return phone.isNotEmpty && phone.length >= 10;
  }

  bool get hasValidEmail {
    return email.isEmpty ||
        RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Search helper - returns true if search term matches customer data
  bool matchesSearch(String searchTerm) {
    final term = searchTerm.toLowerCase();
    return name.toLowerCase().contains(term) ||
        phone.contains(term) ||
        email.toLowerCase().contains(term) ||
        address.toLowerCase().contains(term) ||
        city.toLowerCase().contains(term);
  }

  @override
  String toString() {
    return 'Customer{id: $id, name: $name, phone: $phone, totalPurchases: $totalPurchases}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Customer && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Customer Type Enum for better type safety
enum CustomerType {
  regular('Regular'),
  vip('VIP'),
  wholesale('Wholesale');

  const CustomerType(this.displayName);
  final String displayName;
}

// Customer Statistics class for analytics
class CustomerStatistics {
  final int totalCustomers;
  final int activeCustomers;
  final int newCustomersThisMonth;
  final int vipCustomers;
  final int wholesaleCustomers;
  final double totalCustomerValue;
  final double averageCustomerValue;

  CustomerStatistics({
    required this.totalCustomers,
    required this.activeCustomers,
    required this.newCustomersThisMonth,
    required this.vipCustomers,
    required this.wholesaleCustomers,
    required this.totalCustomerValue,
    required this.averageCustomerValue,
  });
}
