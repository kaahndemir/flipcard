import 'package:FlipCard/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

Map data = {
  'name': 'Business Model',
  'date': '2021-12-09 20:17:09.102',
  'id': '034cbcd0-68db-11ec-808a-67e737091d63',
  'status': 'sec',
  //'sec' means secure 
  //'del' means deleted
  'tags': [],
  'cards': [
    {
      'status': 'undone',
      //undone will be shown in the cardboxes and flipcard screen
      //done will be shown in the cardboxes screen
      //del will be shown in the trash screen
      'id': '8789',
      'term': 'Key Partners',
      'exp': 'Who you are going to cooperate with'
    },
    {
      'status': 'undone',
      'id': '8669',
      'term': 'Value Propositions',
      'exp': 'What benefits you offer to customer'
    },
    {
      'status': 'undone',
      'id': '8498',
      'term': 'Key Resources',
      'exp': 'What you have to accomplish your goal'
    },
    {
      'status': 'undone',
      'id': '1939',
      'term': 'Revenue Streams',
      'exp': 'Where the incomes come from'
    },
    {
      'status': 'undone',
      'id': '1899',
      'term': 'Customer Relationship',
      'exp': 'How you are going to communicate your customer'
    },
    {
      'status': 'undone',
      'id': '6542',
      'term': 'Cost Structure',
      'exp': 'What kind of outcomes you are going to have'
    },
  ]
};

List cardBoxes = [];
Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

late SharedPreferences prefs;

Future setSharedPrefs() async {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  prefs = await _prefs;
  var encodedMap = json.encode(data);
  //Set shared preferences if it's empty

  if (prefs.getKeys().length == 0) {
    prefs.setString('034cbcd0-68db-11ec-808a-67e737091d63', encodedMap);
  }

  cardBoxes = await getCardBoxes();

  

  print('setSharedPreferences() $cardBoxes');
  return cardBoxes;
}

List getCardBoxes() {
  List cardBoxes = [];
  List keys = prefs.getKeys().toList();
  for (int i = 0; i < prefs.getKeys().length;i++) {
    cardBoxes.add(json.decode(prefs.getString(keys[i]).toString()) as Map);
  }
  return cardBoxes;
}
