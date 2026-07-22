import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class CartItem {
  CartItem({
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.costPrice,
    required this.quantity,
    required this.availableStock,
  });

  final int productId;
  final String productName;
  final double unitPrice;
  final double costPrice;
  int quantity;
  final int availableStock;

  double get lineTotal => unitPrice * quantity;
}

class SaleResult {
  const SaleResult({
    required this.saleId,
    required this.invoiceNo,
    required this.total,
  });

  final int saleId;
  final String invoiceNo;
  final double total;
}

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  Database? _database;

  Future<Database> get database async {
    final current = _database;
    if (current != null) return current;
    final opened = await _openDatabase();
    _database = opened;
    return opened;
  }

  Future<void> initialize() async {
    await database;
  }

  Future<Database> _openDatabase() async {
    final root = await getDatabasesPath();
    final dbPath = p.join(root, 'sports_emporium.db');
    return openDatabase(
      dbPath,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE products (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            sku TEXT UNIQUE,
            name TEXT NOT NULL,
            category TEXT,
            cost_price REAL DEFAULT 0,
            sell_price REAL NOT NULL,
            quantity INTEGER DEFAULT 0,
            low_stock_threshold INTEGER DEFAULT 5,
            created_at TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE customers (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            phone TEXT,
            total_spent REAL DEFAULT 0,
            created_at TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE sales (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            invoice_no TEXT UNIQUE,
            customer_id INTEGER,
            sale_date TEXT NOT NULL,
            subtotal REAL NOT NULL,
            discount REAL DEFAULT 0,
            tax REAL DEFAULT 0,
            total REAL NOT NULL,
            payment_method TEXT DEFAULT 'Cash',
            FOREIGN KEY (customer_id) REFERENCES customers(id)
          )
        ''');

        await db.execute('''
          CREATE TABLE sale_items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            sale_id INTEGER NOT NULL,
            product_id INTEGER NOT NULL,
            product_name TEXT NOT NULL,
            unit_price REAL NOT NULL,
            cost_price REAL DEFAULT 0,
            quantity INTEGER NOT NULL,
            line_total REAL NOT NULL,
            FOREIGN KEY (sale_id) REFERENCES sales(id) ON DELETE CASCADE,
            FOREIGN KEY (product_id) REFERENCES products(id)
          )
        ''');

        await db.execute('''
          CREATE TABLE settings (
            key TEXT PRIMARY KEY,
            value TEXT
          )
        ''');

        final defaults = <String, String>{
          'shop_name': 'Shri Shakra Sports',
          'shop_address': '',
          'shop_phone': '',
          'tax_rate': '5',
          'currency_symbol': 'Rs.',
          'next_invoice_no': '1001',
          'app_password': '12345678',
        };

        final batch = db.batch();
        for (final entry in defaults.entries) {
          batch.insert(
            'settings',
            {'key': entry.key, 'value': entry.value},
            conflictAlgorithm: ConflictAlgorithm.ignore,
          );
        }
        await batch.commit(noResult: true);
        await _seedInventory(db);
      },
    );
  }

  Future<void> _seedInventory(Database db) async {
    final count = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM products'),
        ) ??
        0;
    if (count > 0) return;

    final now = DateTime.now().toIso8601String();
    final rows = <List<Object?>>[
      ['BAT-001', 'MRF Grand Edition Cricket Bat', 'Cricket', 12000.0, 18000.0, 10, 3],
      ['BAL-002', 'Nivia Storm Football', 'Football', 600.0, 999.0, 25, 5],
      ['RAC-003', 'Yonex Arcsaber Badminton Racket', 'Badminton', 3500.0, 5500.0, 12, 4],
      ['SHP-004', 'Nike Air Zoom Running Shoes', 'Footwear', 4500.0, 7999.0, 8, 2],
      ['BAL-005', 'Cosco Pro Basketball', 'Basketball', 800.0, 1400.0, 15, 4],
      ['ACC-006', 'SG Club Cricket Batting Gloves', 'Cricket', 450.0, 850.0, 20, 5],
      ['ACC-007', 'Nivia Shin Guards', 'Football', 200.0, 399.0, 30, 6],
      ['ACC-008', 'Stag Table Tennis Racket Set', 'Table Tennis', 700.0, 1200.0, 14, 3],
      ['EQP-009', 'Strauss Agility Training Ladder', 'Fitness', 500.0, 950.0, 10, 2],
      ['BAG-010', 'Puma Kit Gym Duffel Bag', 'Accessories', 1100.0, 1999.0, 18, 4],
    ];

    final batch = db.batch();
    for (final row in rows) {
      batch.rawInsert(
        '''
        INSERT INTO products
        (sku, name, category, cost_price, sell_price, quantity, low_stock_threshold, created_at)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        ''',
        [...row, now],
      );
    }
    await batch.commit(noResult: true);
  }

  Future<String> getSetting(String key, {String fallback = ''}) async {
    final db = await database;
    final rows = await db.query(
      'settings',
      columns: ['value'],
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (rows.isEmpty) return fallback;
    return rows.first['value']?.toString() ?? fallback;
  }

  Future<void> setSetting(String key, String value) async {
    final db = await database;
    await db.insert(
      'settings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, String>> getAllSettings() async {
    final db = await database;
    final rows = await db.query('settings');
    return {
      for (final row in rows)
        row['key'].toString(): row['value']?.toString() ?? '',
    };
  }

  Future<List<Map<String, Object?>>> getProducts({String search = ''}) async {
    final db = await database;
    final clean = search.trim();
    if (clean.isEmpty) {
      return db.query('products', orderBy: 'name COLLATE NOCASE');
    }
    final like = '%$clean%';
    return db.query(
      'products',
      where: 'name LIKE ? OR sku LIKE ? OR category LIKE ?',
      whereArgs: [like, like, like],
      orderBy: 'name COLLATE NOCASE',
    );
  }

  Future<Map<String, Object?>?> getProduct(int id) async {
    final db = await database;
    final rows = await db.query(
      'products',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  Future<int> addProduct({
    required String sku,
    required String name,
    required String category,
    required double costPrice,
    required double sellPrice,
    required int quantity,
    required int lowStockThreshold,
  }) async {
    final db = await database;
    return db.insert('products', {
      'sku': sku.trim().isEmpty ? null : sku.trim(),
      'name': name.trim(),
      'category': category.trim(),
      'cost_price': costPrice,
      'sell_price': sellPrice,
      'quantity': quantity,
      'low_stock_threshold': lowStockThreshold,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> updateProduct({
    required int id,
    required String sku,
    required String name,
    required String category,
    required double costPrice,
    required double sellPrice,
    required int quantity,
    required int lowStockThreshold,
  }) async {
    final db = await database;
    await db.update(
      'products',
      {
        'sku': sku.trim().isEmpty ? null : sku.trim(),
        'name': name.trim(),
        'category': category.trim(),
        'cost_price': costPrice,
        'sell_price': sellPrice,
        'quantity': quantity,
        'low_stock_threshold': lowStockThreshold,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteProduct(int id) async {
    final db = await database;
    await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, Object?>>> getCustomers({String search = ''}) async {
    final db = await database;
    final clean = search.trim();
    if (clean.isEmpty) {
      return db.rawQuery('''
        SELECT * FROM customers
        ORDER BY total_spent DESC, name COLLATE NOCASE
      ''');
    }
    final like = '%$clean%';
    return db.rawQuery('''
      SELECT * FROM customers
      WHERE name LIKE ? OR phone LIKE ?
      ORDER BY total_spent DESC, name COLLATE NOCASE
    ''', [like, like]);
  }

  Future<Map<String, Object?>> dashboardSummary() async {
    final db = await database;
    final now = DateTime.now();
    final startDay = DateTime(now.year, now.month, now.day).toIso8601String();
    final startMonth = DateTime(now.year, now.month).toIso8601String();
    final startYear = DateTime(now.year).toIso8601String();

    Future<Map<String, Object?>> sumSince(String since) async {
      final rows = await db.rawQuery('''
        SELECT COALESCE(SUM(total), 0) AS total, COUNT(*) AS count
        FROM sales WHERE sale_date >= ?
      ''', [since]);
      return rows.first;
    }

    final today = await sumSince(startDay);
    final month = await sumSince(startMonth);
    final year = await sumSince(startYear);
    final low = Sqflite.firstIntValue(await db.rawQuery('''
          SELECT COUNT(*) FROM products
          WHERE quantity <= low_stock_threshold
        ''')) ??
        0;

    return {
      'today_total': (today['total'] as num?)?.toDouble() ?? 0,
      'today_count': (today['count'] as num?)?.toInt() ?? 0,
      'month_total': (month['total'] as num?)?.toDouble() ?? 0,
      'month_count': (month['count'] as num?)?.toInt() ?? 0,
      'year_total': (year['total'] as num?)?.toDouble() ?? 0,
      'year_count': (year['count'] as num?)?.toInt() ?? 0,
      'low_stock_count': low,
    };
  }

  Future<List<Map<String, Object?>>> getLowStockProducts({int limit = 20}) async {
    final db = await database;
    return db.rawQuery('''
      SELECT * FROM products
      WHERE quantity <= low_stock_threshold
      ORDER BY quantity ASC, name COLLATE NOCASE
      LIMIT ?
    ''', [limit]);
  }

  Future<List<Map<String, Object?>>> getRecentSales({int limit = 50}) async {
    final db = await database;
    return db.rawQuery('''
      SELECT s.*, c.name AS customer_name, c.phone AS customer_phone
      FROM sales s
      LEFT JOIN customers c ON c.id = s.customer_id
      ORDER BY s.sale_date DESC
      LIMIT ?
    ''', [limit]);
  }

  Future<List<Map<String, Object?>>> getSaleItems(int saleId) async {
    final db = await database;
    return db.query(
      'sale_items',
      where: 'sale_id = ?',
      whereArgs: [saleId],
      orderBy: 'id',
    );
  }

  Future<SaleResult> createSale({
    required List<CartItem> items,
    required double discount,
    required double tax,
    required String paymentMethod,
    String customerName = '',
    String customerPhone = '',
  }) async {
    if (items.isEmpty) {
      throw StateError('The cart is empty.');
    }

    final db = await database;
    return db.transaction((txn) async {
      for (final item in items) {
        final productRows = await txn.query(
          'products',
          columns: ['quantity'],
          where: 'id = ?',
          whereArgs: [item.productId],
          limit: 1,
        );
        if (productRows.isEmpty) {
          throw StateError('${item.productName} no longer exists.');
        }
        final stock = (productRows.first['quantity'] as num).toInt();
        if (item.quantity > stock) {
          throw StateError('Only $stock units of ${item.productName} remain.');
        }
      }

      final nextRows = await txn.query(
        'settings',
        columns: ['value'],
        where: 'key = ?',
        whereArgs: ['next_invoice_no'],
        limit: 1,
      );
      final nextNo = int.tryParse(
            nextRows.isEmpty ? '1001' : nextRows.first['value'].toString(),
          ) ??
          1001;
      final invoiceNo = 'INV-$nextNo';
      await txn.insert(
        'settings',
        {'key': 'next_invoice_no', 'value': '${nextNo + 1}'},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      int? customerId;
      final cleanName = customerName.trim();
      final cleanPhone = customerPhone.trim();
      if (cleanName.isNotEmpty) {
        final existing = await txn.query(
          'customers',
          where: 'name = ? AND phone = ?',
          whereArgs: [cleanName, cleanPhone],
          limit: 1,
        );
        if (existing.isNotEmpty) {
          customerId = (existing.first['id'] as num).toInt();
        } else {
          customerId = await txn.insert('customers', {
            'name': cleanName,
            'phone': cleanPhone,
            'total_spent': 0,
            'created_at': DateTime.now().toIso8601String(),
          });
        }
      }

      final subtotal = items.fold<double>(0, (sum, item) => sum + item.lineTotal);
      final safeDiscount = discount.clamp(0, subtotal).toDouble();
      final safeTax = tax < 0 ? 0.0 : tax;
      final total = subtotal - safeDiscount + safeTax;
      final saleId = await txn.insert('sales', {
        'invoice_no': invoiceNo,
        'customer_id': customerId,
        'sale_date': DateTime.now().toIso8601String(),
        'subtotal': subtotal,
        'discount': safeDiscount,
        'tax': safeTax,
        'total': total,
        'payment_method': paymentMethod,
      });

      for (final item in items) {
        await txn.insert('sale_items', {
          'sale_id': saleId,
          'product_id': item.productId,
          'product_name': item.productName,
          'unit_price': item.unitPrice,
          'cost_price': item.costPrice,
          'quantity': item.quantity,
          'line_total': item.lineTotal,
        });
        await txn.rawUpdate(
          'UPDATE products SET quantity = quantity - ? WHERE id = ?',
          [item.quantity, item.productId],
        );
      }

      if (customerId != null) {
        await txn.rawUpdate(
          'UPDATE customers SET total_spent = total_spent + ? WHERE id = ?',
          [total, customerId],
        );
      }

      return SaleResult(saleId: saleId, invoiceNo: invoiceNo, total: total);
    });
  }

  Future<Map<String, Object?>> reportSummary() async {
    final db = await database;
    final dashboard = await dashboardSummary();
    final totals = (await db.rawQuery('''
      SELECT
        COALESCE(SUM(line_total), 0) AS revenue,
        COALESCE(SUM(cost_price * quantity), 0) AS cost
      FROM sale_items
    '''))
        .first;
    final revenue = (totals['revenue'] as num?)?.toDouble() ?? 0;
    final cost = (totals['cost'] as num?)?.toDouble() ?? 0;
    return {
      ...dashboard,
      'all_revenue': revenue,
      'all_cost': cost,
      'all_profit': revenue - cost,
    };
  }

  Future<List<Map<String, Object?>>> topSellingProducts({int limit = 10}) async {
    final db = await database;
    return db.rawQuery('''
      SELECT product_name,
             SUM(quantity) AS qty_sold,
             SUM(line_total) AS revenue
      FROM sale_items
      GROUP BY product_name
      ORDER BY qty_sold DESC, revenue DESC
      LIMIT ?
    ''', [limit]);
  }
}
