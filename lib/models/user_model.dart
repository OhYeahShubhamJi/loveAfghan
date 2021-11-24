import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:loveafghan/models/photo.dart';

class User {
  String id;
  String name;
  bool presence;
  int lastSeenInEpoch;
  final String email;
  bool welcomemode;
  final bool isBlocked;
  String address;
  final Map coordinates;
  final List sexualOrientation;
  final bool showOrientation;
  final String gender;
  final String showGender;
  final int age;
  final String phoneNumber;
  int maxDistance;
  Timestamp lastmsg;
  final Map ageRange;
  final Map editInfo;
  List<Photo> imageUrl = [];
  var distanceBW;
  bool isNotificationsEnabled;
  bool isEmailsEnabled;
  double acalls;
  double vcalls;

  User({
    @required this.id,
    @required this.age,
    @required this.presence,
    @required this.lastSeenInEpoch,
    @required this.address,
    this.isBlocked,
    this.coordinates,
    @required this.name,
    @required this.imageUrl,
    this.phoneNumber,
    this.lastmsg,
    this.gender,
    this.showGender,
    this.ageRange,
    this.maxDistance,
    this.editInfo,
    this.distanceBW,
    this.sexualOrientation,
    @required this.email,
    @required this.welcomemode,
    this.acalls,
    this.vcalls,
    this.showOrientation,
    this.isNotificationsEnabled,
    this.isEmailsEnabled,
  });

  factory User.fromDocument(DocumentSnapshot doc) {
    // DateTime date = DateTime.parse(doc["user_DOB"]);
    return User(
      id: doc['userId'],
      isBlocked: doc['isBlocked'] != null ? doc['isBlocked'] : false,
      phoneNumber: doc['phoneNumber'],
      email: doc['Email'],
      name: doc['UserName'],
      editInfo: doc['editInfo'],
      ageRange: doc['age_range'],
      presence: doc['presence'],
      lastSeenInEpoch: doc['last_seen'],
      showGender: doc['showGender'],
      maxDistance: doc['maximum_distance'],
      welcomemode: doc['welcomemode'],
      sexualOrientation: doc['sexualOrientation']['orientation'] ?? "",
      age:
          ((DateTime.now().difference(DateTime.parse(doc["user_DOB"])).inDays) /
                  365.2425)
              .truncate(),
      address: doc['location']['address'],
      coordinates: doc['location'],
      // university: doc['editInfo']['university'],
      imageUrl: doc['Pictures'] != null
          ? List<Photo>.from(doc["Pictures"].map((item) {
              return new Photo(url: item['url'], approved: item['approved']);
            }))
          : null,
      acalls: doc['acalls'],
      vcalls: doc['vcalls'],
      showOrientation: doc['sexualOrientation']['showOnProfile'],
      isNotificationsEnabled: doc['isNotificationsEnabled'] ?? true,
      isEmailsEnabled: doc['isEmailsEnabled'] ?? true,
    );
  }
}
