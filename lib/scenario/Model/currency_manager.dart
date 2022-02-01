import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:street_designer/main.dart';

import 'package:street_designer/scenario/Model/option_image.dart';
import 'package:street_designer/scenario/scenario.dart';

import 'option.dart';
import 'lane_manager.dart';

//PLAYER STATS TO LATER GET FROM SAVE DATA
const playerStartingCurrency = 750;

class CurrencyManager with ChangeNotifier {
  static final CurrencyManager _currencymanager = CurrencyManager._internal();

  DocumentSnapshot? user;
  CollectionReference? designs;
  int? designCount;

  //initial values
  int _used = 0;
  int _remaining = playerStartingCurrency;
  Map<LaneManager, List<Option>> chosenOptions = {};
  Map<LaneManager, int> perLaneCosts = {};

  int get used => _used;
  int get remaining => _remaining;

  List<Map<String, dynamic>> getOptionImagesJSON() {
    List<Map<String, dynamic>> tempJSON = [];

    Map<String, int> choices = {};

    for (List<Option> optionList in chosenOptions.values) {
      for (Option option in optionList) {
        for (OptionImage image in option.images) {
          if (image.enabled ?? false) {
            tempJSON.add(image.toJson());
            choices[image.imagePath] = image.layer;
          }
        }
      }
    }

    for (Option option in staticOptions) {
      for (OptionImage image in option.images) {
        tempJSON.add(image.toJson());
        choices[image.imagePath] = image.layer;
      }
    }

    //designs!.add(choices);

    return tempJSON;
  }

  void addOption(Option option) {
    if (option.parentFeature != null) {
      LaneManager laneManager =
          option.parentFeature!.choiceManager!.laneManager!;

      if (!chosenOptions.containsKey(laneManager)) {
        chosenOptions[laneManager] = [];
      }

      if (!chosenOptions[laneManager]!.contains(option)) {
        chosenOptions[laneManager]!.add(option);
        updateCurrency(option.cost!, laneManager);
      }
    }
  }

  void removeOption(Option option) {
    if (option.parentFeature != null) {
      LaneManager laneManager =
          option.parentFeature!.choiceManager!.laneManager!;
      if (chosenOptions.containsKey(laneManager)) {
        if (chosenOptions[laneManager]!.remove(option)) {
          updateCurrency(option.cost! * -1, laneManager);
        }
      }
    }
  }

  void updateCurrency(int amount, [LaneManager? laneManager]) {
    _used += amount;
    _remaining -= amount;
    if (laneManager != null) {
      if (!perLaneCosts.containsKey(laneManager)) {
        perLaneCosts[laneManager] = amount;
      } else {
        int x = perLaneCosts[laneManager]!;
        x += amount;
        perLaneCosts[laneManager] = x;
      }
    }

    notifyListeners();
  }

  static void getUser(CurrencyManager _currencymanager) async {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    _currencymanager.user = await users.doc(userID).get();
    _currencymanager.designs =
        _currencymanager.user!.reference.collection('designs');
    QuerySnapshot _myDoc = await _currencymanager.designs!.get();
    List myDocCount = _myDoc.docs;
    _currencymanager.designCount = myDocCount.length;
  }

  factory CurrencyManager() {
    getUser(_currencymanager);
    return _currencymanager;
  }

  CurrencyManager._internal();
}
