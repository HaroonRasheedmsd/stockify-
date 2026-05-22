import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/product_provider.dart';
import '../../providers/sales_provider.dart';
import '../../models/product.dart';
import 'cart_screen.dart';

class PosScreen extends StatefulWidget {
  const PosScreen({Key? key}) : super(key: key);

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final productProvider = Provider.of<ProductProvider>(context);
    final salesProvider = Provider.of<SalesProvider>(context);
    final currencyFormatter = NumberFormat.currency(symbol: 'Rs. ', decimalDigits: 0);

    return Scaffold(
      body: Column(
        children: [
          // Search Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => productProvider.setSearchQuery(val),
              decoration: InputDecoration(
                hintText: 'Search product or scan barcode...',
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

          // Categories chips
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

          // Products Catalog Grid
          Expanded(
            child: productProvider.products.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_outlined, size: 60, color: isDark ? Colors.blueGrey[600] : Colors.blueGrey[300]),
                        const SizedBox(height: 16),
                        Text(
                          'No products matching filters!',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.blueGrey[400] : Colors.blueGrey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.88,
                    ),
                    itemCount: productProvider.products.length,
                    itemBuilder: (context, index) {
                      final prod = productProvider.products[index];
                      final cartQty = salesProvider.cart[prod.id]?.quantity ?? 0;
                      final isOutOfStock = prod.quantity <= 0;
                      
                      return Card(
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: isOutOfStock
                              ? null
                              : () {
                                  salesProvider.addToCart(prod);
                                },
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Top row: Category & Cart Badge indicator
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      prod.category,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: theme.primaryColor.withOpacity(0.8),
                                      ),
                                    ),
                                    if (cartQty > 0)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF10B981),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          'x$cartQty',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),

                                const SizedBox(height: 6),

                                // Product Name
                                Text(
                                  prod.name,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),

                                const SizedBox(height: 4),

                                // Location info
                                Text(
                                  'Rack: ${prod.rackLocation}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isDark ? Colors.blueGrey[400] : Colors.blueGrey[500],
                                  ),
                                ),

                                const SizedBox(height: 8),

                                // Bottom row: Price & Stock
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        currencyFormatter.format(prod.salePrice),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: theme.primaryColor,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: isOutOfStock
                                            ? Colors.red.withOpacity(0.12)
                                            : Colors.grey.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        isOutOfStock ? 'Out of stock' : 'Stock: ${prod.quantity}',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w600,
                                          color: isOutOfStock ? Colors.red : (isDark ? Colors.white70 : Colors.black87),
                                        ),
                                      ),
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

          // Floating Cart Indicator at the bottom if items are present
          if (salesProvider.cartItems.isNotEmpty)
            SafeArea(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [theme.primaryColor, theme.colorScheme.secondary],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: theme.primaryColor.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.shopping_bag_outlined, color: Colors.white),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${salesProvider.cartItems.length} Products Selected',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'Total Cost: ${currencyFormatter.format(salesProvider.grandTotal)}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: theme.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const CartScreen(),
                          ),
                        );
                      },
                      child: const Row(
                        children: [
                          Text('View Cart', style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward, size: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
