import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../models/product.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class AddEditProductScreen extends StatefulWidget {
  final Product? product;

  const AddEditProductScreen({Key? key, this.product}) : super(key: key);

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _purchasePriceController = TextEditingController();
  final _salePriceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _rackLocationController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedCategory = 'Electronics';
  final List<String> _categoryOptions = [
    'Electronics',
    'Apparel',
    'Grocery',
    'Home & Kitchen',
    'Office',
    'Others',
  ];

  bool get _isEditMode => widget.product != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      final p = widget.product!;
      _nameController.text = p.name;
      _barcodeController.text = p.barcode;
      _purchasePriceController.text = p.purchasePrice.toString();
      _salePriceController.text = p.salePrice.toString();
      _quantityController.text = p.quantity.toString();
      _rackLocationController.text = p.rackLocation;
      _descriptionController.text = p.description;
      
      if (_categoryOptions.contains(p.category)) {
        _selectedCategory = p.category;
      } else {
        _selectedCategory = 'Others';
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _barcodeController.dispose();
    _purchasePriceController.dispose();
    _salePriceController.dispose();
    _quantityController.dispose();
    _rackLocationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveForm() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final barcode = _barcodeController.text.trim();
    final pPrice = double.parse(_purchasePriceController.text);
    final sPrice = double.parse(_salePriceController.text);
    final qty = int.parse(_quantityController.text);
    final location = _rackLocationController.text.trim().isEmpty ? 'Unassigned' : _rackLocationController.text.trim();
    final desc = _descriptionController.text.trim();

    final productProvider = Provider.of<ProductProvider>(context, listen: false);

    bool success;
    if (_isEditMode) {
      final updatedProduct = widget.product!.copyWith(
        name: name,
        barcode: barcode,
        category: _selectedCategory,
        purchasePrice: pPrice,
        salePrice: sPrice,
        quantity: qty,
        rackLocation: location,
        description: desc,
      );
      success = await productProvider.editProduct(updatedProduct);
    } else {
      final newProduct = Product(
        name: name,
        barcode: barcode,
        category: _selectedCategory,
        purchasePrice: pPrice,
        salePrice: sPrice,
        quantity: qty,
        rackLocation: location,
        description: desc,
      );
      success = await productProvider.addProduct(newProduct);
    }

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditMode ? 'Product updated successfully!' : 'Product added successfully!'),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
      Navigator.of(context).pop();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Operation failed. Please check your data.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Product' : 'Add New Product'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                label: 'Product Name',
                hint: 'e.g., Slim Fit Casual Shirt',
                prefixIcon: Icons.title_outlined,
                controller: _nameController,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Product name is required';
                  return null;
                },
              ),
              const SizedBox(height: 18),
              
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: 'Barcode ID',
                      hint: 'e.g., 88012345',
                      prefixIcon: Icons.qr_code_outlined,
                      controller: _barcodeController,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Barcode is required';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Category',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: isDark ? Colors.blueGrey[300] : Colors.blueGrey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            prefixIcon: Icon(Icons.category_outlined, color: theme.primaryColor.withOpacity(0.8)),
                          ),
                          items: _categoryOptions.map((String cat) {
                            return DropdownMenuItem<String>(
                              value: cat,
                              child: Text(cat),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedCategory = newValue;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: 'Purchase Cost (Rs.)',
                      hint: 'e.g., 250',
                      prefixIcon: Icons.input_outlined,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      controller: _purchasePriceController,
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Cost is required';
                        if (double.tryParse(val) == null) return 'Must be decimal';
                        if (double.parse(val) < 0) return 'Cannot be negative';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      label: 'Selling Price (Rs.)',
                      hint: 'e.g., 400',
                      prefixIcon: Icons.sell_outlined,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      controller: _salePriceController,
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Selling price required';
                        if (double.tryParse(val) == null) return 'Must be decimal';
                        if (double.parse(val) < 0) return 'Cannot be negative';
                        // Validate markup
                        final costStr = _purchasePriceController.text;
                        if (costStr.isNotEmpty && double.tryParse(costStr) != null) {
                          if (double.parse(val) < double.parse(costStr)) {
                            return 'Below cost price';
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: 'Initial Quantity',
                      hint: 'e.g., 100',
                      prefixIcon: Icons.summarize_outlined,
                      keyboardType: TextInputType.number,
                      controller: _quantityController,
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Quantity required';
                        if (int.tryParse(val) == null) return 'Must be integer';
                        if (int.parse(val) < 0) return 'Cannot be negative';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      label: 'Rack Location',
                      hint: 'e.g., Shelf C-4',
                      prefixIcon: Icons.grid_view_outlined,
                      controller: _rackLocationController,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              CustomTextField(
                label: 'Product Description',
                hint: 'Enter item dimensions, components, materials, or features...',
                prefixIcon: Icons.description_outlined,
                controller: _descriptionController,
                maxLines: 3,
              ),
              const SizedBox(height: 36),

              CustomButton(
                text: _isEditMode ? 'Update Product Details' : 'Add Product to Inventory',
                icon: Icons.check_circle_outline,
                onPressed: _saveForm,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
