import 'package:flutter/material.dart';

import '../dashboard/dashboard_screen.dart';
import '../debt/debt_screen.dart';
import '../history/history_screen.dart';
import '../cash/cash_screen.dart';
import '../master/master_layanan_screen.dart';
import '../../core/design/app_colors.dart';
import '../../core/design/app_spacing.dart';
import '../../core/design/app_typography.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  late PageController _pageController;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const HistoryScreen(),
    const DebtScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onItemTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics:
            const NeverScrollableScrollPhysics(), // Disable swipe to keep navigation clean
        children: _screens,
      ),
      drawer: _buildDrawer(context),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.book_outlined),
            selectedIcon: Icon(Icons.book),
            label: 'Debt',
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildDrawerHeader(),
          _buildCategoryLabel('MANAJEMEN MASTER'),
          _buildDrawerItem(
            icon: Icons.account_balance_wallet_outlined,
            label: 'Manajemen Saldo',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CashScreen()),
              );
            },
          ),
          _buildDrawerItem(
            icon: Icons.settings_suggest_outlined,
            label: 'Master Layanan',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MasterLayananScreen(),
                ),
              );
            },
          ),
          const Divider(height: AppSpacing.xl, indent: 20, endIndent: 20),
          _buildDrawerItem(
            icon: Icons.logout,
            label: 'Keluar',
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return UserAccountsDrawerHeader(
      decoration: const BoxDecoration(color: AppColors.primary),
      currentAccountPicture: const CircleAvatar(
        backgroundColor: Colors.white,
        child: Icon(Icons.person, color: AppColors.primary, size: 40),
      ),
      accountName: Text(
        'Toko Maju Jaya',
        style: AppTypography.bodyLarge.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      accountEmail: Text(
        'ID Agen: AG882910',
        style: AppTypography.bodyMedium.copyWith(color: Colors.white70),
      ),
    );
  }

  Widget _buildCategoryLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Text(
        label,
        style: AppTypography.labelMedium.copyWith(
          color: AppColors.onSurfaceVariant.withOpacity(0.5),
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isActive ? AppColors.primary : AppColors.onSurfaceVariant,
        size: 24,
      ),
      title: Text(
        label,
        style: AppTypography.bodyMedium.copyWith(
          color: isActive ? AppColors.primary : AppColors.onSurface,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        size: 18,
        color: AppColors.outlineVariant,
      ),
      selected: isActive,
      selectedTileColor: AppColors.primaryContainer.withOpacity(0.1),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      onTap: onTap,
    );
  }
}
