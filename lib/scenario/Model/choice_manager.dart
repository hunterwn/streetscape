import 'package:flutter/material.dart';

import '../widgets/expandablelistview.dart';
import 'image_manager.dart';
import '../widgets/options_view.dart';
import '../functions.dart';

import 'lane_manager.dart';
import 'option_image.dart';
import 'option.dart';
import 'feature.dart';
import 'currency_manager.dart';

const int numLanes = 5;

//PLAYER STATS TO LATER GET FROM SAVE DATA
const playerStartingCurrency = 750;

class LaneStates {
  static int defaultState = 0;
  static int shiftedState = 1;
  static int limitedWidth = 2;
}

class LaneNames {
  static String lane1 = "Lane 1";
  static String lane2 = "Lane 2";
  static String lane3 = "Lane 3";
  static String lane4 = "Lane 4";
  static String lane5 = "Lane 5";
  static String crosswalk = "Crosswalk";
  static String buildings = "Buildings";
}

class LaneTypeNames {
  static String busLane = "Bus Lane";
  static String parking = "On-Street Parking";
  static String bikeLane = "Bike Lane";
  static String sidewalk = "Sidewalk";
  static String buildings = "Sidewalk";
  static String crosswalk = "Crosswalk";
  static String median = "Median";
}

class ChoiceManager with ChangeNotifier {
  String? title;
  List<Feature>? features;
  List<Feature>? defaultFeatures;
  List<Feature>? altFeatures;
  ImageLayerManager? layerManager;
  CurrencyManager currencyManager = CurrencyManager();
  LaneManager? laneManager;
  bool enabled = false;
  bool altState = false;
  Function? onEnable;
  Function? onDisable;
  var currentState = LaneStates.defaultState;
  bool defaultEnabled = false;

  void addAllOptions(List<Feature> features) {
    List<Option> optionsToAdd = [];
    for (Feature feature in features) {
      optionsToAdd.addAll(feature.options!);
    }
    layerManager!.add(optionsToAdd);
  }

  void removeAllOptions(List<Feature> features) {
    List<Option> optionsToRemove = [];
    for (Feature feature in features) {
      optionsToRemove.addAll(feature.options!);
    }
    layerManager!.remove(optionsToRemove);
  }

  void setFeatures(List<Feature> newFeatures) {
    for (int i = 0; i < features!.length; i++) {
      newFeatures[i].selected = features![i].selected;
      if (features![i].enabled) {
        features![i].disable();
        newFeatures[i].enable();
      }
    }
    features = newFeatures;
    layerManager!.updateAll();
  }

  void setImageState(var state) {
    if (currentState != state) {
      currentState = state;
      for (Feature feature in features!) {
        for (Option option in feature.options!) {
          if (option.enabled) {
            option.disable();
            option.swapImages(state);
            option.enable();
          } else {
            option.swapImages(state);
          }
        }
      }
      layerManager!.updateAll();
    }
  }

  void setAlternate() {
    if (!altState) {
      altState = true;
      setFeatures(altFeatures!);
    }
  }

  void setDefault() {
    if (altState) {
      altState = false;
      setFeatures(defaultFeatures!);
    }
  }

  int getChoice(int row) {
    return (features != null) ? features![row].selected : 0;
  }

  void setLocked(bool val, [String? message]) {
    for (Feature feature in features!) {
      feature.setLocked(val, message);
    }
  }

  void update() {
    if (currentState != laneManager!.currentState) {
      setImageState(laneManager!.currentState);
    }
  }

