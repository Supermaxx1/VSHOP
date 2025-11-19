import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/payment_model.dart';
import '../models/product_model.dart';

class SalesProvider with ChangeNotifier {
  // Sales data
  Map<String, dynamic>? _todaysData;
  List<Payment> _pendingPayments = [];
  List<dynamic> _sales = [];

  // Cart functionality
  List<BillItem> _cartItems = [];
  double _customDiscount = 0.0;

  bool _isLoading = false;
  String? _error;

  // Getters - Sales Data
  Map<String, dynamic>? get todaysData => _todaysData;
  List<Payment> get pendingPayments => _pendingPayments;
  List<dynamic> get sales => _sales;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Today's sales data
  double get todayRevenue => _todaysData?['totalSales'] ?? 0.0;
  int get todayTransactions => _todaysData?['totalOrders'] ?? 0;
  int get paidOrders => _todaysData?['paidOrders'] ?? 0;
  int get pendingOrders => _todaysData?['pendingOrders'] ?? 0;
  double get todayProfit => todayRevenue * 0.3; // Assume 30% profit margin

  // Getters - Cart
  List<BillItem> get cartItems => _cartItems;
  bool get isCartEmpty => _cartItems.isEmpty;
  int get cartItemsCount => _cartItems.length;
  double get customDiscount => _customDiscount;

  double get cartSubtotal {
    return _cartItems.fold(0.0, (sum, item) => sum + item.total);
  }

  double get cartTotal {
    return cartSubtotal - _customDiscount;
  }

  // Load today's sales data
  Future<void> loadTodaysData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _todaysData = await DatabaseService.getTodaysSalesData();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _todaysData = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  // Load pending payments
  Future<void> loadPendingPayments() async {
    try {
      _pendingPayments = await DatabaseService.getPendingPayments();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Cart Methods
  void addToCart(BillItem item) {
    // Check if item already exists
    int existingIndex = _cartItems.indexWhere(
      (cartItem) => cartItem.productId == item.productId,
    );

    if (existingIndex != -1) {
      // Update quantity if item exists
      _cartItems[existingIndex] = _cartItems[existingIndex].copyWith(
        quantity: _cartItems[existingIndex].quantity + item.quantity,
      );
    } else {
      // Add new item
      _cartItems.add(item);
    }
    notifyListeners();
  }

  void removeFromCart(String productId) {
    _cartItems.removeWhere((item) => item.productId == productId);
    notifyListeners();
  }

  void updateCartItemQuantity(String productId, int newQuantity) {
    if (newQuantity <= 0) {
      removeFromCart(productId);
      return;
    }

    int index = _cartItems.indexWhere((item) => item.productId == productId);
    if (index != -1) {
      _cartItems[index] = _cartItems[index].copyWith(quantity: newQuantity);
      notifyListeners();
    }
  }

  void clearCart() {
    _cartItems.clear();
    _customDiscount = 0.0;
    notifyListeners();
  }

  void setCustomDiscount(double discount) {
    _customDiscount = discount.clamp(0.0, cartSubtotal);
    notifyListeners();
  }

  // Refresh all data
  Future<void> refreshData() async {
    await Future.wait([loadTodaysData(), loadPendingPayments()]);
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
