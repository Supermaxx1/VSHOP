import 'package:cloud_firestore/cloud_firestore.dart';

class Sale {
  final String id;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final List<SaleItem> items;
  final double subtotal;
  final double taxAmount;
  final double discount;
  final double total;
  final String paymentMethod;
  final DateTime createdAt;
  final String status; // 'completed', 'pending', 'cancelled', 'refunded'
  final String? notes;
  final String cashierId;
  final String cashierName;
  final String invoiceNumber;
  final bool isPrinted;
  final double paidAmount;
  final double changeAmount;
  final String? refundReason;
  final DateTime? refundDate;

  Sale({
    required this.id,
    this.customerId = '',
    this.customerName = 'Walk-in Customer',
    this.customerPhone = '',
    required this.items,
    required this.subtotal,
    required this.taxAmount,
    this.discount = 0.0,
    required this.total,
    required this.paymentMethod,
    required this.createdAt,
    this.status = 'completed',
    this.notes,
    required this.cashierId,
    required this.cashierName,
    required this.invoiceNumber,
    this.isPrinted = false,
    required this.paidAmount,
    this.changeAmount = 0.0,
    this.refundReason,
    this.refundDate,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'items': items.map((item) => item.toMap()).toList(),
      'subtotal': subtotal,
      'taxAmount': taxAmount,
      'discount': discount,
      'total': total,
      'paymentMethod': paymentMethod,
      'createdAt': createdAt.toIso8601String(),
      'status': status,
      'notes': notes,
      'cashierId': cashierId,
      'cashierName': cashierName,
      'invoiceNumber': invoiceNumber,
      'isPrinted': isPrinted,
      'paidAmount': paidAmount,
      'changeAmount': changeAmount,
      'refundReason': refundReason,
      'refundDate': refundDate?.toIso8601String(),
    };
  }

  // Create from Map
  factory Sale.fromMap(Map<String, dynamic> map) {
    return Sale(
      id: map['id'] ?? '',
      customerId: map['customerId'] ?? '',
      customerName: map['customerName'] ?? 'Walk-in Customer',
      customerPhone: map['customerPhone'] ?? '',
      items: List<SaleItem>.from(
        map['items']?.map((x) => SaleItem.fromMap(x)) ?? [],
      ),
      subtotal: (map['subtotal'] ?? 0).toDouble(),
      taxAmount: (map['taxAmount'] ?? 0).toDouble(),
      discount: (map['discount'] ?? 0).toDouble(),
      total: (map['total'] ?? 0).toDouble(),
      paymentMethod: map['paymentMethod'] ?? 'Cash',
      createdAt: DateTime.parse(map['createdAt']),
      status: map['status'] ?? 'completed',
      notes: map['notes'],
      cashierId: map['cashierId'] ?? '',
      cashierName: map['cashierName'] ?? '',
      invoiceNumber: map['invoiceNumber'] ?? '',
      isPrinted: map['isPrinted'] ?? false,
      paidAmount: (map['paidAmount'] ?? 0).toDouble(),
      changeAmount: (map['changeAmount'] ?? 0).toDouble(),
      refundReason: map['refundReason'],
      refundDate:
          map['refundDate'] != null ? DateTime.parse(map['refundDate']) : null,
    );
  }