  void setChoice(int row, int selectedIndex) {
    Feature feature = features![row];
    Option newOption = feature.options![selectedIndex];

    if (newOption.locked) {
      return;
    }

    if (!enabled) {
      enable();
    }

    update();

    //If a new lane type is clicked, redirect selection to that ChoiceManager
    if (laneManager!.currentLaneType != this) {
      laneManager!.currentLaneType?.disable();
      laneManager!.setType(this);
      layerManager!.updateAll();
      laneManager!.setChoice(row, selectedIndex);
      return;
    }

    //first time a feature is tapped
    if (feature.selected == -1) {
      feature.selected = selectedIndex;
      feature.enable();
      List<Option> toUpdate = [newOption];
      //check for any features that should be enabled by default
      for (int i = 0; i < features!.length; i++) {
        if (features![i].defaultEnabled != null &&
            i != row &&
            features![i].enabled == false) {
          features![i].enableDefault();
          toUpdate.add(features![i].options![features![i].defaultEnabled!]);
        }
      }
      layerManager!.update(toUpdate);
    }
    //already selected option is tapped again
    else if (feature.selected == selectedIndex) {
      Option oldOption = feature.options![feature.selected];
      if (oldOption.type == OptionTypes.extra.index) {
        //extra options leave feature enabled when they're disabled
        oldOption.disable();
        feature.disable();
        layerManager!.update([oldOption]);
      } else if (oldOption.type != OptionTypes.noDisable.index) {
        //required options disable the entire feature when they're disabled
        List<Option> toUpdate = [];
        for (Feature f in features!) {
          if (f.enabled) {
            toUpdate.add(f.options![f.selected]);
            f.disable();
          }
        }
        layerManager!.update(toUpdate);
        laneManager!.disable();
      }
    }
    //a new option is selected
    else {
      Option oldOption = feature.options![feature.selected];
      feature.selected = selectedIndex;
      oldOption.disable();
      newOption.enable();
      layerManager!.update([oldOption, newOption]);
    }

    setLockedByCost(currencyManager.remaining);
    notifyListeners();
  }

  void enable() {
    enabled = true;

    update();

    if (onEnable != null) {
      onEnable!();
    }
  }

  void disable() {
    enabled = false;
    for (Feature feature in features!) {
      feature.disable();
    }
    if (onDisable != null) {
      onDisable!();
    }
    notifyListeners();
  }

  void notify() {
    notifyListeners();
  }

  ChoiceManager(List<Feature> featuresList, String title_,
      [Function? onEnable,
      Function? onDisable,
      bool? defaultEnabled_,
      bool? unDisableable]) {
    title = title_;
    defaultEnabled = defaultEnabled_ ?? false;
    layerManager = ImageLayerManager();
    addAllOptions(featuresList);
    features = featuresList;
    for (Feature feature in features!) {
      if (unDisableable ?? false) {
        for (Option option in feature.options!) {
          option.type = OptionTypes.noDisable.index;
        }
      }
      feature.choiceManager = this;
    }
    if (onEnable != null) {
      this.onEnable = onEnable;
    }
    if (onDisable != null) {
      this.onDisable = onDisable;
    }
  }
}

