import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flipcard/words_screen.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'res/colors.dart';
import 'res/category_creation.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({Key? key}) : super(key: key);

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)!.settings.arguments as Map;
    categoryID = arguments['id'];
    print(categoryID);
    setState(() {
      setSharedPrefs();
    });
    return MaterialApp(
        routes: {
          '/words': (context) => const WordsScreen(),
        },
        home: Scaffold(
            backgroundColor: Colors.transparent, body: CategoryMain()));
  }
}

final cardsetContoller = TextEditingController();
var uuid = Uuid();

class CategoryMain extends StatefulWidget {
  const CategoryMain({Key? key}) : super(key: key);

  @override
  State<CategoryMain> createState() => _CategoryMainState();
}

class _CategoryMainState extends State<CategoryMain> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: setSharedPrefs(),
        builder: (BuildContext context, AsyncSnapshot) {
          return Container(
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [backgroundDark, backgroundLight])),
            child: SafeArea(
              child: Container(
                margin: EdgeInsets.all(15),
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  color: Colors.white,
                  backgroundBlendMode: BlendMode.overlay,
                ),
                child: Scaffold(
                  backgroundColor: Colors.transparent,
                  body: Stack(
                    children: [
                      Column(
                        children: [
                          //Categories
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
                              //Date
                              Expanded(
                                flex: 0,
                                child: Text(
                                  formatDate((returnCategoryAsMap() as Map)['date'])
                                      .toString(),
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Roboto',
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900),
                                ),
                              )
                            ],
                          ),
                          GridView.builder(
                              shrinkWrap: true,
                              gridDelegate:
                                  const SliverGridDelegateWithMaxCrossAxisExtent(
                                      maxCrossAxisExtent: 200,
                                      childAspectRatio: 3 / 2,
                                      crossAxisSpacing: 20,
                                      mainAxisSpacing: 20),
                              itemCount: returnCardsets().length,
                              itemBuilder: (BuildContext context, index) {
                                String name = returnCardSetAsMap(
                                    index)['name']; //Cardset Name
                                return Dismissible(
                                  key: UniqueKey(),
                                  onDismissed: (e) {
                                    deleteCardSet(index);
                                  },
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.of(context,rootNavigator: true)
                                          .pushNamed('/words', arguments: {
                                        'categoryname': categoryID,
                                        'cardsetname': name,
                                        'cardsetid':
                                            returnCardSetAsMap(index)['id'],
                                      });
                                    },
                                    child: Container(
                                      height: 80,
                                      margin: EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.all(Radius.circular(12)),
                                        color: Colors.white,
                                        backgroundBlendMode: BlendMode.overlay,
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                              margin: EdgeInsets.all(10),
                                              child: Center(
                                                child: AutoSizeText(
                                                  name,
                                                  maxLines: 2,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    color: blueDark,
                                                    fontFamily: 'Roboto',
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                                ),
                                              )),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }),
                        ],
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: FloatingActionButton(
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Container(
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 5),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(50)),
                                          color: Colors.white),
                                      child: TextField(
                                        controller: cardsetContoller,
                                        decoration: InputDecoration(
                                            hintText: 'Enter cardset name',
                                            hintStyle: TextStyle(fontSize: 18),
                                            contentPadding:
                                                EdgeInsets.only(left: 15)),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          createCardSet();
                                          Navigator.pop(context);
                                        });
                                      },
                                      child: Container(
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(12)),
                                              color: Colors.white),
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width -
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
                  ),)
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  List returnCardsets() {
    List result = [];
    for (Map d in categories) {
      if (d['id'] == categoryID) {
        result = d['cardsets'] as List;
      }
    }
    return result;
  }

  returnCategoryAsMap() {
    for (Map d in categories) {
      if (d['id'] == categoryID) {
        return d;
      }
    }
  }

  returnCardSetAsMap(int index) {
    return returnCategoryAsMap()['cardsets'][index];
  }

  formatDate(String date) {
    DateTime dateTime = DateTime.parse(date);
    String formattedDate = DateFormat('MM/dd').format(dateTime);
    return formattedDate;
  }

  Future<dynamic> deleteCardSet(int index) async {
    List tempList = [];
    final _prefs = await SharedPreferences.getInstance();
    SharedPreferences prefs = await _prefs;
    //Transfer _prefs to tempList
    tempList = json.decode(prefs.getString('categories').toString());
    print('Before Deleting \n $tempList');
    //Delete category from tempList
    print('After Deleting \n $tempList');
    tempList.forEach((element) {
      if (element['id'] == categoryID) {
        (element['cardsets'] as List).removeAt(index);
      }
    });
    //Overwrite tempList to _prefs
    setState(() {
      prefs.setString('categories', json.encode(tempList));
    });
  }

  void createCardSet() async {
    final _prefs = SharedPreferences.getInstance();
    SharedPreferences prefs = await _prefs;
    List tempList = json.decode(prefs.getString('categories').toString());
    //Add name, id, date and cards[] to new Cardset
    for (Map d in tempList) {
      if (d['id'] == categoryID) {
        d['cardsets'].add({
          'name': cardsetContoller.text.toString(),
          'id': uuid.v4(),
          'date': DateTime.now().toString(),
          'cards': [],
        });
      }
    }
    prefs.setString('categories', json.encode(tempList).toString());
  }
}
