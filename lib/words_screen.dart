import 'package:flutter_slidable/flutter_slidable.dart';
import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flipcard/category_screen.dart';
import 'package:flipcard/game_screen.dart';
import 'package:flipcard/main.dart';
import 'package:flipcard/res/category_creation.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'res/colors.dart';
import 'package:intl/date_symbol_data_local.dart';

class WordsScreen extends StatefulWidget {
  const WordsScreen({Key? key}) : super(key: key);

  @override
  _WordsScreenState createState() => _WordsScreenState();
}

String categoryID = '';
String cardsetName = '';
String cardsetID = '';

final wordContoller = TextEditingController();
final expContoller = TextEditingController();

class _WordsScreenState extends State<WordsScreen> {
  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)!.settings.arguments as Map;
    categoryID = arguments['categoryname'];
    cardsetName = arguments['cardsetname'];
    cardsetID = arguments['cardsetid'];

    return MaterialApp(
        routes: {'/game': (context) => const GamePage()},
        home: Scaffold(
            backgroundColor: Colors.transparent,
            body: FutureBuilder(
                future: setSharedPrefs(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.none ||
                      snapshot.connectionState == ConnectionState.waiting) {
                    return Container();
                  }
                  return CardsScreen();
                })));
  }
}

class CardsScreen extends StatefulWidget {
  const CardsScreen({Key? key}) : super(key: key);

