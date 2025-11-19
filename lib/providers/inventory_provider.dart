import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/product_model.dart';

class InventoryProvider with ChangeNotifier {
  List<Product> _products = [];
  List<Product> _lowStockProducts = [];
  List<String> _categories = ['All'];
  String _selectedCategory = 'All';
  String _searchQuery = '';

  bool _isLoading = false;
  String? _error;

  // Getters
  List<Product> get products => _filteredProducts;
  List<Product> get allProducts => _products;
  List<Product> get lowStockProducts => _lowStockProducts;
  List<String> get categories => _categories;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get totalProducts => _products.length;

  // Filtered products based on search and category
  List<Product> get _filteredProducts {
    List<Product> filtered = _products;

    // Filter by category
    if (_selectedCategory != 'All') {
      filtered =
          filtered
              .where(
                (product) =>
                    product.category.toLowerCase() ==
                    _selectedCategory.toLowerCase(),
              )
              .toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered =
          filtered.where((product) {
            return product.name.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                product.category.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                product.barcode.contains(_searchQuery);
          }).toList();
    }

    return filtered;
  }

  // Load all products
  Future<void> loadProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _products = await DatabaseService.getAllProducts();
      _lowStockProducts = await DatabaseService.getLowStockProducts();
      _updateCategories();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _products = [];
      _lowStockProducts = [];
      _categories = ['All'];
    }

    _isLoading = false;
    notifyListeners();
  }

  // Update categories list
  void _updateCategories() {
    Set<String> categorySet = {'All'};
    for (Product product in _products) {
      if (product.category.isNotEmpty) {
        categorySet.add(product.category);
      }
    }
    _categories = categorySet.toList();
  }

  // Set selected category
  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  // Set search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Add new product
  Future<bool> addProduct(Product product) async {
    try {
      final productId = await DatabaseService.addProduct(product);
      await loadProducts(); // Refresh list
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Update product quantity
  Future<bool> updateProductQuantity(String productId, int newQuantity) async {
    try {
      await DatabaseService.updateProductQuantity(productId, newQuantity);
      await loadProducts(); // Refresh list
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Get product by ID
  Product? getProductById(String productId) {
    try {
      return _products.firstWhere((product) => product.id == productId);
    } catch (e) {
      return null;
    }
  }

  // Get products by category
  List<Product> getProductsByCategory(String category) {
    if (category == 'All') return _products;
    return _products
        .where(
          (product) => product.category.toLowerCase() == category.toLowerCase(),
        )
        .toList();
  }

  // Clear search
  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
