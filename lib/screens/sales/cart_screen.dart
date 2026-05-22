import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/sales_provider.dart';
import '../../providers/customer_provider.dart';
import '../../providers/product_provider.dart';
import '../../models/customer.dart';
import '../../widgets/custom_button.dart';
import 'invoice_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _discountController = TextEditingController();
  final _taxController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final sales = Provider.of<SalesProvider>(context, listen: false);
    _discountController.text = sales.discountPercent.toStringAsFixed(0);
    _taxController.text = sales.taxPercent.toStringAsFixed(0);
  }

  @override
  void dispose() {
    _discountController.dispose();
    _taxController.dispose();
    super.dispose();
  }

  void _processCheckout() async {
    final salesProvider = Provider.of<SalesProvider>(context, listen: false);
    final productProvider = Provider.of<ProductProvider>(context, listen: false);

    final saleId = await salesProvider.checkout();

    if (saleId != null && mounted) {
      // Refresh local products list since stock decreased
      await productProvider.fetchProducts();

      // Navigate to Invoice Viewer Screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => InvoiceScreen(saleId: saleId),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Checkout failed. Please verify item quantities.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final salesProvider = Provider.of<SalesProvider>(context);
    final customerProvider = Provider.of<CustomerProvider>(context);
    
    final currencyFormatter = NumberFormat.currency(symbol: 'Rs. ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined, color: Colors.redAccent),
            onPressed: () {
              salesProvider.clearCart();
              Navigator.of(context).pop();
            },
            tooltip: 'Clear Cart',
          ),
        ],
      ),
      body: salesProvider.cartItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.remove_shopping_cart_outlined, size: 64, color: isDark ? Colors.blueGrey[600] : Colors.blueGrey[300]),
                  const SizedBox(height: 16),
                  const Text(
                    'Your cart is empty!',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Go Back & Add Items'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // 1. Cart Items List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: salesProvider.cartItems.length,
                    itemBuilder: (context, index) {
                      final item = salesProvider.cartItems[index];
                      final prod = item.product;
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              // Text Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      prod.name,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${currencyFormatter.format(prod.salePrice)} / unit',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: theme.primaryColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Quantity Selector Steps
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline, color: Colors.grey),
                                    onPressed: () => salesProvider.decreaseQuantity(prod.id!),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey.withOpacity(0.3)),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '${item.quantity}',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline, color: Colors.grey),
                                    onPressed: () {
                                      if (item.quantity < prod.quantity) {
                                        salesProvider.addToCart(prod);
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Cannot exceed available stock of ${prod.quantity}!'),
                                            duration: const Duration(seconds: 1),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),

                              // Subtotal & Remove
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    currencyFormatter.format(item.subtotal),
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                                    onPressed: () => salesProvider.removeFromCart(prod.id!),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // 2. Settings Bar (Link Customer, Discount, Tax)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, -4),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      // Select Customer
                      Row(
                        children: [
                          Icon(Icons.person_pin_outlined, color: theme.primaryColor),
                          const SizedBox(width: 12),
                          const Text(
                            'Assign Customer:',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                          const Spacer(),
                          DropdownButton<Customer>(
                            value: salesProvider.selectedCustomer,
                            hint: const Text('Walk-in Customer'),
                            onChanged: (Customer? val) {
                              salesProvider.selectCustomer(val);
                            },
                            items: [
                              const DropdownMenuItem<Customer>(
                                value: null,
                                child: Text('Walk-in Customer'),
                              ),
                              ...customerProvider.customers.map((c) {
                                return DropdownMenuItem<Customer>(
                                  value: c,
                                  child: Text('${c.name} (${c.phone.substring(c.phone.length - 4)})'),
                                );
                              }).toList()
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 8),

                      // Discount & Tax inputs
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                const Text('Discount: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                const SizedBox(width: 6),
                                SizedBox(
                                  width: 50,
                                  height: 38,
                                  child: TextField(
                                    controller: _discountController,
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 12),
                                    decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.zero,
                                      suffixText: '%',
                                    ),
                                    onChanged: (val) {
                                      final discount = double.tryParse(val) ?? 0.0;
                                      salesProvider.setDiscount(discount >= 0 ? discount : 0.0);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                const Text('GST Tax: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                const SizedBox(width: 6),
                                SizedBox(
                                  width: 50,
                                  height: 38,
                                  child: TextField(
                                    controller: _taxController,
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 12),
                                    decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.zero,
                                      suffixText: '%',
                                    ),
                                    onChanged: (val) {
                                      final tax = double.tryParse(val) ?? 0.0;
                                      salesProvider.setTax(tax >= 0 ? tax : 0.0);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // 3. Invoice Summary Panel
                Container(
                  color: isDark ? const Color(0xFF111827) : Colors.grey[100],
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Subtotal', style: TextStyle(color: Colors.grey, fontSize: 13)),
                          Text(currencyFormatter.format(salesProvider.subtotal)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Discount (${salesProvider.discountPercent.toStringAsFixed(0)}%)',
                              style: const TextStyle(color: Colors.grey, fontSize: 13)),
                          Text('-${currencyFormatter.format(salesProvider.discountAmount)}', style: const TextStyle(color: Colors.red)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Sales Tax (${salesProvider.taxPercent.toStringAsFixed(0)}%)',
                              style: const TextStyle(color: Colors.grey, fontSize: 13)),
                          Text('+${currencyFormatter.format(salesProvider.taxAmount)}', style: const TextStyle(color: Colors.blue)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Grand Total', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                          Text(
                            currencyFormatter.format(salesProvider.grandTotal),
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.primaryColor),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Checkout button
                      CustomButton(
                        text: 'Process Checkout (Bill)',
                        icon: Icons.point_of_sale,
                        onPressed: _processCheckout,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
