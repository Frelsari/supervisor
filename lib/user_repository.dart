import 'package:firebase_auth/firebase_auth.dart';
import 'package:firevisor/api.dart';

class UserRepository {
  final FirebaseAuth _auth;
  final String _address = "@vghtpe.tw";
  String _jwtToken;

  UserRepository({
    FirebaseAuth firebaseAuth,
  }) : _auth = (firebaseAuth ?? FirebaseAuth.instance)..signOut();

  Future<Map<String, String>> logInWithUsernameAndPassword({
    String username,
    String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: username + _address,
        password: password,
      );
      _jwtToken = await _auth.currentUser.getIdToken();
      final Map userData = await getUserData(_jwtToken);
      return userData;
    } on Exception catch (e) {
      print(e);
      return null;
    }
  }

  Future<void> logOut() async {
    return await _auth.signOut();
  }

  bool isLoggedIn() {
    print('@user_repository.dart -> isLoggedIn() -> ' +
        _auth.currentUser.toString());
    return _auth.currentUser != null;
  }

  String getJwtToken() {
    if (_auth.currentUser != null) {
      return _jwtToken;
    }
    return null;
  }
}

final UserRepository userRepository = UserRepository();
