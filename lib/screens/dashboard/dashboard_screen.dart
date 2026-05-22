import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/sales_provider.dart';
import '../../providers/customer_provider.dart';
import '../../providers/supplier_provider.dart';
import '../../widgets/dashboard_card.dart';
import '../auth/login_screen.dart';
import '../products/product_list_screen.dart';
import '../inventory/inventory_screen.dart';
import '../inventory/inventory_history_screen.dart';
import '../sales/pos_screen.dart';
import '../customers/customer_list_screen.dart';
import '../suppliers/supplier_list_screen.dart';
import '../reports/reports_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  bool _isInit = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      // Fetch initial data
      Provider.of<ProductProvider>(context, listen: false).fetchProducts();
      Provider.of<SalesProvider>(context, listen: false).fetchSalesHistory();
      Provider.of<CustomerProvider>(context, listen: false).fetchCustomers();
      Provider.of<SupplierProvider>(context, listen: false).fetchSuppliers();
      _isInit = false;
    }
  }

  // Reload statistics
  Future<void> _refreshStats() async {
    await Provider.of<ProductProvider>(context, listen: false).fetchProducts();
    await Provider.of<SalesProvider>(context, listen: false).fetchSalesHistory();
    await Provider.of<CustomerProvider>(context, listen: false).fetchCustomers();
    await Provider.of<SupplierProvider>(context, listen: false).fetchSuppliers();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    // Dynamic Pages mapped to Bottom Navigation
    final List<Widget> pages = [
      _buildDashboardHome(context, isDark, authProvider, themeProvider),
      const ProductListScreen(),
      const PosScreen(),
      const ReportsScreen(),
    ];

    final List<String> titles = [
      'Stockify Portal',
      'Inventory Catalog',
      'POS Checkout',
      'Performance Reports',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_currentIndex]),
        actions: [
          IconButton(
            icon: Icon(themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => themeProvider.toggleTheme(),
            tooltip: 'Toggle Theme',
          ),
          if (_currentIndex == 0)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _refreshStats,
              tooltip: 'Refresh Stats',
            ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            // Drawer Header
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [theme.primaryColor, theme.colorScheme.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.9),
                child: Icon(
                  Icons.person,
                  color: theme.primaryColor,
                  size: 38,
                ),
              ),
              accountName: Text(
                authProvider.userName,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              accountEmail: Text(
                authProvider.userRole,
                style: const TextStyle(color: Colors.white70),
              ),
            ),
            
            // Drawer Items
            _buildDrawerTile(
              context,
              icon: Icons.dashboard_outlined,
              title: 'Dashboard Home',
              onTap: () {
                Navigator.of(context).pop();
                setState(() => _currentIndex = 0);
              },
            ),
            _buildDrawerTile(
              context,
              icon: Icons.inventory_2_outlined,
              title: 'Product Inventory',
              onTap: () {
                Navigator.of(context).pop();
                setState(() => _currentIndex = 1);
              },
            ),
            _buildDrawerTile(
              context,
              icon: Icons.point_of_sale_outlined,
              title: 'Point of Sale (POS)',
              onTap: () {
                Navigator.of(context).pop();
                setState(() => _currentIndex = 2);
              },
            ),
            _buildDrawerTile(
              context,
              icon: Icons.swap_horiz_outlined,
              title: 'Stock In / Stock Out',
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const InventoryScreen()),
                ).then((_) => _refreshStats());
              },
            ),
            _buildDrawerTile(
              context,
              icon: Icons.history_outlined,
              title: 'Inventory Transaction Ledger',
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const InventoryHistoryScreen()),
                );
              },
            ),
            const Divider(),
            _buildDrawerTile(
              context,
              icon: Icons.people_alt_outlined,
              title: 'Customers Directory',
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CustomerListScreen()),
                );
              },
            ),
            _buildDrawerTile(
              context,
              icon: Icons.local_shipping_outlined,
              title: 'Suppliers Registry',
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SupplierListScreen()),
                );
              },
            ),
            _buildDrawerTile(
              context,
              icon: Icons.analytics_outlined,
              title: 'Financial Reports',
              onTap: () {
                Navigator.of(context).pop();
                setState(() => _currentIndex = 3);
              },
            ),
            const Spacer(),
            const Divider(),
            _buildDrawerTile(
              context,
              icon: Icons.logout_outlined,
              title: 'Sign Out',
              color: theme.colorScheme.error,
              onTap: () {
                Navigator.of(context).pop();
                authProvider.logout();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'POS',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.insert_chart),
            label: 'Reports',
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: color ?? theme.textTheme.bodyLarge?.color?.withOpacity(0.7)),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: color ?? theme.textTheme.bodyLarge?.color,
        ),
      ),
      onTap: onTap,
    );
  }

  // Dashboard Tab Content
  Widget _buildDashboardHome(
    BuildContext context,
    bool isDark,
    AuthProvider auth,
    ThemeProvider themeProvider,
  ) {
    final theme = Theme.of(context);
    final productProvider = Provider.of<ProductProvider>(context);
    final salesProvider = Provider.of<SalesProvider>(context);

    // Calculate metrics
    final totalStockItems = productProvider.rawProductsList.length;
    final totalQtySum = productProvider.rawProductsList.fold<int>(0, (sum, p) => sum + p.quantity);
    final lowStockCount = productProvider.lowStockProducts.length;

    // Calculate today's sales
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final todaySales = salesProvider.salesHistory.where((s) => s.date.startsWith(todayStr));
    final todayRevenue = todaySales.fold<double>(0.0, (sum, s) => sum + s.total);

    final currencyFormatter = NumberFormat.currency(symbol: 'Rs. ', decimalDigits: 0);

    return RefreshIndicator(
      onRefresh: _refreshStats,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Greetings
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, ${auth.userName} 👋',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Here is your business overview for today',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.blueGrey[400] : Colors.blueGrey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Statistics Grid (3 items)
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.45,
              children: [
                DashboardCard(
                  title: 'Today\'s Sales',
                  value: currencyFormatter.format(todayRevenue),
                  icon: Icons.monetization_on_outlined,
                  color: const Color(0xFF10B981),
                  subtitle: '${todaySales.length} items',
                  onTap: () {
                    setState(() => _currentIndex = 3);
                  },
                ),
                DashboardCard(
                  title: 'Low Stock Alerts',
                  value: lowStockCount.toString(),
                  icon: Icons.warning_amber_outlined,
                  color: lowStockCount > 0 ? Colors.redAccent : Colors.amber,
                  subtitle: lowStockCount > 0 ? 'Critical' : 'Healthy',
                  onTap: () {
                    // Navigate to products catalog filter
                    productProvider.setCategory('All');
                    setState(() => _currentIndex = 1);
                  },
                ),
                DashboardCard(
                  title: 'Total Categories',
                  value: (productProvider.categories.length - 1).toString(),
                  icon: Icons.category_outlined,
                  color: Colors.indigo,
                  onTap: () {
                    setState(() => _currentIndex = 1);
                  },
                ),
                DashboardCard(
                  title: 'Total Inventory Stock',
                  value: totalQtySum.toString(),
                  icon: Icons.inventory_2_outlined,
                  color: Colors.lightBlue,
                  subtitle: '$totalStockItems unique products',
                  onTap: () {
                    setState(() => _currentIndex = 1);
                  },
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Low Stock Warnings section (If any exist)
            if (lowStockCount > 0) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '⚠️ Low Stock Warnings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const InventoryScreen()),
                      ).then((_) => _refreshStats());
                    },
                    child: const Text('Restock Now'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: productProvider.lowStockProducts.length > 3
                    ? 3
                    : productProvider.lowStockProducts.length,
                itemBuilder: (context, index) {
                  final prod = productProvider.lowStockProducts[index];
                  return Card(
                    color: isDark ? const Color(0xFF2D1F2F) : const Color(0xFFFEF2F2),
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.red.withOpacity(0.15),
                        child: const Icon(Icons.warning, color: Colors.red),
                      ),
                      title: Text(
                        prod.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      subtitle: Text(
                        'Category: ${prod.category} | Location: ${prod.rackLocation}',
                        style: TextStyle(fontSize: 12, color: isDark ? Colors.blueGrey[400] : Colors.blueGrey[600]),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Qty: ${prod.quantity}',
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Need Restock',
                            style: TextStyle(fontSize: 10, color: Colors.redAccent),
                          ),
                        ],
                      ),
                      onTap: () {
                        // Edit/Restock action
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const InventoryScreen(),
                          ),
                        ).then((_) => _refreshStats());
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],

            // Quick Nav Links
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),

            // Quick Nav Buttons
            Row(
              children: [
                _buildQuickActionBtn(
                  context,
                  label: 'POS Billing',
                  icon: Icons.add_shopping_cart,
                  color: Colors.teal,
                  onTap: () => setState(() => _currentIndex = 2),
                ),
                const SizedBox(width: 12),
                _buildQuickActionBtn(
                  context,
                  label: 'Adjust Stock',
                  icon: Icons.import_export,
                  color: Colors.purple,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const InventoryScreen()),
                    ).then((_) => _refreshStats());
                  },
                ),
                const SizedBox(width: 12),
                _buildQuickActionBtn(
                  context,
                  label: 'Reports',
                  icon: Icons.insert_chart_outlined,
                  color: Colors.orange,
                  onTap: () => setState(() => _currentIndex = 3),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionBtn(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withOpacity(isDark ? 0.25 : 0.15),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 10),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: isDark ? Colors.blueGrey[200] : Colors.blueGrey[800],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
