import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role; // 'admin', 'cashier', 'manager', 'owner'
  final String shopName;
  final String? shopAddress;
  final String? shopPhone;
  final String? shopEmail;
  final String? gstNumber;
  final String? panNumber;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final bool isActive;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final String? profileImageUrl;
  final Map<String, bool> permissions;
  final String? deviceToken; // For push notifications
  final List<String> assignedStores; // Multi-store support
  final double salesTarget; // Monthly sales target
  final String preferredLanguage;
  final String? notes;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone = '',
    this.role = 'cashier',
    required this.shopName,
    this.shopAddress,
    this.shopPhone,
    this.shopEmail,
    this.gstNumber,
    this.panNumber,
    required this.createdAt,
    DateTime? lastLoginAt,
    this.isActive = true,
    this.isEmailVerified = false,
    this.isPhoneVerified = false,
    this.profileImageUrl,
    this.permissions = const {},
    this.deviceToken,
    this.assignedStores = const [],
    this.salesTarget = 0.0,
    this.preferredLanguage = 'en',
    this.notes,
  }) : lastLoginAt = lastLoginAt ?? createdAt;

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'shopName': shopName,
      'shopAddress': shopAddress,
      'shopPhone': shopPhone,
      'shopEmail': shopEmail,
      'gstNumber': gstNumber,
      'panNumber': panNumber,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt.toIso8601String(),
      'isActive': isActive,
      'isEmailVerified': isEmailVerified,
      'isPhoneVerified': isPhoneVerified,
      'profileImageUrl': profileImageUrl,
      'permissions': permissions,
      'deviceToken': deviceToken,
      'assignedStores': assignedStores,
      'salesTarget': salesTarget,
      'preferredLanguage': preferredLanguage,
      'notes': notes,
    };
  }

  // Create from Map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      role: map['role'] ?? 'cashier',
      shopName: map['shopName'] ?? '',
      shopAddress: map['shopAddress'],
      shopPhone: map['shopPhone'],
      shopEmail: map['shopEmail'],
      gstNumber: map['gstNumber'],
      panNumber: map['panNumber'],
      createdAt: DateTime.parse(map['createdAt']),
      lastLoginAt: DateTime.parse(map['lastLoginAt']),
      isActive: map['isActive'] ?? true,
      isEmailVerified: map['isEmailVerified'] ?? false,
      isPhoneVerified: map['isPhoneVerified'] ?? false,
      profileImageUrl: map['profileImageUrl'],
      permissions: Map<String, bool>.from(map['permissions'] ?? {}),
      deviceToken: map['deviceToken'],
      assignedStores: List<String>.from(map['assignedStores'] ?? []),
      salesTarget: (map['salesTarget'] ?? 0).toDouble(),
      preferredLanguage: map['preferredLanguage'] ?? 'en',
      notes: map['notes'],
    );
  }

  // Create from Firestore Document
  factory UserModel.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data['id'] = doc.id;
    return UserModel.fromMap(data);
  }

  // Create copy with updates
  UserModel copyWith({
    String? name,
    String? email,
    String? phone,
    String? role,
    String? shopName,
    String? shopAddress,
    String? shopPhone,
    String? shopEmail,
    String? gstNumber,
    String? panNumber,
    DateTime? lastLoginAt,
    bool? isActive,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    String? profileImageUrl,
    Map<String, bool>? permissions,
    String? deviceToken,
    List<String>? assignedStores,
    double? salesTarget,
    String? preferredLanguage,
    String? notes,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      shopName: shopName ?? this.shopName,
      shopAddress: shopAddress ?? this.shopAddress,
      shopPhone: shopPhone ?? this.shopPhone,
      shopEmail: shopEmail ?? this.shopEmail,
      gstNumber: gstNumber ?? this.gstNumber,
      panNumber: panNumber ?? this.panNumber,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isActive: isActive ?? this.isActive,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      permissions: permissions ?? this.permissions,
      deviceToken: deviceToken ?? this.deviceToken,
      assignedStores: assignedStores ?? this.assignedStores,
      salesTarget: salesTarget ?? this.salesTarget,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      notes: notes ?? this.notes,
    );
  }

  // Role checks
  bool get isAdmin => role == 'admin';
  bool get isCashier => role == 'cashier';
  bool get isManager => role == 'manager';
  bool get isOwner => role == 'owner';

  // Permission checks
  bool hasPermission(String permission) {
    if (isOwner || isAdmin)
      return true; // Owners and admins have all permissions
    return permissions[permission] ?? false;
  }

  bool get canManageProducts => hasPermission('manage_products');
  bool get canViewReports => hasPermission('view_reports');
  bool get canManageCustomers => hasPermission('manage_customers');
  bool get canProcessRefunds => hasPermission('process_refunds');
  bool get canManageUsers => hasPermission('manage_users');
  bool get canManageSettings => hasPermission('manage_settings');
  bool get canDeleteSales => hasPermission('delete_sales');
  bool get canGiveDiscounts => hasPermission('give_discounts');

  // Status checks
  bool get isFullyVerified => isEmailVerified && isPhoneVerified;
  bool get needsVerification => !isEmailVerified || !isPhoneVerified;

  // Get initials for avatar
  String get initials {
    final names = name.trim().split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }

  // Get role display name
  String get roleDisplayName {
    switch (role.toLowerCase()) {
      case 'admin':
        return 'Administrator';
      case 'cashier':
        return 'Cashier';
      case 'manager':
        return 'Manager';
      case 'owner':
        return 'Owner';
      default:
        return role.toUpperCase();
    }
  }

  // Get default permissions by role
  static Map<String, bool> getDefaultPermissions(String role) {
    switch (role.toLowerCase()) {
      case 'owner':
        return {
          'manage_products': true,
          'view_reports': true,
          'manage_customers': true,
          'process_refunds': true,
          'manage_users': true,
          'manage_settings': true,
          'delete_sales': true,
          'give_discounts': true,
        };
      case 'admin':
        return {
          'manage_products': true,
          'view_reports': true,
          'manage_customers': true,
          'process_refunds': true,
          'manage_users': false,
          'manage_settings': true,
          'delete_sales': true,
          'give_discounts': true,
        };
      case 'manager':
        return {
          'manage_products': true,
          'view_reports': true,
          'manage_customers': true,
          'process_refunds': true,
          'manage_users': false,
          'manage_settings': false,
          'delete_sales': false,
          'give_discounts': true,
        };
      case 'cashier':
        return {
          'manage_products': false,
          'view_reports': false,
          'manage_customers': true,
          'process_refunds': false,
          'manage_users': false,
          'manage_settings': false,
          'delete_sales': false,
          'give_discounts': false,
        };
      default:
        return {};
    }
  }

  @override
  String toString() {
    return 'UserModel{id: $id, name: $name, role: $role, shopName: $shopName}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// User Role Enum
enum UserRole {
  owner('Owner'),
  admin('Administrator'),
  manager('Manager'),
  cashier('Cashier');

  const UserRole(this.displayName);
  final String displayName;
}

// User Statistics for Admin Dashboard
class UserStatistics {
  final int totalUsers;
  final int activeUsers;
  final int adminUsers;
  final int managerUsers;
  final int cashierUsers;
  final int verifiedUsers;
  final DateTime lastActivity;

  UserStatistics({
    required this.totalUsers,
    required this.activeUsers,
    required this.adminUsers,
    required this.managerUsers,
    required this.cashierUsers,
    required this.verifiedUsers,
    required this.lastActivity,
  });
}
