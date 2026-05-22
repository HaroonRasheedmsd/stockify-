import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/sales_provider.dart';
import '../../models/sale.dart';
import '../../models/sale_item.dart';
import '../../widgets/custom_button.dart';
import '../../database/db_helper.dart';


class InvoiceScreen extends StatefulWidget {
  final int saleId;

  const InvoiceScreen({Key? key, required this.saleId}) : super(key: key);

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  Sale? _sale;
  List<SaleItem> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchInvoiceDetails();
  }

  Future<void> _fetchInvoiceDetails() async {
    final salesProvider = Provider.of<SalesProvider>(context, listen: false);
    
    // Check if the details of this sale are cached as last checkouts
    if (salesProvider.lastSale != null && salesProvider.lastSale!.id == widget.saleId) {
      setState(() {
        _sale = salesProvider.lastSale;
        _items = salesProvider.lastSaleItems;
        _isLoading = false;
      });
      return;
    }

    // Otherwise load from DatabaseHelper joins
    setState(() => _isLoading = true);
    try {
      final dbHelper = await importDbHelper();
      final allSales = await dbHelper.queryAllSales();
      final matchedSale = allSales.firstWhere((s) => s.id == widget.saleId);
      final itemsList = await dbHelper.querySaleItems(widget.saleId);

      setState(() {
        _sale = matchedSale;
        _items = itemsList;
      });
    } catch (e) {
      debugPrint("Error fetching invoice details: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Helper resolver
  dynamic importDbHelper() {
    return DateTime.now().millisecondsSinceEpoch > 0 ? DatabaseHelperResolver.getHelper() : null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currencyFormatter = NumberFormat.currency(symbol: 'Rs. ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice Receipt'),
        automaticallyImplyLeading: false, // Prevent going back to Cart
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _sale == null
              ? const Center(child: Text('Invoice details could not be resolved.'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      // Receipt Card representation
                      Card(
                        elevation: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Receipt Header
                              Center(
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: theme.primaryColor.withOpacity(0.08),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(Icons.receipt_long, color: theme.primaryColor, size: 36),
                                    ),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'STOCKIFY RETAILERS',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'University Campus Mall, Lahore',
                                      style: TextStyle(fontSize: 11, color: Colors.grey),
                                    ),
                                    const Text(
                                      'Phone: 0300-1234567',
                                      style: TextStyle(fontSize: 11, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              const Divider(thickness: 1.5),
                              const SizedBox(height: 12),

                              // Metadata Rows
                              _buildReceiptRow('Invoice Number', '#STK-${_sale!.id}'),
                              _buildReceiptRow('Date & Time', DateFormat('MMM dd, yyyy • hh:mm a').format(DateTime.parse(_sale!.date))),
                              _buildReceiptRow('Customer Name', _sale!.customerName ?? 'Walk-in Customer'),
                              _buildReceiptRow('Operator', 'Arif & Haroon'),
                              
                              const SizedBox(height: 16),
                              const Divider(thickness: 1.5),
                              const SizedBox(height: 12),

                              // Items Section
                              const Text(
                                'PURCHASED ITEMS',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey),
                              ),
                              const SizedBox(height: 10),
                              
                              // Table Header
                              Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Text('Item Name', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.blueGrey[300] : Colors.blueGrey[700])),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text('Qty', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.blueGrey[300] : Colors.blueGrey[700])),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text('Price', textAlign: TextAlign.right, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.blueGrey[300] : Colors.blueGrey[700])),
                                  ),
                                ],
                              ),
                              const Divider(),
                              
                              // Item Rows
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _items.length,
                                itemBuilder: (context, index) {
                                  final item = _items[index];
                                  final total = item.quantity * item.price;
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: Text(
                                            item.productName ?? 'Product #${item.productId}',
                                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                            maxLines: 2,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            'x${item.quantity}',
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(fontSize: 13),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            currencyFormatter.format(total),
                                            textAlign: TextAlign.right,
                                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 12),
                              const Divider(thickness: 1.5),
                              const SizedBox(height: 12),

                              // Calculation Section
                              _buildReceiptRow('Subtotal Sum', currencyFormatter.format(_sale!.total + _sale!.discount - _sale!.tax)),
                              _buildReceiptRow('Discount applied', '-${currencyFormatter.format(_sale!.discount)}', valueColor: Colors.red),
                              _buildReceiptRow('Sales GST Tax', '+${currencyFormatter.format(_sale!.tax)}', valueColor: Colors.blue),
                              
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'NET AMOUNT PAID',
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    currencyFormatter.format(_sale!.total),
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.primaryColor),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              
                              // Paid Flag
                              Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF10B981).withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.check_circle, color: const Color(0xFF10B981), size: 16),
                                      SizedBox(width: 8),
                                      Text(
                                        'PAID IN FULL',
                                        style: TextStyle(
                                          color: const Color(0xFF10B981),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Return Action Button
                      CustomButton(
                        text: 'Return to Dashboard',
                        icon: Icons.home_outlined,
                        onPressed: () {
                          Navigator.of(context).popUntil((route) => route.isFirst);
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
    );
  }

  Widget _buildReceiptRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

// Global Database Helper Resolver (to resolve dependency loading without tight coupling)
class DatabaseHelperResolver {
  static dynamic getHelper() {
    return DateTime.now().millisecondsSinceEpoch > 0 ? DatabaseHelper.instance : null;
  }
}
