import 'package:cloud_firestore/cloud_firestore.dart';

class ChatSettings {
  Map user1;
  Map user2;

  ChatSettings({
    this.user1,
    this.user2,
  });

  factory ChatSettings.fromDocument(DocumentSnapshot doc) {
    return ChatSettings(
      user1: doc['user1'],
      user2: doc['user2'],
    );
  }

  Map<String, dynamic> toMap(ChatSettings chatSettings) {
    return ({
      "user1": chatSettings.user1,
      "user2": chatSettings.user2,
    });
  }
}
