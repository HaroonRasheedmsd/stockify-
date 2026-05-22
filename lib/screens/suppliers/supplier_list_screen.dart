import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/supplier_provider.dart';
import '../../models/supplier.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import 'supplier_detail_screen.dart';

class SupplierListScreen extends StatefulWidget {
  const SupplierListScreen({Key? key}) : super(key: key);

  @override
  State<SupplierListScreen> createState() => _SupplierListScreenState();
}

class _SupplierListScreenState extends State<SupplierListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openAddSupplierSheet(BuildContext context, {Supplier? supplier}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final nameController = TextEditingController(text: supplier?.name);
    final companyController = TextEditingController(text: supplier?.company);
    final phoneController = TextEditingController(text: supplier?.phone);
    final addressController = TextEditingController(text: supplier?.address);
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          top: 24,
          left: 20,
          right: 20,
        ),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  supplier == null ? 'Register New Supplier' : 'Modify Supplier Info',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                
                CustomTextField(
                  label: 'Company Name',
                  hint: 'e.g., Al-Makkah Electronics',
                  prefixIcon: Icons.business_outlined,
                  controller: companyController,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Company name is required';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  label: 'Contact Representative',
                  hint: 'e.g., Muhammad Arif',
                  prefixIcon: Icons.person_outline,
                  controller: nameController,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Representative name is required';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                CustomTextField(
                  label: 'Phone Number',
                  hint: 'e.g., 0321-9998877',
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  controller: phoneController,
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Phone is required';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                CustomTextField(
                  label: 'Office Address',
                  hint: 'e.g., Hall Road, Lahore',
                  prefixIcon: Icons.map_outlined,
                  controller: addressController,
                ),
                const SizedBox(height: 24),
                
                CustomButton(
                  text: supplier == null ? 'Register Supplier' : 'Save Details',
                  icon: Icons.check_circle_outline,
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    
                    final provider = Provider.of<SupplierProvider>(context, listen: false);
                    bool success;

                    if (supplier != null) {
                      final updated = supplier.copyWith(
                        name: nameController.text.trim(),
                        company: companyController.text.trim(),
                        phone: phoneController.text.trim(),
                        address: addressController.text.trim(),
                      );
                      success = await provider.editSupplier(updated);
                    } else {
                      final newSup = Supplier(
                        name: nameController.text.trim(),
                        company: companyController.text.trim(),
                        phone: phoneController.text.trim(),
                        address: addressController.text.trim(),
                      );
                      success = await provider.addSupplier(newSup);
                    }

                    if (success && mounted) {
                      Navigator.of(ctx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(supplier == null ? 'Supplier added!' : 'Supplier details updated!'),
                          backgroundColor: const Color(0xFF10B981),
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, int id, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Supplier?'),
        content: Text('Are you sure you want to remove "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.of(ctx).pop();
              final success = await Provider.of<SupplierProvider>(context, listen: false).removeSupplier(id);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Supplier profile removed.')),
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
    final provider = Provider.of<SupplierProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Suppliers Registry'),
      ),
      body: Column(
        children: [
          // Search Box
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => provider.setSearchQuery(val),
              decoration: InputDecoration(
                hintText: 'Search company or contact person...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          provider.setSearchQuery('');
                        },
                      )
                    : null,
              ),
            ),
          ),

          // Lists
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.suppliers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.local_shipping_outlined, size: 60, color: isDark ? Colors.blueGrey[600] : Colors.blueGrey[300]),
                            const SizedBox(height: 16),
                            Text(
                              'No suppliers registered.',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.blueGrey[400] : Colors.blueGrey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => provider.fetchSuppliers(),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: provider.suppliers.length,
                          itemBuilder: (context, index) {
                            final sup = provider.suppliers[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: ListTile(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => SupplierDetailScreen(supplier: sup),
                                    ),
                                  );
                                },
                                leading: CircleAvatar(
                                  backgroundColor: theme.primaryColor.withOpacity(0.08),
                                  child: Icon(Icons.local_shipping, color: theme.primaryColor),
                                ),
                                title: Text(
                                  sup.company,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text('Agent: ${sup.name} • Phone: ${sup.phone}\nAddr: ${sup.address.isEmpty ? "No Address" : sup.address}'),
                                isThreeLine: true,
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 20),
                                      onPressed: () => _openAddSupplierSheet(context, supplier: sup),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete_outline, color: theme.colorScheme.error, size: 20),
                                      onPressed: () => _confirmDelete(context, sup.id!, sup.company),
                                    ),
                                  ],
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
        onPressed: () => _openAddSupplierSheet(context),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.local_shipping_outlined),
      ),
    );
  }
}
