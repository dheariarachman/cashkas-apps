import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/transaction_model.dart';
import '../models/wallet_model.dart';
import '../models/debt_model.dart';
import '../models/cash_denomination_model.dart';
import '../models/service_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  static Future<Database>? _databaseFuture;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _databaseFuture ??= _initDatabase();
    _database = await _databaseFuture;
    return _database!;
  }

  Future<Database> _initDatabase() async {
    if (!kIsWeb &&
        (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'cashkas.db');

    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const integerType = 'INTEGER NOT NULL';
    const realType = 'REAL NOT NULL';

    // Wallets Table
    await db.execute('''
      CREATE TABLE wallets (
        id $idType,
        name $textType,
        balance $realType,
        type $textType
      )
    ''');

    // Transactions Table
    await db.execute('''
      CREATE TABLE transactions (
        id $idType,
        wallet_id $integerType,
        type $textType,
        amount $realType,
        fee $realType,
        cost $realType,
        profit $realType,
        status $textType,
        created_at $textType,
        FOREIGN KEY (wallet_id) REFERENCES wallets (id) ON DELETE CASCADE
      )
    ''');

    // Debt Table
    await db.execute('''
      CREATE TABLE debts (
        id $idType,
        customer_name $textType,
        amount $realType,
        transaction_id $integerType,
        status $textType,
        FOREIGN KEY (transaction_id) REFERENCES transactions (id) ON DELETE CASCADE
      )
    ''');

    // CashDenominations Table
    await db.execute('''
      CREATE TABLE cash_denominations (
        id $idType,
        value $realType,
        count $integerType,
        total $realType
      )
    ''');

    // Services Table
    await db.execute('''
      CREATE TABLE services (
        id $idType,
        name $textType,
        icon $textType
      )
    ''');

    // Initial data for Wallets
    await db.insert('wallets', {
      'name': 'Cash',
      'balance': 0.0,
      'type': 'cash',
    });

    await db.insert('wallets', {
      'name': 'Bank BCA',
      'balance': 12500000.0,
      'type': 'bank',
    });

    // Initial data for Services
    final List<String> initialServices = [
      'Transfer',
      'Tarik Tunai',
      'Topup',
      'PPOB',
    ];
    for (var service in initialServices) {
      await db.insert('services', {
        'name': service,
        'icon': 'category_outlined',
      });
    }
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      await db.execute('DROP TABLE IF EXISTS transactions');
      await db.execute('DROP TABLE IF EXISTS wallets');
      await db.execute('DROP TABLE IF EXISTS debts');
      await db.execute('DROP TABLE IF EXISTS cash_denominations');
      await db.execute('DROP TABLE IF EXISTS services');
      await _createDB(db, newVersion);
    }
  }

  // --- Transactions ---
  Future<int> insertTransaction(TransactionModel transaction) async {
    final db = await instance.database;
    return await db.insert('transactions', transaction.toMap());
  }

  Future<List<TransactionModel>> getAllTransactions() async {
    final db = await instance.database;
    final result = await db.query('transactions', orderBy: 'created_at DESC');
    return result.map((json) => TransactionModel.fromMap(json)).toList();
  }

  Future<List<TransactionModel>> getPaginatedTransactions({
    String period = 'Harian',
    int limit = 10,
    int offset = 0,
  }) async {
    final db = await instance.database;
    String dateFilter = "";
    DateTime now = DateTime.now();

    if (period == 'Harian') {
      String today = DateFormat('yyyy-MM-dd').format(now);
      dateFilter = "created_at LIKE '$today%'";
    } else if (period == 'Mingguan') {
      DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      String start = DateFormat('yyyy-MM-dd').format(startOfWeek);
      dateFilter = "created_at >= '$start'";
    } else if (period == 'Bulanan') {
      String startOfMonth = DateFormat('yyyy-MM-01').format(now);
      dateFilter = "created_at >= '$startOfMonth'";
    }

    final result = await db.query(
      'transactions',
      where: dateFilter.isNotEmpty ? dateFilter : null,
      orderBy: 'created_at DESC',
      limit: limit,
      offset: offset,
    );
    return result.map((json) => TransactionModel.fromMap(json)).toList();
  }

  // --- Wallets ---
  Future<int> insertWallet(WalletModel wallet) async {
    final db = await instance.database;
    return await db.insert('wallets', wallet.toMap());
  }

  Future<List<WalletModel>> getAllWallets() async {
    final db = await instance.database;
    final result = await db.query('wallets');
    return result.map((json) => WalletModel.fromMap(json)).toList();
  }

  Future<int> updateWallet(WalletModel wallet) async {
    final db = await instance.database;
    return await db.update(
      'wallets',
      wallet.toMap(),
      where: 'id = ?',
      whereArgs: [wallet.id],
    );
  }

  Future<int> deleteWallet(int id) async {
    final db = await instance.database;
    return await db.delete('wallets', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateWalletBalance(int id, double newBalance) async {
    final db = await instance.database;
    return await db.update(
      'wallets',
      {'balance': newBalance},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --- Debts ---
  Future<int> insertDebt(DebtModel debt) async {
    final db = await instance.database;
    return await db.insert('debts', debt.toMap());
  }

  Future<List<Map<String, dynamic>>> getAllDebts() async {
    final db = await instance.database;
    // Join with transactions to get the date, filter by pending status
    return await db.rawQuery('''
      SELECT d.*, t.created_at 
      FROM debts d
      JOIN transactions t ON d.transaction_id = t.id
      WHERE d.status = 'pending'
      ORDER BY t.created_at DESC
    ''');
  }

  Future<int> updateDebtStatus(int id, DebtStatus status) async {
    final db = await instance.database;
    return await db.update(
      'debts',
      {'status': status.name},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --- Cash Denominations ---
  Future<void> updateCashDenominations(
    List<CashDenominationModel> denoms,
  ) async {
    final db = await instance.database;
    await db.transaction((txn) async {
      await txn.delete('cash_denominations');
      for (var denom in denoms) {
        await txn.insert('cash_denominations', denom.toMap());
      }
    });
  }

  Future<List<CashDenominationModel>> getCashDenominations() async {
    final db = await instance.database;
    final result = await db.query('cash_denominations');
    return result.map((json) => CashDenominationModel.fromMap(json)).toList();
  }

  // --- Services ---
  Future<int> insertService(ServiceModel service) async {
    final db = await instance.database;
    return await db.insert('services', service.toMap());
  }

  Future<List<ServiceModel>> getAllServices() async {
    final db = await instance.database;
    final result = await db.query('services');
    return result.map((json) => ServiceModel.fromMap(json)).toList();
  }

  Future<int> updateService(ServiceModel service) async {
    final db = await instance.database;
    return await db.update(
      'services',
      service.toMap(),
      where: 'id = ?',
      whereArgs: [service.id],
    );
  }

  Future<int> deleteService(int id) async {
    final db = await instance.database;
    return await db.delete('services', where: 'id = ?', whereArgs: [id]);
  }

  Future<double> getTotalBalance() async {
    final db = await instance.database;
    final result = await db.rawQuery(
      'SELECT SUM(balance) as total FROM wallets',
    );
    return result.first['total'] != null
        ? (result.first['total'] as num).toDouble()
        : 0.0;
  }

  // --- Analytics ---
  Future<Map<String, dynamic>> getDashboardStats({String period = 'Hari Ini'}) async {
    final db = await instance.database;
    String dateFilter = "";
    DateTime now = DateTime.now();

    if (period == 'Hari Ini') {
      String today = DateFormat('yyyy-MM-dd').format(now);
      dateFilter = " WHERE created_at LIKE '$today%'";
    } else if (period == 'Minggu Ini') {
      DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      String start = DateFormat('yyyy-MM-dd').format(startOfWeek);
      dateFilter = " WHERE created_at >= '$start'";
    } else if (period == 'Bulan Ini') {
      String startOfMonth = DateFormat('yyyy-MM-01').format(now);
      dateFilter = " WHERE created_at >= '$startOfMonth'";
    }

    final profitResult = await db.rawQuery(
      'SELECT SUM(profit) as total FROM transactions$dateFilter',
    );
    final omsetResult = await db.rawQuery(
      'SELECT SUM(amount + fee) as total FROM transactions$dateFilter',
    );
    final countResult = await db.rawQuery(
      'SELECT COUNT(*) as total FROM transactions$dateFilter',
    );

    // Debts are usually cumulative (total current outstanding), 
    // but the user might want them filtered too? 
    // Usually "Total Piutang Berjalan" is everything pending.
    // However, for the dashboard warning card, it might make sense to show all.
    final debtResult = await db.rawQuery(
      "SELECT COUNT(*) as count, SUM(amount) as total FROM debts WHERE status = 'pending'",
    );

    return {
      'totalProfit': profitResult.first['total'] ?? 0.0,
      'totalOmset': omsetResult.first['total'] ?? 0.0,
      'totalTransactions': countResult.first['total'] ?? 0,
      'debtCount': debtResult.first['count'] ?? 0,
      'debtAmount': debtResult.first['total'] ?? 0.0,
    };
  }

  Future<List<double>> getWeeklyActivity() async {
    final db = await instance.database;
    // Simple logic to get last 7 days activity (count of transactions)
    List<double> activity = [];

    for (int i = 6; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      final dateString = DateFormat('yyyy-MM-dd').format(date);

      final result = await db.rawQuery(
        "SELECT COUNT(*) as count FROM transactions WHERE created_at LIKE '$dateString%'",
      );
      int count = result.first['count'] as int? ?? 0;
      activity.add(count.toDouble());
    }

    return activity;
  }
}
