import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final String category;
  final double price;
  final double costPrice;
  final int quantity;
  final int minStock;
  final String barcode;
  final String imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final String unit;
  final double gst;

  Product({
    required this.id,
    required this.name,
    this.description = '',
    required this.category,
    required this.price,
    required this.costPrice,
    required this.quantity,
    this.minStock = 5,
    this.barcode = '',
    this.imageUrl = '',
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.unit = 'pcs',
    this.gst = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'costPrice': costPrice,
      'quantity': quantity,
      'minStock': minStock,
      'barcode': barcode,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive,
      'unit': unit,
      'gst': gst,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      costPrice: (map['costPrice'] ?? 0).toDouble(),
      quantity: map['quantity'] ?? 0,
      minStock: map['minStock'] ?? 5,
      barcode: map['barcode'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      isActive: map['isActive'] ?? true,
      unit: map['unit'] ?? 'pcs',
      gst: (map['gst'] ?? 0).toDouble(),
    );
  }

  factory Product.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data['id'] = doc.id;
    return Product.fromMap(data);
  }

  Product copyWith({
    String? name,
    String? description,
    String? category,
    double? price,
    double? costPrice,
    int? quantity,
    int? minStock,
    String? barcode,
    String? imageUrl,
    DateTime? updatedAt,
    bool? isActive,
    String? unit,
    double? gst,
  }) {
    return Product(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      price: price ?? this.price,
      costPrice: costPrice ?? this.costPrice,
      quantity: quantity ?? this.quantity,
      minStock: minStock ?? this.minStock,
      barcode: barcode ?? this.barcode,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      isActive: isActive ?? this.isActive,
      unit: unit ?? this.unit,
      gst: gst ?? this.gst,
    );
  }

  // Helper getters
  bool get isLowStock => quantity <= minStock;
  double get profit => price - costPrice;
  double get profitMargin =>
      costPrice > 0 ? ((price - costPrice) / costPrice) * 100 : 0;
  double get totalValue => price * quantity;
}

// ✅ NEW BILLITEM CLASS FOR BILLING SYSTEM
class BillItem {
  final String productId;
  final String productName;
  final String brand;
  final String size;
  final double price;
  final int quantity;
  final String? other;

  BillItem({
    required this.productId,
    required this.productName,
    required this.brand,
    required this.size,
    required this.price,
    required this.quantity,
    this.other,
  });

  // Calculate total for this line item
  double get total => price * quantity;

  // Convert to map for storage/serialization
  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'brand': brand,
      'size': size,
      'price': price,
      'quantity': quantity,
      'other': other,
    };
  }

  // Create from map (for deserialization)
  factory BillItem.fromMap(Map<String, dynamic> map) {
    return BillItem(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      brand: map['brand'] ?? '',
      size: map['size'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      quantity: map['quantity'] ?? 0,
      other: map['other'],
    );
  }

  // Helper method to create BillItem from existing Product
  factory BillItem.fromProduct(
    Product product,
    int quantity, {
    String? customBrand,
    String? customSize,
  }) {
    return BillItem(
      productId: product.id,
      productName: product.name,
      brand:
          customBrand ??
          product.category, // Use category as brand if not specified
      size: customSize ?? product.unit, // Use unit as size if not specified
      price: product.price,
      quantity: quantity,
      other: product.description.isEmpty ? null : product.description,
    );
  }

  // Create a copy with updated values
  BillItem copyWith({
    String? productId,
    String? productName,
    String? brand,
    String? size,
    double? price,
    int? quantity,
    String? other,
  }) {
    return BillItem(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      brand: brand ?? this.brand,
      size: size ?? this.size,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      other: other ?? this.other,
    );
  }

  @override
  String toString() {
    return 'BillItem{productId: $productId, productName: $productName, brand: $brand, size: $size, price: $price, quantity: $quantity, total: ${total.toStringAsFixed(2)}}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BillItem &&
          runtimeType == other.runtimeType &&
          productId == other.productId &&
          productName == other.productName &&
          brand == other.brand &&
          size == other.size &&
          price == other.price &&
          quantity == other.quantity;

  @override
  int get hashCode =>
      productId.hashCode ^
      productName.hashCode ^
      brand.hashCode ^
      size.hashCode ^
      price.hashCode ^
      quantity.hashCode;
}
