import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/product_provider.dart';
import '../../database/db_helper.dart';
import '../../models/inventory_transaction.dart';
import 'add_edit_product_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;

  const ProductDetailScreen({Key? key, required this.productId}) : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  List<InventoryTransaction> _history = [];
  bool _isLoadingHistory = true;

  @override
  void initState() {
    super.initState();
    _loadTransactionHistory();
  }

  Future<void> _loadTransactionHistory() async {
    setState(() => _isLoadingHistory = true);
    try {
      final logs = await DatabaseHelper.instance.queryTransactionsByProduct(widget.productId);
      setState(() {
        _history = logs;
      });
    } catch (e) {
      debugPrint("Error loading product transaction ledger: $e");
    } finally {
      setState(() => _isLoadingHistory = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final productProvider = Provider.of<ProductProvider>(context);
    final product = productProvider.findProductById(widget.productId);
    final currencyFormatter = NumberFormat.currency(symbol: 'Rs. ', decimalDigits: 0);

    if (product == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Product Detail')),
        body: const Center(child: Text('Product not found!')),
      );
    }

    // Profit margin calculations
    final profit = product.salePrice - product.purchasePrice;
    final marginPercent = product.purchasePrice > 0 ? (profit / product.purchasePrice) * 100 : 0.0;
    final isLowStock = product.quantity <= 10;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AddEditProductScreen(product: product),
                ),
              ).then((_) {
                _loadTransactionHistory();
              });
            },
            tooltip: 'Edit Product',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product summary card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Large Category Badge
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.primaryColor.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            _getCategoryIcon(product.category),
                            color: theme.primaryColor,
                            size: 40,
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Title & category
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: theme.primaryColor.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  product.category,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: theme.primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 12),

                    // Metrics row (Cost, Sale, Profit)
                    Row(
                      children: [
                        Expanded(
                          child: _buildDetailMetric(
                            'Purchase Cost',
                            currencyFormatter.format(product.purchasePrice),
                            isDark ? Colors.blueGrey[400]! : Colors.blueGrey[600]!,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildDetailMetric(
                            'Selling Price',
                            currencyFormatter.format(product.salePrice),
                            theme.primaryColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildDetailMetric(
                            'Unit Margin',
                            '+${currencyFormatter.format(profit)} (${marginPercent.toStringAsFixed(0)}%)',
                            const Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Stock status and location specifications
            const Text(
              'Warehouse Parameters',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildSpecRow(
                      context,
                      label: 'Barcode Identifier',
                      value: product.barcode,
                      icon: Icons.qr_code,
                    ),
                    const Divider(height: 24),
                    _buildSpecRow(
                      context,
                      label: 'Rack / Shelf Location',
                      value: product.rackLocation,
                      icon: Icons.grid_view,
                    ),
                    const Divider(height: 24),
                    _buildSpecRow(
                      context,
                      label: 'Current Quantity Stock',
                      value: '${product.quantity} units',
                      icon: Icons.summarize,
                      valueColor: isLowStock ? Colors.red : const Color(0xFF10B981),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Product Description
            if (product.description.isNotEmpty) ...[
              const Text(
                'Product Description',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    product.description,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: isDark ? Colors.blueGrey[300] : Colors.blueGrey[700],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Product Stock Transactions ledger (Log history)
            const Text(
              'Stock Ledger History',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _isLoadingHistory
                ? const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator()))
                : _history.isEmpty
                    ? Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Center(
                            child: Text(
                              'No ledger logs recorded for this item.',
                              style: TextStyle(color: isDark ? Colors.blueGrey[400] : Colors.blueGrey[600]),
                            ),
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _history.length,
                        itemBuilder: (context, index) {
                          final log = _history[index];
                          final isIn = log.type == 'IN';
                          final dateText = DateFormat('MMM dd, yyyy - hh:mm a')
                              .format(DateTime.parse(log.date));

                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: isIn ? const Color(0xFF10B981).withOpacity(0.12) : Colors.red.withOpacity(0.12),
                                child: Icon(
                                  isIn ? Icons.arrow_downward : Icons.arrow_upward,
                                  color: isIn ? const Color(0xFF10B981) : Colors.red,
                                  size: 18,
                                ),
                              ),
                              title: Text(
                                log.reason,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              subtitle: Text(
                                dateText,
                                style: TextStyle(fontSize: 11, color: isDark ? Colors.blueGrey[400] : Colors.blueGrey[600]),
                              ),
                              trailing: Text(
                                '${isIn ? "+" : "-"}${log.quantity}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isIn ? const Color(0xFF10B981) : Colors.red,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailMetric(String title, String val, Color valColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          val,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: valColor,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildSpecRow(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    Color? valueColor,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        Icon(icon, color: theme.primaryColor.withOpacity(0.7), size: 20),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: isDark ? Colors.blueGrey[300] : Colors.blueGrey[700],
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: valueColor ?? (isDark ? Colors.white : Colors.black87),
          ),
        ),
      ],
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'electronics':
        return Icons.devices;
      case 'apparel':
      case 'clothing':
        return Icons.checkroom;
      case 'grocery':
      case 'food':
        return Icons.local_grocery_store;
      case 'home & kitchen':
      case 'home':
        return Icons.kitchen;
      case 'office':
      case 'stationary':
        return Icons.edit_note;
      default:
        return Icons.widgets_outlined;
    }
  }
}