Map<String, LaneManager> laneTypeManagers = {
  LaneNames.lane1: LaneManager([
    ChoiceManager([
      Feature([
        Option([
          [
            OptionImage(layer: 2, imagePath: 'assets/bikelane_outer_L.png'),
            OptionImage(
                layer: 5, imagePath: 'assets/cyclist_frontfacing_outer.png')
          ]
        ], 'assets/bikelane_preview.png'),
        Option([
          [
            OptionImage(
                layer: 2, imagePath: 'assets/bikelane_outer_green_L.png'),
            OptionImage(
                layer: 5, imagePath: 'assets/cyclist_frontfacing_outer.png')
          ]
        ], 'assets/bikelane_green_preview.png')
      ]),
    ], "Bike Lane", BikeLane.onEnableOuterL, BikeLane.onDisableOuterL),
    ChoiceManager([
      //Bus Lane paint type
      Feature([
        Option([
          [
            OptionImage(layer: 2, imagePath: 'assets/buslane_outer_L.png'),
            OptionImage(layer: 5, imagePath: 'assets/Bus_outer_L.png')
          ]
        ], 'assets/buslane_preview.png', 100, OptionTypes.wide.index),
        Option([
          [
            OptionImage(layer: 2, imagePath: 'assets/buslane_outer_red_L.png'),
            OptionImage(layer: 5, imagePath: 'assets/Bus_outer_L.png')
          ]
        ], 'assets/buslane_red_preview.png', 100, OptionTypes.wide.index)
      ], 0),
    ], "Bus Lane", BusLane.onEnableOuterL, BusLane.onDisableOuterL),
    ChoiceManager([
      //type of parking
      Feature([
        Option([
          [
            OptionImage(
                layer: 3, imagePath: 'assets/parking_parallel_outer_L.png'),
            OptionImage(
                layer: 6, imagePath: 'assets/white_volvo_parallel_outer_L.png')
          ]
        ], 'assets/parking_parallel_preview.png'),
        Option([
          [
            OptionImage(layer: 3, imagePath: 'assets/parking_diagonal_L.png'),
            OptionImage(
                layer: 6, imagePath: 'assets/white_volvo_diagonal_L.png'),
          ]
        ], 'assets/parking_diagonal_preview.png', 100, OptionTypes.wide.index,
            DiagonalParking.onEnableOuterL, DiagonalParking.onDisableOuterL)
      ]),
    ], "On-Street Parking", Parking.onEnableOuterL, Parking.onDisableOuterL),
    ChoiceManager([
      Feature([
        Option([
          [OptionImage(layer: 4, imagePath: 'assets/sidewalk_extension_L.png')]
        ], 'assets/sidewalk_extension_L.png'),
      ], 0),
      Feature([
        Option([
          [
            OptionImage(layer: 7, imagePath: 'assets/trees_near_L.png'),
            OptionImage(layer: 5, imagePath: 'assets/trees_far_L.png')
          ],
        ], 'assets/trees_near_L.png', 100, OptionTypes.extra.index),
      ]),
    ], "Sidewalk", Sidewalk.onEnableL, Sidewalk.onDisableL),
  ], Lane1.onEnable, Lane1.onDisable),
  LaneNames.lane2: LaneManager([
    ChoiceManager([
      //Bike lane paint type
      Feature([
        Option([
          [
            OptionImage(layer: 2, imagePath: 'assets/bikelane_mid_L.png'),
            OptionImage(
                layer: 5, imagePath: 'assets/cyclist_frontfacing_mid.png')
          ],
          [
            OptionImage(layer: 2, imagePath: 'assets/bikelane_inner_L.png'),
            OptionImage(
                layer: 5, imagePath: 'assets/cyclist_frontfacing_inner.png')
          ],
        ], 'assets/bikelane_preview.png'),
        Option([
          [
            OptionImage(layer: 2, imagePath: 'assets/bikelane_mid_green_L.png'),
            OptionImage(
                layer: 5, imagePath: 'assets/cyclist_frontfacing_mid.png')
          ],
          [
            OptionImage(
                layer: 2, imagePath: 'assets/bikelane_inner_green_L.png'),
            OptionImage(
                layer: 5, imagePath: 'assets/cyclist_frontfacing_inner.png')
          ]
        ], 'assets/bikelane_green_preview.png')
      ]),
    ], "Bike Lane", BikeLane.onEnableInnerL, BikeLane.onDisableInnerL),
    ChoiceManager([
      //Bus Lane paint type
      Feature([
        Option([
          [
            OptionImage(layer: 2, imagePath: 'assets/buslane_inner_L.png'),
            OptionImage(layer: 5, imagePath: 'assets/Bus_inner_L.png')
          ]
        ], 'assets/buslane_preview.png', 100, OptionTypes.wide.index),
        Option([
          [
            OptionImage(layer: 2, imagePath: 'assets/buslane_inner_red_L.png'),
            OptionImage(layer: 5, imagePath: 'assets/Bus_inner_L.png')
          ]
        ], 'assets/buslane_red_preview.png', 100, OptionTypes.wide.index)
      ], 0),
    ], "Bus Lane", BusLane.onEnableInnerL, BusLane.onDisableInnerL),
    ChoiceManager([
      Feature([
        Option([
          [
            OptionImage(
                layer: 3, imagePath: 'assets/parking_parallel_mid_L.png'),
            OptionImage(
                layer: 6, imagePath: 'assets/white_volvo_parallel_mid_L.png')
          ],
          [
            OptionImage(
                layer: 3, imagePath: 'assets/parking_parallel_inner_L.png'),
            OptionImage(
                layer: 6, imagePath: 'assets/white_volvo_parallel_inner_L.png')
          ]
        ], 'assets/parking_parallel_preview.png'),
        Option([
          [
            OptionImage(
                layer: 3, imagePath: 'assets/parking_diagonal_inner_L.png'),
            OptionImage(
                layer: 6, imagePath: 'assets/white_volvo_diagonal_inner_L.png'),
          ]
        ], 'assets/parking_diagonal_preview.png', 100, OptionTypes.wide.index,
            DiagonalParking.onEnableInnerL, DiagonalParking.onDisableInnerL)
      ]),
    ], "On-Street Parking", Parking.onEnableInnerL, Parking.onDisableInnerL),
  ], Lane2.onEnable, Lane2.onDisable),
  LaneNames.lane3: LaneManager([
    ChoiceManager([
      Feature([
        Option([
          [OptionImage(layer: 2, imagePath: 'assets/median_yellowlines.png')]
        ], 'assets/median_yellowlines_preview.png'),
        Option([
          [OptionImage(layer: 2, imagePath: 'assets/median_concrete.png')]
        ], 'assets/median_concrete_preview.png')
      ]),
    ], "Median", null, null, true, true),
  ], Lane3.onEnable, Lane3.onDisable),
  LaneNames.lane4: LaneManager([
    ChoiceManager([
      //Bike lane paint type
      Feature([
        Option([
          [
            OptionImage(layer: 2, imagePath: 'assets/bikelane_mid_R.png'),
            OptionImage(
                layer: 5, imagePath: 'assets/cyclist_rearfacing_mid.png')
          ],
          [
            OptionImage(layer: 2, imagePath: 'assets/bikelane_inner_R.png'),
            OptionImage(
                layer: 5, imagePath: 'assets/cyclist_rearfacing_inner.png')
          ],
        ], 'assets/bikelane_preview.png'),
        Option([
          [
            OptionImage(layer: 2, imagePath: 'assets/bikelane_mid_green_R.png'),
            OptionImage(
                layer: 5, imagePath: 'assets/cyclist_rearfacing_mid.png')
          ],
          [
            OptionImage(
                layer: 2, imagePath: 'assets/bikelane_inner_green_R.png'),
            OptionImage(
                layer: 5, imagePath: 'assets/cyclist_rearfacing_inner.png')
          ]
        ], 'assets/bikelane_green_preview.png')
      ]),
    ], "Bike Lane", BikeLane.onEnableInnerR, BikeLane.onDisableInnerR),
    ChoiceManager([
      //Bus Lane paint type
      Feature([
        Option([
          [
            OptionImage(layer: 2, imagePath: 'assets/buslane_inner_R.png'),
            OptionImage(layer: 5, imagePath: 'assets/Bus_inner_R.png')
          ]
        ], 'assets/buslane_preview.png', 100, OptionTypes.wide.index),
        Option([
          [
            OptionImage(layer: 2, imagePath: 'assets/buslane_inner_red_R.png'),
            OptionImage(layer: 5, imagePath: 'assets/Bus_inner_R.png')
          ]
        ], 'assets/buslane_red_preview.png', 100, OptionTypes.wide.index)
      ], 0),
    ], "Bus Lane", BusLane.onEnableInnerR, BusLane.onDisableInnerR),
    ChoiceManager([
      //type of parking
      Feature([
        Option([
          [
            OptionImage(
                layer: 3, imagePath: 'assets/parking_parallel_mid_R.png'),
            OptionImage(
                layer: 6, imagePath: 'assets/white_volvo_parallel_mid_R.png')
          ],
          [
            OptionImage(
                layer: 3, imagePath: 'assets/parking_parallel_inner_R.png'),
            OptionImage(
                layer: 6, imagePath: 'assets/white_volvo_parallel_inner_R.png')
          ]
        ], 'assets/parking_parallel_preview.png'),
        Option([
          [
            OptionImage(
                layer: 3, imagePath: 'assets/parking_diagonal_inner_R.png'),
            OptionImage(
                layer: 6, imagePath: 'assets/white_volvo_diagonal_inner_R.png'),
          ]
        ], 'assets/parking_diagonal_preview.png', 100, OptionTypes.wide.index,
            DiagonalParking.onEnableInnerR, DiagonalParking.onDisableInnerR)
      ]),
    ], "On-Street Parking", Parking.onEnableInnerR, Parking.onDisableInnerR),
  ], Lane4.onEnable, Lane4.onDisable),
  LaneNames.lane5: LaneManager([
    ChoiceManager([
      //Bike lane paint type
      Feature([
        Option([
          [
            OptionImage(layer: 2, imagePath: 'assets/bikelane_outer_R.png'),
            OptionImage(
                layer: 5, imagePath: 'assets/cyclist_rearfacing_outer.png')
          ]
        ], 'assets/bikelane_preview.png'),
        Option([
          [
            OptionImage(
                layer: 2, imagePath: 'assets/bikelane_outer_green_R.png'),
            OptionImage(
                layer: 5, imagePath: 'assets/cyclist_rearfacing_outer.png')
          ]
        ], 'assets/bikelane_green_preview.png')
      ]),
    ], "Bike Lane", BikeLane.onEnableOuterR, BikeLane.onDisableOuterR),
    ChoiceManager([
      Feature([
        Option([
          [
            OptionImage(layer: 2, imagePath: 'assets/buslane_outer_R.png'),
            OptionImage(layer: 5, imagePath: 'assets/Bus_outer_R.png')
          ]
        ], 'assets/buslane_preview.png', 100, OptionTypes.wide.index),
        Option([
          [
            OptionImage(layer: 2, imagePath: 'assets/buslane_outer_red_R.png'),
            OptionImage(layer: 5, imagePath: 'assets/Bus_outer_R.png')
          ]
        ], 'assets/buslane_red_preview.png', 100, OptionTypes.wide.index)
      ], 0),
    ], "Bus Lane", BusLane.onEnableOuterR, BusLane.onDisableOuterR),
    ChoiceManager([
      Feature([
        Option([
          [
            OptionImage(
                layer: 3, imagePath: 'assets/parking_parallel_outer_R.png'),
            OptionImage(
                layer: 6, imagePath: 'assets/white_volvo_parallel_outer_R.png')
          ]
        ], 'assets/parking_parallel_preview.png'),
        Option([
          [
            OptionImage(layer: 3, imagePath: 'assets/parking_diagonal_R.png'),
            OptionImage(
                layer: 6, imagePath: 'assets/white_volvo_diagonal_R.png'),
          ]
        ], 'assets/parking_diagonal_preview.png', 100, OptionTypes.wide.index,
            DiagonalParking.onEnableOuterR, DiagonalParking.onDisableOuterR)
      ]),
    ], "On-Street Parking", Parking.onEnableOuterR, Parking.onDisableOuterR),
    ChoiceManager([
      Feature([
        Option([
          [OptionImage(layer: 4, imagePath: 'assets/sidewalk_extension_R.png')]
        ], 'assets/sidewalk_extension_R.png'),
      ], 0),
      Feature([
        Option([
          [
            OptionImage(layer: 7, imagePath: 'assets/trees_near_R.png'),
            OptionImage(layer: 5, imagePath: 'assets/trees_far_R.png')
          ],
        ], 'assets/trees_near_R.png', 100, OptionTypes.extra.index),
      ]),
    ], "Sidewalk", Sidewalk.onEnableR, Sidewalk.onDisableR),
  ], Lane5.onEnable, Lane5.onDisable),
  LaneNames.crosswalk: LaneManager([
    ChoiceManager([
      Feature(
        [
          Option([
            [
              OptionImage(layer: 6, imagePath: 'assets/crosswalk_L.png'),
              OptionImage(layer: 6, imagePath: 'assets/crosswalk_R.png')
            ],
            [
              OptionImage(
                  layer: 6, imagePath: 'assets/crosswalk_extended_L.png'),
              OptionImage(
                  layer: 6, imagePath: 'assets/crosswalk_extended_R.png')
            ],
          ], 'assets/crosswalk_default_preview.png'),
        ],
      ),
      Feature(
        [
          Option([
            [OptionImage(layer: 5, imagePath: 'assets/crosswalk_lines.png')]
          ], 'assets/crosswalk_lines_preview.png'),
        ],
      ),
    ], "Crosswalk", null, null, true, true),
  ], Crosswalk.onEnable, Crosswalk.onDisable),
  LaneNames.buildings: LaneManager([
    ChoiceManager([
      Feature([
        Option([
          [OptionImage(layer: 4, imagePath: 'assets/brownstone_building.png')]
        ], 'assets/brownstone_building_preview.png'),
        Option([
          [OptionImage(layer: 4, imagePath: 'assets/condo_whiteandred.png')]
        ], 'assets/condo_whiteandred_preview.png'),
      ]),
    ], "Buildings", null, null, true, true)
  ], Buildings.onEnable, Buildings.onDisable),
};

List<dynamic> getLaneOptionsList() {
  List<List<ChoiceManager>> managers = [];

  laneTypeManagers.forEach((key, laneTypeManager) {
    managers.add(laneTypeManager.laneTypes!);
  });

  List laneOptionsList = List.generate(
      managers.length,
      (i) => List.generate(
          managers[i].length,
          (j) => (managers[i][j].defaultEnabled)
              ? OptionsView(choiceManager: managers[i][j])
              : ExpandableListView(
                  title: managers[i][j].title,
                  childWidget: OptionsView(choiceManager: managers[i][j]),
                )));

  return laneOptionsList;
}
