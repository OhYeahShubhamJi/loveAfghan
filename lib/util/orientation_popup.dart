import 'package:flutter/material.dart';
import 'package:loveafghan/localization/localization_constants.dart';
import 'package:loveafghan/util/color.dart';
import 'package:loveafghan/util/snackbar.dart';

class OrientationPopup extends StatefulWidget {
  final List selected;
  final GlobalKey<ScaffoldState> scaffoldKey;
  const OrientationPopup({Key key, this.scaffoldKey, this.selected})
      : super(key: key);

  @override
  State<OrientationPopup> createState() => _OrientationPopupState();
}

class _OrientationPopupState extends State<OrientationPopup> {
  List<Map<String, dynamic>> orientationlist = [
    {'name': 'Straight', 'ontap': false},
    {'name': 'Gay', 'ontap': false},
    {'name': 'Asexual', 'ontap': false},
    {'name': 'Lesbian', 'ontap': false},
    {'name': 'Bisexual', 'ontap': false},
    {'name': 'Demisexual', 'ontap': false},
  ];
  List selected = [];
  bool select = false;

  void updateSelection() {
    if (widget.selected != null) {
      for (var i = 0; i < orientationlist.length; i++) {
        orientationlist[i] =
            widget.selected.contains(orientationlist[i]['name'])
                ? {'name': orientationlist[i]['name'], 'ontap': true}
                : {
                    'name': orientationlist[i]['name'],
                    'ontap': orientationlist[i]['ontap']
                  };
      }
      selected = widget.selected;
      print(orientationlist);
    }
  }

  @override
  void initState() {
    updateSelection();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(12.0)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Select Any 3',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 25,
              ),
              ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: orientationlist.length,
                itemBuilder: (context, index) {
                  return OutlineButton(
                    highlightedBorderColor: primaryColor,
                    child: Container(
                      height: MediaQuery.of(context).size.height * .055,
                      width: MediaQuery.of(context).size.width * .65,
                      child: Center(
                          child: Text("${orientationlist[index]["name"]}",
                              style: TextStyle(
                                  fontSize: 20,
                                  color: orientationlist[index]["ontap"]
                                      ? primaryColor
                                      : secondryColor,
                                  fontWeight: FontWeight.bold))),
                    ),
                    borderSide: BorderSide(
                        width: 1,
                        style: BorderStyle.solid,
                        color: orientationlist[index]["ontap"]
                            ? primaryColor
                            : secondryColor),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25)),
                    onPressed: () {
                      setState(() {
                        if (selected.length < 3) {
                          orientationlist[index]["ontap"] =
                              !orientationlist[index]["ontap"];
                          if (orientationlist[index]["ontap"]) {
                            selected.add(orientationlist[index]["name"]);
                            print(orientationlist[index]["name"]);
                            print(selected);
                          } else {
                            selected.remove(orientationlist[index]["name"]);
                            print(selected);
                          }
                        } else {
                          if (orientationlist[index]["ontap"]) {
                            orientationlist[index]["ontap"] =
                                !orientationlist[index]["ontap"];
                            selected.remove(orientationlist[index]["name"]);
                          } else {
                            CustomSnackbar.snackbar(
                                getTranslated(context, 'select_upto_3'),
                                widget.scaffoldKey);
                          }
                        }
                      });
                    },
                  );
                },
              ),
              SizedBox(
                height: 20,
              ),
              selected.length > 0
                  ? Align(
                      alignment: Alignment.bottomCenter,
                      child: InkWell(
                        child: Container(
                            decoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(25),
                                gradient: LinearGradient(
                                    begin: Alignment.topRight,
                                    end: Alignment.bottomLeft,
                                    colors: [
                                      primaryColor.withOpacity(.5),
                                      primaryColor.withOpacity(.8),
                                      primaryColor,
                                      primaryColor
                                    ])),
                            height: MediaQuery.of(context).size.height * .065,
                            width: MediaQuery.of(context).size.width * .75,
                            child: Center(
                                child: Text(
                              'Done', // TODO: translate this text
                              style: TextStyle(
                                  fontSize: 15,
                                  color: textColor,
                                  fontWeight: FontWeight.bold),
                            ))),
                        onTap: () {
                          Navigator.of(context).pop(selected);
                        },
                      ),
                    )
                  : Align(
                      alignment: Alignment.bottomCenter,
                      child: InkWell(
                        child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            height: MediaQuery.of(context).size.height * .065,
                            width: MediaQuery.of(context).size.width * .75,
                            child: Center(
                                child: Text(
                              'Done', // TODO: translate this text
                              style: TextStyle(
                                  fontSize: 15,
                                  color: secondryColor,
                                  fontWeight: FontWeight.bold),
                            ))),
                        onTap: () {
                          CustomSnackbar.snackbar(
                              getTranslated(context, 'please_select_one'),
                              widget.scaffoldKey);
                        },
                      ),
                    )
            ],
          ),
        ),
      ),
    );
  }
}
