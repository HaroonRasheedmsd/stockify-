import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/product.dart';
import '../models/customer.dart';
import '../models/sale.dart';
import '../models/sale_item.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, required this.quantity});

  double get subtotal => product.salePrice * quantity;
}

class SalesProvider with ChangeNotifier {
  final Map<int, CartItem> _cart = {};
  Customer? _selectedCustomer;
  double _discountPercent = 0.0;
  double _taxPercent = 5.0; // Default GST (e.g., 5% or 17%)
  
  List<Sale> _salesHistory = [];
  bool _isLoading = false;

  // Last invoice data for receipt printing mock
  Sale? _lastSale;
  List<SaleItem> _lastSaleItems = [];

  Map<int, CartItem> get cart => _cart;
  List<CartItem> get cartItems => _cart.values.toList();
  Customer? get selectedCustomer => _selectedCustomer;
  double get discountPercent => _discountPercent;
  double get taxPercent => _taxPercent;
  
  List<Sale> get salesHistory => _salesHistory;
  bool get isLoading => _isLoading;

  Sale? get lastSale => _lastSale;
  List<SaleItem> get lastSaleItems => _lastSaleItems;

  // Cart Calculations
  double get subtotal {
    double total = 0.0;
    _cart.forEach((key, item) {
      total += item.subtotal;
    });
    return total;
  }

  double get discountAmount => subtotal * (_discountPercent / 100);
  
  double get taxAmount => (subtotal - discountAmount) * (_taxPercent / 100);

  double get grandTotal => (subtotal - discountAmount) + taxAmount;

  // Cart Operations
  void addToCart(Product product) {
    if (_cart.containsKey(product.id)) {
      if (_cart[product.id]!.quantity < product.quantity) {
        _cart[product.id]!.quantity++;
      }
    } else {
      if (product.quantity > 0) {
        _cart[product.id!] = CartItem(product: product, quantity: 1);
      }
    }
    notifyListeners();
  }

  void decreaseQuantity(int productId) {
    if (!_cart.containsKey(productId)) return;
    if (_cart[productId]!.quantity > 1) {
      _cart[productId]!.quantity--;
    } else {
      _cart.remove(productId);
    }
    notifyListeners();
  }

  void removeFromCart(int productId) {
    _cart.remove(productId);
    notifyListeners();
  }

  void updateQuantity(int productId, int quantity) {
    if (!_cart.containsKey(productId)) return;
    if (quantity <= 0) {
      _cart.remove(productId);
    } else {
      // Don't exceed product's current stock
      final maxStock = _cart[productId]!.product.quantity;
      _cart[productId]!.quantity = quantity > maxStock ? maxStock : quantity;
    }
    notifyListeners();
  }

  void selectCustomer(Customer? customer) {
    _selectedCustomer = customer;
    notifyListeners();
  }

  void setDiscount(double discount) {
    _discountPercent = discount;
    notifyListeners();
  }

  void setTax(double tax) {
    _taxPercent = tax;
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    _selectedCustomer = null;
    _discountPercent = 0.0;
    _taxPercent = 5.0;
    notifyListeners();
  }

  // Checkout
  Future<int?> checkout() async {
    if (_cart.isEmpty) return null;

    _isLoading = true;
    notifyListeners();

    try {
      final now = DateTime.now().toIso8601String();
      final sale = Sale(
        customerId: _selectedCustomer?.id,
        date: now,
        total: grandTotal,
        discount: discountAmount,
        tax: taxAmount,
      );

      final List<SaleItem> items = _cart.values.map((cartItem) {
        return SaleItem(
          productId: cartItem.product.id!,
          quantity: cartItem.quantity,
          price: cartItem.product.salePrice,
          productName: cartItem.product.name,
        );
      }).toList();

      // Execute transaction
      final saleId = await DatabaseHelper.instance.executeSaleTransaction(sale, items);
      
      // Cache details for invoice representation
      _lastSale = sale.copyWith(id: saleId, customerName: _selectedCustomer?.name);
      _lastSaleItems = items;

      clearCart();
      await fetchSalesHistory();

      return saleId;
    } catch (e) {
      debugPrint("Checkout failed: $e");
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchSalesHistory() async {
    _isLoading = true;
    notifyListeners();
    try {
      _salesHistory = await DatabaseHelper.instance.queryAllSales();
    } catch (e) {
      debugPrint("Error fetching sales history: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
