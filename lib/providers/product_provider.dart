import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/product.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String _selectedCategory = 'All';

  List<Product> get products {
    return _products.where((product) {
      final matchesSearch = product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          product.barcode.contains(_searchQuery);
      final matchesCategory = _selectedCategory == 'All' || product.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  List<Product> get rawProductsList => _products;

  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;

  // Retrieve distinct categories
  List<String> get categories {
    final list = _products.map((p) => p.category).toSet().toList();
    list.sort();
    return ['All', ...list];
  }

  // Retrieve items below a warning threshold (e.g. 10 items)
  List<Product> get lowStockProducts {
    return _products.where((p) => p.quantity <= 10).toList();
  }

  Future<void> fetchProducts() async {
    _isLoading = true;
    notifyListeners();
    try {
      _products = await DatabaseHelper.instance.queryAllProducts();
    } catch (e) {
      debugPrint("Error fetching products: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  Future<bool> addProduct(Product product) async {
    try {
      await DatabaseHelper.instance.insertProduct(product);
      await fetchProducts();
      return true;
    } catch (e) {
      debugPrint("Error adding product: $e");
      return false;
    }
  }

  Future<bool> editProduct(Product product) async {
    try {
      await DatabaseHelper.instance.updateProduct(product);
      await fetchProducts();
      return true;
    } catch (e) {
      debugPrint("Error editing product: $e");
      return false;
    }
  }

  Future<bool> removeProduct(int id) async {
    try {
      await DatabaseHelper.instance.deleteProduct(id);
      await fetchProducts();
      return true;
    } catch (e) {
      debugPrint("Error deleting product: $e");
      return false;
    }
  }

  Product? findProductById(int id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}
