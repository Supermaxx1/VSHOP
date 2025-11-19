import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../providers/theme_provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/common/glassmorphism_container.dart';
import '../../widgets/navigation/side_navigation_drawer.dart';
import 'dashboard_screen.dart';
import '../inventory/inventory_screen.dart';
import '../billing/billing_screen.dart';
import '../reports/reports_screen.dart';
import '../settings/settings_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({Key? key}) : super(key: key);

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageController;
  late AnimationController _fabAnimationController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Widget> _screens = [
    const DashboardScreen(),
    const InventoryScreen(),
    const BillingScreen(),
    const ReportsScreen(),
    const SettingsScreen(),
  ];

  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.dashboard_rounded,
      label: 'Dashboard',
      color: AppColors.primaryColor,
    ),
    NavigationItem(
      icon: Icons.inventory_2_rounded,
      label: 'Stock',
      color: AppColors.success,
    ),
    NavigationItem(
      icon: Icons.receipt_long_rounded,
      label: 'Billing',
      color: AppColors.warning,
    ),
    NavigationItem(
      icon: Icons.analytics_rounded,
      label: 'Reports',
      color: AppColors.info,
    ),
    NavigationItem(
      icon: Icons.settings_rounded,
      label: 'Settings',
      color: AppColors.textGrey,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          _getScreenTitle(),
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF2C3E50),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Search functionality
            },
            icon: const Icon(Icons.search, color: Colors.white),
          ),
          IconButton(
            onPressed: () {
              // More options
            },
            icon: const Icon(Icons.more_vert, color: Colors.white),
          ),
        ],
      ),
      drawer: SideNavigationDrawer(
        selectedIndex: _currentIndex,
        onItemTapped: (index) {
          // Handle side navigation taps
          if (index <= 4) {
            // Main navigation items (0-4)
            setState(() {
              _currentIndex = index;
            });
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          } else {
            // Additional navigation items
            _handleAdditionalNavigation(index);
          }
        },
      ),
      body: PageView(
        controller: _pageController,
        children: _screens,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      bottomNavigationBar: _buildBottomNavigationBar(isDarkMode),
      floatingActionButton:
          _currentIndex == 2 ? _buildFloatingActionButton() : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  String _getScreenTitle() {
    switch (_currentIndex) {
      case 0:
        return 'VShop - Dashboard';
      case 1:
        return 'Inventory Manager';
      case 2:
        return 'Billing System';
      case 3:
        return 'Reports & Analytics';
      case 4:
        return 'Settings';
      default:
        return 'VShop Pro';
    }
  }

  void _handleAdditionalNavigation(int index) {
    // Handle additional navigation items from side drawer
    String screenName = '';
    switch (index) {
      case 5:
        screenName = 'Customers';
        break;
      case 6:
        screenName = 'Suppliers';
        break;
      case 7:
        screenName = 'Stock Categories';
        break;
      case 8:
        screenName = 'Manage Taxes';
        break;
      case 9:
        screenName = 'Import Data';
        break;
      case 10:
        screenName = 'Export Data';
        break;
      case 11:
        screenName = 'Daily Activity Report';
        break;
      case 12:
        screenName = 'Sales Report';
        break;
      case 13:
        screenName = 'Purchase Report';
        break;
      case 14:
        screenName = 'Low Stock Items Report';
        break;
      case 15:
        screenName = 'Sales Outstanding';
        break;
      case 16:
        screenName = 'Purchase Outstanding';
        break;
      case 17:
        screenName = 'User Info';
        break;
      case 18:
        screenName = 'User Access Management';
        break;
      case 19:
        screenName = 'My Profile';
        break;
    }

    // Show a placeholder screen or navigate to specific screens
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => Scaffold(
              appBar: AppBar(
                title: Text(screenName),
                backgroundColor: const Color(0xFF2C3E50),
                foregroundColor: Colors.white,
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.construction, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      '$screenName',
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Coming Soon!',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: GlassmorphismContainer(
          blur: 20,
          opacity: isDarkMode ? 0.2 : 0.1,
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onTabTapped,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: AppColors.primaryColor,
            unselectedItemColor: AppColors.textMuted,
            selectedLabelStyle: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
            items:
                _navigationItems.map((item) {
                  final index = _navigationItems.indexOf(item);
                  return BottomNavigationBarItem(
                    icon: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color:
                            _currentIndex == index
                                ? item.color.withOpacity(0.1)
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        item.icon,
                        size: _currentIndex == index ? 28 : 24,
                        color:
                            _currentIndex == index
                                ? item.color
                                : AppColors.textMuted,
                      ),
                    ),
                    label: item.label,
                  );
                }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return ScaleTransition(
      scale: _fabAnimationController,
      child: FloatingActionButton.extended(
        onPressed: () {
          // Quick sale action
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Quick Sale feature coming soon!',
                style: GoogleFonts.inter(color: Colors.white),
              ),
              backgroundColor: AppColors.success,
            ),
          );
        },
        backgroundColor: AppColors.primaryColor,
        elevation: 8,
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add_shopping_cart_rounded, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              'Quick Sale',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onTabTapped(int index) {
    if (index != _currentIndex) {
      setState(() {
        _currentIndex = index;
      });
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );

      if (index == 2) {
        _fabAnimationController.forward();
      } else {
        _fabAnimationController.reverse();
      }
    }
  }
}

class NavigationItem {
  final IconData icon;
  final String label;
  final Color color;

  NavigationItem({
    required this.icon,
    required this.label,
    required this.color,
  });
}
