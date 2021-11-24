import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:loveafghan/Screens/Chat/recent_chats.dart';
import 'package:loveafghan/localization/localization_constants.dart';
import 'package:loveafghan/models/user_model.dart';
import 'package:loveafghan/util/color.dart';
import 'Matches.dart';

class HomeScreen extends StatefulWidget {
  final User currentUser;
  final List<User> matches;
  final List<User> newmatches;
  HomeScreen(this.currentUser, this.matches, this.newmatches);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  getUserStatus(User index, int i) {
    try {
      Firestore.instance
          .collection('Users')
          .document(index.id)
          .snapshots()
          .listen((DocumentSnapshot documentSnapshot) {
        Map<String, dynamic> firestoreInfo = documentSnapshot.data;
        print(firestoreInfo);
        if (mounted) {
          setState(() {
            widget.newmatches[i].presence = firestoreInfo['presence'];
            print(widget.newmatches[i].presence);
            print(firestoreInfo['presence']);
          });
        }
      }).onError((e) {
        print(e);
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    Future.delayed(Duration(milliseconds: 500), () {
      if (widget.matches.isNotEmpty && widget.matches[0].lastmsg != null) {
        widget.matches.sort((a, b) {
          var adate = a.lastmsg; //before -> var adate = a.expiry;
          var bdate = b.lastmsg; //before -> var bdate = b.expiry;
          return bdate?.compareTo(
              adate); //to get the order other way just switch `adate & bdate`
        });
        if (mounted) {
          setState(() {});
        }
      }
    });
    super.initState();
    for (var i = 0; i < widget.newmatches.length; i++) {
      getUserStatus(widget.newmatches[i], i);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Text(
          getTranslated(context, 'messages'),
          style: TextStyle(
            color: primaryColor,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        elevation: 0.0,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(49),
            topRight: const Radius.circular(49),
          ), // BorderRadius
        ),
        child: Container(
          margin: const EdgeInsetsDirectional.only(top: 4),
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50), topRight: Radius.circular(50)),
              color: Colors.white),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(50), topRight: Radius.circular(50)),
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Matches(widget.currentUser, widget.newmatches, _scaffoldKey),
                  Divider(),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      getTranslated(context, 'recent_messages'),
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  RecentChats(widget.currentUser, widget.matches, _scaffoldKey),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
