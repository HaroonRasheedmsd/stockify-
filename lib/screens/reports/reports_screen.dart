import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../database/db_helper.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  bool _isLoading = true;
  double _revenue = 0.0;
  double _cost = 0.0;
  double _profit = 0.0;
  
  List<Map<String, dynamic>> _categoryMetrics = [];
  List<Map<String, dynamic>> _dailySales = [];

  @override
  void initState() {
    super.initState();
    _loadReportMetrics();
  }

  Future<void> _loadReportMetrics() async {
    setState(() => _isLoading = true);
    try {
      final metrics = await DatabaseHelper.instance.getProfitAndCostMetrics();
      final cats = await DatabaseHelper.instance.getCategorySalesMetrics();
      final daily = await DatabaseHelper.instance.getDailySalesHistory();

      setState(() {
        _revenue = metrics['revenue'] ?? 0.0;
        _cost = metrics['cost'] ?? 0.0;
        _profit = metrics['profit'] ?? 0.0;
        _categoryMetrics = cats;
        _dailySales = daily.reversed.toList(); // chronological
      });
    } catch (e) {
      debugPrint("Error loading report metrics: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currencyFormatter = NumberFormat.currency(symbol: 'Rs. ', decimalDigits: 0);

    // Calculate margin percent
    final marginPercent = _revenue > 0 ? (_profit / _revenue) * 100 : 0.0;

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadReportMetrics,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Financial summary cards
                    const Text(
                      'Financial Summary',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    
                    // Card rows
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            _buildSummaryItem('Total Sales Revenue', currencyFormatter.format(_revenue), const Color(0xFF10B981), true),
                            const Divider(height: 24),
                            _buildSummaryItem('Cost of Goods Sold (COGS)', currencyFormatter.format(_cost), Colors.redAccent, false),
                            const Divider(height: 24),
                            _buildSummaryItem('Gross Net Profit', currencyFormatter.format(_profit), theme.primaryColor, true),
                            const Divider(height: 24),
                            _buildSummaryItem('Profit Margin %', '${marginPercent.toStringAsFixed(1)}%', Colors.orange, false),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Custom Pure-Flutter bar chart for daily sales
                    const Text(
                      'Sales History (Last 7 Days)',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_dailySales.isEmpty)
                              const Padding(
                                padding: EdgeInsets.all(24.0),
                                child: Center(child: Text('No daily sales records available.')),
                              )
                            else ...[
                              // Bar Chart Render
                              SizedBox(
                                height: 160,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: _dailySales.map((dayData) {
                                    final total = (dayData['day_total'] as num).toDouble();
                                    final dayLabel = dayData['sale_day'].toString().substring(5); // MM-DD
                                    
                                    // Calculate maximum height scalar
                                    double maxVal = _dailySales.fold<double>(1.0, (max, d) {
                                      final v = (d['day_total'] as num).toDouble();
                                      return v > max ? v : max;
                                    });

                                    final barHeight = (total / maxVal) * 110.0;

                                    return Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        // Tooltip numeric value
                                        Text(
                                          total > 1000 ? '${(total / 1000).toStringAsFixed(1)}k' : total.toStringAsFixed(0),
                                          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 4),
                                        // Animated Bar Container
                                        AnimatedContainer(
                                          duration: const Duration(milliseconds: 500),
                                          width: 24,
                                          height: barHeight < 5 ? 5 : barHeight,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.bottomCenter,
                                              end: Alignment.topCenter,
                                              colors: [theme.primaryColor, theme.colorScheme.secondary],
                                            ),
                                            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        // Label
                                        Text(
                                          dayLabel,
                                          style: TextStyle(fontSize: 10, color: isDark ? Colors.blueGrey[400] : Colors.blueGrey[600]),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Category breakdown details (Satisfies DataTable Topic)
                    const Text(
                      'Category Breakdown',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(8.0),
                        child: _categoryMetrics.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.all(24.0),
                                child: Center(child: Text('No sales records to partition.')),
                              )
                            : SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  columnSpacing: 28.0,
                                  columns: const [
                                    DataColumn(label: Text('Category', style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('Units Sold', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                                    DataColumn(label: Text('Revenue Generated', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                                  ],
                                  rows: _categoryMetrics.map((row) {
                                    final cat = row['category'] as String;
                                    final sold = row['items_sold'] as int;
                                    final rev = (row['revenue'] as num).toDouble();

                                    return DataRow(
                                      cells: [
                                        DataCell(Text(cat)),
                                        DataCell(Text('$sold units')),
                                        DataCell(Text(currencyFormatter.format(rev))),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSummaryItem(String label, String val, Color highlightColor, bool isBold) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.blueGrey[300] : Colors.blueGrey[700],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          val,
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: highlightColor,
          ),
        ),
      ],
    );
  }
}