  @override
  _CardsScreenState createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              backgroundDark,
              backgroundLight,
            ],
          )),
          child: SafeArea(
            child: Container(
              margin: EdgeInsets.all(20),
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                color: Colors.white,
                backgroundBlendMode: BlendMode.overlay,
              ),
              child: Scaffold(
                backgroundColor: Colors.transparent,
                body: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        //Category name
                        Expanded(
                          child: AutoSizeText(
                            returnCategoryAsMap()['name'],
                            maxLines: 2,
                            style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Roboto',
                                fontSize: 24,
                                fontWeight: FontWeight.w800),
                          ),
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        //Date
                        Expanded(
                          flex: 0,
                          child: Text(
                            'Date created: ${formatDate((returnCategoryAsMap() as Map)['date']).toString()}',
                            style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Roboto',
                                fontSize: 15,
                                fontWeight: FontWeight.w900),
                          ),
                        )
                      ],
                    ),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(left: 10, right: 10, top: 10),
                        padding: EdgeInsets.only(left: 15, right: 15, top: 15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          color: Colors.white,
                        ),
                        child: Stack(
                          children: [
                            Column(
                              children: [
                                Container(
                                  margin: EdgeInsets.only(top: 2, bottom: 12),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: AutoSizeText(
                                          returnCardSetAsMap()['name']
                                              .toString(),
                                          style: TextStyle(
                                              color: backgroundDark,
                                              fontFamily: 'Roboto',
                                              fontSize: 20,
                                              fontWeight: FontWeight.w500),
                                          maxLines: 2,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 0,
                                        child: AutoSizeText(
                                          'Date created: ${formatDate(returnCardSetAsMap()['date'].toString())}',
                                          maxLines: 2,
                                          style: TextStyle(
                                              color: backgroundDark,
                                              fontFamily: 'Roboto',
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      color: blueMediumLight,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10))),
                                  padding: EdgeInsets.all(10),
                                  margin: EdgeInsets.only(
                                      left: 5, right: 5, bottom: 5, top: 7),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Concept',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      Text(
                                        'Explanation',
                                        style: TextStyle(color: Colors.white),
                                      )
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: FutureBuilder(
                                      future: setSharedPrefs(),
                                      builder: (context, snapshot) {
                                        return ListView.builder(
                                            shrinkWrap: true,
                                            itemCount:
                                                returnCardSetAsMap()['cards']
                                                    .length,
                                            itemBuilder: (context, index) {
                                              var item =
                                                  returnCardSetAsMap()['cards']
                                                      [index];
                                              return Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Slidable(
                                                    key: UniqueKey(),
                                                    startActionPane: ActionPane(
                                                        extentRatio: 1 / 2,
                                                        motion: ScrollMotion(),
                                                        children: [
                                                          SlidableAction(
                                                              label: isDone(
                                                                      index)
                                                                  ? 'Mark As Undone'
                                                                  : 'Mark As Done',
                                                              icon: isDone(
                                                                      index)
                                                                  ? Icons
                                                                      .mark_as_unread_rounded
                                                                  : Icons.done,
                                                              foregroundColor:
                                                                  blueMediumLight,
                                                              onPressed:
                                                                  (context) {
                                                                if (isDone(
                                                                    index)) {
                                                                  markAsUndone(
                                                                      index);
                                                                } else {
                                                                  markAsDone(
                                                                      index);
                                                                }
                                                              }),
                                                        ]),
                                                    endActionPane: ActionPane(
                                                        extentRatio: 1 / 2,
                                                        motion: ScrollMotion(),
                                                        dismissible:
                                                            DismissiblePane(
                                                          onDismissed: () {
                                                            removeCard(index);
                                                          },
                                                        ),
                                                        children: [
                                                          SlidableAction(
                                                              label: 'Delete',
                                                              foregroundColor:
                                                                  Colors.white,
                                                              backgroundColor:
                                                                  Colors.red,
                                                              onPressed:
                                                                  (context) {
                                                                removeCard(
                                                                    index);
                                                              }),
                                                        ]),
                                                    child: Container(
                                                      constraints:
                                                          BoxConstraints(
                                                              minHeight: 30),
                                                      margin:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 10,
                                                              vertical: 5),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Expanded(
                                                            child: AutoSizeText(
                                                              '${index + 1}.${item['word']}',
                                                              maxLines: 2,
                                                              style: TextStyle(
                                                                  color:
                                                                      blueDark,
                                                                  fontFamily:
                                                                      'Roboto',
                                                                  fontSize: 15,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width: 7,
                                                          ),
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .end,
                                                              children: [
                                                                AutoSizeText(
                                                                  '${item['exp']}',
                                                                  maxLines: 2,
                                                                  textAlign:
                                                                      TextAlign
                                                                          .right,
                                                                  style: TextStyle(
                                                                      color:
                                                                          blueDark,
                                                                      fontFamily:
                                                                          'Roboto',
                                                                      fontSize:
                                                                          15,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            });
                                      }),
                                ),
                              ],
                            ),
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 10,
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    flex: 4,
                                    child: GestureDetector(
                                      onTap: () {
                                        //If there isn't any card created, show snack bar
                                        if (returnCardSetAsMap()['cards']
                                            .isEmpty) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                                  duration:
                                                      Duration(seconds: 2),
                                                  backgroundColor:
                                                      blueMediumLight,
                                                  content: Text(
                                                      'Create some cards to shuffle')));

                                          //if returnUndones are empty show snackbar
                                        } else if (returnUndones().isEmpty) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                                  duration:
                                                      Duration(seconds: 2),
                                                  backgroundColor:
                                                      blueMediumLight,
                                                  content: Text(
                                                      'All cards are marked as Done')));
                                        } else {
                                          Navigator.pushNamed(context, '/game',
                                              arguments: {
                                                'categoryid': categoryID,
                                                'cardsetid': cardsetID
                                              });
                                        }
                                      },
                                      child: Container(
                                        height: 55,
                                        margin: EdgeInsets.only(right: 5),
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(10),
                                                topRight: Radius.circular(10),
                                                bottomLeft: Radius.circular(10),
                                                bottomRight:
                                                    Radius.circular(10)),
                                            color: blueMediumLight,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey
                                                    .withOpacity(0.5),
                                                spreadRadius: -5,
                                                blurRadius: 7,
                                                offset: Offset(0,
                                                    3), // changes position of shadow
                                              ),
                                            ]),
                                        child: Center(
                                          child: Text(
                                            'Shuffle',
                                            style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w800,
                                                color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: FloatingActionButton(
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(15))),
                                      onPressed: () {
                                        showBottomSheet(
                                            context: context,
                                            builder: (context) {
                                              return GestureDetector(
                                                onTap: () {
                                                  FocusManager
                                                      .instance.primaryFocus!
                                                      .nextFocus();
                                                },
                                                child: Container(
                                                  color: blueMediumLight,
                                                  height: 180,
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: [
                                                      Container(
                                                        margin: EdgeInsets
                                                            .symmetric(
                                                                horizontal: 5),
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          50)),
                                                          color: Colors.white,
                                                          backgroundBlendMode:
                                                              BlendMode.overlay,
                                                        ),
                                                        child: TextField(
                                                          controller:
                                                              wordContoller,
                                                          decoration: InputDecoration(
                                                              hintText:
                                                                  'Enter word',
                                                              hintStyle:
                                                                  TextStyle(
                                                                      fontSize:
                                                                          18),
                                                              contentPadding:
                                                                  EdgeInsets.only(
                                                                      left:
                                                                          15)),
                                                        ),
                                                      ),
                                                      Container(
                                                        margin: EdgeInsets
                                                            .symmetric(
                                                                horizontal: 5),
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            50)),
                                                            color:
                                                                Colors.white),
                                                        child: TextField(
                                                          maxLines: null,
                                                          controller:
                                                              expContoller,
                                                          decoration: InputDecoration(
                                                              hintText:
                                                                  'Enter explanation',
                                                              hintStyle:
                                                                  TextStyle(
                                                                      fontSize:
                                                                          18),
                                                              contentPadding:
                                                                  EdgeInsets.only(
                                                                      left:
                                                                          15)),
                                                        ),
                                                      ),
                                                      GestureDetector(
                                                        onTap: () {
                                                          setState(() {
                                                            createCard();
                                                            Navigator.pop(
                                                                context);
                                                          });
                                                        },
                                                        child: Container(
                                                            decoration: BoxDecoration(
                                                                borderRadius: BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            12)),
                                                                color: Colors
                                                                    .white),
                                                            child: Container(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width -
                                                                  20,
                                                              height: 50,
                                                              child: Center(
                                                                  child: Text(
                                                                'Save',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        20),
                                                              )),
                                                            )),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              );
                                            });
                                      },
                                      backgroundColor: blueMediumLight,
                                      foregroundColor: blueMediumLight,
                                      child: Icon(
                                        Icons.add,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  returnCategoryAsMap() {
    for (Map d in categories) {
      if (d['id'] == categoryID) {
        return d;
      }
    }
  }

  returnCardSetAsMap() {
    Map cardSet = {};
    for (Map d in returnCategoryAsMap()['cardsets']) {
      if (d['id'] == cardsetID) {
        cardSet = d;
      }
    }
    return cardSet;
  }

  formatDate(String date) {
    DateTime dateTime = DateTime.parse(date);
    String formattedDate = DateFormat('MM/dd').format(dateTime);
    return formattedDate;
  }

  void createCard() async {
    List tempList = [];
    final _prefs = SharedPreferences.getInstance();
    SharedPreferences prefs = await _prefs;

    tempList = json.decode(prefs.getString('categories').toString());
    tempList.forEach((element) {
      if (element['id'] == categoryID) {
        element['cardsets'].forEach((element) {
          if (element['id'] == cardsetID) {
            element['cards'].add({
              'status': 'null',
              'id': uuid.v4(),
              'word': wordContoller.text,
              'exp': expContoller.text,
            });
          }
        });
      }
    });
    setState(() {
      prefs.setString('categories', json.encode(tempList));
    });
  }

  removeCard(int index) async {
    List tempList = [];
    final _prefs = SharedPreferences.getInstance();
    SharedPreferences prefs = await _prefs;

    tempList = json.decode(prefs.getString('categories').toString());
    tempList.forEach((element) {
      if (element['id'] == categoryID) {
        element['cardsets'].forEach((element) {
          if (element['id'] == cardsetID) {
            element['cards'].removeAt(index);
          }
        });
      }
    });
    setState(() {
      prefs.setString('categories', json.encode(tempList));
      returnCardSetAsMap();
    });
  }

  void markAsDone(int index) async {
    final _prefs = SharedPreferences.getInstance();
    SharedPreferences prefs = await _prefs;
    List tempList = json.decode(prefs.getString('categories').toString());

    //Set status as 'done'
    for (var element in tempList) {
      if (element['id'] == categoryID) {
        element['cardsets'].forEach((element) {
          if (element['id'] == cardsetID) {
            element['cards'].forEach((element) {
              if (element['id'] == returnCardSetAsMap()['cards'][index]['id']) {
                element['status'] = 'done';
              }
            });
          }
        });
      }
    }
    print('Mark As Done\Temporary List: $tempList');
    //overwrite sharedprefs
    setState(() {
      prefs.setString('categories', json.encode(tempList));
    });
  }

  void markAsUndone(int index) async {
    final _prefs = SharedPreferences.getInstance();
    SharedPreferences prefs = await _prefs;
    List tempList = json.decode(prefs.getString('categories').toString());

    //Set status as 'undone'
    for (var element in tempList) {
      if (element['id'] == categoryID) {
        element['cardsets'].forEach((element) {
          if (element['id'] == cardsetID) {
            element['cards'].forEach((element) {
              if (element['id'] == returnCardSetAsMap()['cards'][index]['id']) {
                element['status'] = 'undone';
              }
            });
          }
        });
      }
    }
    print('Mark As Undone\Temporary List: $tempList');
    //overwrite sharedprefs
    setState(() {
      prefs.setString('categories', json.encode(tempList));
    });
  }

  bool isDone(int index) {
    String status = returnCardSetAsMap()['cards'][index]['status'];
    bool isDone = status == 'done' ? true : false;
    print('Status: $status | isDone: $isDone');
    return isDone;
  }

  returnUndones() {
    List tempList = [];
    for (Map e in returnCardSetAsMap()['cards']) {
      if (e['status'] != 'done') {
        tempList.add(e);
      }
    }
    return tempList;
  }
}

class WordDivider extends StatelessWidget {
  const WordDivider({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Divider(
      color: blueMediumLight,
      thickness: 3,
    );
  }
}
