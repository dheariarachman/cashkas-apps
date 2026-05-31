import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/components/financial_card.dart';
import '../../core/design/app_colors.dart';
import '../../core/design/app_spacing.dart';
import '../../core/design/app_typography.dart';
import '../../core/models/transaction_model.dart';
import '../../core/providers/financial_provider.dart';
import '../../core/components/status_badge.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final ScrollController _scrollController = ScrollController();
  String _selectedPeriod = 'Harian';
  bool _isInitialLoading = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _initData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<FinancialProvider>().loadMoreHistory(period: _selectedPeriod);
    }
  }

  Future<void> _initData() async {
    await context.read<FinancialProvider>().refreshHistory(period: _selectedPeriod);
    if (mounted) {
      setState(() {
        _isInitialLoading = false;
      });
    }
  }

  String _formatCurrency(double amount) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(amount);
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return DateFormat('HH:mm • dd MMM').format(date);
    } catch (e) {
      return isoDate;
    }
  }

  IconData _getIconForType(TransactionType type) {
    switch (type) {
      case TransactionType.transfer: return Icons.account_balance_outlined;
      case TransactionType.withdrawal: return Icons.account_balance_wallet_outlined;
      case TransactionType.topup: return Icons.phone_android_outlined;
      case TransactionType.ppob: return Icons.bolt;
      default: return Icons.receipt_long_outlined;
    }
  }

  Color _getIconColorForType(TransactionType type) {
    switch (type) {
      case TransactionType.transfer: return Colors.blue;
      case TransactionType.withdrawal: return Colors.indigo;
      case TransactionType.topup: return Colors.blueAccent;
      case TransactionType.ppob: return Colors.orange;
      default: return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.history, color: AppColors.primary),
          onPressed: () {},
        ),
        title: Text(
          'History',
          style: AppTypography.headlineSmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: AppColors.onSurfaceVariant),
            onPressed: () {},
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isInitialLoading 
          ? const Center(child: CircularProgressIndicator()) 
          : Consumer<FinancialProvider>(
              builder: (context, financial, _) => RefreshIndicator(
                onRefresh: () => financial.refreshHistory(period: _selectedPeriod),
                child: ListView.builder(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(AppSpacing.gridMargin),
                  itemCount: financial.historyTransactions.length + 2, // Header, Summary + List items + Loader
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildPeriodFilter(),
                          const SizedBox(height: AppSpacing.lg),
                          _buildSummaryCard(financial),
                          const SizedBox(height: AppSpacing.lg),
                          _buildListHeader(),
                          const SizedBox(height: AppSpacing.sm),
                        ],
                      );
                    }
                    
                    final txIndex = index - 1;
                    if (txIndex < financial.historyTransactions.length) {
                      final t = financial.historyTransactions[txIndex];
                      return FinancialCard(
                        title: t.type.name.toUpperCase(),
                        timestamp: _formatDate(t.createdAt),
                        formattedAmount: _formatCurrency(t.amount + t.fee),
                        formattedProfit: '+${_formatCurrency(t.profit)}',
                        type: t.type,
                        badgeStatus: t.status == TransactionStatus.lunas ? BadgeStatus.lunas : BadgeStatus.piutang,
                        badgeLabel: t.status == TransactionStatus.lunas ? 'Lunas' : 'Piutang',
                        icon: _getIconForType(t.type),
                        iconColor: _getIconColorForType(t.type),
                        iconBackgroundColor: _getIconColorForType(t.type).withOpacity(0.1),
                        leftBorderColor: t.status == TransactionStatus.piutang ? Colors.orange : null,
                        onTap: () {},
                      );
                    }

                    if (financial.hasMoreHistory) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    if (financial.historyTransactions.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 48),
                        child: Center(child: Text('Belum ada riwayat transaksi')),
                      );
                    }

                    return const SizedBox(height: 32);
                  },
                ),
              ),
            ),
    );
  }

  Widget _buildPeriodFilter() {
    final periods = ['Harian', 'Mingguan', 'Bulanan'];
    return Row(
      children: periods.map((period) {
        final isSelected = _selectedPeriod == period;
        return Padding(
          padding: const EdgeInsets.only(right: AppSpacing.sm),
          child: ChoiceChip(
            label: Text(period),
            selected: isSelected,
            onSelected: (selected) {
              if (selected) {
                setState(() => _selectedPeriod = period);
                context.read<FinancialProvider>().refreshHistory(period: period);
              }
            },
            selectedColor: const Color(0xFF003D9B),
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 12,
            ),
            shape: StadiumBorder(
              side: BorderSide(
                color: isSelected ? Colors.transparent : AppColors.outlineVariant,
              ),
            ),
            showCheckmark: false,
            padding: const EdgeInsets.symmetric(horizontal: 12),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSummaryCard(FinancialProvider financial) {
    // Note: Summary card uses totalProfit and totalTransactions filtered by the same period
    // We already updated FinancialProvider.refreshHistory to fetch these.
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TOTAL PROFIT (ESTIMASI)',
                    style: AppTypography.labelMd.copyWith(
                      color: AppColors.onSurfaceVariant,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatCurrency(financial.totalProfit),
                    style: AppTypography.headlineMd.copyWith(
                      color: AppColors.primary,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.trending_up, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Transaksi', style: AppTypography.bodySm.copyWith(color: AppColors.outline)),
                    Text('${financial.totalTransactions} Total', style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Container(width: 1, height: 30, color: AppColors.outlineVariant.withOpacity(0.5)),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Periode', style: AppTypography.bodySm.copyWith(color: AppColors.outline)),
                    Text(_selectedPeriod, style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildListHeader() {
    final now = DateTime.now();
    final monthName = DateFormat('MMMM yyyy').format(now).toUpperCase();
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Riwayat Transaksi',
          style: AppTypography.bodyLg.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          monthName,
          style: AppTypography.labelMd.copyWith(color: AppColors.outline, fontSize: 10),
        ),
      ],
    );
  }
}
