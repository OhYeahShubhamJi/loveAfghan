import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loveafghan/Screens/Chat/largeImage.dart';
import 'package:loveafghan/Screens/Information.dart';
import 'package:loveafghan/Screens/reportUser.dart';
import 'package:loveafghan/localization/localization_constants.dart';
import 'package:loveafghan/models/chat_settings.dart';
import 'package:loveafghan/models/user_model.dart';
import 'package:loveafghan/util/color.dart';
import 'package:loveafghan/util/snackbar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:loveafghan/screens/Calling/dial.dart';
import 'package:loveafghan/util/Marquee.dart';
import 'package:timeago/timeago.dart';
import 'package:loveafghan/Screens/Calling/settings.dart';

class ChatPage extends StatefulWidget {
  final User sender;
  final String chatId;
  final User second;
  ChatPage({this.sender, this.chatId, this.second});
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  bool _present = false;
  String _last_seen = "";

  bool isAudioAllowed = false;
  bool isVideoAllowed = false;

  CollectionReference chats = Firestore.instance.collection("chats");
  ChatSettings chatSettings;

  getCallSettings() {
    try {
      chats
          .document(widget.chatId)
          .snapshots()
          .listen((DocumentSnapshot snapshot) {
        if (snapshot.data != null) {
          chatSettings = ChatSettings.fromDocument(snapshot);
          var getuid = getChatSettingsId(widget.sender, widget.second);
          if (getuid == 1) {
            if (chatSettings.user2 != null) {
              setState(() {
                isAudioAllowed = chatSettings.user2['acalls'];
                isVideoAllowed = chatSettings.user2['vcalls'];
              });
            } else {
              setState(() {
                isAudioAllowed = false;
                isVideoAllowed = false;
              });
            }
          } else if (getuid == 2) {
            if (chatSettings.user1 != null) {
              setState(() {
                isAudioAllowed = chatSettings.user1['acalls'];
                isVideoAllowed = chatSettings.user1['vcalls'];
              });
            } else {
              setState(() {
                isAudioAllowed = false;
                isVideoAllowed = false;
              });
            }
          }
        }
      });
    } catch (e) {
      CustomSnackbar.snackbar(e.toString(), _scaffoldKey);
    }
  }

  getUserStatus(User index) {
    Firestore.instance
        .collection('Users')
        .document(index.id)
        .snapshots()
        .listen((DocumentSnapshot documentSnapshot) {
      Map<String, dynamic> firestoreInfo = documentSnapshot.data;
      if (mounted) {
        setState(() {
          _present = firestoreInfo['presence'];
          try {
            _last_seen = 'last seen ' +
                format(DateTime.fromMillisecondsSinceEpoch(
                    firestoreInfo['last_seen']));
          } catch (error) {
            print(error.toString());
          }
        });
      }
    }).onError((e) {
      print(e);
    });
  }

