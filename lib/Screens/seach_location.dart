import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loveafghan/localization/localization_constants.dart';
import 'package:loveafghan/util/color.dart';
import 'package:loveafghan/util/snackbar.dart';
import 'package:mapbox_search_flutter/mapbox_search_flutter.dart';
import 'AllowLocation.dart';

class SearchLocation extends StatefulWidget {
  final Map<String, dynamic> userData;
  SearchLocation(this.userData);

  @override
  _SearchLocationState createState() => _SearchLocationState();
}

class _SearchLocationState extends State<SearchLocation> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  MapBoxPlace _mapBoxPlace;
  TextEditingController _city = TextEditingController();
  //Add here your mapbox token
  String _mapboxApi = //"<----- Add here your mapbox token-->"
      "pk.eyJ1IjoibG92ZWFmZ2hhbiIsImEiOiJja2tpbGRwMWEwNWtlMm9raHFzdXc1dTU2In0.hoXgkDLXsxbydI6CnBweew";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
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
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Container(
            height: MediaQuery.of(context).size.height,
            child: Stack(
              children: <Widget>[
                Padding(
                  child: Text(
                    getTranslated(context, 'select_your_city'),
                    style: TextStyle(fontSize: 40),
                  ),
                  padding: EdgeInsets.only(left: 50, top: 120),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: TextField(
                        autofocus: false,
                        readOnly: true,
                        decoration: InputDecoration(
                          hintText:
                              getTranslated(context, 'enter_your_city_name'),
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: primaryColor)),
                          helperText: getTranslated(
                              context, 'this_is_how_it_will_appear_in_app'),
                          helperStyle:
                              TextStyle(color: secondryColor, fontSize: 15),
                        ),
                        controller: _city,
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Material(
                                      child: Column(
                                        children: <Widget>[
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 80),
                                            child: MapBoxPlaceSearchWidget(
                                              // language:
                                              //     getLanguageCode().toString(),
                                              popOnSelect: true,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  .5,
                                              apiKey: _mapboxApi,
                                              // limit: 10,
                                              searchHint: getTranslated(context,
                                                  'enter_your_city_name'),
                                              onSelected: (place) {
                                                setState(() {
                                                  _mapBoxPlace = place;
                                                  _city.text =
                                                      _mapBoxPlace.placeName;
                                                });
                                              },
                                              context: context,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ))),
                      ),
                    ),
                  ],
                ),
                _city.text.length > 0
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 40.0),
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
                                height:
                                    MediaQuery.of(context).size.height * .065,
                                width: MediaQuery.of(context).size.width * .75,
                                child: Center(
                                    child: Text(
                                  getTranslated(context, 'continue'),
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: textColor,
                                      fontWeight: FontWeight.bold),
                                ))),
                            onTap: () async {
                              widget.userData.addAll(
                                {
                                  'location': {
                                    'latitude':
                                        _mapBoxPlace.geometry.coordinates[1],
                                    'longitude':
                                        _mapBoxPlace.geometry.coordinates[0],
                                    'address': "${_mapBoxPlace.placeName}"
                                  },
                                  'maximum_distance': 20,
                                  'age_range': {
                                    'min': "20",
                                    'max': "50",
                                  },
                                },
                              );

                              showWelcomDialog(context);
                              setUserData(widget.userData);
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
                                height:
                                    MediaQuery.of(context).size.height * .065,
                                width: MediaQuery.of(context).size.width * .75,
                                child: Center(
                                    child: Text(
                                  getTranslated(context, 'continue'),
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: secondryColor,
                                      fontWeight: FontWeight.bold),
                                ))),
                            onTap: () {
                              CustomSnackbar.snackbar(
                                  getTranslated(context, 'select_a_location'),
                                  _scaffoldKey);
                            },
                          ),
                        ),
                      )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
