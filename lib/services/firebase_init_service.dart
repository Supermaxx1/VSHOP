import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class FirebaseInitService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> initializeCollections() async {
    try {
      // Check if products collection is empty
      final productsSnapshot =
          await _firestore.collection('products').limit(1).get();

      if (productsSnapshot.docs.isEmpty) {
        // Add sample products
        await _addSampleProducts();
        print('✅ Sample products added to Firestore');
      }
    } catch (e) {
      print('❌ Error initializing Firestore: $e');
    }
  }

  static Future<void> _addSampleProducts() async {
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
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
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
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
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
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
    ];

    final batch = _firestore.batch();

    for (var productData in sampleProducts) {
      final docRef = _firestore.collection('products').doc();
      productData['id'] = docRef.id;
      batch.set(docRef, productData);
    }

    await batch.commit();
  }
}
