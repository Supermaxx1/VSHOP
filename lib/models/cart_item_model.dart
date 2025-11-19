class CartItem {
  final String productId;
  final String productName;
  final double price;
  final double costPrice;
  int quantity;
  final double gst;
  final String unit;
  final String? imageUrl;

  CartItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.costPrice,
    this.quantity = 1,
    this.gst = 0.0,
    this.unit = 'pcs',
    this.imageUrl,
  });

  double get total => price * quantity;
  double get gstAmount => (total * gst) / 100;
  double get totalWithGst => total + gstAmount;
  double get profit => (price - costPrice) * quantity;

  CartItem copyWith({int? quantity, double? price}) {
    return CartItem(
      productId: productId,
      productName: productName,
      price: price ?? this.price,
      costPrice: costPrice,
      quantity: quantity ?? this.quantity,
      gst: gst,
      unit: unit,
      imageUrl: imageUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'price': price,
      'costPrice': costPrice,
      'quantity': quantity,
      'gst': gst,
      'unit': unit,
      'imageUrl': imageUrl,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      costPrice: (map['costPrice'] ?? 0).toDouble(),
      quantity: map['quantity'] ?? 1,
      gst: (map['gst'] ?? 0).toDouble(),
      unit: map['unit'] ?? 'pcs',
      imageUrl: map['imageUrl'],
    );
  }
}
