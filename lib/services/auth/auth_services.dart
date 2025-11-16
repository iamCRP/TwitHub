import 'package:firebase_auth/firebase_auth.dart';
import '../database/database_service.dart';

/*
  Authentication Service
  This handles everything to do with authentication in Firebase

  ---------------------------------------------------------------------

  - login
  - register
  - logout
  - delete account
*/

class AuthService {
  // get instance of FirebaseAuth
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // get instance of DatabaseService
  final DatabaseService _dbService = DatabaseService();

  // Loading status is optional (since no provider)
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  // get current user and UID
  User? getCurrentUser() => _auth.currentUser;

  String? getCurrentUid() => _auth.currentUser?.uid;

  // login -> email & pw
  Future<UserCredential> loginEmailPassword(
    String email,
    String password,
  ) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  // register -> email & pw
  Future<UserCredential> registerEmailPassword(
    String name,
    String email,
    String password,
  ) async {
    try {
      // Create user
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Save user info in Firestore
      await _dbService.saveUserInfoFirebase(name: name, email: email);

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  // logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  // delect account
  Future<void> delectAccount() async {
    User? user = getCurrentUser();

    if (user != null) {
      //delete user data from firestore
      await DatabaseService().deleteUserInfoFromFirebase(user.uid);

      //delete the user auth record
      await user.delete();
    }
  }
}
