import 'package:cashkas/core/utils/currency_formatter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/design/app_colors.dart';
import '../../core/design/app_spacing.dart';
import '../../core/design/app_shapes.dart';
import '../../core/design/app_typography.dart';
import '../../core/design/app_elevation.dart';
import '../../core/database/database_helper.dart';
import '../../core/models/debt_model.dart';
import '../../core/models/transaction_model.dart';
import '../../core/providers/financial_provider.dart';

class DebtScreen extends StatefulWidget {
  const DebtScreen({super.key});

  @override
  State<DebtScreen> createState() => _DebtScreenState();
}

class _DebtScreenState extends State<DebtScreen>
    with AutomaticKeepAliveClientMixin {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  bool get wantKeepAlive => true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    await context.read<FinancialProvider>().refreshAllData();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatCurrency(double amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return isoDate;
    }
  }

  Future<void> _settleDebt(Map<String, dynamic> debt) async {
    try {
      await _dbHelper.updateDebtStatus(debt['id'], DebtStatus.paid);
      if (mounted) {
        context.read<FinancialProvider>().refreshAllData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Piutang berhasil dilunasi')),
        );
      }
    } catch (e) {
      debugPrint('Error settling debt: $e');
    }
  }

  void _showAddDebtModal() {
    final nameController = TextEditingController();
    final amountController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          top: AppSpacing.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Tambah Piutang Baru',
              style: AppTypography.headlineMd.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'NAMA PELANGGAN',
              style: AppTypography.labelMd.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            TextField(
              controller: nameController,
              style: AppTypography.bodyLg,
              decoration: InputDecoration(
                hintText: 'Masukkan nama pelanggan',
                hintStyle: AppTypography.bodyMd.copyWith(color: Colors.grey),
                filled: true,
                fillColor: AppColors.surfaceContainerLow,
                border: OutlineInputBorder(
                  borderRadius: AppShapes.borderRadiusMd,
                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.1)),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'NOMINAL PIUTANG',
              style: AppTypography.labelMd.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              style: AppTypography.bodyLg,
              inputFormatters: [CurrencyInputFormatter()],
              decoration: InputDecoration(
                prefixText: 'Rp ',
                filled: true,
                fillColor: AppColors.surfaceContainerLow,
                border: OutlineInputBorder(
                  borderRadius: AppShapes.borderRadiusMd,
                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.1)),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () async {
                  final name = nameController.text;
                  final amount =
                      double.tryParse(
                        amountController.text.replaceAll(RegExp(r'[^0-9]'), ''),
                      ) ??
                      0;
                  if (name.isEmpty || amount <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Nama dan nominal harus diisi dengan benar',
                        ),
                      ),
                    );
                    return;
                  }
                  try {
                    final transaction = TransactionModel(
                      walletId: 1,
                      type: TransactionType.other,
                      amount: amount,
                      fee: 0,
                      cost: 0,
                      profit: 0,
                      status: TransactionStatus.piutang,
                      createdAt: DateTime.now().toIso8601String(),
                    );
                    final txId = await _dbHelper.insertTransaction(transaction);
                    final debt = DebtModel(
                      customerName: name,
                      amount: amount,
                      transactionId: txId,
                      status: DebtStatus.pending,
                    );
                    await _dbHelper.insertDebt(debt);
                    if (mounted) {
                      Navigator.pop(context);
                      context.read<FinancialProvider>().refreshAllData();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Piutang baru berhasil dicatat'),
                        ),
                      );
                    }
                  } catch (e) {
                    debugPrint('Error saving debt: $e');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppShapes.borderRadiusMd,
                  ),
                ),
                child: const Text(
                  'Simpan Piutang',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(
          'Buku Piutang',
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: AppColors.primary),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.more_vert,
              color: AppColors.onSurfaceVariant,
              size: 20,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Consumer<FinancialProvider>(
        builder: (context, financial, _) => RefreshIndicator(
          onRefresh: () => financial.refreshAllData(),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.gridMargin,
                    vertical: AppSpacing.sm,
                  ),
                  children: [
                    _buildTotalDebtCard(financial.totalDebt),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'DAFTAR PIUTANG AKTIF',
                          style: AppTypography.labelMd.copyWith(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              'Urutkan',
                              style: AppTypography.bodySm.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Icon(
                              Icons.keyboard_arrow_down,
                              size: 14,
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    if (financial.debts.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(child: Text('Tidak ada piutang aktif')),
                      )
                    else
                      ...financial.debts.map((debt) => _buildDebtCard(debt)),
                    const SizedBox(height: 80),
                  ],
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDebtModal,
        backgroundColor: AppColors.primary,
        mini: true,
        child: const Icon(Icons.add, color: Colors.white, size: 24),
      ),
    );
  }

  Widget _buildTotalDebtCard(double totalDebt) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppShapes.borderRadiusMd,
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TOTAL PIUTANG BERJALAN',
            style: AppTypography.labelMd.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Rp ',
                style: AppTypography.headlineSmall.copyWith(
                  color: Colors.orange[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 500),
                tween: Tween(begin: 0, end: totalDebt),
                builder: (context, value, child) => Text(
                  NumberFormat.currency(
                    locale: 'id_ID',
                    symbol: '',
                    decimalDigits: 0,
                  ).format(value),
                  style: AppTypography.headlineLg.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.trending_up, color: Colors.green, size: 12),
                const SizedBox(width: 4),
                Text(
                  '12%',
                  style: AppTypography.bodySm.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'dari bulan lalu',
                  style: AppTypography.bodySm.copyWith(
                    color: Colors.grey[600],
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDebtCard(Map<String, dynamic> debt) {
    bool isOverdue = false;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      debt['customer_name'] ?? 'Unknown',
                      style: AppTypography.bodyMd.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 12,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Dibuat ${_formatDate(debt['created_at'] ?? '')}',
                          style: AppTypography.bodySm.copyWith(
                            fontSize: 10,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isOverdue
                        ? const Color(0xFFFFF1F1)
                        : const Color(0xFFFFF8E7),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    isOverdue ? 'JATUH TEMPO' : 'MENUNGGU',
                    style: TextStyle(
                      color: isOverdue ? Colors.red[700] : Colors.orange[700],
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.outlineVariant.withOpacity(0.2)),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'JUMLAH PIUTANG',
                        style: AppTypography.labelMd.copyWith(
                          fontSize: 9,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatCurrency(
                          (debt['amount'] as num?)?.toDouble() ?? 0,
                        ),
                        style: AppTypography.numericMd.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 36,
                  width: 100,
                  child: ElevatedButton.icon(
                    onPressed: () => _settleDebt(debt),
                    icon: const Icon(Icons.check_circle, size: 12),
                    label: const Text('Lunas', style: TextStyle(fontSize: 10)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF004496),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
