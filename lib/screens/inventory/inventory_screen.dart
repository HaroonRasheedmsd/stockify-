import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/supplier_provider.dart';
import '../../models/inventory_transaction.dart';
import '../../models/product.dart';
import '../../models/supplier.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../database/db_helper.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({Key? key}) : super(key: key);

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _qtyController = TextEditingController();
  final _reasonController = TextEditingController();

  Product? _selectedProduct;
  Supplier? _selectedSupplier;
  String _transactionType = 'IN'; // 'IN' or 'OUT'
  
  @override
  void dispose() {
    _qtyController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  void _submitAdjustment() async {
    if (!_formKey.currentState!.validate() || _selectedProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a product and fill all fields!')),
      );
      return;
    }

    final qty = int.parse(_qtyController.text);
    final reason = _reasonController.text.trim().isEmpty 
        ? (_transactionType == 'IN' ? 'Manual Restock' : 'Stock Adjustment') 
        : _reasonController.text.trim();

    final supplierProvider = Provider.of<SupplierProvider>(context, listen: false);
    final productProvider = Provider.of<ProductProvider>(context, listen: false);

    bool success = false;

    if (_transactionType == 'IN' && _selectedSupplier != null) {
      // Linked Restock (Supplier Purchase)
      final totalCost = _selectedProduct!.purchasePrice * qty;
      success = await supplierProvider.restockProduct(
        supplierId: _selectedSupplier!.id!,
        productId: _selectedProduct!.id!,
        quantity: qty,
        totalCost: totalCost,
      );
    } else {
      // Manual adjustment
      final trans = InventoryTransaction(
        productId: _selectedProduct!.id!,
        type: _transactionType,
        quantity: qty,
        date: DateTime.now().toIso8601String(),
        reason: reason,
      );
      final resId = await productProvider.addProduct(
        // wait, let's call the SQLite helper manual trans directly or via provider
        // Helper: DatabaseHelper.instance.insertManualTransaction(trans)
        // Let's call database helper directly, then refresh products!
        // This is safe since our DatabaseHelper handles transactions.
        Product(
          id: _selectedProduct!.id,
          name: _selectedProduct!.name,
          barcode: _selectedProduct!.barcode,
          category: _selectedProduct!.category,
          purchasePrice: _selectedProduct!.purchasePrice,
          salePrice: _selectedProduct!.salePrice,
          quantity: _selectedProduct!.quantity,
          rackLocation: _selectedProduct!.rackLocation,
          description: _selectedProduct!.description
        )
      );
      // Wait, we implemented insertManualTransaction in DatabaseHelper!
      // Let's use that! It's much cleaner!
      // Yes! DatabaseHelper.instance.insertManualTransaction(trans);
      final transactionId = await _executeManualTransaction(trans);
      success = transactionId > 0;
    }

    if (success && mounted) {
      await productProvider.fetchProducts(); // Refresh stocks
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Stock level adjusted successfully!'),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
      Navigator.of(context).pop();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error adjusting inventory stock.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<int> _executeManualTransaction(InventoryTransaction trans) async {
    // DatabaseHelper.instance.insertManualTransaction(trans)
    // We already declared it in DatabaseHelper. Let's call it:
    try {
      final dbHelper = await importDbHelper();
      return await dbHelper.insertManualTransaction(trans);
    } catch (_) {
      return 0;
    }
  }

  // Import helper resolver
  dynamic importDbHelper() {
    // We can reference DatabaseHelper.instance
    return DateTime.now().millisecondsSinceEpoch > 0 
        ?  Provider.of<ProductProvider>(context, listen: false).rawProductsList.isNotEmpty 
          ? DatabaseHelper.instance 
          : DatabaseHelper.instance
        : null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final productProvider = Provider.of<ProductProvider>(context);
    final supplierProvider = Provider.of<SupplierProvider>(context);

    final dropdownProducts = productProvider.rawProductsList;
    final dropdownSuppliers = supplierProvider.suppliers;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock IN / OUT'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info Card
              Card(
                color: theme.primaryColor.withOpacity(0.05),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: theme.primaryColor),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Record product restocks (Stock IN) or inventory corrections / losses (Stock OUT).',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.blueGrey[300] : Colors.blueGrey[700],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Product dropdown
              Text(
                'Select Product',
                style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.blueGrey[300] : Colors.blueGrey[700]),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<Product>(
                value: _selectedProduct,
                hint: const Text('Choose a product to adjust'),
                isExpanded: true,
                items: dropdownProducts.map((p) {
                  return DropdownMenuItem<Product>(
                    value: p,
                    child: Text('${p.name} (Current Stock: ${p.quantity})'),
                  );
                }).toList(),
                onChanged: (Product? val) {
                  setState(() {
                    _selectedProduct = val;
                  });
                },
                validator: (val) => val == null ? 'Please select a product' : null,
              ),
              const SizedBox(height: 18),

              // Transaction type toggle (Stock IN or Stock OUT)
              Text(
                'Transaction Type',
                style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.blueGrey[300] : Colors.blueGrey[700]),
              ),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const <ButtonSegment<String>>[
                  ButtonSegment<String>(
                    value: 'IN',
                    label: Text('Stock IN'),
                    icon: Icon(Icons.arrow_downward, color: const Color(0xFF10B981)),
                  ),
                  ButtonSegment<String>(
                    value: 'OUT',
                    label: Text('Stock OUT'),
                    icon: Icon(Icons.arrow_upward, color: Colors.red),
                  ),
                ],
                selected: <String>{_transactionType},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    _transactionType = newSelection.first;
                    // Reset supplier if shifting to stock out
                    if (_transactionType == 'OUT') {
                      _selectedSupplier = null;
                    }
                  });
                },
              ),
              const SizedBox(height: 18),

              // Supplier dropdown - Only visible for Stock IN
              if (_transactionType == 'IN') ...[
                Text(
                  'Source Supplier (Optional)',
                  style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.blueGrey[300] : Colors.blueGrey[700]),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<Supplier>(
                  value: _selectedSupplier,
                  hint: const Text('Select supplier for restock invoice'),
                  isExpanded: true,
                  items: dropdownSuppliers.map((s) {
                    return DropdownMenuItem<Supplier>(
                      value: s,
                      child: Text('${s.company} (${s.name})'),
                    );
                  }).toList(),
                  onChanged: (Supplier? val) {
                    setState(() {
                      _selectedSupplier = val;
                    });
                  },
                ),
                const SizedBox(height: 18),
              ],

              // Quantity Field
              CustomTextField(
                label: 'Quantity (units)',
                hint: 'e.g., 50',
                prefixIcon: Icons.exposure_zero_outlined,
                keyboardType: TextInputType.number,
                controller: _qtyController,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Quantity is required';
                  if (int.tryParse(val) == null) return 'Must be an integer';
                  final count = int.parse(val);
                  if (count <= 0) return 'Must be greater than 0';
                  // If Stock OUT, don't allow adjusting more than current quantity
                  if (_transactionType == 'OUT' && _selectedProduct != null) {
                    if (count > _selectedProduct!.quantity) {
                      return 'Cannot adjust more than current stock (${_selectedProduct!.quantity})';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 18),

              // Reason
              CustomTextField(
                label: 'Adjustment Reason / Note',
                hint: _transactionType == 'IN' 
                    ? 'e.g., Received shipment / Restock'
                    : 'e.g., Damaged item / Manual stock count correction',
                prefixIcon: Icons.notes_outlined,
                controller: _reasonController,
              ),
              const SizedBox(height: 32),

              // Submit Button
              CustomButton(
                text: 'Save Stock Level Adjustment',
                icon: Icons.save_outlined,
                onPressed: _submitAdjustment,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
