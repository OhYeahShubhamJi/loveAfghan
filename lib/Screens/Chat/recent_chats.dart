import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loveafghan/Screens/Chat/Matches.dart';
import 'package:loveafghan/Screens/Chat/chatPage.dart';
import 'package:loveafghan/localization/localization_constants.dart';
import 'package:loveafghan/models/user_model.dart';
import 'package:loveafghan/util/color.dart';
import 'package:loveafghan/util/snackbar.dart';

class RecentChats extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final User currentUser;
  final List<User> matches;

  RecentChats(this.currentUser, this.matches, this.scaffoldKey);

  @override
  _RecentChatsState createState() => _RecentChatsState();
}

class _RecentChatsState extends State<RecentChats> {
  final db = Firestore.instance;

  @override
  void initState() {
    super.initState();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30.0),
                topRight: Radius.circular(30.0),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                //   topLeft: Radius.circular(30.0),
                topRight: Radius.circular(30.0),
              ),
              child: ListView(
                  physics: ScrollPhysics(),
                  children: widget.matches
                      .map((index) => GestureDetector(
                            onTap: () {
                              if (index.name.isEmpty || index.name == null) {
                                CustomSnackbar.snackbar(
                                    "User not found!, this account is deleted!",
                                    widget.scaffoldKey);
                              } else {
                                Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (_) => ChatPage(
                                      chatId: chatId(widget.currentUser, index),
                                      sender: widget.currentUser,
                                      second: index,
                                    ),
                                  ),
                                );
                              }
                            },
                            child: StreamBuilder(
                                stream: db
                                    .collection("chats")
                                    .document(chatId(widget.currentUser, index))
                                    .collection('messages')
                                    .orderBy('time', descending: true)
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData)
                                    return Container(
                                      child: Padding(
                                        padding: const EdgeInsets.all(18.0),
                                        child: CupertinoActivityIndicator(),
                                      ),
                                    );
                                  else if (snapshot.data.documents.length ==
                                      0) {
                                    return Container();
                                  }
                                  index.lastmsg =
                                      snapshot.data.documents[0]['time'];
                                  return Container(
                                    margin: EdgeInsets.only(
                                        top: 5.0, bottom: 5.0, right: 20.0),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20.0, vertical: 10.0),
                                    decoration: BoxDecoration(
                                      color: snapshot.data.documents[0]
                                                      ['sender_id'] !=
                                                  widget.currentUser.id &&
                                              !snapshot.data.documents[0]
                                                  ['isRead']
                                          ? primaryColor.withOpacity(.1)
                                          : secondryColor.withOpacity(.2),
                                      borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(20.0),
                                        bottomRight: Radius.circular(20.0),
                                      ),
                                    ),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: secondryColor,
                                        radius: 30.0,
                                        child: Stack(
                                          children: <Widget>[
                                            Align(
                                              alignment: Alignment.center,
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(90),
                                                child: CachedNetworkImage(
                                                  fit: BoxFit.cover,
                                                  imageUrl: index
                                                          .imageUrl[0].url ??
                                                      'https://firebasestorage.googleapis.com/v0/b/loveafghan-de2aa.appspot.com/o/default.png?alt=media&token=9077ffd4-bcf0-44fb-8770-e515334a8802',
                                                  useOldImageOnUrlChange: true,
                                                  placeholder: (context, url) =>
                                                      CupertinoActivityIndicator(
                                                    radius: 15,
                                                  ),
                                                  errorWidget:
                                                      (context, url, error) =>
                                                          Icon(Icons.error),
                                                ),
                                              ),
                                            ),
                                            Align(
                                              alignment: Alignment.bottomRight,
                                              child: Container(
                                                width: 15,
                                                height: 15,
                                                decoration: new BoxDecoration(
                                                  color: index.presence != null
                                                      ? index.presence
                                                          ? Colors
                                                              .lightGreen[400]
                                                          : Colors.grey
                                                      : Colors.grey,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      title: Text(
                                        index.name ?? "User Not Found!",
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Text(
                                        (snapshot.data.documents[0]['image_url']
                                                        .toString()
                                                        .length >
                                                    0
                                                ? "Photo"
                                                : snapshot.data.documents[0]
                                                            ['type'] ==
                                                        'req'
                                                    ? "Call Request Sent!"
                                                    : snapshot.data.documents[0]
                                                        ['text']) ??
                                            "",
                                        style: TextStyle(
                                          color: Colors.blueGrey,
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      trailing: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: <Widget>[
                                          // Text(
                                          //   snapshot.data.documents[0]
                                          //               ["time"] !=
                                          //           null
                                          //       ? DateFormat.MMMd()
                                          //           .add_jm()
                                          //           .format(snapshot.data
                                          //               .documents[0]["time"]
                                          //               .toDate())
                                          //           .toString()
                                          //       : "",
                                          //   style: TextStyle(
                                          //     color: Colors.grey,
                                          //     fontSize: 15.0,
                                          //     fontWeight: FontWeight.bold,
                                          //   ),
                                          // ),
                                          (snapshot.data.documents[0]
                                                              ['sender_id'] !=
                                                          widget
                                                              .currentUser.id &&
                                                      !snapshot
                                                              .data.documents[0]
                                                          ['isRead']) ??
                                                  false
                                              ? Container(
                                                  width: 40.0,
                                                  height: 20.0,
                                                  decoration: BoxDecoration(
                                                    color: primaryColor,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30.0),
                                                  ),
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    getTranslated(
                                                        context, 'new'),
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12.0,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                )
                                              : Text(""),
                                          (snapshot.data.documents[0]
                                                          ['sender_id'] ==
                                                      widget.currentUser.id) ??
                                                  false
                                              ? !snapshot.data.documents[0]
                                                      ['isRead']
                                                  ? Icon(
                                                      Icons.done,
                                                      color: secondryColor,
                                                      size: 15,
                                                    )
                                                  : Icon(
                                                      Icons.done_all,
                                                      color: primaryColor,
                                                      size: 15,
                                                    )
                                              : Text("")
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                          ))
                      .toList()),
            )));
  }
}
