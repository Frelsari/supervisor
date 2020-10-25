import 'package:firebase_auth/firebase_auth.dart';
import 'package:firevisor/api.dart';

class UserRepository {
  final FirebaseAuth _auth;
  final String _address = "@vghtpe.tw";

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
      final String jwtToken = await getJwtToken();
      print(jwtToken);
      final Map userData = await getUserData(jwtToken);
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

  Future<String> getJwtToken() async {
    if (_auth.currentUser != null) {
      return await _auth.currentUser.getIdToken();
    }
    return null;
  }
}

final UserRepository userRepository = UserRepository();
