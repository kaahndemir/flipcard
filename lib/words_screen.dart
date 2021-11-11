import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:informative_cards/category_screen.dart';
import 'package:informative_cards/res/category_creation.dart';
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
      home: Scaffold(
        backgroundColor: Colors.transparent,
        body: CardsScreen()));
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
    return FutureBuilder(
      future: setSharedPrefs(),
      builder: (BuildContext, AsyncSnapshot) {
        return Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    backgroundLight,
                    backgroundDark,
                  ],
                  )
                  ),
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
                floatingActionButton: FloatingActionButton(
                  onPressed: () {
                    showBottomSheet(
                        context: context,
                        builder: (context) {
                          return GestureDetector(
                            onTap: () {
                              FocusManager.instance.primaryFocus!.nextFocus();
                            },
                            child: Container(
                              color: blueMediumLight,
                              height: 180,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Container(
                                    margin: EdgeInsets.symmetric(horizontal: 5),
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.all(Radius.circular(50)),
                                        color: Colors.white),
                                    child: TextField(
                                      controller: wordContoller,
                                      decoration: InputDecoration(
                                          hintText: 'Enter word',
                                          hintStyle: TextStyle(fontSize: 18),
                                          contentPadding:
                                              EdgeInsets.only(left: 15)),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.symmetric(horizontal: 5),
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.all(Radius.circular(50)),
                                        color: Colors.white),
                                    child: TextField(
                                      maxLines: null,
                                      controller: expContoller,
                                      decoration: InputDecoration(
                                          hintText: 'Enter explanation',
                                          hintStyle: TextStyle(fontSize: 18),
                                          contentPadding:
                                              EdgeInsets.only(left: 15)),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        createCard();
                                        Navigator.pop(context);
                                      });
                                    },
                                    child: Container(
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(12)),
                                            color: Colors.white),
                                        child: Container(
                                          width: MediaQuery.of(context).size.width -
                                              20,
                                          height: 50,
                                          child: Center(
                                              child: Text(
                                            'Save',
                                            style: TextStyle(fontSize: 20),
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
                body: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        //Category name
                        Text(
                          returnCategoryAsMap()['name'],
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Roboto',
                              fontSize: 24,
                              fontWeight: FontWeight.w800),
                        ),
                        //Date
                        Text(
                          'Date created: ${formatDate((returnCategoryAsMap() as Map)['date']).toString()}',
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Roboto',
                              fontSize: 15,
                              fontWeight: FontWeight.w900),
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
                        child: Column(
                          children: [
                            Container(
                              margin: EdgeInsets.only(top: 5, bottom: 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    returnCardSetAsMap()['name'].toString(),
                                    style: TextStyle(
                                        color: backgroundDark,
                                        fontFamily: 'Roboto',
                                        fontSize: 22,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  Text(
                                    'Date created: ${formatDate(returnCardSetAsMap()['date'].toString())}',
                                    style: TextStyle(
                                        color: backgroundDark,
                                        fontFamily: 'Roboto',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                                child: ListView.builder(
                                    itemCount: returnCardSetAsMap()['cards'].length,
                                    itemBuilder: (context, index) {
                                      var item =
                                          returnCardSetAsMap()['cards'][index];
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          WordDivider(),
                                          Dismissible(
                                            key: UniqueKey(),
                                            onDismissed: (direction) {
                                              //Remove Map from categories
                                              removeCard(index);
                                            },
                                            child: Container(
                                              margin: EdgeInsets.symmetric(
                                                  horizontal: 10, vertical: 5),
                                              child: Text(
                                                item['word'],
                                                style: TextStyle(
                                                    color: blueDark,
                                                    fontFamily: 'Roboto',
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.w500),
                                              ),
                                            ),
                                          ),
                                          WordDivider(),
                                        ],
                                      );
                                    })),
                          ],
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

  void createCard() async{
    List tempList = [];
    final _prefs = SharedPreferences.getInstance();
    SharedPreferences prefs = await _prefs;
    
    tempList = json.decode(prefs.getString('categories').toString());
    tempList.forEach((element) {
      if(element['id'] == categoryID){
        
        element['cardsets'].forEach((element){
          if(element['id'] == cardsetID){
            element['cards'].add(
              {
                'id': uuid.v4(),
                'word': wordContoller.text,
                'exp': expContoller.text,
              }
            );
          }
        });
        
      }
    });
    setState(() {
      prefs.setString('categories', json.encode(tempList));
    });
  }

  void removeCard(int index) async{
     List tempList = [];
    final _prefs = SharedPreferences.getInstance();
    SharedPreferences prefs = await _prefs;
    
    tempList = json.decode(prefs.getString('categories').toString());
    tempList.forEach((element) {
      if(element['id'] == categoryID){
        
        element['cardsets'].forEach((element){
          if(element['id'] == cardsetID){
            element['cards'].removeAt(index);
          }
        });
        
      }
    });
    setState(() {
      prefs.setString('categories', json.encode(tempList));
    });
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
