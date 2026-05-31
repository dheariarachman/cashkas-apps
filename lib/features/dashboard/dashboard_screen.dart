import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/design/app_colors.dart';
import '../../core/design/app_spacing.dart';
import '../../core/design/app_shapes.dart';
import '../../core/design/app_typography.dart';
import '../../core/design/app_elevation.dart';
import '../../core/providers/financial_provider.dart';
import '../transaction/new_transaction_bottom_sheet.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  String _selectedFilter = 'Hari Ini';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    await context.read<FinancialProvider>().refreshAllData(period: _selectedFilter);
    if (mounted) setState(() => _isLoading = false);
  }

  String _formatCurrency(double amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: AppColors.primary),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
        title: Text(
          'Dashboard',
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () => context.read<FinancialProvider>().refreshAllData(period: _selectedFilter),
            icon: const Icon(Icons.refresh, color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
      body: Consumer<FinancialProvider>(
        builder: (context, financial, _) => SafeArea(
          child: RefreshIndicator(
            onRefresh: () => financial.refreshAllData(period: _selectedFilter),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.gridMargin,
                vertical: AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFilterChips(),
                  const SizedBox(height: AppSpacing.lg),
                  _buildMainProfitCard(financial.totalProfit),
                  const SizedBox(height: AppSpacing.md),
                  _buildBalanceCards(financial),
                  const SizedBox(height: AppSpacing.md),
                  _buildSummaryCards(financial),
                  const SizedBox(height: AppSpacing.md),
                  if (financial.debtCount > 0) ...[
                    _buildWarningCard(financial.debtCount, financial.totalDebt),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  _buildActivitySection(financial.weeklyActivity),
                  const SizedBox(height: AppSpacing.xl * 2),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.white,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            builder: (context) => const NewTransactionBottomSheet(),
          );
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['Hari Ini', 'Minggu Ini', 'Bulan Ini'];
    return Row(
      children: filters.map((filter) {
        final isSelected = _selectedFilter == filter;
        return Padding(
          padding: const EdgeInsets.only(right: AppSpacing.sm),
          child: ChoiceChip(
            label: Text(filter),
            selected: isSelected,
            onSelected: (selected) {
              if (selected) {
                setState(() => _selectedFilter = filter);
                context.read<FinancialProvider>().refreshAllData(period: filter);
              }
            },
            selectedColor: const Color(0xFF003D9B),
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            shape: StadiumBorder(
              side: BorderSide(
                color: isSelected
                    ? Colors.transparent
                    : AppColors.outlineVariant,
              ),
            ),
            showCheckmark: false,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMainProfitCard(double profit) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppShapes.borderRadiusLg,
        boxShadow: AppElevation.level1,
        border: const Border(
          left: BorderSide(color: AppColors.primary, width: 4),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TOTAL PROFIT BERSIH',
                  style: AppTypography.labelMedium.copyWith(
                    letterSpacing: 1.2,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 500),
                  tween: Tween(begin: 0, end: profit),
                  builder: (context, value, child) => Text(
                    _formatCurrency(value),
                    style: AppTypography.displayLarge.copyWith(
                      color: AppColors.primary,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    const Icon(
                      Icons.trending_up,
                      color: AppColors.success,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '+12.5% dari kemarin',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F7FF),
              borderRadius: AppShapes.borderRadiusMd,
            ),
            child: const Icon(
              Icons.account_balance_wallet,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCards(FinancialProvider financial) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          SizedBox(
            width: 160,
            child: _buildSmallBalanceCard(
              'Saldo Digital',
              financial.digitalBalance,
              Icons.account_balance,
              AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          SizedBox(
            width: 160,
            child: _buildSmallBalanceCard(
              'Saldo Laci (Cash)',
              financial.cashBalance,
              Icons.wallet,
              AppColors.success,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          SizedBox(
            width: 160,
            child: _buildSmallBalanceCard(
              'Total Piutang',
              financial.totalDebt,
              Icons.book_outlined,
              AppColors.tertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallBalanceCard(
    String title,
    double amount,
    IconData icon,
    Color accentColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppShapes.borderRadiusLg,
        boxShadow: AppElevation.level1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: accentColor),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.labelMedium.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 500),
            tween: Tween(begin: 0, end: amount),
            builder: (context, value, child) => Text(
              _formatCurrency(value),
              style: AppTypography.numericMd.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            height: 4,
            width: double.infinity,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: 0.6,
              child: Container(
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(FinancialProvider financial) {
    return Column(
      children: [
        _buildSummaryItem(
          'Total Omset',
          _formatCurrency(financial.totalOmset),
          Icons.receipt_long,
        ),
        const SizedBox(height: AppSpacing.md),
        _buildSummaryItem(
          'Total Transaksi',
          '${financial.totalTransactions} Sukses',
          Icons.swap_horiz,
        ),
      ],
    );
  }

  Widget _buildSummaryItem(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppShapes.borderRadiusLg,
        boxShadow: AppElevation.level1,
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F7FF),
              borderRadius: AppShapes.borderRadiusMd,
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: AppTypography.numericMd.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: AppColors.outlineVariant,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildWarningCard(int count, double amount) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F5),
        borderRadius: AppShapes.borderRadiusLg,
        border: Border.all(color: const Color(0xFFFFE0E0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: AppColors.error,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.priority_high,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Piutang Pelanggan',
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(height: 2),
                RichText(
                  text: TextSpan(
                    style: AppTypography.bodyMedium.copyWith(
                      color: const Color(0xFF93000A),
                    ),
                    children: [
                      TextSpan(
                        text: 'Terdapat $count tagihan piutang senilai ',
                      ),
                      TextSpan(
                        text: _formatCurrency(amount),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivitySection(List<double> activity) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Aktivitas Minggu Ini',
          style: AppTypography.headlineSmall.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          height: 200,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F7FF),
            borderRadius: AppShapes.borderRadiusLg,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: activity.asMap().entries.map((entry) {
              double maxVal = activity.reduce((a, b) => a > b ? a : b);
              if (maxVal == 0) maxVal = 1;
              double heightFactor = (entry.value / maxVal) * 150;
              return _buildBar(
                heightFactor,
                isHighlight: entry.value == maxVal && entry.value > 0,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildBar(double height, {bool isHighlight = false}) {
    return Container(
      width: 32,
      height: height.clamp(10, 150),
      decoration: BoxDecoration(
        color: isHighlight ? const Color(0xFF004496) : const Color(0xFFADC6FF),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
      ),
    );
  }
}
