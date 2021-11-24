import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class Photo {
  String url;
  String approved;

  Photo({
    @required this.url,
    @required this.approved,
  });
  factory Photo.fromDocument(DocumentSnapshot doc) {
    return Photo(
      approved: doc['approved'],
      url: doc['url'],
    );
  }
}
