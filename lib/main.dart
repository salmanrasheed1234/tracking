// ignore_for_file: avoid_print

import 'package:tracking/home.dart' as home;

import 'exports/exports.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyD4Y...your-real-api-key...",
          appId: "1:1234567890:android:abcd1234efgh5678",
          messagingSenderId: "1234567890",  
          projectId: "your-project-id",
        ),
      );
    } else {
      Firebase.app(); // just get the existing instance
    }
  } catch (e) {
    print("Firebase already initialized: $e");
  }

  // Hive init
  await Hive.initFlutter();
  Hive.registerAdapter(ExpenseAdapter());
  await Hive.openBox<Expense>('expensesBox');

  final provider = ExpenseProvider();
  await provider.init();

  runApp(ChangeNotifierProvider.value(value: provider, child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tracking App',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: AuthCheck(),
    );
  }
}

class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          // User is signed in, navigate to the Home screen
          return home.HomeScreen();
        } else {
          return SignupScreen(); // Ensure SignupScreen is defined or imported
        }
      },
    );
  }
}
