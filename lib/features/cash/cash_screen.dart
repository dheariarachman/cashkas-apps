import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/design/app_colors.dart';
import '../../core/design/app_spacing.dart';
import '../../core/design/app_shapes.dart';
import '../../core/design/app_typography.dart';
import '../../core/design/app_elevation.dart';
import '../../core/database/database_helper.dart';
import '../../core/models/wallet_model.dart';
import '../../core/models/cash_denomination_model.dart';
import '../../core/providers/financial_provider.dart';

class CashScreen extends StatefulWidget {
  const CashScreen({super.key});

  @override
  State<CashScreen> createState() => _CashScreenState();
}

class _CashScreenState extends State<CashScreen> with AutomaticKeepAliveClientMixin {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  bool get wantKeepAlive => true;

  List<WalletModel> _wallets = [];
  Map<int, int> _cashCounts = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final wallets = await _dbHelper.getAllWallets();
      final denoms = await _dbHelper.getCashDenominations();
      
      setState(() {
        _wallets = wallets;
        _cashCounts.clear();
        if (denoms.isNotEmpty) {
          for (var d in denoms) {
            _cashCounts[d.value.toInt()] = d.count;
          }
        } else {
          _cashCounts = {
            100000: 0,
            50000: 0,
            20000: 0,
            10000: 0,
            5000: 0,
            2000: 0,
            1000: 0,
            500: 0,
          };
        }
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading cash data: $e');
      setState(() => _isLoading = false);
    }
  }

  int get _totalCash {
    int total = 0;
    _cashCounts.forEach((denom, count) {
      total += denom * count;
    });
    return total;
  }

  double get _totalDigital {
    double total = 0;
    for (var w in _wallets) {
      if (w.type != WalletType.cash) {
        total += w.balance;
      }
    }
    return total;
  }

  String _formatCurrency(num amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  Future<void> _saveOpname() async {
    try {
      List<CashDenominationModel> denoms = [];
      _cashCounts.forEach((denom, count) {
        denoms.add(CashDenominationModel(
          value: denom.toDouble(),
          count: count,
          total: (denom * count).toDouble(),
        ));
      });
      
      await _dbHelper.updateCashDenominations(denoms);
      
      try {
        final cashWallet = _wallets.firstWhere((w) => w.type == WalletType.cash);
        if (cashWallet.id != null) {
          await _dbHelper.updateWalletBalance(cashWallet.id!, _totalCash.toDouble());
        }
      } catch (e) {
        await _dbHelper.insertWallet(WalletModel(name: 'Cash', balance: _totalCash.toDouble(), type: WalletType.cash));
      }
      
      if (mounted) {
        context.read<FinancialProvider>().refreshAllData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Opname Kas berhasil disimpan')),
        );
      }
    } catch (e) {
      debugPrint('Error saving opname: $e');
    }
  }

