import '../exports/exports.dart'; // assuming it includes provider and hive models
import 'package:fl_chart/fl_chart.dart'; // Import the fl_chart package

class SecondScreen extends StatelessWidget {
  const SecondScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);

    Map<String, double> categoryTotals = {};
    for (var expense in provider.expenses) {
      categoryTotals.update(
        expense.category,
        (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }

    final barGroups =
        categoryTotals.entries.map((entry) {
          final index = categoryTotals.keys.toList().indexOf(entry.key);
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: entry.value,
                gradient: const LinearGradient(
                  colors: [Colors.tealAccent, Colors.teal],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                width: 22,
                borderRadius: BorderRadius.circular(8),
                rodStackItems: [
                  BarChartRodStackItem(
                    0,
                    entry.value,
                    Colors.teal.withOpacity(0.2),
                  ),
                ],
              ),
            ],
          );
        }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 Expense Graph'),
        backgroundColor: const Color(0xFF343C52),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFF22283C),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: BarChart(
          BarChartData(
            maxY:
                categoryTotals.values.isEmpty
                    ? 0
                    : categoryTotals.values.reduce((a, b) => a > b ? a : b) *
                        1.1, // Dynamic Y-axis scaling
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final keys = categoryTotals.keys.toList();
                    if (value.toInt() < keys.length) {
                      return Text(
                        keys[value.toInt()],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      );
                    }
                    return const Text('');
                  },
                ),
              ),
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: FlGridData(show: false),
            borderData: FlBorderData(show: false),
            barGroups: barGroups,
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final category =
                      categoryTotals.keys.toList()[group.x.toInt()];
                  return BarTooltipItem(
                    '$category\n\$${rod.toY.toStringAsFixed(2)}',
                    const TextStyle(color: Colors.white),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
