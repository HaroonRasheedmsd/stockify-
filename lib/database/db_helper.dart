import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/product.dart';
import '../models/customer.dart';
import '../models/supplier.dart';
import '../models/sale.dart';
import '../models/sale_item.dart';
import '../models/purchase.dart';
import '../models/inventory_transaction.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('stockify.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const textNullableType = 'TEXT';
    const integerType = 'INTEGER NOT NULL';
    const integerNullableType = 'INTEGER';
    const realType = 'REAL NOT NULL';

    // 1. Products
    await db.execute('''
      CREATE TABLE products (
        id $idType,
        name $textType,
        barcode $textType,
        category $textType,
        purchase_price $realType,
        sale_price $realType,
        quantity $integerType,
        rack_location $textType,
        description $textType
      )
    ''');

    // 2. Customers
    await db.execute('''
      CREATE TABLE customers (
        id $idType,
        name $textType,
        phone $textType,
        address $textType
      )
    ''');

    // 3. Suppliers
    await db.execute('''
      CREATE TABLE suppliers (
        id $idType,
        name $textType,
        phone $textType,
        company $textType,
        address $textType
      )
    ''');

    // 4. Sales
    await db.execute('''
      CREATE TABLE sales (
        id $idType,
        customer_id $integerNullableType,
        date $textType,
        total $realType,
        discount $realType,
        tax $realType
      )
    ''');

    // 5. SaleItems
    await db.execute('''
      CREATE TABLE sale_items (
        id $idType,
        sale_id $integerType,
        product_id $integerType,
        quantity $integerType,
        price $realType
      )
    ''');

    // 6. Purchases
    await db.execute('''
      CREATE TABLE purchases (
        id $idType,
        supplier_id $integerType,
        date $textType,
        total $realType
      )
    ''');

    // 7. Inventory Transactions
    await db.execute('''
      CREATE TABLE inventory_transactions (
        id $idType,
        product_id $integerType,
        type $textType,
        quantity $integerType,
        date $textType,
        reason $textType
      )
    ''');

    // Seed mock data for demonstration
    await _seedData(db);
  }

  Future<void> _seedData(Database db) async {
    final now = DateTime.now().toIso8601String();

    // Seed Suppliers
    await db.insert('suppliers', {
      'name': 'Arshad Electronics Ltd',
      'phone': '0300-1234567',
      'company': 'Arshad Tech',
      'address': 'Hall Road, Lahore'
    });
    await db.insert('suppliers', {
      'name': 'Zenith Garments',
      'phone': '0321-7654321',
      'company': 'Zenith Inc.',
      'address': 'Faisalabad Textile Zone'
    });

    // Seed Customers
    await db.insert('customers', {
      'name': 'Ali Khan',
      'phone': '0333-5556677',
      'address': 'DHA Phase 5, Lahore'
    });
    await db.insert('customers', {
      'name': 'Sana Patel',
      'phone': '0345-8889900',
      'address': 'Clifton, Karachi'
    });

    // Seed Products
    // Product 1
    int p1 = await db.insert('products', {
      'name': 'Wireless Bluetooth Mouse',
      'barcode': '11223344',
      'category': 'Electronics',
      'purchase_price': 15.0,
      'sale_price': 25.0,
      'quantity': 45,
      'rack_location': 'Rack A-3',
      'description': 'Ergonomic 2.4GHz wireless mouse with optical sensor.'
    });
    // Product 2
    int p2 = await db.insert('products', {
      'name': 'Cotton Crewneck T-Shirt',
      'barcode': '55667788',
      'category': 'Apparel',
      'purchase_price': 8.0,
      'sale_price': 18.0,
      'quantity': 8, // Low stock on purpose
      'rack_location': 'Rack B-1',
      'description': '100% combed cotton breathable summer t-shirt.'
    });
    // Product 3
    int p3 = await db.insert('products', {
      'name': 'Stainless Steel Water Bottle',
      'barcode': '99001122',
      'category': 'Home & Kitchen',
      'purchase_price': 12.0,
      'sale_price': 22.0,
      'quantity': 15,
      'rack_location': 'Rack C-2',
      'description': 'Double-walled vacuum insulated bottle (1 Litre).'
    });

    // Log seed transactions in inventory ledger
    await db.insert('inventory_transactions', {
      'product_id': p1,
      'type': 'IN',
      'quantity': 45,
      'date': now,
      'reason': 'Initial Seeding'
    });
    await db.insert('inventory_transactions', {
      'product_id': p2,
      'type': 'IN',
      'quantity': 8,
      'date': now,
      'reason': 'Initial Seeding'
    });
    await db.insert('inventory_transactions', {
      'product_id': p3,
      'type': 'IN',
      'quantity': 15,
      'date': now,
      'reason': 'Initial Seeding'
    });
  }

  // ================= PRODUCTS CRUD =================

  Future<int> insertProduct(Product product) async {
    final db = await instance.database;
    return await db.insert('products', product.toMap());
  }

  Future<List<Product>> queryAllProducts() async {
    final db = await instance.database;
    final result = await db.query('products', orderBy: 'name ASC');
    return result.map((json) => Product.fromMap(json)).toList();
  }

  Future<Product?> queryProductById(int id) async {
    final db = await instance.database;
    final result = await db.query('products', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      return Product.fromMap(result.first);
    }
    return null;
  }

  Future<int> updateProduct(Product product) async {
    final db = await instance.database;
    return await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<int> deleteProduct(int id) async {
    final db = await instance.database;
    return await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ================= CUSTOMERS CRUD =================

  Future<int> insertCustomer(Customer customer) async {
    final db = await instance.database;
    return await db.insert('customers', customer.toMap());
  }

  Future<List<Customer>> queryAllCustomers() async {
    final db = await instance.database;
    final result = await db.query('customers', orderBy: 'name ASC');
    return result.map((json) => Customer.fromMap(json)).toList();
  }

  Future<int> updateCustomer(Customer customer) async {
    final db = await instance.database;
    return await db.update(
      'customers',
      customer.toMap(),
      where: 'id = ?',
      whereArgs: [customer.id],
    );
  }

  Future<int> deleteCustomer(int id) async {
    final db = await instance.database;
    return await db.delete(
      'customers',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ================= SUPPLIERS CRUD =================

  Future<int> insertSupplier(Supplier supplier) async {
    final db = await instance.database;
    return await db.insert('suppliers', supplier.toMap());
  }

  Future<List<Supplier>> queryAllSuppliers() async {
    final db = await instance.database;
    final result = await db.query('suppliers', orderBy: 'name ASC');
    return result.map((json) => Supplier.fromMap(json)).toList();
  }

  Future<int> updateSupplier(Supplier supplier) async {
    final db = await instance.database;
    return await db.update(
      'suppliers',
      supplier.toMap(),
      where: 'id = ?',
      whereArgs: [supplier.id],
    );
  }

  Future<int> deleteSupplier(int id) async {
    final db = await instance.database;
    return await db.delete(
      'suppliers',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ================= SALES TRANSACTION & HISTORY =================

  Future<int> executeSaleTransaction(Sale sale, List<SaleItem> items) async {
    final db = await instance.database;
    int saleId = -1;

    // Run inside SQLite Transaction block to ensure consistency
    await db.transaction((txn) async {
      // 1. Insert Sales header record
      saleId = await txn.insert('sales', sale.toMap());

      // 2. Process each item
      for (var item in items) {
        // Insert line item
        final finalItem = item.copyWith(saleId: saleId);
        await txn.insert('sale_items', finalItem.toMap());

        // Update product quantity in products table
        final productList = await txn.query('products', where: 'id = ?', whereArgs: [item.productId]);
        if (productList.isNotEmpty) {
          final productMap = productList.first;
          final currentQty = productMap['quantity'] as int;
          final newQty = currentQty - item.quantity;

          await txn.update(
            'products',
            {'quantity': newQty},
            where: 'id = ?',
            whereArgs: [item.productId],
          );

          // Log transaction in history
          await txn.insert('inventory_transactions', {
            'product_id': item.productId,
            'type': 'OUT',
            'quantity': item.quantity,
            'date': sale.date,
            'reason': 'POS Sale (Inv #${saleId})'
          });
        }
      }
    });

    return saleId;
  }

  Future<List<Sale>> queryAllSales() async {
    final db = await instance.database;
    // Join with customers to show name
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT s.*, c.name as customer_name
      FROM sales s
      LEFT JOIN customers c ON s.customer_id = c.id
      ORDER BY s.id DESC
    ''');
    return maps.map((map) => Sale.fromMap(map)).toList();
  }

  Future<List<SaleItem>> querySaleItems(int saleId) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT si.*, p.name as product_name
      FROM sale_items si
      INNER JOIN products p ON si.product_id = p.id
      WHERE si.sale_id = ?
    ''', [saleId]);
    return maps.map((map) => SaleItem.fromMap(map)).toList();
  }

  // ================= PURCHASES (RESTOCKING) CRUD =================

  Future<int> executeRestockPurchase(Purchase purchase, int productId, int addQty) async {
    final db = await instance.database;
    int purchaseId = -1;

    await db.transaction((txn) async {
      // 1. Insert Purchase
      purchaseId = await txn.insert('purchases', purchase.toMap());

      // 2. Update product stock
      final productList = await txn.query('products', where: 'id = ?', whereArgs: [productId]);
      if (productList.isNotEmpty) {
        final productMap = productList.first;
        final currentQty = productMap['quantity'] as int;
        final newQty = currentQty + addQty;

        await txn.update(
          'products',
          {'quantity': newQty},
          where: 'id = ?',
          whereArgs: [productId],
        );

        // 3. Log stock IN transaction
        await txn.insert('inventory_transactions', {
          'product_id': productId,
          'type': 'IN',
          'quantity': addQty,
          'date': purchase.date,
          'reason': 'Supplier Restock (PO #${purchaseId})'
        });
      }
    });

    return purchaseId;
  }

  Future<List<Purchase>> queryAllPurchases() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT p.*, s.name as supplier_name
      FROM purchases p
      INNER JOIN suppliers s ON p.supplier_id = s.id
      ORDER BY p.id DESC
    ''');
    return maps.map((map) => Purchase.fromMap(map)).toList();
  }

  // ================= INVENTORY TRANSACTIONS =================

  Future<int> insertManualTransaction(InventoryTransaction transaction) async {
    final db = await instance.database;
    int transId = -1;

    await db.transaction((txn) async {
      // 1. Log transaction
      transId = await txn.insert('inventory_transactions', transaction.toMap());

      // 2. Adjust product qty
      final productList = await txn.query('products', where: 'id = ?', whereArgs: [transaction.productId]);
      if (productList.isNotEmpty) {
        final productMap = productList.first;
        final currentQty = productMap['quantity'] as int;
        
        int newQty = currentQty;
        if (transaction.type == 'IN') {
          newQty += transaction.quantity;
        } else {
          newQty -= transaction.quantity;
        }

        await txn.update(
          'products',
          {'quantity': newQty},
          where: 'id = ?',
          whereArgs: [transaction.productId],
        );
      }
    });

    return transId;
  }

  Future<List<InventoryTransaction>> queryAllTransactions() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT it.*, p.name as product_name
      FROM inventory_transactions it
      INNER JOIN products p ON it.product_id = p.id
      ORDER BY it.id DESC
    ''');
    return maps.map((map) => InventoryTransaction.fromMap(map)).toList();
  }

  Future<List<InventoryTransaction>> queryTransactionsByProduct(int productId) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT it.*, p.name as product_name
      FROM inventory_transactions it
      INNER JOIN products p ON it.product_id = p.id
      WHERE it.product_id = ?
      ORDER BY it.id DESC
    ''', [productId]);
    return maps.map((map) => InventoryTransaction.fromMap(map)).toList();
  }

  // ================= REPORTS & ANALYTICS QUERIES =================

  Future<double> getTodaySalesTotal() async {
    final db = await instance.database;
    final today = DateTime.now().toIso8601String().substring(0, 10); // YYYY-MM-DD
    final result = await db.rawQuery('''
      SELECT SUM(total) as today_total FROM sales 
      WHERE date LIKE ?
    ''', ['$today%']);
    if (result.first['today_total'] != null) {
      return (result.first['today_total'] as num).toDouble();
    }
    return 0.0;
  }

  Future<int> getTodaySalesCount() async {
    final db = await instance.database;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final result = await db.rawQuery('''
      SELECT COUNT(*) as sales_count FROM sales 
      WHERE date LIKE ?
    ''', ['$today%']);
    return result.first['sales_count'] as int? ?? 0;
  }

  Future<int> getTotalStockQuantity() async {
    final db = await instance.database;
    final result = await db.rawQuery('SELECT SUM(quantity) as total_qty FROM products');
    return result.first['total_qty'] as int? ?? 0;
  }

  Future<int> getLowStockCount(int threshold) async {
    final db = await instance.database;
    final result = await db.rawQuery('SELECT COUNT(*) as low_count FROM products WHERE quantity <= ?', [threshold]);
    return result.first['low_count'] as int? ?? 0;
  }

  Future<Map<String, double>> getProfitAndCostMetrics() async {
    final db = await instance.database;
    
    // Profit = SUM(sale_item.qty * (sale_item.price - product.purchase_price)) - discounts + taxes
    // Wait, let's keep it simple: Profit = Total Sales - Cost of Goods Sold (COGS)
    // Let's compute: 
    // Sales Revenue (total sales sum)
    // COGS = SUM(sale_item.quantity * product.purchase_price)
    
    final salesResult = await db.rawQuery('SELECT SUM(total) as revenue FROM sales');
    final revenue = (salesResult.first['revenue'] as num?)?.toDouble() ?? 0.0;

    final cogsResult = await db.rawQuery('''
      SELECT SUM(si.quantity * p.purchase_price) as total_cost
      FROM sale_items si
      INNER JOIN products p ON si.product_id = p.id
    ''');
    final cost = (cogsResult.first['total_cost'] as num?)?.toDouble() ?? 0.0;

    return {
      'revenue': revenue,
      'cost': cost,
      'profit': revenue - cost,
    };
  }

  Future<List<Map<String, dynamic>>> getCategorySalesMetrics() async {
    final db = await instance.database;
    // Group sales by category
    return await db.rawQuery('''
      SELECT p.category, SUM(si.quantity) as items_sold, SUM(si.quantity * si.price) as revenue
      FROM sale_items si
      INNER JOIN products p ON si.product_id = p.id
      GROUP BY p.category
      ORDER BY revenue DESC
    ''');
  }

  Future<List<Map<String, dynamic>>> getDailySalesHistory() async {
    final db = await instance.database;
    // Get last 7 days of sales
    return await db.rawQuery('''
      SELECT SUBSTR(date, 1, 10) as sale_day, SUM(total) as day_total, COUNT(*) as day_count
      FROM sales
      GROUP BY sale_day
      ORDER BY sale_day DESC
      LIMIT 7
    ''');
  }

  // Clear Database (for testing / reset options)
  Future<void> clearAllData() async {
    final db = await instance.database;
    await db.delete('products');
    await db.delete('customers');
    await db.delete('suppliers');
    await db.delete('sales');
    await db.delete('sale_items');
    await db.delete('purchases');
    await db.delete('inventory_transactions');
  }
}
