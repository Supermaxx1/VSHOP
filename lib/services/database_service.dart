import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/customer_model.dart';
import '../models/product_model.dart';
import '../models/payment_model.dart';

class DatabaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  static final CollectionReference _customersCollection = _firestore.collection(
    'customers',
  );
  static final CollectionReference _productsCollection = _firestore.collection(
    'products',
  );
  static final CollectionReference _paymentsCollection = _firestore.collection(
    'payments',
  );
  static final CollectionReference _salesCollection = _firestore.collection(
    'sales',
  );
  static final CollectionReference _billItemsCollection = _firestore.collection(
    'billItems',
  );

  // ========== INITIALIZATION ==========

  /// Initialize Firebase collections and sample data
  static Future<void> initializeDatabase() async {
    try {
      print('Initializing Firebase Database...');

      // Ensure collections exist
      await _ensureCollectionsExist();

      // Add sample data if collections are empty
      await _addSampleDataIfEmpty();

      print('Firebase Database initialized successfully');
    } catch (e) {
      print('Error initializing database: $e');
      throw Exception('Failed to initialize database: $e');
    }
  }

  /// Check database status and initialize if needed
  static Future<bool> checkDatabaseStatus() async {
    try {
      print('Checking database status...');

      // Try to read from products collection
      QuerySnapshot productsTest = await _productsCollection.limit(1).get();
      print('Products collection accessible: ${productsTest.docs.length} docs');

      // Try to read from customers collection
      QuerySnapshot customersTest = await _customersCollection.limit(1).get();
      print(
        'Customers collection accessible: ${customersTest.docs.length} docs',
      );

      // If collections are empty, initialize with sample data
      if (productsTest.docs.isEmpty) {
        print('Products collection empty, adding sample products...');
        await _addSampleProducts();
      }

      return true;
    } catch (e) {
      print('Database status check failed: $e');
      return false;
    }
  }

  /// Ensure all collections exist
  static Future<void> _ensureCollectionsExist() async {
    try {
      final collections = [
        'customers',
        'products',
        'payments',
        'sales',
        'billItems',
      ];

      for (String collection in collections) {
        // Create a dummy document to ensure collection exists
        await _firestore.collection(collection).doc('_init').set({
          'initialized': true,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Delete the dummy document
        await _firestore.collection(collection).doc('_init').delete();
      }
    } catch (e) {
      print('Error ensuring collections exist: $e');
    }
  }

  /// Add sample data if collections are empty
  static Future<void> _addSampleDataIfEmpty() async {
    try {
      // Check if products collection is empty
      final productsSnapshot = await _productsCollection.limit(1).get();

      if (productsSnapshot.docs.isEmpty) {
        await _addSampleProducts();
        print('Sample products added');
      }
    } catch (e) {
      print('Error adding sample data: $e');
    }
  }

  /// Add sample products
  static Future<void> _addSampleProducts() async {
    try {
      final sampleProducts = [
        {
          'name': 'Hand Pump',
          'brand': 'Bharat',
          'category': 'Hardware',
          'price': 3200.0,
          'quantity': 10,
          'size': 'Standard',
          'barcode': 'HP001',
          'isActive': true,
          'lowStockThreshold': 5,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        {
          'name': 'Shicket',
          'brand': 'CI',
          'category': 'Tools',
          'price': 25.0,
          'quantity': 50,
          'size': '4inch',
          'barcode': 'SH001',
          'isActive': true,
          'lowStockThreshold': 10,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        {
          'name': 'Chapakal',
          'brand': 'Bharat',
          'category': 'Hardware',
          'price': 3200.0,
          'quantity': 8,
          'size': 'Large',
          'barcode': 'CK001',
          'isActive': true,
          'lowStockThreshold': 3,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
      ];

      final batch = _firestore.batch();

      for (var productData in sampleProducts) {
        final docRef = _productsCollection.doc();
        productData['id'] = docRef.id;
        batch.set(docRef, productData);
      }

      await batch.commit();
    } catch (e) {
      print('Error adding sample products: $e');
    }
  }

  // ========== CUSTOMERS ==========

  /// Add new customer
  static Future<String> addCustomer(Customer customer) async {
    try {
      // Create customer data with server timestamp
      Map<String, dynamic> customerData = customer.toMap();
      customerData['createdAt'] = FieldValue.serverTimestamp();
      customerData['updatedAt'] = FieldValue.serverTimestamp();

      DocumentReference docRef = await _customersCollection.add(customerData);
      return docRef.id;
    } catch (e) {
      print('Error adding customer: $e');
      throw Exception('Failed to add customer: $e');
    }
  }

  /// Get all customers
  static Future<List<Customer>> getAllCustomers() async {
    try {
      QuerySnapshot querySnapshot =
          await _customersCollection
              .orderBy('createdAt', descending: true)
              .get();

      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Customer.fromMap(data);
      }).toList();
    } catch (e) {
      print('Error getting customers: $e');
      // Return empty list instead of throwing exception
      return [];
    }
  }

  /// Get customer by ID
  static Future<Customer?> getCustomerById(String customerId) async {
    try {
      DocumentSnapshot doc = await _customersCollection.doc(customerId).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Customer.fromMap(data);
      }
      return null;
    } catch (e) {
      print('Error getting customer: $e');
      return null;
    }
  }

  /// Update customer
  static Future<void> updateCustomer(
    String customerId,
    Customer customer,
  ) async {
    try {
      Map<String, dynamic> customerData = customer.toMap();
      customerData['updatedAt'] = FieldValue.serverTimestamp();
      await _customersCollection.doc(customerId).update(customerData);
    } catch (e) {
      print('Error updating customer: $e');
      throw Exception('Failed to update customer: $e');
    }
  }

  /// Search customers
  static Future<List<Customer>> searchCustomers(String searchTerm) async {
    try {
      QuerySnapshot querySnapshot =
          await _customersCollection
              .where('name', isGreaterThanOrEqualTo: searchTerm)
              .where('name', isLessThan: searchTerm + 'z')
              .get();

      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Customer.fromMap(data);
      }).toList();
    } catch (e) {
      print('Error searching customers: $e');
      return [];
    }
  }

  // ========== PRODUCTS ==========

  /// Add new product
  static Future<String> addProduct(Product product) async {
    try {
      Map<String, dynamic> productData = product.toMap();
      productData['createdAt'] = FieldValue.serverTimestamp();
      productData['updatedAt'] = FieldValue.serverTimestamp();

      DocumentReference docRef = await _productsCollection.add(productData);
      return docRef.id;
    } catch (e) {
      print('Error adding product: $e');
      throw Exception('Failed to add product: $e');
    }
  }

  /// Get all products (with better error handling)
  static Future<List<Product>> getAllProducts() async {
    try {
      // Try without orderBy first to avoid index issues
      QuerySnapshot querySnapshot =
          await _productsCollection.where('isActive', isEqualTo: true).get();

      List<Product> products =
          querySnapshot.docs.map((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return Product.fromMap(data);
          }).toList();

      // Sort in memory to avoid index requirements
      products.sort((a, b) => a.name.compareTo(b.name));

      return products;
    } catch (e) {
      print('Error getting products: $e');
      // Return empty list instead of throwing exception
      return [];
    }
  }

  /// Get low stock products
  static Future<List<Product>> getLowStockProducts() async {
    try {
      QuerySnapshot querySnapshot =
          await _productsCollection.where('isActive', isEqualTo: true).get();

      List<Product> products =
          querySnapshot.docs
              .map((doc) {
                Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                data['id'] = doc.id;
                return Product.fromMap(data);
              })
              .where((product) {
                // Define low stock as quantity < 10
                return product.quantity < 10;
              })
              .toList();

      return products;
    } catch (e) {
      print('Error getting low stock products: $e');
      return [];
    }
  }

  /// Update product quantity
  static Future<void> updateProductQuantity(
    String productId,
    int newQuantity,
  ) async {
    try {
      await _productsCollection.doc(productId).update({
        'quantity': newQuantity,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating product quantity: $e');
      throw Exception('Failed to update product quantity: $e');
    }
  }

  // ========== SALES & PAYMENTS ==========

  /// Save complete sale (payment + bill items) - FIXED FOR PRODUCT UPDATE ISSUE
  static Future<String> saveSale({
    required Customer customer,
    required List<BillItem> billItems,
    required Payment payment,
    required String invoiceNumber,
  }) async {
    WriteBatch? batch;
    try {
      print('Starting to save sale...');
      print('Customer: ${customer.name} (ID: ${customer.id})');
      print('Items: ${billItems.length}');
      print('Total: ${payment.totalAmount}');

      // Debug: Print bill items to see what product IDs we have
      for (var item in billItems) {
        print('Bill item: ${item.productName}, Product ID: ${item.productId}');
      }

      // Start a batch write
      batch = _firestore.batch();

      // 1. ALWAYS CREATE A NEW CUSTOMER ENTRY FOR EACH SALE
      DocumentReference customerRef = _customersCollection.doc();
      String newCustomerId = customerRef.id;

      Map<String, dynamic> customerData = customer.toMap();
      customerData['id'] = newCustomerId;
      customerData['totalPurchases'] = payment.totalAmount;
      customerData['totalOrders'] = 1;
      customerData['outstandingAmount'] = payment.dueAmount;
      customerData['lastPurchase'] = FieldValue.serverTimestamp();
      customerData['createdAt'] = FieldValue.serverTimestamp();
      customerData['updatedAt'] = FieldValue.serverTimestamp();

      batch.set(customerRef, customerData);
      print('Customer will be created with ID: $newCustomerId');

      // 2. Save Payment Record
      DocumentReference paymentRef = _paymentsCollection.doc();
      Map<String, dynamic> paymentData = payment.toMap();
      paymentData['id'] = paymentRef.id;
      paymentData['customerId'] = newCustomerId;
      paymentData['createdAt'] = FieldValue.serverTimestamp();
      paymentData['updatedAt'] = FieldValue.serverTimestamp();
      batch.set(paymentRef, paymentData);
      print('Payment will be created with ID: ${paymentRef.id}');

      // 3. Save Sale Record
      DocumentReference saleRef = _salesCollection.doc();
      Map<String, dynamic> saleData = {
        'id': saleRef.id,
        'customerId': newCustomerId,
        'paymentId': paymentRef.id,
        'invoiceNumber': invoiceNumber,
        'totalAmount': payment.totalAmount,
        'paidAmount': payment.paidAmount,
        'dueAmount': payment.dueAmount,
        'paymentMethod': payment.paymentMethod,
        'itemCount': billItems.length,
        'saleDate': FieldValue.serverTimestamp(),
        'status': payment.status,
        'createdAt': FieldValue.serverTimestamp(),
      };
      batch.set(saleRef, saleData);
      print('Sale will be created with ID: ${saleRef.id}');

      // 4. Save Bill Items
      for (int i = 0; i < billItems.length; i++) {
        BillItem item = billItems[i];
        DocumentReference itemRef = _billItemsCollection.doc();
        Map<String, dynamic> itemData = item.toMap();
        itemData['id'] = itemRef.id;
        itemData['saleId'] = saleRef.id;
        itemData['customerId'] = newCustomerId;
        itemData['createdAt'] = FieldValue.serverTimestamp();
        batch.set(itemRef, itemData);
        print('Item ${i + 1} will be saved: ${item.productName}');
      }

      // 5. FIXED: Skip Product Updates to Avoid Document Not Found Error
      print(
        'Skipping product quantity updates to avoid document not found errors',
      );
      print('Product inventory will need to be managed separately');

      // Alternative approach: Only update products that we know exist
      // This section is commented out to prevent the error
      /*
      List<String> validProductIds = [];
      
      // First, collect all product IDs from our actual products collection
      QuerySnapshot existingProducts = await _productsCollection.get();
      for (var doc in existingProducts.docs) {
        validProductIds.add(doc.id);
      }
      
      // Then only update products that actually exist
      for (BillItem item in billItems) {
        if (validProductIds.contains(item.productId)) {
          DocumentReference productRef = _productsCollection.doc(item.productId);
          batch.update(productRef, {
            'quantity': FieldValue.increment(-item.quantity),
            'updatedAt': FieldValue.serverTimestamp(),
          });
          print('Product ${item.productId} quantity will be updated');
        } else {
          print('Product ${item.productId} not found in valid products, skipping');
        }
      }
      */

      // Commit the batch
      print('Committing batch transaction...');
      await batch.commit();

      print('Sale saved successfully: ${saleRef.id}');
      return saleRef.id;
    } catch (e) {
      print('Error saving sale: $e');
      print('Error details: ${e.toString()}');

      // If batch was created but failed, we don't need to rollback
      // Firestore batch operations are atomic

      throw Exception('Failed to save sale: $e');
    }
  }

  // ========== ANALYTICS & REPORTS ==========

  /// Get today's sales summary (IMPROVED)
  static Future<Map<String, dynamic>> getTodaysSalesData() async {
    try {
      DateTime today = DateTime.now();
      DateTime startOfDay = DateTime(today.year, today.month, today.day);

      // Get today's sales without date range query to avoid index issues
      QuerySnapshot salesSnapshot = await _salesCollection.get();

      double totalSales = 0.0;
      int totalOrders = 0;
      int paidOrders = 0;
      int pendingOrders = 0;

      for (var doc in salesSnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // Check if sale is from today
        if (data['saleDate'] != null) {
          DateTime saleDate;
          if (data['saleDate'] is Timestamp) {
            saleDate = (data['saleDate'] as Timestamp).toDate();
          } else if (data['saleDate'] is String) {
            saleDate = DateTime.parse(data['saleDate']);
          } else {
            continue;
          }

          if (saleDate.year == today.year &&
              saleDate.month == today.month &&
              saleDate.day == today.day) {
            totalOrders++;
            totalSales += (data['totalAmount'] ?? 0.0).toDouble();

            if (data['status'] == 'paid') {
              paidOrders++;
            } else {
              pendingOrders++;
            }
          }
        }
      }

      return {
        'totalSales': totalSales,
        'totalOrders': totalOrders,
        'paidOrders': paidOrders,
        'pendingOrders': pendingOrders,
        'date': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      print('Error getting today\'s sales data: $e');
      // Return default data instead of throwing exception
      return {
        'totalSales': 0.0,
        'totalOrders': 0,
        'paidOrders': 0,
        'pendingOrders': 0,
        'date': DateTime.now().toIso8601String(),
      };
    }
  }

  /// Get customer purchase history
  static Future<List<Map<String, dynamic>>> getCustomerPurchaseHistory(
    String customerId,
  ) async {
    try {
      QuerySnapshot salesSnapshot =
          await _salesCollection
              .where('customerId', isEqualTo: customerId)
              .get();

      List<Map<String, dynamic>> history = [];

      for (var doc in salesSnapshot.docs) {
        Map<String, dynamic> saleData = doc.data() as Map<String, dynamic>;

        // Get bill items for this sale
        QuerySnapshot itemsSnapshot =
            await _billItemsCollection.where('saleId', isEqualTo: doc.id).get();

        List<BillItem> items =
            itemsSnapshot.docs.map((itemDoc) {
              Map<String, dynamic> itemData =
                  itemDoc.data() as Map<String, dynamic>;
              return BillItem.fromMap(itemData);
            }).toList();

        history.add({'sale': saleData, 'items': items});
      }

      return history;
    } catch (e) {
      print('Error getting customer purchase history: $e');
      return [];
    }
  }

  /// Get pending payments (due amounts) - IMPROVED
  static Future<List<Payment>> getPendingPayments() async {
    try {
      // Get all partial payments without complex queries to avoid index issues
      QuerySnapshot querySnapshot =
          await _paymentsCollection.where('status', isEqualTo: 'partial').get();

      List<Payment> pendingPayments = [];

      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        double dueAmount = (data['dueAmount'] ?? 0.0).toDouble();

        if (dueAmount > 0) {
          data['id'] = doc.id;
          pendingPayments.add(Payment.fromMap(data));
        }
      }

      return pendingPayments;
    } catch (e) {
      print('Error getting pending payments: $e');
      return [];
    }
  }

  /// Update payment status (for partial payments)
  static Future<void> updatePaymentStatus(
    String paymentId, {
    double? additionalPayment,
    String? newStatus,
  }) async {
    try {
      Map<String, dynamic> updates = {};

      if (additionalPayment != null) {
        updates['paidAmount'] = FieldValue.increment(additionalPayment);
        updates['dueAmount'] = FieldValue.increment(-additionalPayment);
      }

      if (newStatus != null) {
        updates['status'] = newStatus;
      }

      updates['updatedAt'] = FieldValue.serverTimestamp();

      await _paymentsCollection.doc(paymentId).update(updates);
    } catch (e) {
      print('Error updating payment status: $e');
      throw Exception('Failed to update payment: $e');
    }
  }

  // ========== PRODUCT INVENTORY MANAGEMENT ==========

  /// Safely update product quantities after sale (separate method)
  static Future<void> updateProductQuantitiesAfterSale({
    required String saleId,
    required List<BillItem> billItems,
  }) async {
    try {
      print('Updating product quantities for sale: $saleId');

      // Get all existing products first
      QuerySnapshot existingProducts = await _productsCollection.get();
      Set<String> validProductIds =
          existingProducts.docs.map((doc) => doc.id).toSet();

      WriteBatch batch = _firestore.batch();
      int updatedCount = 0;

      for (BillItem item in billItems) {
        if (item.productId.isNotEmpty &&
            item.productId != 'manual' &&
            validProductIds.contains(item.productId)) {
          DocumentReference productRef = _productsCollection.doc(
            item.productId,
          );
          batch.update(productRef, {
            'quantity': FieldValue.increment(-item.quantity),
            'updatedAt': FieldValue.serverTimestamp(),
          });
          updatedCount++;
          print('Queued quantity update for product: ${item.productId}');
        } else {
          print(
            'Skipping product ${item.productId} (not found or manual entry)',
          );
        }
      }

      if (updatedCount > 0) {
        await batch.commit();
        print('Successfully updated quantities for $updatedCount products');
      } else {
        print('No product quantities to update');
      }
    } catch (e) {
      print('Error updating product quantities: $e');
      // Don't throw exception - this is a separate operation
    }
  }

  // ========== BACKUP & SYNC ==========

  /// Get all data for backup
  static Future<Map<String, dynamic>> getAllDataForBackup() async {
    try {
      final customers = await getAllCustomers();
      final products = await getAllProducts();

      final paymentsSnapshot = await _paymentsCollection.get();
      final payments =
          paymentsSnapshot.docs.map((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return Payment.fromMap(data);
          }).toList();

      return {
        'customers': customers.map((c) => c.toMap()).toList(),
        'products': products.map((p) => p.toMap()).toList(),
        'payments': payments.map((p) => p.toMap()).toList(),
        'exportDate': DateTime.now().toIso8601String(),
        'version': '1.0.0',
      };
    } catch (e) {
      print('Error getting backup data: $e');
      throw Exception('Failed to get backup data: $e');
    }
  }

  // ========== UTILITY METHODS ==========

  /// Clean up test/demo data (use with caution)
  static Future<void> clearAllTestData() async {
    try {
      print('Warning: Clearing all test data...');

      WriteBatch batch = _firestore.batch();

      // Get all collections
      final collections = [
        _customersCollection,
        _productsCollection,
        _paymentsCollection,
        _salesCollection,
        _billItemsCollection,
      ];

      for (var collection in collections) {
        QuerySnapshot snapshot = await collection.get();
        for (var doc in snapshot.docs) {
          batch.delete(doc.reference);
        }
      }

      await batch.commit();
      print('All test data cleared');
    } catch (e) {
      print('Error clearing test data: $e');
      throw Exception('Failed to clear test data: $e');
    }
  }

  /// Get database statistics
  static Future<Map<String, dynamic>> getDatabaseStats() async {
    try {
      final customersCount = (await _customersCollection.get()).docs.length;
      final productsCount = (await _productsCollection.get()).docs.length;
      final paymentsCount = (await _paymentsCollection.get()).docs.length;
      final salesCount = (await _salesCollection.get()).docs.length;
      final billItemsCount = (await _billItemsCollection.get()).docs.length;

      return {
        'customers': customersCount,
        'products': productsCount,
        'payments': paymentsCount,
        'sales': salesCount,
        'billItems': billItemsCount,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      print('Error getting database stats: $e');
      return {
        'error': e.toString(),
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    }
  }
}
