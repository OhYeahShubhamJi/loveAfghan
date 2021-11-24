import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loveafghan/Screens/Chat/chatPage.dart';
import 'package:loveafghan/localization/localization_constants.dart';
import 'package:loveafghan/models/user_model.dart';
import 'package:loveafghan/util/color.dart';
import 'package:loveafghan/util/snackbar.dart';

class Matches extends StatefulWidget {
  final User currentUser;
  final List<User> matches;
  final GlobalKey<ScaffoldState> scaffoldKey;

  Matches(this.currentUser, this.matches, this.scaffoldKey);

  @override
  _MatchesState createState() => _MatchesState();
}

class _MatchesState extends State<Matches> {
  @override
  void initState() {
    super.initState();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  getTranslated(context, 'new_matches'),
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.more_horiz,
                  ),
                  iconSize: 30.0,
                  color: Colors.white,
                  onPressed: () {},
                ),
              ],
            ),
          ),
          Container(
              height: 120.0,
              child: widget.matches.length > 0
                  ? ListView.builder(
                      padding: EdgeInsets.only(left: 10.0),
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.matches.length,
                      itemBuilder: (BuildContext context, int index) {
                        return GestureDetector(
                          onTap: () {
                            if (widget.matches[index].name.isEmpty ||
                                widget.matches[index].name == null) {
                              CustomSnackbar.snackbar(
                                  "User not found!, this account is deleted!",
                                  widget.scaffoldKey);
                            } else {
                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (_) => ChatPage(
                                    sender: widget.currentUser,
                                    chatId: chatId(widget.currentUser,
                                        widget.matches[index]),
                                    second: widget.matches[index],
                                  ),
                                ),
                              );
                            }
                          },
                          child: Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Column(
                              children: <Widget>[
                                CircleAvatar(
                                  backgroundColor: secondryColor,
                                  radius: 35.0,
                                  child: Stack(
                                    children: <Widget>[
                                      Align(
                                        alignment: Alignment.center,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(90),
                                          child: CachedNetworkImage(
                                            width: double.maxFinite,
                                            height: double.maxFinite,
                                            fit: BoxFit.cover,
                                            imageUrl: widget.matches[index]
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
                                            color: widget.matches[index]
                                                        .presence !=
                                                    null
                                                ? widget.matches[index].presence
                                                    ? Colors.lightGreen[400]
                                                    : Colors.grey
                                                : Colors.grey,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                SizedBox(height: 6.0),
                                Text(
                                  widget.matches[index].name ??
                                      "User not found",
                                  style: TextStyle(
                                    color: secondryColor,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Text(
                      getTranslated(context, 'no_match_found'),
                      style: TextStyle(color: secondryColor, fontSize: 16),
                    ))),
        ],
      ),
    );
  }
}

var groupChatId;
chatId(currentUser, sender) {
  if (currentUser.id.hashCode <= sender.id.hashCode) {
    return groupChatId = '${currentUser.id}-${sender.id}';
  } else {
    return groupChatId = '${sender.id}-${currentUser.id}';
  }
}
