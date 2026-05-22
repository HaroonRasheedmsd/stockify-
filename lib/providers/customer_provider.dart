import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/customer.dart';

class CustomerProvider with ChangeNotifier {
  List<Customer> _customers = [];
  bool _isLoading = false;
  String _searchQuery = '';

  List<Customer> get customers {
    if (_searchQuery.isEmpty) return _customers;
    return _customers.where((customer) {
      return customer.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          customer.phone.contains(_searchQuery);
    }).toList();
  }

  bool get isLoading => _isLoading;

  Future<void> fetchCustomers() async {
    _isLoading = true;
    notifyListeners();
    try {
      _customers = await DatabaseHelper.instance.queryAllCustomers();
    } catch (e) {
      debugPrint("Error fetching customers: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<bool> addCustomer(Customer customer) async {
    try {
      await DatabaseHelper.instance.insertCustomer(customer);
      await fetchCustomers();
      return true;
    } catch (e) {
      debugPrint("Error adding customer: $e");
      return false;
    }
  }

  Future<bool> editCustomer(Customer customer) async {
    try {
      await DatabaseHelper.instance.updateCustomer(customer);
      await fetchCustomers();
      return true;
    } catch (e) {
      debugPrint("Error editing customer: $e");
      return false;
    }
  }

  Future<bool> removeCustomer(int id) async {
    try {
      await DatabaseHelper.instance.deleteCustomer(id);
      await fetchCustomers();
      return true;
    } catch (e) {
      debugPrint("Error deleting customer: $e");
      return false;
    }
  }
}
