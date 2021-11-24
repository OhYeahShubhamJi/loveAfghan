import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loveafghan/models/chat_settings.dart';
import 'package:loveafghan/models/user_model.dart';
import 'package:loveafghan/util/color.dart';
import 'package:loveafghan/util/snackbar.dart';

class CallSettings extends StatefulWidget {
  final User currentUser;
  final User seconduser;
  final String chatId;

  CallSettings(
      {@required this.currentUser,
      @required this.seconduser,
      @required this.chatId});

  @override
  _CallSettingsState createState() => _CallSettingsState();
}

class _CallSettingsState extends State<CallSettings> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
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
        var getuid = getChatSettingsId(widget.currentUser, widget.seconduser);
        if (snapshot.data != null) {
          chatSettings = ChatSettings.fromDocument(snapshot);
          if (getuid == 1) {
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
          } else if (getuid == 2) {
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
          }
        }
      });
    } catch (e) {
      CustomSnackbar.snackbar(e.toString(), _scaffoldKey);
    }
  }

  setCallSettings(ChatSettings newChatSettings) async {
    try {
      await chats
          .document(widget.chatId)
          .setData(newChatSettings.toMap(newChatSettings), merge: true)
          .then((value) {
        print("updated!");
      });
    } catch (e) {
      CustomSnackbar.snackbar(e.toString(), _scaffoldKey);
    }
  }

  @override
  void initState() {
    getCallSettings();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Call Settings", //TODO : translate
          style: TextStyle(color: primaryColor),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          color: primaryColor,
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
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
          decoration: BoxDecoration(
              color: Colors.white,
              // border: Border(top: BorderSide(width: 4)),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50), topRight: Radius.circular(50))),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(50), topRight: Radius.circular(50)),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Text(
                      "You can allow or deny audio calls and/or video calls from ${widget.seconduser.name} by turning the below switches on/off.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: primaryColor),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Allow Audio Calls", // TODO: translate
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        Switch(
                          value: isAudioAllowed,
                          onChanged: (value) {
                            setState(() {
                              isAudioAllowed = value;
                              print(isAudioAllowed);
                              if (chatSettings != null) {
                                if (chatSettingsId == 1) {
                                  if (chatSettings.user2 != null) {
                                    print("not null");
                                    setCallSettings(new ChatSettings(user1: {
                                      "acalls": isAudioAllowed,
                                      "vcalls": isVideoAllowed
                                    }, user2: {
                                      "acalls": chatSettings.user2['acalls'],
                                      "vcalls": chatSettings.user2['vcalls']
                                    }));
                                  } else {
                                    print("null");
                                    setCallSettings(new ChatSettings(user1: {
                                      "acalls": isAudioAllowed,
                                      "vcalls": isVideoAllowed
                                    }, user2: {
                                      "acalls": false,
                                      "vcalls": false
                                    }));
                                  }
                                } else if (chatSettingsId == 2) {
                                  if (chatSettings.user1 != null) {
                                    print("not null");
                                    setCallSettings(new ChatSettings(user2: {
                                      "acalls": isAudioAllowed,
                                      "vcalls": isVideoAllowed
                                    }, user1: {
                                      "acalls": chatSettings.user1['acalls'],
                                      "vcalls": chatSettings.user1['vcalls']
                                    }));
                                  } else {
                                    print("null");
                                    setCallSettings(new ChatSettings(user2: {
                                      "acalls": isAudioAllowed,
                                      "vcalls": isVideoAllowed
                                    }, user1: {
                                      "acalls": false,
                                      "vcalls": false
                                    }));
                                  }
                                }
                              } else {
                                if (chatSettingsId == 1) {
                                  setCallSettings(new ChatSettings(user1: {
                                    "acalls": isAudioAllowed,
                                    "vcalls": isVideoAllowed
                                  }, user2: {
                                    "acalls": false,
                                    "vcalls": false
                                  }));
                                } else if (chatSettingsId == 2) {
                                  setCallSettings(new ChatSettings(user2: {
                                    "acalls": isAudioAllowed,
                                    "vcalls": isVideoAllowed
                                  }, user1: {
                                    "acalls": false,
                                    "vcalls": false
                                  }));
                                }
                              }
                            });
                          },
                          activeTrackColor: darkPrimaryColor,
                          activeColor: primaryColor,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Allow Video Calls", // TODO: translate
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        Switch(
                          value: isVideoAllowed,
                          onChanged: (value) {
                            setState(() {
                              isVideoAllowed = value;
                              print(isVideoAllowed);
                              if (chatSettingsId == 1) {
                                if (chatSettings.user2 != null) {
                                  print("not null");
                                  setCallSettings(new ChatSettings(user1: {
                                    "acalls": isAudioAllowed,
                                    "vcalls": isVideoAllowed
                                  }, user2: {
                                    "acalls": chatSettings.user2['acalls'],
                                    "vcalls": chatSettings.user2['vcalls']
                                  }));
                                } else {
                                  print("null");
                                  setCallSettings(new ChatSettings(user1: {
                                    "acalls": isAudioAllowed,
                                    "vcalls": isVideoAllowed
                                  }, user2: {
                                    "acalls": false,
                                    "vcalls": false
                                  }));
                                }
                              } else if (chatSettingsId == 2) {
                                if (chatSettings.user1 != null) {
                                  print("not null");
                                  setCallSettings(new ChatSettings(user2: {
                                    "acalls": isAudioAllowed,
                                    "vcalls": isVideoAllowed
                                  }, user1: {
                                    "acalls": chatSettings.user1['acalls'],
                                    "vcalls": chatSettings.user1['vcalls']
                                  }));
                                } else {
                                  print("null");
                                  setCallSettings(new ChatSettings(user2: {
                                    "acalls": isAudioAllowed,
                                    "vcalls": isVideoAllowed
                                  }, user1: {
                                    "acalls": false,
                                    "vcalls": false
                                  }));
                                }
                              } else {
                                print(
                                    "Invalid ChatSettingsId: $chatSettingsId");
                              }
                            });
                          },
                          activeTrackColor: darkPrimaryColor,
                          activeColor: primaryColor,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

var chatSettingsId;
getChatSettingsId(currentUser, sender) {
  if (currentUser.id.hashCode <= sender.id.hashCode) {
    return chatSettingsId = 1;
  } else {
    return chatSettingsId = 2;
  }
}
