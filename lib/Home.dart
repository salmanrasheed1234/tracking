// ignore_for_file: file_names, deprecated_member_use

import 'exports/exports.dart';
import 'screens/second.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String? _selectedCategory;
  late AnimationController _controller;
  late Animation<double> _animation;

  final List<String> _categories = [
    'Food',
    'Transport',
    'Shopping',
    'Bills',
    'Entertainment',
    'Health',
    'Education',
    'Travel',
    'Groceries',
    'Subscriptions',
    'Gifts',
    'Insurance',
    'Investment',
    'Savings',
    'Others',
  ];

  final Map<String, IconData> _categoryIcons = {
    'Food': Icons.fastfood,
    'Transport': Icons.directions_car,
    'Shopping': Icons.shopping_bag,
    'Bills': Icons.receipt_long,
    'Entertainment': Icons.movie,
    'Health': Icons.healing,
    'Education': Icons.school,
    'Travel': Icons.flight_takeoff,
    'Groceries': Icons.local_grocery_store,
    'Subscriptions': Icons.subscriptions,
    'Gifts': Icons.card_giftcard,
    'Insurance': Icons.shield,
    'Investment': Icons.trending_up,
    'Savings': Icons.savings,
    'Others': Icons.more_horiz,
  };

  void _addExpense(ExpenseProvider provider) {
    final amount = double.tryParse(_amountController.text);
    if (amount != null && _selectedCategory != null) {
      provider.addExpense(
        Expense(
          amount: amount,
          category: _selectedCategory!,
          date: _selectedDate,
        ),
      );
      _amountController.clear();
      setState(() => _selectedCategory = null);
    }
  }

  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      // Navigate to login screen or root
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => LoginScreen()));
    } catch (e) {
      // Optionally show error
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Logout failed: $e')));
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder:
          (context, child) => Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: const ColorScheme.dark(
                primary: Color.fromARGB(255, 159, 175, 171),
                surface: Color.fromARGB(255, 141, 55, 55),
                onSurface: Color.fromARGB(255, 136, 117, 117),
              ),
              dialogTheme: const DialogTheme(
                backgroundColor: Color.fromARGB(255, 255, 121, 121),
              ),
            ),
            child: child!,
          ),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      // This line removes the back arrow
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color.fromARGB(255, 52, 60, 82),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          '💰 Expense Tracker',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 52, 60, 82),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          TextButton(
            onPressed: () => _logout(context),
            child: Text('Log out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! < 0) {
            Navigator.push(
              context,
              PageRouteBuilder<SecondScreen>(
                transitionDuration: const Duration(milliseconds: 400),
                pageBuilder: (_, __, ___) => const SecondScreen(),
                transitionsBuilder: (_, animation, __, child) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(1.0, 0.0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  );
                },
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: width * 0.07, vertical: 12),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF121C2D), Color(0xFF1E293B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.tealAccent.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Spending',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.grey[400],
                        ),
                      ),
                      const SizedBox(height: 6),
                      ScaleTransition(
                        scale: _animation,
                        child: ShaderMask(
                          shaderCallback: (bounds) {
                            return const LinearGradient(
                              colors: [Colors.tealAccent, Colors.cyanAccent],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ).createShader(bounds);
                          },
                          child: Text(
                            'Rs. ${provider.totalSpending.toStringAsFixed(2)}',
                            style: GoogleFonts.orbitron(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFF1C1C1C),
                          labelText: 'Amount',
                          labelStyle: const TextStyle(color: Colors.tealAccent),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        dropdownColor: Colors.grey[900],
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFF1C1C1C),
                          labelText: 'Category',
                          labelStyle: const TextStyle(color: Colors.tealAccent),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        iconEnabledColor: Colors.tealAccent,
                        style: const TextStyle(color: Colors.white),
                        items:
                            _categories.map((category) {
                              return DropdownMenuItem(
                                value: category,
                                child: Row(
                                  children: [
                                    Icon(
                                      _categoryIcons[category],
                                      color: Colors.tealAccent,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(category),
                                  ],
                                ),
                              );
                            }).toList(),
                        onChanged:
                            (value) =>
                                setState(() => _selectedCategory = value),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Date: ${_selectedDate.toString().split(' ')[0]}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          TextButton(
                            onPressed: () => _selectDate(context),
                            child: const Text(
                              'Pick Date',
                              style: TextStyle(color: Colors.tealAccent),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: () => _addExpense(provider),
                          icon: const Icon(Icons.add),
                          label: const Text('Add Expense'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.tealAccent[700],
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: min(provider.expenses.length, 50),
                itemBuilder: (context, index) {
                  final expense = provider.expenses[index];
                  return Card(
                    color: const Color(0xFF161D29),
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.tealAccent.withOpacity(0.1),
                        child: Icon(
                          _categoryIcons[expense.category] ?? Icons.category,
                          color: Colors.tealAccent,
                        ),
                      ),
                      title: Text(
                        expense.category,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        expense.date.toString().split(' ')[0],
                        style: const TextStyle(color: Colors.white60),
                      ),
                      trailing: SizedBox(
                        width: 90,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Rs ${expense.amount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.tealAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Expanded(
                              child: IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.redAccent,
                                  size: 20,
                                ),
                                onPressed:
                                    () => provider.removeExpense(expense),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
