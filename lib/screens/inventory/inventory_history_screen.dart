import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../database/db_helper.dart';
import '../../models/inventory_transaction.dart';

class InventoryHistoryScreen extends StatefulWidget {
  const InventoryHistoryScreen({Key? key}) : super(key: key);

  @override
  State<InventoryHistoryScreen> createState() => _InventoryHistoryScreenState();
}

class _InventoryHistoryScreenState extends State<InventoryHistoryScreen> {
  List<InventoryTransaction> _transactions = [];
  String _activeFilter = 'ALL'; // 'ALL', 'IN', 'OUT'
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLedger();
  }

  Future<void> _loadLedger() async {
    setState(() => _isLoading = true);
    try {
      final logs = await DatabaseHelper.instance.queryAllTransactions();
      setState(() {
        _transactions = logs;
      });
    } catch (e) {
      debugPrint("Error loading ledger logs: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<InventoryTransaction> get _filteredTransactions {
    if (_activeFilter == 'ALL') return _transactions;
    return _transactions.where((t) => t.type == _activeFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Ledger'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadLedger,
            tooltip: 'Refresh Ledger',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs Selector
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
            child: Row(
              children: [
                _buildFilterButton('ALL', 'All Logs', Icons.list_alt),
                const SizedBox(width: 8),
                _buildFilterButton('IN', 'Stock IN', Icons.arrow_downward),
                const SizedBox(width: 8),
                _buildFilterButton('OUT', 'Stock OUT', Icons.arrow_upward),
              ],
            ),
          ),

          // Ledger Log Items
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredTransactions.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.receipt_long_outlined, size: 60, color: isDark ? Colors.blueGrey[600] : Colors.blueGrey[300]),
                            const SizedBox(height: 16),
                            Text(
                              'Ledger is empty!',
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
                        onRefresh: _loadLedger,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: _filteredTransactions.length,
                          itemBuilder: (context, index) {
                            final log = _filteredTransactions[index];
                            final isIn = log.type == 'IN';
                            final dateVal = DateTime.tryParse(log.date);
                            final formattedDate = dateVal != null
                                ? DateFormat('MMM dd, yyyy • hh:mm a').format(dateVal)
                                : log.date;

                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: isIn
                                      ? const Color(0xFF10B981).withOpacity(0.12)
                                      : Colors.red.withOpacity(0.12),
                                  child: Icon(
                                    isIn ? Icons.arrow_downward : Icons.arrow_upward,
                                    color: isIn ? const Color(0xFF10B981) : Colors.red,
                                    size: 18,
                                  ),
                                ),
                                title: Text(
                                  log.productName ?? 'Unknown Product',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 2),
                                    Text(
                                      'Reason: ${log.reason}',
                                      style: TextStyle(fontSize: 12, color: isDark ? Colors.blueGrey[300] : Colors.blueGrey[700]),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      formattedDate,
                                      style: TextStyle(fontSize: 10, color: isDark ? Colors.blueGrey[500] : Colors.blueGrey[500]),
                                    ),
                                  ],
                                ),
                                isThreeLine: true,
                                trailing: Text(
                                  '${isIn ? "+" : "-"}${log.quantity}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isIn ? const Color(0xFF10B981) : Colors.red,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String filterVal, String label, IconData icon) {
    final theme = Theme.of(context);
    final isSelected = _activeFilter == filterVal;
    
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _activeFilter = filterVal;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? theme.primaryColor.withOpacity(0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? theme.primaryColor : Colors.grey.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 14,
                color: isSelected ? theme.primaryColor : Colors.grey,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? theme.primaryColor : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
