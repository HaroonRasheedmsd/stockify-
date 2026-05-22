import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/supplier.dart';
import '../models/purchase.dart';

class SupplierProvider with ChangeNotifier {
  List<Supplier> _suppliers = [];
  List<Purchase> _purchases = [];
  bool _isLoading = false;
  String _searchQuery = '';

  List<Supplier> get suppliers {
    if (_searchQuery.isEmpty) return _suppliers;
    return _suppliers.where((supplier) {
      return supplier.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          supplier.company.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  List<Purchase> get purchases => _purchases;
  bool get isLoading => _isLoading;

  Future<void> fetchSuppliers() async {
    _isLoading = true;
    notifyListeners();
    try {
      _suppliers = await DatabaseHelper.instance.queryAllSuppliers();
    } catch (e) {
      debugPrint("Error fetching suppliers: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchPurchases() async {
    try {
      _purchases = await DatabaseHelper.instance.queryAllPurchases();
    } catch (e) {
      debugPrint("Error fetching purchases: $e");
    }
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<bool> addSupplier(Supplier supplier) async {
    try {
      await DatabaseHelper.instance.insertSupplier(supplier);
      await fetchSuppliers();
      return true;
    } catch (e) {
      debugPrint("Error adding supplier: $e");
      return false;
    }
  }

  Future<bool> editSupplier(Supplier supplier) async {
    try {
      await DatabaseHelper.instance.updateSupplier(supplier);
      await fetchSuppliers();
      return true;
    } catch (e) {
      debugPrint("Error editing supplier: $e");
      return false;
    }
  }

  Future<bool> removeSupplier(int id) async {
    try {
      await DatabaseHelper.instance.deleteSupplier(id);
      await fetchSuppliers();
      return true;
    } catch (e) {
      debugPrint("Error deleting supplier: $e");
      return false;
    }
  }

  Future<bool> restockProduct({
    required int supplierId,
    required int productId,
    required int quantity,
    required double totalCost,
  }) async {
    try {
      final purchase = Purchase(
        supplierId: supplierId,
        date: DateTime.now().toIso8601String(),
        total: totalCost,
      );
      
      await DatabaseHelper.instance.executeRestockPurchase(purchase, productId, quantity);
      await fetchPurchases();
      return true;
    } catch (e) {
      debugPrint("Error restocking product: $e");
      return false;
    }
  }
}
