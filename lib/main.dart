import 'package:firebase_auth/firebase_auth.dart';
import 'package:tracking/screens/signup.dart';
import 'package:firebase_core/firebase_core.dart';
import 'exports/exports.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Safe Firebase initialization
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
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tracking App',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: AuthCheck(),
    );
  }
}

class AuthCheck extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          // User is signed in, navigate to the Home screen
          return HomeScreen();
        } else {
          // User is not signed in, show Login screen
          return SignupScreen();
        }
      },
    );
  }
}
