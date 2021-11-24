import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CallLog {
  String callFrom;
  int duration;
  Timestamp callTime;
  String callType;

  CallLog({
    @required this.callFrom,
    @required this.duration,
    @required this.callTime,
    @required this.callType,
  });

  factory CallLog.fromDocument(DocumentSnapshot doc) {
    return CallLog(
      callFrom: doc['callFrom'],
      duration: doc['duration'],
      callTime: doc['callTime'],
      callType: doc['callType'],
    );
  }

  Map<String, dynamic> toMap(CallLog callLog) {
    return ({
      "callFrom": callLog.callFrom,
      "duration": callLog.duration,
      "callTime": callLog.callTime,
      "callType": callLog.callType,
    });
  }
}
