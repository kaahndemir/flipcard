import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:informative_cards/game_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'category_screen.dart';
import 'package:flutter/material.dart';
import 'res/category_creation.dart';
import 'res/colors.dart';
import 'words_screen.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(const Home());
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        bottomSheetTheme:
            BottomSheetThemeData(backgroundColor: Colors.black.withOpacity(0)),
      ),
      routes: {
        '/category': (context) => const CategoryScreen(),
        '/words': (context) => const WordsScreen(),
        
      },
      home: Scaffold(
        backgroundColor: Colors.transparent,
        body: Main(),
      ),
    );
  }
}

final categoryContoller = TextEditingController();

class Main extends StatefulWidget {
  const Main({
    Key? key,
  }) : super(key: key);

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {
  @override
  void initState() {
    super.initState();
    setSharedPrefs();
  }
  @override
  Widget build(BuildContext context) {
    setState(() {
      setSharedPrefs();
    });

    return FutureBuilder(
        future: setSharedPrefs(),
        builder: (BuildContext context, AsyncSnapshot) {
          return Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [backgroundLight, backgroundDark])),
                child: Scaffold(
                  backgroundColor: Colors.transparent,
                  appBar: AppBar(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10),bottomRight: Radius.circular(10))),
                    backgroundColor: backgroundDark,
                    shadowColor: Colors.transparent,
                    title: Text('FlipCard'),
                    actions: [
                      
                      SizedBox(width: 10,),
                      Icon(Icons.settings),
                      SizedBox(width: 15,),
                    ],
                    
                  ),
                  body: Stack(
                    children: [
                      Column(
                        children: [
                          //Categories
                          Expanded(
                              child: ListView.builder(
                                  itemCount: categories.length,
                                  itemBuilder: (BuildContext context, index) {
                                    Map category = categories[index];
                                    String name = category['name'];
                                    return Dismissible(
                                          key: UniqueKey(),
                                          onDismissed: (e) => deleteCategory(e, name),
                                          child: GestureDetector(
                                            onTap: () {
                                              print('Tapped on $index');
                                              Navigator.of(context,rootNavigator: true).pushNamed('/category',
                                                  arguments: {'id': categories[index]['id']});
                                            },
                                            child: Container(
                                              height: 70,
                                              margin: EdgeInsets.all(5),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(12)),
                                                color: Colors.white,
                                                backgroundBlendMode:
                                                    BlendMode.softLight,
                                              ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                      margin: EdgeInsets.only(left: 25),
                                                      child: AutoSizeText(
                                                        name,
                                                        maxLines: 2,
                                                        style: TextStyle(
                                                          fontSize: 22,
                                                          color: Colors.white,
                                                          fontFamily: 'Roboto',
                                                          fontWeight: FontWeight.w800,
                                                        ),
                                                      )),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      
                                  }))
                        ],
                      ),
                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: FloatingActionButton(
                          onPressed: () {
                            showBottomSheet(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                context: context,
                                builder: (context) {
                                  return GestureDetector(
                                    onTap: () {
                                      FocusManager.instance.primaryFocus!
                                          .nextFocus();
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: blueMediumLight,
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(15),
                                            topRight: Radius.circular(15)),
                                      ),
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
                                              controller: categoryContoller,
                                              decoration: InputDecoration(
                                                  hintText: 'Enter category name',
                                                  hintStyle:
                                                      TextStyle(fontSize: 18),
                                                  contentPadding:
                                                      EdgeInsets.only(left: 15)),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                writeDataToPrefs();
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
                        ),
                      )
                    ],
                  ),
                ),
              );
        });
  }

  writeDataToPrefs() async {
    var uuid = Uuid();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List tempMap = json.decode(prefs.getString('categories').toString());
    if (categoryContoller.text.isNotEmpty) {
      tempMap.add({
        'name': categoryContoller.text,
        'date': DateTime.now().toString(),
        'id': uuid.v1(),
        'cardsets': []
      });
      setState(() {
        prefs.setString('categories', json.encode(tempMap));
        //Clean textfield
        categoryContoller.text = '';
      });
      print(prefs.getString('categories'));
    }
  }

  deleteCategory(DismissDirection e, String name) async {
    List tempList = [];
    final _prefs = await SharedPreferences.getInstance();
    SharedPreferences prefs = await _prefs;
    //Transfer _prefs to tempList
    tempList = json.decode(prefs.getString('categories').toString());
    print('Before Deleting \n $tempList');
    //Delete category from tempList
    print('After Deleting \n $tempList');
    for (int i = 0; i < tempList.length; i++) {
      if (tempList[i]['name'] == name) {
        tempList.removeAt(i);
      }
    }
    //Overwrite tempList to _prefs
    setState(() {
      prefs.setString('categories', json.encode(tempList));
    });
  }

  Stream updateList() async*{
    setState(() {
      categories;
    });
  }

  
}
