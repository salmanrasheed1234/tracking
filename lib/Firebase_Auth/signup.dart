import 'package:tracking/exports/exports.dart';
import 'package:tracking/home.dart';

class FirebaseAuthService {
  static Future<void> signUpWithEmailPassword(
    BuildContext context,
    String email,
    String password,
    String confirmPassword,
  ) async {
    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showError(context, 'Please fill all fields');
      return;
    }

    if (password != confirmPassword) {
      _showError(context, 'Passwords do not match');
      return;
    }

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute<HomeScreen>(builder: (context) => const HomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      String message = 'Signup failed';

      if (e.code == 'email-already-in-use') {
        message = 'Email already in use';
      } else if (e.code == 'invalid-email') {
        message = 'Invalid email';
      } else if (e.code == 'weak-password') {
        message = 'Password is too weak';
      }

      _showError(context, message);
    } catch (e) {
      _showError(context, 'An error occurred');
    }
  }

  // Helper method to show error messages
  static void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }
}