  void _showAddAccountBottomSheet() {
    final nameController = TextEditingController();
    final balanceController = TextEditingController(text: '0');
    WalletType selectedType = WalletType.bank;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Tambah Akun Baru', style: AppTypography.headlineSmall),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              
              Text('NAMA BANK / E-WALLET', style: AppTypography.labelMedium),
              const SizedBox(height: AppSpacing.xs),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: 'Contoh: Bank BNI, GoPay',
                  filled: true,
                  fillColor: AppColors.surfaceContainerLow,
                  border: OutlineInputBorder(
                    borderRadius: AppShapes.borderRadiusMd,
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              
              Text('SALDO AWAL', style: AppTypography.labelMedium),
              const SizedBox(height: AppSpacing.xs),
              TextField(
                controller: balanceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  prefixText: 'Rp ',
                  filled: true,
                  fillColor: AppColors.surfaceContainerLow,
                  border: OutlineInputBorder(
                    borderRadius: AppShapes.borderRadiusMd,
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              
              Text('TIPE AKUN', style: AppTypography.labelMedium),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => setModalState(() => selectedType = WalletType.bank),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: AppShapes.borderRadiusMd,
                          border: Border.all(
                            color: selectedType == WalletType.bank ? AppColors.primary : AppColors.outlineVariant,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Radio<WalletType>(
                              value: WalletType.bank,
                              groupValue: selectedType,
                              onChanged: (val) => setModalState(() => selectedType = val!),
                              activeColor: AppColors.primary,
                            ),
                            const Icon(Icons.account_balance, size: 18),
                            const SizedBox(width: AppSpacing.xs),
                            const Text('Bank', style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: InkWell(
                      onTap: () => setModalState(() => selectedType = WalletType.eWallet),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: AppShapes.borderRadiusMd,
                          border: Border.all(
                            color: selectedType == WalletType.eWallet ? AppColors.primary : AppColors.outlineVariant,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Radio<WalletType>(
                              value: WalletType.eWallet,
                              groupValue: selectedType,
                              onChanged: (val) => setModalState(() => selectedType = val!),
                              activeColor: AppColors.primary,
                            ),
                            const Icon(Icons.account_balance_wallet, size: 18),
                            const SizedBox(width: AppSpacing.xs),
                            const Text('E-Wallet', style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.isEmpty) return;
                    final balance = double.tryParse(balanceController.text) ?? 0;
                    
                    final newWallet = WalletModel(
                      name: nameController.text,
                      balance: balance,
                      type: selectedType,
                    );
                    
                    await _dbHelper.insertWallet(newWallet);
                    if (context.mounted) {
                      Navigator.pop(context);
                      context.read<FinancialProvider>().refreshAllData();
                      _loadData();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: AppShapes.borderRadiusLg),
                  ),
                  child: const Text('Simpan Akun', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditAccountBottomSheet(WalletModel wallet) {
    final nameController = TextEditingController(text: wallet.name);
    final balanceController = TextEditingController(text: wallet.balance.toStringAsFixed(0));
    WalletType selectedType = wallet.type;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Edit Akun', style: AppTypography.headlineSmall),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              
              Text('NAMA BANK / E-WALLET', style: AppTypography.labelMedium),
              const SizedBox(height: AppSpacing.xs),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.surfaceContainerLow,
                  border: OutlineInputBorder(
                    borderRadius: AppShapes.borderRadiusMd,
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              
              Text('SALDO', style: AppTypography.labelMedium),
              const SizedBox(height: AppSpacing.xs),
              TextField(
                controller: balanceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  prefixText: 'Rp ',
                  filled: true,
                  fillColor: AppColors.surfaceContainerLow,
                  border: OutlineInputBorder(
                    borderRadius: AppShapes.borderRadiusMd,
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              
              Text('TIPE AKUN', style: AppTypography.labelMedium),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => setModalState(() => selectedType = WalletType.bank),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: AppShapes.borderRadiusMd,
                          border: Border.all(
                            color: selectedType == WalletType.bank ? AppColors.primary : AppColors.outlineVariant,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Radio<WalletType>(
                              value: WalletType.bank,
                              groupValue: selectedType,
                              onChanged: (val) => setModalState(() => selectedType = val!),
                              activeColor: AppColors.primary,
                            ),
                            const Icon(Icons.account_balance, size: 18),
                            const SizedBox(width: AppSpacing.xs),
                            const Text('Bank', style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: InkWell(
                      onTap: () => setModalState(() => selectedType = WalletType.eWallet),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: AppShapes.borderRadiusMd,
                          border: Border.all(
                            color: selectedType == WalletType.eWallet ? AppColors.primary : AppColors.outlineVariant,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Radio<WalletType>(
                              value: WalletType.eWallet,
                              groupValue: selectedType,
                              onChanged: (val) => setModalState(() => selectedType = val!),
                              activeColor: AppColors.primary,
                            ),
                            const Icon(Icons.account_balance_wallet, size: 18),
                            const SizedBox(width: AppSpacing.xs),
                            const Text('E-Wallet', style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.isEmpty) return;
                    final balance = double.tryParse(balanceController.text) ?? 0;
                    
                    final updatedWallet = WalletModel(
                      id: wallet.id,
                      name: nameController.text,
                      balance: balance,
                      type: selectedType,
                    );
                    
                    await _dbHelper.updateWallet(updatedWallet);
                    if (context.mounted) {
                      Navigator.pop(context);
                      context.read<FinancialProvider>().refreshAllData();
                      _loadData();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: AppShapes.borderRadiusLg),
                  ),
                  child: const Text('Simpan Perubahan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton(
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Hapus Akun?'),
                        content: Text('Apakah Anda yakin ingin menghapus akun ${wallet.name}?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Batal'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      await _dbHelper.deleteWallet(wallet.id!);
                      if (context.mounted) {
                        Navigator.pop(context); // Close bottom sheet
                        context.read<FinancialProvider>().refreshAllData();
                        _loadData();
                      }
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    foregroundColor: Colors.red,
                    shape: RoundedRectangleBorder(borderRadius: AppShapes.borderRadiusLg),
                  ),
                  child: const Text('Hapus Saldo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.gridMargin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: AppSpacing.lg),
              _buildDigitalBalanceSection(),
              const SizedBox(height: AppSpacing.xl),
              _buildCashSection(),
              const SizedBox(height: AppSpacing.xl),
              _buildSaveButton(),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        const SizedBox(width: AppSpacing.md),
        const Icon(Icons.account_balance_wallet_outlined, color: AppColors.primary, size: 24),
        const SizedBox(width: AppSpacing.sm),
        Text(
          'Manajemen Saldo',
          style: AppTypography.headlineMedium.copyWith(color: AppColors.primary),
        ),
      ],
    );
  }

  Widget _buildDigitalBalanceSection() {
    final digitalWallets = _wallets.where((w) => w.type != WalletType.cash).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Saldo Digital', style: AppTypography.headlineSmall),
            TextButton(
              onPressed: _showAddAccountBottomSheet,
              child: const Text('+ Tambah Akun', style: TextStyle(color: AppColors.primary)),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppShapes.borderRadiusLg,
            boxShadow: AppElevation.level1,
            border: Border.all(color: AppColors.primary, width: 2),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOTAL SALDO DIGITAL',
                      style: AppTypography.labelMedium.copyWith(
                        letterSpacing: 1.2,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      _formatCurrency(_totalDigital),
                      style: AppTypography.displayLarge.copyWith(
                        color: AppColors.primary,
                        fontSize: 28,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.account_balance, color: AppColors.primary, size: 32),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (digitalWallets.isEmpty)
           const Padding(
             padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
             child: Center(child: Text('Belum ada akun digital')),
           )
        else
          ...digitalWallets.map((w) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _buildDigitalCard(w),
          )),
      ],
    );
  }

  Widget _buildDigitalCard(WalletModel wallet) {
    IconData icon = Icons.account_balance;
    Color accentColor = AppColors.primary;
    
    if (wallet.type == WalletType.eWallet) {
      icon = Icons.account_balance_wallet;
      accentColor = Colors.blueAccent;
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppShapes.borderRadiusLg,
        boxShadow: AppElevation.level1,
        border: Border(
          left: BorderSide(color: accentColor, width: 4),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: AppShapes.borderRadiusMd,
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(wallet.name, style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant)),
                Text(_formatCurrency(wallet.balance), style: AppTypography.numericMd.copyWith(fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _showEditAccountBottomSheet(wallet),
            icon: const Icon(Icons.edit_note, color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildCashSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Saldo Laci (Cash)', style: AppTypography.headlineSmall),
        const SizedBox(height: AppSpacing.md),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppShapes.borderRadiusLg,
            boxShadow: AppElevation.level1,
            border: Border.all(color: AppColors.primary, width: 2),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOTAL SALDO LACI',
                      style: AppTypography.labelMedium.copyWith(
                        letterSpacing: 1.2,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      _formatCurrency(_totalCash),
                      style: AppTypography.displayLarge.copyWith(
                        color: AppColors.primary,
                        fontSize: 28,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.money, color: Colors.brown, size: 32),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        ...(_cashCounts.keys.toList()..sort((a, b) => b.compareTo(a))).map((denom) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: _buildCashDenomRow(denom),
        )),
        const SizedBox(height: AppSpacing.md),
        Center(
          child: OutlinedButton.icon(
            onPressed: _showAddDenominationDialog,
            icon: const Icon(Icons.add),
            label: const Text('Tambah Pecahan Baru'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(borderRadius: AppShapes.borderRadiusMd),
            ),
          ),
        ),
      ],
    );
  }

  void _showAddDenominationDialog() {
    final denomController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Pecahan Baru', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Masukkan nominal pecahan (contoh: 200)', style: AppTypography.bodyMedium),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: denomController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixText: 'Rp ',
                filled: true,
                fillColor: AppColors.surfaceContainerLow,
                border: OutlineInputBorder(
                  borderRadius: AppShapes.borderRadiusMd,
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final denom = int.tryParse(denomController.text) ?? 0;
              if (denom > 0) {
                setState(() {
                  _cashCounts[denom] = _cashCounts[denom] ?? 0;
                });
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }

  Widget _buildCashDenomRow(int denom) {
    String label = denom >= 1000 ? '${denom ~/ 1000}k' : denom.toString();
    String typeLabel = denom == 1000 ? 'Koin/Lembar' : 'Lembar';
    Color badgeColor;
    if (denom >= 50000) badgeColor = AppColors.primary;
    else if (denom >= 10000) badgeColor = Colors.blueAccent;
    else badgeColor = AppColors.primaryFixedDim;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppShapes.borderRadiusLg,
        boxShadow: AppElevation.level1,
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: AppShapes.borderRadiusMd,
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_formatCurrency(denom), style: AppTypography.numericMd.copyWith(fontWeight: FontWeight.bold)),
                Text(typeLabel, style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant, fontSize: 12)),
              ],
            ),
          ),
          Container(
            width: 80,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: AppShapes.borderRadiusMd,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TextFormField(
                  initialValue: _cashCounts[denom].toString(),
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                  ),
                  onChanged: (val) {
                    setState(() {
                      _cashCounts[denom] = int.tryParse(val) ?? 0;
                    });
                  },
                ),
                Text(
                  _formatCurrency(denom * (_cashCounts[denom] ?? 0)),
                  style: const TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: _saveOpname,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: AppShapes.borderRadiusLg),
        ),
        icon: const Icon(Icons.save_outlined),
        label: const Text('Simpan Opname Kas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }
}
