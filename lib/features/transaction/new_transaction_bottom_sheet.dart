import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/design/app_colors.dart';
import '../../core/design/app_spacing.dart';
import '../../core/design/app_shapes.dart';
import '../../core/design/app_typography.dart';
import '../../core/database/database_helper.dart';
import '../../core/models/transaction_model.dart';
import '../../core/models/wallet_model.dart';
import '../../core/models/service_model.dart';
import '../../core/models/debt_model.dart';
import '../../core/providers/financial_provider.dart';
import '../../core/utils/currency_formatter.dart';

class NewTransactionBottomSheet extends StatefulWidget {
  const NewTransactionBottomSheet({super.key});

  @override
  State<NewTransactionBottomSheet> createState() => _NewTransactionBottomSheetState();
}

class _NewTransactionBottomSheetState extends State<NewTransactionBottomSheet> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  final TextEditingController _modalController = TextEditingController(text: '0');
  final TextEditingController _receivedController = TextEditingController(text: '0');
  final TextEditingController _customerNameController = TextEditingController();
  
  ServiceModel? _selectedService;
  WalletModel? _selectedWallet;
  bool _isDebt = false;

  List<ServiceModel> _availableServices = [];
  List<WalletModel> _availableWallets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _modalController.addListener(_onFieldChanged);
    _receivedController.addListener(_onFieldChanged);
  }

  @override
  void dispose() {
    _modalController.dispose();
    _receivedController.dispose();
    _customerNameController.dispose();
    super.dispose();
  }

  void _onFieldChanged() {
    setState(() {});
  }

  Future<void> _loadInitialData() async {
    try {
      final wallets = await _dbHelper.getAllWallets();
      final services = await _dbHelper.getAllServices();
      setState(() {
        _availableWallets = wallets;
        _availableServices = services;
        if (wallets.isNotEmpty) {
          _selectedWallet = wallets.firstWhere((w) => w.type == WalletType.cash, orElse: () => wallets.first);
        }
        if (services.isNotEmpty) {
          _selectedService = services.first;
        }
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading initial data: $e');
      setState(() => _isLoading = false);
    }
  }

  double get _profit {
    double modal = CurrencyInputFormatter.parse(_modalController.text);
    double received = CurrencyInputFormatter.parse(_receivedController.text);
    return received - modal;
  }

  String _formatCurrency(double amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  TransactionType _mapServiceToType(String serviceName) {
    switch (serviceName.toLowerCase()) {
      case 'transfer': return TransactionType.transfer;
      case 'tarik tunai': return TransactionType.withdrawal;
      case 'topup':
      case 'top up': return TransactionType.topup;
      case 'ppob': return TransactionType.ppob;
      default: return TransactionType.other;
    }
  }

  Future<void> _saveTransaction() async {
    final modal = CurrencyInputFormatter.parse(_modalController.text);
    final received = CurrencyInputFormatter.parse(_receivedController.text);
    final profit = received - modal;

    if (modal <= 0 && received <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nominal transaksi tidak boleh 0')));
      return;
    }

    if (_selectedWallet == null || _selectedService == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Layanan dan Sumber dana harus dipilih')));
      return;
    }

    if (_isDebt && _customerNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nama Pelanggan wajib diisi untuk transaksi hutang')));
      return;
    }

    try {
      final transaction = TransactionModel(
        walletId: _selectedWallet!.id!,
        type: _mapServiceToType(_selectedService!.name),
        amount: modal,
        fee: profit,
        cost: 0, 
        profit: profit, 
        status: _isDebt ? TransactionStatus.piutang : TransactionStatus.lunas,
        createdAt: DateTime.now().toIso8601String(),
      );

      final txId = await _dbHelper.insertTransaction(transaction);

      if (_isDebt) {
        final debt = DebtModel(
          customerName: _customerNameController.text.trim(),
          amount: received,
          transactionId: txId,
          status: DebtStatus.pending,
        );
        await _dbHelper.insertDebt(debt);
      } else {
        final newBalance = _selectedWallet!.balance - modal; 
        await _dbHelper.updateWalletBalance(_selectedWallet!.id!, newBalance);
      }

      if (mounted) {
        context.read<FinancialProvider>().refreshAllData();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transaksi berhasil disimpan')));
        Navigator.pop(context); // Close bottom sheet
      }
    } catch (e) {
      debugPrint('Error saving transaction: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
    }

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.md,
      ),
      child: SingleChildScrollView(
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Transaksi Baru', style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('LAYANAN', style: AppTypography.labelMd.copyWith(color: Colors.grey[600], fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: AppShapes.borderRadiusMd,
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<ServiceModel>(
                            isExpanded: true,
                            value: _selectedService,
                            items: _availableServices.map((s) => DropdownMenuItem(
                              value: s,
                              child: Text(s.name, style: AppTypography.bodyMd),
                            )).toList(),
                            onChanged: (val) => setState(() => _selectedService = val),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('SUMBER DANA', style: AppTypography.labelMd.copyWith(color: Colors.grey[600], fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: AppShapes.borderRadiusMd,
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<WalletModel>(
                            isExpanded: true,
                            value: _selectedWallet,
                            items: _availableWallets.map((w) => DropdownMenuItem(
                              value: w,
                              child: Text(w.name, style: AppTypography.bodyMd, maxLines: 1, overflow: TextOverflow.ellipsis),
                            )).toList(),
                            onChanged: (val) => setState(() => _selectedWallet = val),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('MODAL TRANSAKSI', style: AppTypography.labelMd.copyWith(color: Colors.grey[600], fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  _buildThousandInput(_modalController),
                  const SizedBox(height: 16),
                  
                  Text('UANG DITERIMA DARI PELANGGAN', style: AppTypography.labelMd.copyWith(color: Colors.grey[600], fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  _buildThousandInput(_receivedController, isPrimary: true),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              decoration: BoxDecoration(
                color: _profit >= 0 ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _profit >= 0 ? Colors.green[300]! : Colors.red[300]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('PROFIT TRANSAKSI', style: AppTypography.labelMd.copyWith(color: _profit >= 0 ? Colors.green[800] : Colors.red[800], fontWeight: FontWeight.bold)),
                  Text(
                    _profit >= 0 ? '+${_formatCurrency(_profit)}' : _formatCurrency(_profit),
                    style: AppTypography.headlineSmall.copyWith(color: _profit >= 0 ? Colors.green[800] : Colors.red[800], fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('STATUS PEMBAYARAN', style: AppTypography.labelMd.copyWith(color: Colors.grey[600], fontWeight: FontWeight.bold)),
                Container(
                  decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildToggleButton('Lunas', !_isDebt),
                      _buildToggleButton('Hutang', _isDebt),
                    ],
                  ),
                ),
              ],
            ),
            
            if (_isDebt) ...[
              const SizedBox(height: 16),
              Text('NAMA PELANGGAN', style: AppTypography.labelMd.copyWith(color: Colors.grey[600], fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: _customerNameController,
                decoration: InputDecoration(
                  hintText: 'Masukkan nama pelanggan',
                  filled: true,
                  fillColor: AppColors.surfaceContainerLow,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  border: OutlineInputBorder(borderRadius: AppShapes.borderRadiusMd, borderSide: BorderSide(color: Colors.grey[300]!)),
                ),
              ),
            ],
            
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _saveTransaction,
                icon: const Icon(Icons.check_circle_outline, size: 20),
                label: const Text('Simpan Transaksi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildThousandInput(TextEditingController controller, {bool isPrimary = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text('Rp', style: AppTypography.headlineSmall.copyWith(color: isPrimary ? AppColors.primary : Colors.grey[800], fontWeight: FontWeight.bold)),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [CurrencyInputFormatter()],
            style: AppTypography.headlineMedium.copyWith(
              color: isPrimary ? AppColors.primary : AppColors.onSurface, 
              fontSize: 24,
              fontWeight: FontWeight.bold
            ),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 4),
              border: UnderlineInputBorder(borderSide: BorderSide(color: isPrimary ? AppColors.primary : Colors.grey[300]!, width: 1)),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: isPrimary ? AppColors.primary : Colors.grey[300]!, width: 1)),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary, width: 2)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleButton(String label, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => _isDebt = label == 'Hutang'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label, style: AppTypography.bodySm.copyWith(color: isSelected ? Colors.white : Colors.grey[600], fontWeight: FontWeight.bold)),
      ),
    );
  }
}
