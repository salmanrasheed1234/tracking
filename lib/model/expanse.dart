import '../exports/exports.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

@HiveType(typeId: 0)
class Expense extends HiveObject {
  @HiveField(0)
  double amount;

  @HiveField(1)
  String category;

  @HiveField(2)
  DateTime date;

  String? id; // Firestore document ID

  Expense({
    required this.amount,
    required this.category,
    required this.date,
    this.id,
  });

  // Convert Expense to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'amount': amount,
      'category': category,
      'date': Timestamp.fromDate(date),
    };
  }

  // Create Expense from Firestore document
  static Expense fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Expense(
      id: doc.id,
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      category: (data['category'] as String?) ?? '',
      date: (data['date'] as Timestamp).toDate(),
    );
  }

  // Save expense to Firestore
  Future<void> saveToFirestore() async {
    final collection = FirebaseFirestore.instance.collection('expenses');
    if (id != null) {
      await collection.doc(id).set(toFirestore());
    } else {
      final docRef = await collection.add(toFirestore());
      id = docRef.id;
    }
  }

  // Delete expense from Firestore
  Future<void> deleteFromFirestore() async {
    if (id != null) {
      await FirebaseFirestore.instance.collection('expenses').doc(id).delete();
    }
  }

  // Get all expenses from Firestore
  static Stream<List<Expense>> getAllExpenses() {
    return FirebaseFirestore.instance
        .collection('expenses')
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Expense.fromFirestore(doc)).toList(),
        );
  }
}

// ExpenseAdapter is automatically generated when you run the build_runner
// Manually adding it here just in case, but typically not needed
class ExpenseAdapter extends TypeAdapter<Expense> {
  @override
  final int typeId = 0;

  @override
  Expense read(BinaryReader reader) {
    return Expense(
      amount: reader.readDouble(),
      category: reader.readString(),
      date: DateTime.fromMillisecondsSinceEpoch(
        reader.readInt(),
      ), // Convert from milliseconds
    );
  }

  @override
  void write(BinaryWriter writer, Expense obj) {
    writer.writeDouble(obj.amount);
    writer.writeString(obj.category);
    writer.writeInt(obj.date.millisecondsSinceEpoch); // Store as milliseconds
  }
}
