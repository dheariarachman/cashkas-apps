import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../dashboard/dashboard_screen.dart';
import '../debt/debt_screen.dart';
import '../history/history_screen.dart';
import '../cash/cash_screen.dart';
import '../master/master_layanan_screen.dart';
import '../../core/design/app_colors.dart';
import '../../core/design/app_spacing.dart';
import '../../core/design/app_typography.dart';
import '../../core/providers/financial_provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late PageController _pageController;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const HistoryScreen(),
    const DebtScreen(),
  ];

  @override
  void initState() {
    super.initState();
    final initialTab = context.read<FinancialProvider>().currentTabIndex;
    _pageController = PageController(initialPage: initialTab);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    context.read<FinancialProvider>().setTabIndex(index);
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
    return Consumer<FinancialProvider>(
      builder: (context, provider, _) {
        // Ensure PageController is in sync with provider index if changed externally
        if (_pageController.hasClients &&
            _pageController.page?.round() != provider.currentTabIndex) {
          _pageController.animateToPage(
            provider.currentTabIndex,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutCubic,
          );
        }

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
            selectedIndex: provider.currentTabIndex,
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
      },
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
        style: AppTypography.bodyLg.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      accountEmail: Text(
        'ID Agen: AG882910',
        style: AppTypography.bodyMd.copyWith(color: Colors.white70),
      ),
    );
  }

  Widget _buildCategoryLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Text(
        label,
        style: AppTypography.labelMd.copyWith(
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
        style: AppTypography.bodyMd.copyWith(
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
