import 'package:tracking/exports/exports.dart';

Future<String?> loginWithEmailAndPassword(String email, String password) async {
  try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return null; // success
  } on FirebaseAuthException catch (e) {
    switch (e.code) {
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user has been disabled.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      default:
        return 'Login failed: ${e.message}';
    }
  } catch (e) {
    return 'Something went wrong: $e';
  }
}
