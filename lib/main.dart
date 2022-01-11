import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:FlipCard/flipcard.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'cardbox.dart';
import 'package:flutter/material.dart';
import 'res/category_creation.dart';
import 'res/colors.dart';
import 'words_screen.dart';
import 'package:uuid/uuid.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
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
      scrollBehavior: MyBehavior(),
      title: 'FlipCard',
      theme: ThemeData(
        bottomSheetTheme:
            BottomSheetThemeData(backgroundColor: Colors.black.withOpacity(0)),
      ),
      routes: {
        '/category': (context) => const CardBoxScreen(),
        '/words': (context) => const WordsScreen(),
      },
      home: Scaffold(
        backgroundColor: Colors.transparent,
        body: Main(),
      ),
    );
  }
}

final categoryController = TextEditingController();
StreamController<int> streamcontroller = StreamController<int>();

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

    if (!streamcontroller.hasListener) {
      streamcontroller.stream.listen((e) {
        addSecureBoxes();
        setState(() {});
      });
    }
    setState(() {});

    WidgetsBinding.instance!.addPostFrameCallback((e){streamcontroller.add(0);});
  }

  List secureBoxes = [];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [backgroundLight, backgroundDark])),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10))),
          backgroundColor: backgroundDark,
          shadowColor: Colors.transparent,
          title: Text('FlipCard'),
          actions: [],
        ),
        body: Stack(
          children: [
            Column(
              children: [
                SizedBox(
                  height: 15,
                ),
                //CardBoxes
                Expanded(
                    child: ListView.builder(
                        itemCount: secureBoxes.length,
                        itemBuilder: (BuildContext context, index) {
                          Map cardBox = secureBoxes[index];
                          String name = cardBox['name'];
                          return Dismissible(
                            key: UniqueKey(),
                            onDismissed: (e) => deleteCategory(index),
                            child: GestureDetector(
                              onTap: () {
                                print('Tapped on $index');
                                Navigator.of(context, rootNavigator: true)
                                    .pushNamed('/category', arguments: {
                                  'id': secureBoxes[index]['id']
                                });
                              },
                              child: Container(
                                height: 63,
                                margin: EdgeInsets.only(
                                    left: 15, right: 15, bottom: 10),
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20)),
                                  color: Colors.white,
                                  backgroundBlendMode: BlendMode.softLight,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                        margin: EdgeInsets.only(left: 25),
                                        child: AutoSizeText(
                                          name,
                                          maxLines: 1,
                                          style: TextStyle(
                                            fontSize: 25,
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
                heroTag: 3,
                onPressed: () {
                  showBottomSheet(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      context: context,
                      builder: (context) {
                        return GestureDetector(
                          onTap: () {
                            FocusManager.instance.primaryFocus!.nextFocus();
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
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Container(
                                  margin: EdgeInsets.symmetric(horizontal: 5),
                                  decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(50)),
                                      color: Colors.white),
                                  child: TextField(
                                    controller: categoryController,
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: 'Enter category name',
                                        hintStyle: TextStyle(fontSize: 18),
                                        contentPadding:
                                            EdgeInsets.only(left: 15)),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      createCategory();
                                      Navigator.pop(context);
                                    });
                                  },
                                  child: Container(
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(12)),
                                          color: Colors.white),
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width -
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
  }

  createCategory() async {
    var uuid = Uuid();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String id = uuid.v1();
    Map value = {
      'name': categoryController.text,
      'date': DateTime.now().toString(),
      'status': 'sec',
      'tags': [],
      'id': id,
      'cards': []
    };
    if (categoryController.text.isNotEmpty) {
      setState(() {
        prefs.setString(id, json.encode(value));
        //Clear textfield
        categoryController.clear();
      });
    }
    streamcontroller.add(0);
  }

  deleteCategory(int index) async {
    final _prefs = await SharedPreferences.getInstance();
    SharedPreferences prefs = await _prefs;
    Map cardBox = secureBoxes[index];
    cardBox['status'] = 'del';
    await prefs.setString(cardBox['id'], json.encode(cardBox));
    await setSharedPrefs();
    streamcontroller.add(0);
  }

  addSecureBoxes() async {
    secureBoxes.clear();
    await setSharedPrefs();
    for (Map box in cardBoxes) {
      if (box['status'] == 'sec') {
        secureBoxes.add(box);
      }
    }
    print('SecureBoxes: $secureBoxes');

    return secureBoxes;
  }
}