  // Create from Firestore Document
  factory Sale.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data['id'] = doc.id;
    return Sale.fromMap(data);
  }

  // Create copy with updates
  Sale copyWith({
    String? customerId,
    String? customerName,
    String? customerPhone,
    List<SaleItem>? items,
    double? subtotal,
    double? taxAmount,
    double? discount,
    double? total,
    String? paymentMethod,
    String? status,
    String? notes,
    bool? isPrinted,
    double? paidAmount,
    double? changeAmount,
    String? refundReason,
    DateTime? refundDate,
  }) {
    return Sale(
      id: id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      taxAmount: taxAmount ?? this.taxAmount,
      discount: discount ?? this.discount,
      total: total ?? this.total,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      createdAt: createdAt,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      cashierId: cashierId,
      cashierName: cashierName,
      invoiceNumber: invoiceNumber,
      isPrinted: isPrinted ?? this.isPrinted,
      paidAmount: paidAmount ?? this.paidAmount,
      changeAmount: changeAmount ?? this.changeAmount,
      refundReason: refundReason ?? this.refundReason,
      refundDate: refundDate ?? this.refundDate,
    );
  }

  // Business calculations
  double get profit {
    return items.fold(
      0.0,
      (sum, item) => sum + ((item.price - item.costPrice) * item.quantity),
    );
  }

  double get profitMargin {
    return subtotal > 0 ? (profit / subtotal) * 100 : 0.0;
  }

  int get totalItems {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  double get averageItemPrice {
    return totalItems > 0 ? subtotal / totalItems : 0.0;
  }

  // Status checks
  bool get isCompleted => status == 'completed';
  bool get isPending => status == 'pending';
  bool get isCancelled => status == 'cancelled';
  bool get isRefunded => status == 'refunded';
  bool get canBeRefunded => isCompleted && refundDate == null;
  bool get hasDiscount => discount > 0;

  // Payment checks
  bool get isFullyPaid => paidAmount >= total;
  bool get hasChange => changeAmount > 0;
  double get balanceAmount => total - paidAmount;

  // Generate invoice number
  static String generateInvoiceNumber() {
    final now = DateTime.now();
    return 'INV${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}${now.millisecondsSinceEpoch.toString().substring(8)}';
  }

  @override
  String toString() {
    return 'Sale{id: $id, invoiceNumber: $invoiceNumber, total: $total, status: $status}';
  }
}

class SaleItem {
  final String productId;
  final String productName;
  final String productCategory;
  final double price;
  final double costPrice;
  final int quantity;
  final double gst;
  final String unit;
  final double discountPerItem;
  final String? productImage;
  final String? barcode;

  SaleItem({
    required this.productId,
    required this.productName,
    this.productCategory = '',
    required this.price,
    required this.costPrice,
    required this.quantity,
    this.gst = 0.0,
    this.unit = 'pcs',
    this.discountPerItem = 0.0,
    this.productImage,
    this.barcode,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'productCategory': productCategory,
      'price': price,
      'costPrice': costPrice,
      'quantity': quantity,
      'gst': gst,
      'unit': unit,
      'discountPerItem': discountPerItem,
      'productImage': productImage,
      'barcode': barcode,
    };
  }

  factory SaleItem.fromMap(Map<String, dynamic> map) {
    return SaleItem(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      productCategory: map['productCategory'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      costPrice: (map['costPrice'] ?? 0).toDouble(),
      quantity: map['quantity'] ?? 0,
      gst: (map['gst'] ?? 0).toDouble(),
      unit: map['unit'] ?? 'pcs',
      discountPerItem: (map['discountPerItem'] ?? 0).toDouble(),
      productImage: map['productImage'],
      barcode: map['barcode'],
    );
  }

  // Calculations
  double get subtotal => price * quantity;
  double get totalDiscount => discountPerItem * quantity;
  double get discountedSubtotal => subtotal - totalDiscount;
  double get gstAmount => (discountedSubtotal * gst) / 100;
  double get total => discountedSubtotal + gstAmount;
  double get profit => (price - costPrice) * quantity - totalDiscount;
  double get profitPercentage =>
      costPrice > 0 ? ((price - costPrice) / costPrice) * 100 : 0;

  @override
  String toString() {
    return 'SaleItem{productName: $productName, quantity: $quantity, total: $total}';
  }
}

// Sale Status Enum
enum SaleStatus {
  completed('Completed'),
  pending('Pending'),
  cancelled('Cancelled'),
  refunded('Refunded');

  const SaleStatus(this.displayName);
  final String displayName;
}

// Sale Statistics for Analytics
class SaleStatistics {
  final double totalRevenue;
  final double totalProfit;
  final int totalTransactions;
  final double averageTransaction;
  final int totalItems;
  final double averageItemsPerTransaction;
  final Map<String, double> paymentMethodBreakdown;
  final Map<String, int> categoryBreakdown;

  SaleStatistics({
    required this.totalRevenue,
    required this.totalProfit,
    required this.totalTransactions,
    required this.averageTransaction,
    required this.totalItems,
    required this.averageItemsPerTransaction,
    required this.paymentMethodBreakdown,
    required this.categoryBreakdown,
  });
}
