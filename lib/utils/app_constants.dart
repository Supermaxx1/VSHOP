class AppConstants {
  static const String appName = 'VShop';
  static const String version = '1.0.0';

  // Firebase Config (Replace with your actual values)
  static const String firebaseApiKey = 'YOUR_FIREBASE_API_KEY';
  static const String firebaseAppId = 'YOUR_FIREBASE_APP_ID';
  static const String messagingSenderId = 'YOUR_MESSAGING_SENDER_ID';
  static const String projectId = 'YOUR_PROJECT_ID';

  // Hive Boxes
  static const String settingsBox = 'settings';
  static const String cacheBox = 'cache';
  static const String offlineBox = 'offline_data';

  // Firestore Collections
  static const String productsCollection = 'products';
  static const String customersCollection = 'customers';
  static const String salesCollection = 'sales';
  static const String categoriesCollection = 'categories';
  static const String usersCollection = 'users';

  // Business Info
  static const String defaultShopName = 'Your Shop Name';
  static const String defaultAddress = 'Your Shop Address';
  static const String defaultPhone = '+91 9999999999';
  static const String defaultCurrency = '₹';

  // Settings Keys
  static const String themeKey = 'app_theme';
  static const String shopInfoKey = 'shop_info';

  // Default Categories
  static const List<String> defaultCategories = [
    'Electronics',
    'Clothing',
    'Food & Beverages',
    'Books',
    'Home & Garden',
    'Health & Beauty',
    'Others',
  ];

  // Payment Methods
  static const List<String> paymentMethods = [
    'Cash',
    'Card',
    'UPI',
    'Net Banking',
  ];
}
