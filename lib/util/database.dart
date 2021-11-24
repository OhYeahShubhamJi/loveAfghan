import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class Database {
  final DatabaseReference databaseReference =
      FirebaseDatabase.instance.reference().child("/users/");

  FirebaseUser _user;

  Future updateUserPresence() async {
    _user = await FirebaseAuth.instance.currentUser();
    var id = _user.uid;
    print("Current User's UID is " + id.toString());
    Map<String, dynamic> presenceStatusTrue = {
      'presence': true,
      'last_seen': DateTime.now().millisecondsSinceEpoch,
    };

    await databaseReference
        .child(id)
        .update(presenceStatusTrue)
        .whenComplete(() => print('Updated your presence.'))
        .catchError((e) => print("Error: " + e));

    Map<String, dynamic> presenceStatusFalse = {
      'presence': false,
      'last_seen': DateTime.now().millisecondsSinceEpoch,
    };
    databaseReference.child(id).onDisconnect().update(presenceStatusFalse);
  }
}
