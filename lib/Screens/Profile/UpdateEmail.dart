import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loveafghan/Screens/Email.dart';
import 'package:loveafghan/localization/localization_constants.dart';
import 'package:loveafghan/util/color.dart';
import 'package:loveafghan/util/snackbar.dart';

class UpdateEmail extends StatefulWidget {
  final String email;
  final String id;
  UpdateEmail(this.email, this.id);

  @override
  _UpdateEmailState createState() => _UpdateEmailState();
}

class _UpdateEmailState extends State<UpdateEmail> {
  String email;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    widget.email == '' ? email = "" : email = "${widget.email}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          getTranslated(context, 'update_email'),
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
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      child: TextFormField(
                        initialValue: email,
                        style: TextStyle(fontSize: 18),
                        decoration: InputDecoration(
                          hintText: getTranslated(
                              context, 'enter_your_email_address'),
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: primaryColor)),
                          helperStyle:
                              TextStyle(color: secondryColor, fontSize: 12),
                        ),
                        onChanged: (value) {
                          setState(() {
                            email = value;
                            print(email);
                          });
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Center(
                      child: InkWell(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(18.0),
                            child: Text(getTranslated(context, 'save'),
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: primaryColor)),
                          ),
                        ),
                        onTap: () async {
                          if (validateEmail(email)) {
                            await Firestore.instance
                                .collection('Users')
                                .document(widget.id)
                                .updateData({'Email': '$email'}).then((value) {
                              Navigator.of(context).pop(email);
                            });
                          } else {
                            CustomSnackbar.snackbar(
                                getTranslated(
                                    context, 'please_enter_valid_email'),
                                _scaffoldKey);
                          }
                        },
                      ),
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
