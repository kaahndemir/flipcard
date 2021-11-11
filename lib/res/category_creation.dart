import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';


List data = [
  {'name': 'Entrepreneurship',
    'id': '8456',
    'date': '2021-11-09 20:17:09.102',
    'cardsets': [
      {'name': 'Business Model',
        'date': '2021-12-09 20:17:09.102',
        'id': '4651',
        'cards': [
          {'id': '8789','word': 'Key Partners', 'exp': 'Who you are going to cooperate with'},
          {'id': '8789','word': 'Value Propositions', 'exp': 'Who you are going to cooperate with'},
        ]
      }
    ]
  },
];

List categories = [];

Future<List> setSharedPrefs() async{
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  SharedPreferences prefs = await _prefs;
  var encodedMap = json.encode(data);
  //Set shared preferences if doesn't containg any data
  if(!prefs.containsKey('categories')){
    prefs.setString('categories', encodedMap);
  } else {
    categories = json.decode(prefs.getString('categories').toString());
  }
  print('setSharedPreferences() $categories');
  return categories;
}