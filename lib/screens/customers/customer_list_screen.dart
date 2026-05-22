import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/customer_provider.dart';
import '../../models/customer.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({Key? key}) : super(key: key);

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openAddCustomerSheet(BuildContext context, {Customer? customer}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final nameController = TextEditingController(text: customer?.name);
    final phoneController = TextEditingController(text: customer?.phone);
    final addressController = TextEditingController(text: customer?.address);
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
                  customer == null ? 'Add Customer Profile' : 'Edit Customer Profile',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                
                CustomTextField(
                  label: 'Customer Name',
                  hint: 'e.g., Haroon Arif',
                  prefixIcon: Icons.person_outline,
                  controller: nameController,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Name is required';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                CustomTextField(
                  label: 'Phone Number',
                  hint: 'e.g., 0300-1234567',
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  controller: phoneController,
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Phone is required';
                    if (val.length < 7) return 'Enter a valid phone number';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                CustomTextField(
                  label: 'Billing Address',
                  hint: 'e.g., Block H, Gulberg III, Lahore',
                  prefixIcon: Icons.map_outlined,
                  controller: addressController,
                ),
                const SizedBox(height: 24),
                
                CustomButton(
                  text: customer == null ? 'Register Customer' : 'Save Modifications',
                  icon: Icons.check_circle_outline,
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    
                    final provider = Provider.of<CustomerProvider>(context, listen: false);
                    bool success;

                    if (customer != null) {
                      final updated = customer.copyWith(
                        name: nameController.text.trim(),
                        phone: phoneController.text.trim(),
                        address: addressController.text.trim(),
                      );
                      success = await provider.editCustomer(updated);
                    } else {
                      final newCust = Customer(
                        name: nameController.text.trim(),
                        phone: phoneController.text.trim(),
                        address: addressController.text.trim(),
                      );
                      success = await provider.addCustomer(newCust);
                    }

                    if (success && mounted) {
                      Navigator.of(ctx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(customer == null ? 'Customer registered!' : 'Details modified!'),
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
        title: const Text('Remove Customer?'),
        content: Text('Are you sure you want to remove customer "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.of(ctx).pop();
              final success = await Provider.of<CustomerProvider>(context, listen: false).removeCustomer(id);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Customer profile deleted.')),
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
    final provider = Provider.of<CustomerProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers Directory'),
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
                hintText: 'Search customer name or phone...',
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

          // Customer Lists
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.customers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people_outline, size: 60, color: isDark ? Colors.blueGrey[600] : Colors.blueGrey[300]),
                            const SizedBox(height: 16),
                            Text(
                              'No customers registered.',
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
                        onRefresh: () => provider.fetchCustomers(),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: provider.customers.length,
                          itemBuilder: (context, index) {
                            final cust = provider.customers[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: theme.primaryColor.withOpacity(0.08),
                                  child: Icon(Icons.person, color: theme.primaryColor),
                                ),
                                title: Text(
                                  cust.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text('${cust.phone} • Address: ${cust.address.isEmpty ? "No Address" : cust.address}'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 20),
                                      onPressed: () => _openAddCustomerSheet(context, customer: cust),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete_outline, color: theme.colorScheme.error, size: 20),
                                      onPressed: () => _confirmDelete(context, cust.id!, cust.name),
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
        onPressed: () => _openAddCustomerSheet(context),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_reaction_outlined),
      ),
    );
  }
}
