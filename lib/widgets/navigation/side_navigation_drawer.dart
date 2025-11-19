import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_colors.dart';
import '../../models/navigation_models.dart';

class SideNavigationDrawer extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const SideNavigationDrawer({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

  static final List<NavigationGroup> _drawerGroups = [
    NavigationGroup(
      title: 'Main',
      items: [
        NavigationItem(
          icon: Icons.dashboard_rounded,
          label: 'Dashboard',
          color: AppColors.primaryColor,
          index: 0,
        ),
        NavigationItem(
          icon: Icons.inventory_2_rounded,
          label: 'Stock Items',
          color: AppColors.success,
          index: 1,
        ),
        NavigationItem(
          icon: Icons.receipt_long_rounded,
          label: 'Purchase Order',
          color: AppColors.warning,
          index: 2,
        ),
        NavigationItem(
          icon: Icons.point_of_sale_rounded,
          label: 'Sales Order',
          color: AppColors.info,
          index: 3,
        ),
      ],
    ),
    NavigationGroup(
      title: 'Masters',
      isExpandable: true,
      items: [
        NavigationItem(
          icon: Icons.people_rounded,
          label: 'Customers',
          color: AppColors.textGrey,
          index: 5,
        ),
        NavigationItem(
          icon: Icons.local_shipping_rounded,
          label: 'Suppliers',
          color: AppColors.textGrey,
          index: 6,
        ),
        NavigationItem(
          icon: Icons.category_rounded,
          label: 'Stock Categories',
          color: AppColors.textGrey,
          index: 7,
        ),
        NavigationItem(
          icon: Icons.calculate_rounded,
          label: 'Manage Taxes',
          color: AppColors.textGrey,
          index: 8,
        ),
      ],
    ),
    NavigationGroup(
      title: 'Data Management',
      isExpandable: true,
      items: [
        NavigationItem(
          icon: Icons.cloud_upload_rounded,
          label: 'Import Data',
          color: AppColors.textGrey,
          index: 9,
        ),
        NavigationItem(
          icon: Icons.backup_rounded,
          label: 'Export Data',
          color: AppColors.textGrey,
          index: 10,
        ),
      ],
    ),
    NavigationGroup(
      title: 'Reports',
      isExpandable: true,
      items: [
        NavigationItem(
          icon: Icons.analytics_rounded,
          label: 'Daily Activity Report',
          color: AppColors.textGrey,
          index: 11,
        ),
        NavigationItem(
          icon: Icons.trending_up_rounded,
          label: 'Sales Report',
          color: AppColors.textGrey,
          index: 12,
        ),
        NavigationItem(
          icon: Icons.shopping_cart_rounded,
          label: 'Purchase Report',
          color: AppColors.textGrey,
          index: 13,
        ),
        NavigationItem(
          icon: Icons.inventory_rounded,
          label: 'Low Stock Items Report',
          color: AppColors.textGrey,
          index: 14,
        ),
        NavigationItem(
          icon: Icons.assignment_rounded,
          label: 'Sales Outstanding',
          color: AppColors.textGrey,
          index: 15,
        ),
        NavigationItem(
          icon: Icons.assignment_late_rounded,
          label: 'Purchase Outstanding',
          color: AppColors.textGrey,
          index: 16,
        ),
      ],
    ),
    NavigationGroup(
      title: 'User Management',
      isExpandable: true,
      items: [
        NavigationItem(
          icon: Icons.person_rounded,
          label: 'User Info',
          color: AppColors.textGrey,
          index: 17,
        ),
        NavigationItem(
          icon: Icons.security_rounded,
          label: 'User Access Management',
          color: AppColors.textGrey,
          index: 18,
        ),
        NavigationItem(
          icon: Icons.account_circle_rounded,
          label: 'My Profile',
          color: AppColors.textGrey,
          index: 19,
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF2C3E50),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: _drawerGroups.length,
              itemBuilder: (context, groupIndex) {
                final group = _drawerGroups[groupIndex];
                return _buildNavigationGroup(group, groupIndex, context);
              },
            ),
          ),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF34495E), Color(0xFF2C3E50)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white24,
            child: Icon(Icons.store_rounded, size: 40, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            'VShop Pro',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            'Inventory Management',
            style: GoogleFonts.inter(fontSize: 14, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationGroup(
    NavigationGroup group,
    int groupIndex,
    BuildContext context,
  ) {
    return ExpansionTile(
      title: Text(
        group.title,
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      iconColor: Colors.white,
      collapsedIconColor: Colors.white,
      initiallyExpanded: groupIndex == 0,
      children:
          group.items.map((item) {
            return ListTile(
              leading: Icon(
                item.icon,
                color:
                    selectedIndex == item.index
                        ? AppColors.primaryColor
                        : Colors.white70,
                size: 20,
              ),
              title: Text(
                item.label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight:
                      selectedIndex == item.index
                          ? FontWeight.w600
                          : FontWeight.w400,
                  color:
                      selectedIndex == item.index
                          ? Colors.white
                          : Colors.white70,
                ),
              ),
              selected: selectedIndex == item.index,
              selectedTileColor: Colors.white10,
              onTap: () {
                onItemTapped(item.index);
                Navigator.pop(context);
              },
            );
          }).toList(),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 16),
          Text(
            'VShop v1.0.0',
            style: GoogleFonts.inter(fontSize: 12, color: Colors.white54),
          ),
        ],
      ),
    );
  }
}
