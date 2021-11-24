import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loveafghan/localization/localization_constants.dart';
import 'package:loveafghan/util/color.dart';
import 'AllowLocation.dart';

class University extends StatefulWidget {
  final Map<String, dynamic> userData;
  University(this.userData);

  @override
  _UniversityState createState() => _UniversityState();
}

class _UniversityState extends State<University> {
  String university = 'Select option';
  List<String> educationLevel = [
    'Select option',
    'High School',
    '2-Year Degree',
    'Bachelor’s Degree',
    'Master’s and Beyond',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(60),
        ),
        width: 60,
        height: 60,
        alignment: Alignment.center,
        child: IconButton(
          alignment: Alignment.centerRight,
          color: secondryColor,
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Stack(
                children: <Widget>[
                  Padding(
                    child: Text(
                      "Education Level", // TODO: translate this.
                      style: TextStyle(fontSize: 40),
                    ),
                    padding: EdgeInsets.only(left: 50, top: 120),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Container(
                  child: Center(
                    child: DropdownButton(
                      value: university,
                      iconEnabledColor: primaryColor,
                      iconDisabledColor: secondryColor,
                      onChanged: (String newValue) {
                        setState(() {
                          university = newValue;
                        });
                      },
                      items: educationLevel
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                  // child: TextFormField(
                  //   style: TextStyle(fontSize: 23),
                  //   decoration: InputDecoration(
                  //     hintText:
                  //         getTranslated(context, 'enter_your_university_name'),
                  //     focusedBorder: UnderlineInputBorder(
                  //         borderSide: BorderSide(color: primaryColor)),
                  //     helperText: getTranslated(
                  //         context, 'this_is_how_it_will_appear_in_app'),
                  //     helperStyle:
                  //         TextStyle(color: secondryColor, fontSize: 15),
                  //   ),
                  //   onChanged: (value) {
                  //     setState(() {
                  //       university = value;
                  //     });
                  //   },
                  // ),
                ),
              ),
              university != 'Select option'
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 40),
                      child: Align(
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
                                getTranslated(context, 'continue'),
                                style: TextStyle(
                                    fontSize: 15,
                                    color: textColor,
                                    fontWeight: FontWeight.bold),
                              ))),
                          onTap: () {
                            widget.userData.addAll({
                              'editInfo': {
                                'university': "$university",
                                'userGender': widget.userData['userGender'],
                                'showOnProfile':
                                    widget.userData['showOnProfile']
                              }
                            });
                            widget.userData.remove('showOnProfile');
                            widget.userData.remove('userGender');

                            print(widget.userData);
                            Navigator.push(
                                context,
                                CupertinoPageRoute(
                                    builder: (context) =>
                                        AllowLocation(widget.userData)));
                          },
                        ),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.only(bottom: 40),
                      child: Align(
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
                                getTranslated(context, 'continue'),
                                style: TextStyle(
                                    fontSize: 15,
                                    color: secondryColor,
                                    fontWeight: FontWeight.bold),
                              ))),
                          onTap: () {},
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
