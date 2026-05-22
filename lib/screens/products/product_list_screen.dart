import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/product_provider.dart';
import '../../models/product.dart';
import 'add_edit_product_screen.dart';
import 'product_detail_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({Key? key}) : super(key: key);

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-populate search query if any
    final query = Provider.of<ProductProvider>(context, listen: false).searchQuery;
    _searchController.text = query;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _deleteProduct(BuildContext context, int id, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Product?'),
        content: Text('Are you sure you want to delete "$name"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              final success = await Provider.of<ProductProvider>(context, listen: false).removeProduct(id);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Product deleted successfully!')),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final productProvider = Provider.of<ProductProvider>(context);
    final currencyFormatter = NumberFormat.currency(symbol: 'Rs. ', decimalDigits: 0);

    return Scaffold(
      body: Column(
        children: [
          // Search & Filter header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => productProvider.setSearchQuery(val),
              decoration: InputDecoration(
                hintText: 'Search products by name or barcode...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          productProvider.setSearchQuery('');
                        },
                      )
                    : null,
              ),
            ),
          ),

          // Categories List Header
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: productProvider.categories.length,
              itemBuilder: (context, index) {
                final cat = productProvider.categories[index];
                final isSelected = productProvider.selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: FilterChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (selected) {
                      productProvider.setCategory(cat);
                    },
                    selectedColor: theme.primaryColor.withOpacity(0.18),
                    checkmarkColor: theme.primaryColor,
                    labelStyle: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? theme.primaryColor : (isDark ? Colors.blueGrey[300] : Colors.blueGrey[700]),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                );
              },
            ),
          ),

          // Products List
          Expanded(
            child: productProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : productProvider.products.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inventory_2_outlined, size: 64, color: isDark ? Colors.blueGrey[600] : Colors.blueGrey[300]),
                            const SizedBox(height: 16),
                            Text(
                              'No products found!',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.blueGrey[400] : Colors.blueGrey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text('Try adjusting your search or category filters.'),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => productProvider.fetchProducts(),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: productProvider.products.length,
                          itemBuilder: (context, index) {
                            final prod = productProvider.products[index];
                            final isLowStock = prod.quantity <= 10;
                            
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: InkWell(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => ProductDetailScreen(productId: prod.id!),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Image Placeholder / Category icon
                                      Container(
                                        width: 58,
                                        height: 58,
                                        decoration: BoxDecoration(
                                          color: theme.primaryColor.withOpacity(0.08),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          _getCategoryIcon(prod.category),
                                          color: theme.primaryColor,
                                          size: 28,
                                        ),
                                      ),
                                      const SizedBox(width: 14),

                                      // Product Details
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              prod.name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 3),
                                            Text(
                                              'Barcode: ${prod.barcode} • Rack: ${prod.rackLocation}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: isDark ? Colors.blueGrey[400] : Colors.blueGrey[600],
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Row(
                                              children: [
                                                Text(
                                                  'Sale: ${currencyFormatter.format(prod.salePrice)}',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13,
                                                    color: theme.primaryColor,
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Text(
                                                  'Cost: ${currencyFormatter.format(prod.purchasePrice)}',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: isDark ? Colors.blueGrey[400] : Colors.blueGrey[600],
                                                  ),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),

                                      // Quantity & Operations
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: isLowStock
                                                  ? Colors.red.withOpacity(0.12)
                                                  : theme.primaryColor.withOpacity(0.08),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              'Stock: ${prod.quantity}',
                                              style: TextStyle(
                                                color: isLowStock ? Colors.red : theme.primaryColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                padding: EdgeInsets.zero,
                                                constraints: const BoxConstraints(),
                                                icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 20),
                                                onPressed: () {
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                      builder: (_) => AddEditProductScreen(product: prod),
                                                    ),
                                                  );
                                                },
                                              ),
                                              const SizedBox(width: 10),
                                              IconButton(
                                                padding: EdgeInsets.zero,
                                                constraints: const BoxConstraints(),
                                                icon: Icon(Icons.delete_outline, color: theme.colorScheme.error, size: 20),
                                                onPressed: () => _deleteProduct(context, prod.id!, prod.name),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const AddEditProductScreen(),
            ),
          );
        },
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
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