  bool isBlocked = false;
  final db = Firestore.instance;
  CollectionReference chatReference;
  final TextEditingController _textController = new TextEditingController();
  bool _isWritting = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    print("object    -${widget.chatId}");
    super.initState();
    chatReference =
        db.collection("chats").document(widget.chatId).collection('messages');
    checkblock();
    getUserStatus(widget.second);
    getCallSettings();
  }

  var blockedBy;
  checkblock() {
    chatReference.document('blocked').snapshots().listen((onData) {
      if (onData.data != null) {
        blockedBy = onData.data['blockedBy'];
        if (onData.data['isBlocked']) {
          isBlocked = true;
        } else {
          isBlocked = false;
        }

        if (mounted) setState(() {});
      }
      // print(onData.data['blockedBy']);
    });
  }

  List<Widget> generateSenderLayout(DocumentSnapshot documentSnapshot) {
    return <Widget>[
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Container(
              child: documentSnapshot.data['image_url'] != ''
                  ? InkWell(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          new Container(
                            margin: EdgeInsets.only(
                                top: 2.0, bottom: 2.0, right: 15),
                            child: Stack(
                              children: <Widget>[
                                CachedNetworkImage(
                                  placeholder: (context, url) => Center(
                                    child: CupertinoActivityIndicator(
                                      radius: 10,
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Icon(Icons.error),
                                  height:
                                      MediaQuery.of(context).size.height * .65,
                                  width: MediaQuery.of(context).size.width * .9,
                                  imageUrl:
                                      documentSnapshot.data['image_url'] ?? '',
                                  fit: BoxFit.fitWidth,
                                ),
                                Container(
                                  alignment: Alignment.bottomRight,
                                  child:
                                      documentSnapshot.data['isRead'] == false
                                          ? Icon(
                                              Icons.done,
                                              color: secondryColor,
                                              size: 15,
                                            )
                                          : Icon(
                                              Icons.done_all,
                                              color: primaryColor,
                                              size: 15,
                                            ),
                                )
                              ],
                            ),
                            height: 150,
                            width: 150.0,
                            color: secondryColor.withOpacity(.5),
                            padding: EdgeInsets.all(5),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Text(
                                documentSnapshot.data["time"] != null
                                    ? DateFormat.yMMMd()
                                        .add_jm()
                                        .format(documentSnapshot.data["time"]
                                            .toDate())
                                        .toString()
                                    : "",
                                style: TextStyle(
                                  color: secondryColor,
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.w600,
                                )),
                          )
                        ],
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (context) => LargeImage(
                              documentSnapshot.data['image_url'],
                            ),
                          ),
                        );
                      },
                    )
                  : Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 7.0, vertical: 7.0),
                      margin: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * 0.30,
                          right: 10),
                      decoration: BoxDecoration(
                          color: primaryColor.withOpacity(.1),
                          borderRadius: BorderRadius.circular(20)),
                      child: Column(
                        children: <Widget>[
                          Stack(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: RichText(
                                  text: TextSpan(
                                    children: <TextSpan>[
                                      //real message
                                      TextSpan(
                                        text: documentSnapshot.data['text'] +
                                            "    ",
                                        style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),

                                      //fake additionalInfo as placeholder
                                      TextSpan(
                                          text: documentSnapshot.data["time"] !=
                                                  null
                                              ? DateFormat.MMMd()
                                                  .add_jm()
                                                  .format(documentSnapshot
                                                      .data["time"]
                                                      .toDate())
                                                  .toString()
                                              : "",
                                          style: TextStyle(
                                              color: Color.fromRGBO(
                                                      255, 255, 255, 1)
                                                  .withOpacity(0))),
                                    ],
                                  ),
                                ),
                              ),

                              //real additionalInfo
                              Positioned(
                                child: Text(
                                  documentSnapshot.data["time"] != null
                                      ? DateFormat.MMMd()
                                          .add_jm()
                                          .format(documentSnapshot.data["time"]
                                              .toDate())
                                          .toString()
                                      : "",
                                  style: TextStyle(
                                    color: secondryColor,
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                right: 8.0,
                                bottom: 4.0,
                              )
                            ],
                          ),
                        ],
                      )),
            ),
          ],
        ),
      ),
    ];
  }

  _messagesIsRead(documentSnapshot) {
    return <Widget>[
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          InkWell(
            child: CircleAvatar(
              backgroundColor: secondryColor,
              radius: 25.0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(90),
                child: CachedNetworkImage(
                  imageUrl: widget.second.imageUrl[0].url ?? '',
                  useOldImageOnUrlChange: true,
                  placeholder: (context, url) => CupertinoActivityIndicator(
                    radius: 15,
                  ),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
            ),
            onTap: () => showDialog(
                barrierDismissible: false,
                context: context,
                builder: (context) {
                  return Info(widget.second, widget.sender, null);
                }),
          ),
        ],
      ),
      SizedBox(
        width: 5,
      ),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              child: documentSnapshot.data['image_url'] != ''
                  ? InkWell(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          new Container(
                            margin: EdgeInsets.only(
                                top: 2.0, bottom: 2.0, right: 15),
                            child: CachedNetworkImage(
                              placeholder: (context, url) => Center(
                                child: CupertinoActivityIndicator(
                                  radius: 10,
                                ),
                              ),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                              height: MediaQuery.of(context).size.height * .65,
                              width: MediaQuery.of(context).size.width * .9,
                              imageUrl:
                                  documentSnapshot.data['image_url'] ?? '',
                              fit: BoxFit.fitWidth,
                            ),
                            height: 150,
                            width: 150.0,
                            color: Color.fromRGBO(0, 0, 0, 0.2),
                            padding: EdgeInsets.all(5),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Text(
                                documentSnapshot.data["time"] != null
                                    ? DateFormat.yMMMd()
                                        .add_jm()
                                        .format(documentSnapshot.data["time"]
                                            .toDate())
                                        .toString()
                                    : "",
                                style: TextStyle(
                                  color: secondryColor,
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.w600,
                                )),
                          )
                        ],
                      ),
                      onTap: () {
                        Navigator.of(context).push(CupertinoPageRoute(
                          builder: (context) => LargeImage(
                            documentSnapshot.data['image_url'],
                          ),
                        ));
                      },
                    )
                  : Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 7.0, vertical: 7.0),
                      margin: EdgeInsets.only(
                          right: MediaQuery.of(context).size.width * 0.30),
                      decoration: BoxDecoration(
                          color: secondryColor.withOpacity(.3),
                          borderRadius: BorderRadius.circular(20)),
                      child: Column(
                        children: <Widget>[
                          Stack(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: RichText(
                                  text: TextSpan(
                                    children: <TextSpan>[
                                      //real message
                                      TextSpan(
                                        text: documentSnapshot.data['text'] +
                                            "    ",
                                        style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),

                                      //fake additionalInfo as placeholder
                                      TextSpan(
                                          text: documentSnapshot.data["time"] !=
                                                  null
                                              ? DateFormat.MMMd()
                                                  .add_jm()
                                                  .format(documentSnapshot
                                                      .data["time"]
                                                      .toDate())
                                                  .toString()
                                              : "",
                                          style: TextStyle(
                                              color: Color.fromRGBO(
                                                      255, 255, 255, 1)
                                                  .withOpacity(0))),
                                    ],
                                  ),
                                ),
                              ),

                              //real additionalInfo
                              Positioned(
                                child: Text(
                                  documentSnapshot.data["time"] != null
                                      ? DateFormat.MMMd()
                                          .add_jm()
                                          .format(documentSnapshot.data["time"]
                                              .toDate())
                                          .toString()
                                      : "",
                                  style: TextStyle(
                                    color: secondryColor,
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                right: 8.0,
                                bottom: 4.0,
                              )
                            ],
                          ),
                        ],
                      )),
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> generateReceiverLayout(DocumentSnapshot documentSnapshot) {
    if (!documentSnapshot.data['isRead']) {
      chatReference.document(documentSnapshot.documentID).updateData({
        'isRead': true,
      });

      return _messagesIsRead(documentSnapshot);
    }
    return _messagesIsRead(documentSnapshot);
  }

  generateMessages(AsyncSnapshot<QuerySnapshot> snapshot) {
    return snapshot.data.documents
        .map<Widget>(
          (doc) => Container(
            margin: const EdgeInsets.symmetric(vertical: 10.0),
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: doc.data['type'] == "Call"
                  ? [
                      Text(doc.data["time"] != null
                          ? "${doc.data['text']} : " +
                              DateFormat.yMMMd()
                                  .add_jm()
                                  .format(doc.data["time"].toDate())
                                  .toString() +
                              " by ${doc.data['sender_id'] == widget.sender.id ? "You" : "${widget.second.name}"}"
                          : "")
                    ]
                  : doc.data["type"] == "req"
                      ? [
                          Column(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 7.0, vertical: 7.0),
                                width: MediaQuery.of(context).size.width * 0.9,
                                decoration: BoxDecoration(
                                    color: doc.data['sender_id'] ==
                                            widget.sender.id
                                        ? primaryColor.withOpacity(.1)
                                        : secondryColor.withOpacity(.3),
                                    borderRadius: BorderRadius.circular(20)),
                                child: Column(
                                  children: [
                                    Stack(
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: RichText(
                                            text: TextSpan(
                                              children: <TextSpan>[
                                                //real message
                                                TextSpan(
                                                  text: doc.data['sender_id'] ==
                                                          widget.sender.id
                                                      ? "Call Request Sent!" +
                                                          "    "
                                                      : doc.data['text'] +
                                                          "    ",
                                                  style: TextStyle(
                                                    color: Colors.black87,
                                                    fontSize: 16.0,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),

                                                //fake additionalInfo as placeholder
                                                TextSpan(
                                                    text: doc.data["time"] !=
                                                            null
                                                        ? DateFormat.MMMd()
                                                            .add_jm()
                                                            .format(doc
                                                                .data["time"]
                                                                .toDate())
                                                            .toString()
                                                        : "",
                                                    style: TextStyle(
                                                        color: Color.fromRGBO(
                                                                255,
                                                                255,
                                                                255,
                                                                1)
                                                            .withOpacity(0))),
                                              ],
                                            ),
                                          ),
                                        ),

                                        //real additionalInfo
                                        Positioned(
                                          child: Text(
                                            doc.data["time"] != null
                                                ? DateFormat.MMMd()
                                                    .add_jm()
                                                    .format(doc.data["time"]
                                                        .toDate())
                                                    .toString()
                                                : "",
                                            style: TextStyle(
                                              color: secondryColor,
                                              fontSize: 13.0,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          right: 8.0,
                                          bottom: 4.0,
                                        ),
                                      ],
                                    ),
                                    doc.data['sender_id'] != widget.sender.id
                                        ? TextButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                CupertinoPageRoute(
                                                  builder: (context) =>
                                                      CallSettings(
                                                    currentUser: widget.sender,
                                                    seconduser: widget.second,
                                                    chatId: widget.chatId,
                                                  ),
                                                ),
                                              );
                                            },
                                            style: TextButton.styleFrom(
                                              primary: Colors.transparent,
                                              minimumSize:
                                                  Size(double.maxFinite, 40),
                                              shape:
                                                  const RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(10),
                                                ),
                                              ),
                                              backgroundColor: primaryColor,
                                            ),
                                            child: Text(
                                              "Go to Call Settings", // TODO: translate this
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          )
                                        : Container(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ]
                      : doc.data['sender_id'] != widget.sender.id
                          ? generateReceiverLayout(
                              doc,
                            )
                          : generateSenderLayout(doc),
            ),
          ),
        )
        .toList();
  }

  void choiceAction(String value) {
    if (value == "report_user") {
      print("report");
      showDialog(
          barrierDismissible: true,
          context: context,
          builder: (context) => ReportUser(
                currentUser: widget.sender,
                seconduser: widget.second,
              ));
    } else if (value == "block_user") {
      showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: Text(isBlocked
                ? getTranslated(context, 'unblock')
                : getTranslated(context, 'block')),
            content: Text(
                'Do you want to ${isBlocked ? 'Unblock' : 'Block'} ${widget.second.name}?'),
            actions: <Widget>[
              FlatButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('No'),
              ),
              FlatButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  if (isBlocked && blockedBy == widget.sender.id) {
                    chatReference.document('blocked').setData({
                      'isBlocked': !isBlocked,
                      'blockedBy': widget.sender.id,
                    });
                  } else if (!isBlocked) {
                    chatReference.document('blocked').setData({
                      'isBlocked': !isBlocked,
                      'blockedBy': widget.sender.id,
                    });
                  } else {
                    CustomSnackbar.snackbar(
                        getTranslated(context, 'you_cant_unblock'),
                        _scaffoldKey);
                  }
                },
                child: Text('Yes'),
              ),
            ],
          );
        },
      );
    } else if (value == "call_settings") {
      Navigator.push(
          context,
          CupertinoPageRoute(
              builder: (context) => CallSettings(
                    currentUser: widget.sender,
                    seconduser: widget.second,
                    chatId: widget.chatId,
                  )));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: _present
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.second.name ?? "User not found",
                      style: TextStyle(color: primaryColor, fontSize: 18),
                      textAlign: TextAlign.start,
                    ),
                    MarqueeWidget(
                      direction: Axis.horizontal,
                      child: Text(
                        "Online",
                        style: TextStyle(
                          color: secondryColor,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.start,
                      ),
                    ),
                  ],
                )
              : _last_seen == null || _last_seen == ""
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.second.name ?? "User not found",
                          style: TextStyle(color: primaryColor),
                          textAlign: TextAlign.start,
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.second.name,
                          style: TextStyle(color: primaryColor, fontSize: 18),
                          textAlign: TextAlign.start,
                        ),
                        MarqueeWidget(
                          direction: Axis.horizontal,
                          child: Text(
                            _last_seen,
                            style: TextStyle(
                              color: secondryColor,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.start,
                          ),
                        ),
                      ],
                    ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            color: primaryColor,
            onPressed: () => Navigator.pop(context),
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.call,
                color: primaryColor,
              ),
              onPressed: () => !isBlocked || !widget.second.isBlocked
                  ? isAudioAllowed
                      ? onJoin("AudioCall")
                      : showCupertinoModalPopup(
                          context: context,
                          builder: (BuildContext context) =>
                              showPermissionDialog("Audio Call"))
                  : CustomSnackbar.snackbar(
                      blockedBy == widget.sender.id
                          ? "You blocked this contact."
                          : widget.second.isBlocked
                              ? "${widget.second.name} can no longer be contacted."
                              : "You have been blocked from making calls to this user",
                      _scaffoldKey),
            ),
            IconButton(
              icon: Icon(
                Icons.video_call,
                color: primaryColor,
              ),
              onPressed: () => !isBlocked || !widget.second.isBlocked
                  ? isVideoAllowed
                      ? onJoin("VideoCall")
                      : showCupertinoModalPopup(
                          context: context,
                          builder: (BuildContext context) =>
                              showPermissionDialog("Video Call"))
                  : CustomSnackbar.snackbar(
                      blockedBy == widget.sender.id
                          ? "You blocked this contact."
                          : "You have been blocked from making calls to this user",
                      _scaffoldKey),
            ),
            PopupMenuButton(
                onSelected: choiceAction,
                icon: Icon(
                  Icons.more_vert,
                  color: primaryColor,
                ),
                itemBuilder: (ct) {
                  return [
                    PopupMenuItem(
                        value: 'report_user',
                        child: Text(
                          getTranslated(context, 'report'),
                        )),
                    PopupMenuItem(
                      value: 'block_user',
                      child: Text(isBlocked
                          ? getTranslated(context, 'unblock_user')
                          : getTranslated(context, 'block_user')),
                    ),
                    PopupMenuItem(
                        value: "call_settings",
                        child: Text(
                          "Call Settings", // TODO: translate this
                        )),
                  ];
                })
          ]),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: Colors.white,
          body: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(50.0),
              topRight: Radius.circular(50.0),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: primaryColor,

                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(49),
                  topRight: const Radius.circular(49),
                ), // BorderRadius
              ),
              child: Container(
                margin: const EdgeInsetsDirectional.only(top: 4),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(50),
                        topRight: Radius.circular(50)),
                    color: Colors.white),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    StreamBuilder<QuerySnapshot>(
                      stream: chatReference
                          .orderBy('time', descending: true)
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (!snapshot.hasData)
                          return Container(
                            height: 15,
                            width: 15,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(primaryColor),
                              strokeWidth: 2,
                            ),
                          );
                        return Expanded(
                          child: ListView(
                            reverse: true,
                            children: generateMessages(snapshot),
                          ),
                        );
                      },
                    ),
                    Divider(height: 1.0),
                    Container(
                      alignment: Alignment.bottomCenter,
                      decoration:
                          BoxDecoration(color: Theme.of(context).cardColor),
                      child: isBlocked
                          ? GestureDetector(
                              onTap: () {
                                if (isBlocked &&
                                    blockedBy == widget.sender.id) {
                                  choiceAction('block_user');
                                }
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                alignment: Alignment.center,
                                color: primaryColor,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 18.0),
                                child: Text(
                                  !(isBlocked && blockedBy == widget.sender.id)
                                      ? "You have been blocked from sending messages to this user"
                                      : "You blocked this contact. Tap to unblock.", //TODO:translate this
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            )
                          : widget.second.isBlocked
                              ? Container(
                                  width: MediaQuery.of(context).size.width,
                                  alignment: Alignment.center,
                                  color: primaryColor,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 18.0),
                                  child: Text(
                                    "${widget.second.name} can no longer be contacted.", //TODO:translate this
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white),
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              : _buildTextComposer(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget showPermissionDialog(String callType) {
    return CupertinoActionSheet(
      cancelButton: CupertinoActionSheetAction(
        onPressed: () => Navigator.pop(context),
        child: Text("Cancel"),
      ),
      title: Text(
        "Required Permission!",
        style: TextStyle(
          fontSize: 18,
        ),
      ),
      message: Text(
        "You can't call ${widget.second.name} without their permission! Would you like to ask for permission to allow you to $callType?",
        style: TextStyle(fontSize: 16),
      ),
      actions: [
        CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
            print("Requesting $callType permission...");
            _sendText(
                text:
                    "Hey ${widget.second.name}! \n ${widget.sender.name} wants to $callType. Would you like to recevice $callType from ${widget.sender.name}?",
                type: 'req');
          },
          child: Text(
            "Request permission for $callType",
            style: TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget getDefaultSendButton() {
    return IconButton(
      icon: Transform.rotate(
        angle: -pi / 9,
        child: Icon(
          Icons.send,
          size: 25,
        ),
      ),
      color: primaryColor,
      onPressed: _isWritting
          ? () => _sendText(text: _textController.text.trimRight(), type: 'Msg')
          : null,
    );
  }

  Widget _buildTextComposer() {
    return IconTheme(
        data: IconThemeData(color: _isWritting ? primaryColor : secondryColor),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: <Widget>[
              Container(
                margin: EdgeInsets.symmetric(horizontal: 4.0),
                child: IconButton(
                    icon: Icon(
                      Icons.photo_camera,
                      color: primaryColor,
                    ),
                    onPressed: () async {
                      var image = await ImagePicker.pickImage(
                          source: ImageSource.gallery);
                      int timestamp = new DateTime.now().millisecondsSinceEpoch;
                      StorageReference storageReference = FirebaseStorage
                          .instance
                          .ref()
                          .child('chats/${widget.chatId}/img_' +
                              timestamp.toString() +
                              '.jpg');
                      StorageUploadTask uploadTask =
                          storageReference.putFile(image);
                      await uploadTask.onComplete;
                      String fileUrl = await storageReference.getDownloadURL();
                      _sendImage(messageText: 'Photo', imageUrl: fileUrl);
                    }),
              ),
              new Flexible(
                child: new TextField(
                  controller: _textController,
                  maxLines: 15,
                  minLines: 1,
                  autofocus: false,
                  onChanged: (String messageText) {
                    setState(() {
                      _isWritting = messageText.trim().length > 0;
                    });
                  },
                  decoration: new InputDecoration.collapsed(
                      floatingLabelBehavior: FloatingLabelBehavior.auto,
                      // border: OutlineInputBorder(
                      //     borderRadius: BorderRadius.circular(18)),
                      hintText: "Send a message..."),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                child: getDefaultSendButton(),
              ),
            ],
          ),
        ));
  }

  Future<Null> _sendText({@required String text, @required String type}) async {
    _textController.clear();
    chatReference.add({
      'type': type,
      'text': text,
      'sender_id': widget.sender.id,
      'receiver_id': widget.second.id,
      'isRead': false,
      'image_url': '',
      'time': FieldValue.serverTimestamp(),
    }).then((documentReference) {
      setState(() {
        _isWritting = false;
      });
    }).catchError((e) {});
  }

  void _sendImage({String messageText, String imageUrl}) {
    chatReference.add({
      'type': 'Image',
      'text': messageText,
      'sender_id': widget.sender.id,
      'receiver_id': widget.second.id,
      'isRead': false,
      'image_url': imageUrl,
      'time': FieldValue.serverTimestamp(),
    });
  }

  Future<void> onJoin(callType) async {
    if (!isBlocked) {
      // await for camera and mic permissions before pushing video page

      await handleCameraAndMic(callType);
      await chatReference.add({
        'type': 'Call',
        'text': callType,
        'sender_id': widget.sender.id,
        'receiver_id': widget.second.id,
        'isRead': false,
        'image_url': "",
        'time': FieldValue.serverTimestamp(),
      });

      // push video page with given channel name
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DialCall(
              channelName: widget.chatId,
              receiver: widget.second,
              callType: callType),
        ),
      );
    } else {
      CustomSnackbar.snackbar(getTranslated(context, 'blocked'), _scaffoldKey);
    }
  }
}

Future<void> handleCameraAndMic(callType) async {
  await PermissionHandler().requestPermissions(callType == "VideoCall"
      ? [PermissionGroup.camera, PermissionGroup.microphone]
      : [PermissionGroup.microphone]);
}
