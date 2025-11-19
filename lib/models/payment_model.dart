class Payment {
  final String id;
  final String customerId;
  final String invoiceNumber;
  final double totalAmount;
  final double paidAmount;
  final double dueAmount;
  final String paymentMethod;
  final DateTime paymentDate;
  final String status; // 'paid', 'partial', 'due'

  Payment({
    required this.id,
    required this.customerId,
    required this.invoiceNumber,
    required this.totalAmount,
    required this.paidAmount,
    required this.dueAmount,
    required this.paymentMethod,
    required this.paymentDate,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerId': customerId,
      'invoiceNumber': invoiceNumber,
      'totalAmount': totalAmount,
      'paidAmount': paidAmount,
      'dueAmount': dueAmount,
      'paymentMethod': paymentMethod,
      'paymentDate': paymentDate.toIso8601String(),
      'status': status,
    };
  }

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['id'] ?? '',
      customerId: map['customerId'] ?? '',
      invoiceNumber: map['invoiceNumber'] ?? '',
      totalAmount: (map['totalAmount'] ?? 0.0).toDouble(),
      paidAmount: (map['paidAmount'] ?? 0.0).toDouble(),
      dueAmount: (map['dueAmount'] ?? 0.0).toDouble(),
      paymentMethod: map['paymentMethod'] ?? '',
      paymentDate: DateTime.parse(map['paymentDate']),
      status: map['status'] ?? 'due',
    );
  }

  // ✅ ADD THE MISSING copyWith METHOD
  Payment copyWith({
    String? id,
    String? customerId,
    String? invoiceNumber,
    double? totalAmount,
    double? paidAmount,
    double? dueAmount,
    String? paymentMethod,
    DateTime? paymentDate,
    String? status,
  }) {
    return Payment(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      totalAmount: totalAmount ?? this.totalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      dueAmount: dueAmount ?? this.dueAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentDate: paymentDate ?? this.paymentDate,
      status: status ?? this.status,
    );
  }

  // ✅ ENHANCED HELPER GETTERS
  bool get isFullyPaid => dueAmount <= 0;
  bool get isPartiallyPaid => paidAmount > 0 && dueAmount > 0;
  bool get isPending => paidAmount <= 0;

  // ✅ PAYMENT STATUS HELPERS
  String get statusDisplayName {
    switch (status.toLowerCase()) {
      case 'paid':
        return 'Fully Paid';
      case 'partial':
        return 'Partially Paid';
      case 'due':
        return 'Payment Due';
      case 'pending':
        return 'Payment Pending';
      default:
        return status.toUpperCase();
    }
  }

  // ✅ PAYMENT COMPLETION PERCENTAGE
  double get completionPercentage {
    if (totalAmount <= 0) return 0.0;
    return (paidAmount / totalAmount).clamp(0.0, 1.0);
  }

  // ✅ REMAINING PAYMENT INFO
  double get remainingAmount => dueAmount;

  // ✅ PAYMENT METHOD HELPERS
  bool get isCashPayment => paymentMethod.toLowerCase() == 'cash';
  bool get isCardPayment => paymentMethod.toLowerCase() == 'card';
  bool get isUpiPayment => paymentMethod.toLowerCase() == 'upi';
  bool get isNetBankingPayment => paymentMethod.toLowerCase() == 'net banking';

  // ✅ DATE HELPERS
  String get formattedDate {
    return '${paymentDate.day}/${paymentDate.month}/${paymentDate.year}';
  }

  String get formattedTime {
    return '${paymentDate.hour.toString().padLeft(2, '0')}:${paymentDate.minute.toString().padLeft(2, '0')}';
  }

  String get formattedDateTime {
    return '$formattedDate at $formattedTime';
  }

  // ✅ CHECK IF PAYMENT IS OVERDUE (if needed later)
  bool isOverdue({int graceDays = 30}) {
    if (isFullyPaid) return false;
    final overdueDate = paymentDate.add(Duration(days: graceDays));
    return DateTime.now().isAfter(overdueDate);
  }

  // ✅ VALIDATION
  bool get isValid {
    return id.isNotEmpty &&
        customerId.isNotEmpty &&
        invoiceNumber.isNotEmpty &&
        totalAmount > 0 &&
        paidAmount >= 0 &&
        dueAmount >= 0 &&
        paymentMethod.isNotEmpty &&
        status.isNotEmpty;
  }

  // ✅ DISPLAY HELPERS
  String get amountSummary {
    if (isFullyPaid) {
      return 'Paid: ₹${paidAmount.toStringAsFixed(2)}';
    } else if (isPartiallyPaid) {
      return 'Paid: ₹${paidAmount.toStringAsFixed(2)} | Due: ₹${dueAmount.toStringAsFixed(2)}';
    } else {
      return 'Total Due: ₹${totalAmount.toStringAsFixed(2)}';
    }
  }

  // ✅ FOR DEBUGGING
  @override
  String toString() {
    return 'Payment{id: $id, invoice: $invoiceNumber, total: ₹${totalAmount.toStringAsFixed(2)}, paid: ₹${paidAmount.toStringAsFixed(2)}, due: ₹${dueAmount.toStringAsFixed(2)}, status: $status}';
  }

  // ✅ EQUALITY COMPARISON
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Payment && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// ✅ PAYMENT STATUS ENUM FOR TYPE SAFETY
enum PaymentStatus {
  paid('paid', 'Fully Paid'),
  partial('partial', 'Partially Paid'),
  due('due', 'Payment Due'),
  pending('pending', 'Payment Pending'),
  cancelled('cancelled', 'Cancelled'),
  refunded('refunded', 'Refunded');

  const PaymentStatus(this.value, this.displayName);
  final String value;
  final String displayName;

  static PaymentStatus fromString(String value) {
    return PaymentStatus.values.firstWhere(
      (status) => status.value == value.toLowerCase(),
      orElse: () => PaymentStatus.pending,
    );
  }
}

// ✅ PAYMENT METHOD ENUM FOR TYPE SAFETY
enum PaymentMethodType {
  cash('Cash'),
  card('Card'),
  upi('UPI'),
  netBanking('Net Banking'),
  wallet('Digital Wallet'),
  cheque('Cheque'),
  other('Other');

  const PaymentMethodType(this.displayName);
  final String displayName;

  static PaymentMethodType fromString(String value) {
    return PaymentMethodType.values.firstWhere(
      (method) => method.displayName.toLowerCase() == value.toLowerCase(),
      orElse: () => PaymentMethodType.other,
    );
  }
}
