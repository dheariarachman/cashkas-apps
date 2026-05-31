import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/wallet_model.dart';
import '../models/transaction_model.dart';

class FinancialProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  double _totalProfit = 0;
  double _digitalBalance = 0;
  double _cashBalance = 0;
  double _totalOmset = 0;
  double _totalDebt = 0;
  int _totalTransactions = 0;
  int _debtCount = 0;
  List<double> _weeklyActivity = [0, 0, 0, 0, 0, 0, 0];
  List<TransactionModel> _transactions = [];
  List<Map<String, dynamic>> _debts = [];

  // History Pagination
  List<TransactionModel> _historyTransactions = [];
  bool _hasMoreHistory = true;
  int _historyOffset = 0;
  static const int _historyLimit = 10;
  bool _isHistoryLoading = false;

  double get totalProfit => _totalProfit;
  double get digitalBalance => _digitalBalance;
  double get cashBalance => _cashBalance;
  double get totalOmset => _totalOmset;
  double get totalDebt => _totalDebt;
  int get totalTransactions => _totalTransactions;
  int get debtCount => _debtCount;
  List<double> get weeklyActivity => _weeklyActivity;
  List<TransactionModel> get transactions => _transactions;
  List<Map<String, dynamic>> get debts => _debts;
  double get totalBalance => _digitalBalance + _cashBalance;

  // History Getters
  List<TransactionModel> get historyTransactions => _historyTransactions;
  bool get hasMoreHistory => _hasMoreHistory;
  bool get isHistoryLoading => _isHistoryLoading;

  Future<void> refreshAllData({String period = 'Hari Ini'}) async {
    try {
      final wallets = await _dbHelper.getAllWallets();
      final stats = await _dbHelper.getDashboardStats(period: period);
      final activity = await _dbHelper.getWeeklyActivity();
      final txs = await _dbHelper.getAllTransactions();
      final debtList = await _dbHelper.getAllDebts();
      
      double digital = 0;
      double cash = 0;
      
      for (var wallet in wallets) {
        if (wallet.type == WalletType.cash) {
          cash += wallet.balance;
        } else {
          digital += wallet.balance;
        }
      }

      _digitalBalance = digital;
      _cashBalance = cash;
      _totalProfit = (stats['totalProfit'] as num).toDouble();
      _totalOmset = (stats['totalOmset'] as num).toDouble();
      _totalTransactions = stats['totalTransactions'] as int;
      _debtCount = stats['debtCount'] as int;
      _totalDebt = (stats['debtAmount'] as num).toDouble();
      _weeklyActivity = activity;
      _transactions = txs;
      _debts = debtList;
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error refreshing provider data: $e');
    }
  }

  Future<void> refreshHistory({String period = 'Harian'}) async {
    try {
      _isHistoryLoading = true;
      _historyOffset = 0;
      _hasMoreHistory = true;
      
      // Also refresh dashboard stats for the summary card in history
      final stats = await _dbHelper.getDashboardStats(
        period: period == 'Harian' ? 'Hari Ini' : (period == 'Mingguan' ? 'Minggu Ini' : 'Bulan Ini')
      );
      _totalProfit = (stats['totalProfit'] as num).toDouble();
      _totalTransactions = stats['totalTransactions'] as int;

      _historyTransactions = await _dbHelper.getPaginatedTransactions(
        period: period,
        limit: _historyLimit,
        offset: _historyOffset,
      );
      
      if (_historyTransactions.length < _historyLimit) {
        _hasMoreHistory = false;
      }
      
      _isHistoryLoading = false;
      notifyListeners();
    } catch (e) {
      _isHistoryLoading = false;
      debugPrint('Error refreshing history: $e');
    }
  }

  Future<void> loadMoreHistory({String period = 'Harian'}) async {
    if (!_hasMoreHistory || _isHistoryLoading) return;

    try {
      _isHistoryLoading = true;
      _historyOffset += _historyLimit;
      final newTransactions = await _dbHelper.getPaginatedTransactions(
        period: period,
        limit: _historyLimit,
        offset: _historyOffset,
      );

      if (newTransactions.length < _historyLimit) {
        _hasMoreHistory = false;
      }

      _historyTransactions.addAll(newTransactions);
      _isHistoryLoading = false;
      notifyListeners();
    } catch (e) {
      _isHistoryLoading = false;
      debugPrint('Error loading more history: $e');
    }
  }
}
