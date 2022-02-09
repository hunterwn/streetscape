import 'package:flutter/material.dart';
import 'get_scenario_options.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

String userID = 'kXowmTClRlEGs2xCsQr9';

enum OptionTypes { optionDefault, extra, noDisable, wide }

class OptionImage {
  int layer;
  String imagePath;
  bool? enabled = false;

  OptionImage({required this.layer, required this.imagePath, this.enabled});
}

class Option {
  List<OptionImage> images = [];
  List<List<OptionImage>> altImages = [];
  String? previewImagePath;
  bool enabled = false;
  int? type;
  int? cost;
  Function? onEnable;
  Function? onDisable;
  bool? defaultEnabled;
  Feature? parentFeature;
  bool locked = false;
  String? message;

  int? hash;

  Option(this.altImages,
      [this.previewImagePath,
      this.cost,
      this.type,
      this.onEnable,
      this.onDisable]) {
    images = altImages[0];
    cost ??= 100;
    type ??= OptionTypes.optionDefault.index;
  }

  void disable() {
    if (!locked && enabled) {
      enabled = false;
      // PlayerInfo currencyManager = PlayerInfo();
      // currencyManager.removeOption(this);
      for (OptionImage image in images) {
        image.enabled = false;
      }
      if (onDisable != null) {
        onDisable!();
      }
    }
  }

  void forceDisable() {
    setLocked(false);
    enabled = false;
    for (OptionImage image in images) {
      image.enabled = false;
    }
  }

  void enable() {
    if (!locked && !enabled) {
      enabled = true;
      // PlayerInfo currencyManager = PlayerInfo();
      // currencyManager.addOption(this);
      for (OptionImage image in images) {
        image.enabled = true;
      }
      if (onEnable != null) {
        onEnable!();
      }
    }
  }

  void forceEnable() {
    setLocked(false);
    enabled = true;
    for (OptionImage image in images) {
      image.enabled = true;
    }
  }

  void update() {
    ImageLayerManager imageLayerManager = ImageLayerManager();
    imageLayerManager.update([this]);
  }

  void setLocked(bool val, [String? message]) {
    locked = val;
    setMessage(message);
  }

  void setMessage(String? message) {
    this.message = message;
  }

  void swapImages(int set) {
    if (altImages.length > set) {
      images = altImages[set];
    }
  }
}

class Feature {
  List<Option>? options;
  int selected = -1;
  int? defaultEnabled;
  bool enabled = false;
  ChoiceManager? choiceManager;

  void disable() {
    enabled = false;
    selected = -1;
    for (Option option in options!) {
      option.disable();
    }
  }

  void forceDisable() {
    enabled = false;
    selected = -1;
    for (Option option in options!) {
      option.forceDisable();
    }
  }

  void enable() {
    enabled = true;
    if (selected != -1) {
      options![selected].enable();
    }
  }

  void setLocked(bool val, [String? message]) {
    for (Option option in options!) {
      option.setLocked(val, message);
    }
  }

  void enableDefault() {
    enabled = true;
    if ((defaultEnabled ?? -1) != selected) {
      options![defaultEnabled!].enable();
      selected = defaultEnabled!;
    }
  }

  Feature(List<Option> options_, [int? defaultEnabled_]) {
    options = options_;
    for (Option option in options!) {
      option.parentFeature = this;
    }
    defaultEnabled = defaultEnabled_;
  }
}

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

class LaneManager {
  ChoiceManager? currentLaneType;
  List<ChoiceManager>? laneTypes;
  var currentState = LaneStates.defaultState;
  Function? onEnable;
  Function? onDisable;

  void setType(ChoiceManager newType) {
    if (currentLaneType == null) {
      if (onEnable != null) {
        onEnable!();
      }
      currentLaneType = newType;
    } else if (newType != currentLaneType) {
      currentLaneType!.disable();
      newType.enable();
      currentLaneType = newType;
    }
  }

  void disable() {
    currentLaneType!.disable();
    currentLaneType = null;
    if (onDisable != null) {
      onDisable!();
    }
  }

  void forceDisable() {
    if (currentLaneType != null) {
      currentLaneType!.forceDisable();
      currentLaneType = null;
    }
  }

  void setChoice(int row, int selectedIndex) {
    currentLaneType!.setChoice(row, selectedIndex);
  }

  LaneManager(List<ChoiceManager> managersList,
      [Function? onEnable, Function? onDisable]) {
    laneTypes = managersList;
    for (ChoiceManager choiceManager in managersList) {
      choiceManager.laneManager = this;
    }
    if (onEnable != null) {
      this.onEnable = onEnable;
    }
    if (onDisable != null) {
      this.onDisable = onDisable;
    }
  }
}

class ChoiceManager with ChangeNotifier {
  String? title;
  List<Feature>? features;
  List<Feature>? defaultFeatures;
  List<Feature>? altFeatures;
  ImageLayerManager? layerManager;
  PlayerInfo currencyManager = PlayerInfo();
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

    // setLockedByCost(currencyManager.remaining);
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

  void forceDisable() {
    enabled = false;
    for (Feature feature in features!) {
      feature.forceDisable();
    }
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

int numLayers = 8;

final List<GlobalKey<_ImageLayerState>> keys =
    List.generate(numLayers, (i) => GlobalKey<_ImageLayerState>());

class ImageLayerManager with ChangeNotifier {
  static final ImageLayerManager _imageLayerManager =
      ImageLayerManager._internal();

  List<Map<int, OptionImage>> layerImages = List.generate(numLayers, (i) => {});
  List<int> updatedLayers = [];

  void add(List<Option> options) {
    List<int> updated = [];

    for (Option option in options) {
      for (List<OptionImage> imageList in option.altImages) {
        for (OptionImage laneImage in imageList) {
          layerImages[laneImage.layer][laneImage.hashCode] = laneImage;
          if (!updated.contains(laneImage.layer)) {
            updated.add(laneImage.layer);
          }
        }
      }
    }
    for (int layer in updated) {
      keys[layer].currentState!.updateLayer();
    }
  }

  void remove(List<Option> options) {
    List<int> updated = [];

    for (Option option in options) {
      for (OptionImage laneImage in option.images) {
        layerImages[laneImage.layer].remove(laneImage.hashCode);
        if (!updated.contains(laneImage.layer)) {
          updated.add(laneImage.layer);
        }
      }
    }
    for (int layer in updated) {
      keys[layer].currentState!.updateLayer();
    }
  }

  void update(List<Option> options) {
    List<int> updated = [];
    for (Option option in options) {
      for (OptionImage laneImage in option.images) {
        if (!updated.contains(laneImage.layer)) {
          updated.add(laneImage.layer);
        }
      }
    }
    for (int layer in updated) {
      keys[layer].currentState!.updateLayer();
    }
  }

  void updateAll() {
    for (GlobalKey<_ImageLayerState> layer in keys) {
      layer.currentState!.updateLayer();
    }
  }

  void removeAll() {
    layerImages = List.generate(numLayers, (i) => {});
    updateAll();
  }

  factory ImageLayerManager() {
    return _imageLayerManager;
  }

  ImageLayerManager._internal();
}

class ImageLayer extends StatefulWidget {
  final int? layer;

  const ImageLayer({Key? key, @required this.layer}) : super(key: key);

  @override
  _ImageLayerState createState() => _ImageLayerState();
}

class _ImageLayerState extends State<ImageLayer> {
  final imageLayerManager = ImageLayerManager();

  List<Image> images = [];

  int count = 0;

  void updateLayer() {
    images = [];
    imageLayerManager.layerImages[widget.layer!].forEach((id, laneImage) {
      if (laneImage.enabled ?? false) {
        images.add(Image(image: AssetImage(laneImage.imagePath)));
      }
    });
    Future.delayed(Duration.zero, () async {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: images,
    );
  }

  @override
  void dispose() {
    super.dispose();
    imageLayerManager.removeListener(() {});
  }
}

String? currentScenario;

void setLaneLocked(String lane, String type, bool val, [String? message]) {
  if (getScenarioOptions(currentScenario!).containsKey(lane)) {
    for (ChoiceManager choiceManager
        in getScenarioOptions(currentScenario!)[lane]!.laneTypes!) {
      if (choiceManager.title == type) {
        choiceManager.setLocked(val, message);
      }
    }
  }
}

void setLaneState(String lane, int state) {
  if (getScenarioOptions(currentScenario!).containsKey(lane)) {
    getScenarioOptions(currentScenario!)[lane]!.currentState = state;
    getScenarioOptions(currentScenario!)[lane]!.currentLaneType?.update();
  }
}

void setLockedOptionType(String lane, int type, bool val, [String? message]) {
  for (ChoiceManager choiceManager
      in getScenarioOptions(currentScenario!)[lane]!.laneTypes!) {
    for (Feature feature in choiceManager.features!) {
      for (Option option in feature.options!) {
        if (option.type == type && option.locked != val) {
          option.setLocked(val, message);
        }
      }
    }
  }
}

void unlockOptionsWithMessage(String lane, String message) {
  for (ChoiceManager choiceManager
      in getScenarioOptions(currentScenario!)[lane]!.laneTypes!) {
    for (Feature feature in choiceManager.features!) {
      for (Option option in feature.options!) {
        if (option.locked && option.message == message) {
          option.setLocked(false);
        }
      }
    }
  }
}

void setLockedByCost(int minCost) {
  List<ChoiceManager> toNotify = [];
  PlayerInfo currencyManager = PlayerInfo();
  String lowCurrencyWarning = "Not enough\ncurrency!";
  getScenarioOptions(currentScenario!).forEach((key, laneTypeManager) {
    int totalLaneCost =
        (currencyManager.perLaneCosts.containsKey(laneTypeManager))
            ? currencyManager.perLaneCosts[laneTypeManager]!
            : minCost;
    for (ChoiceManager choiceManager in laneTypeManager.laneTypes!) {
      for (Feature feature in choiceManager.features!) {
        int featureCost = (feature.selected != -1)
            ? feature.options![feature.selected].cost!
            : 0;

        for (Option option in feature.options!) {
          int optionCost = option.cost!;

          //if option requires other options to be enabled, add those options' costs
          if (option.type == OptionTypes.extra.index) {
            for (Feature feature in choiceManager.features!) {
              if (feature.defaultEnabled != null) {
                if (!feature.options![feature.defaultEnabled!].enabled) {
                  optionCost += feature.options![feature.defaultEnabled!].cost!;
                }
              }
            }
          }

          //Check if option could be swapped in with remaining currency
          if (!choiceManager.enabled && optionCost <= totalLaneCost) {
            if (option.message == lowCurrencyWarning) {
              option.setLocked(false);
              if (!toNotify.contains(feature.choiceManager)) {
                toNotify.add(feature.choiceManager!);
              }
            }
            continue;
          }

          //Lock options that cost more than remaining currency
          if (optionCost > minCost &&
              !option.enabled &&
              optionCost > featureCost) {
            option.setLocked(true, lowCurrencyWarning);
            if (!toNotify.contains(feature.choiceManager)) {
              toNotify.add(feature.choiceManager!);
            }
            //Unlock options that cost less than remaining currency
          } else if (optionCost <= minCost &&
              option.message == lowCurrencyWarning) {
            option.setLocked(false);
            if (!toNotify.contains(feature.choiceManager)) {
              toNotify.add(feature.choiceManager!);
            }
          }
        }
      }
    }
  });

  for (ChoiceManager choiceManager in toNotify) {
    choiceManager.notify();
  }

  return;
}

void unlockAllOptions() {
  getScenarioOptions(currentScenario!).forEach((laneName, laneManager) {
    for (ChoiceManager choiceManager in laneManager.laneTypes!) {
      for (Feature feature in choiceManager.features!) {
        for (Option option in feature.options!) {
          option.setLocked(false);
        }
      }
    }
  });
}

class Sidewalk {
  static void onEnableL() {
    Option crosswalk = getScenarioOptions(currentScenario!)["Crosswalk"]!
        .currentLaneType!
        .features![0]
        .options![0];
    crosswalk.altImages[0][0].enabled = false;
    crosswalk.altImages[1][0].enabled = true;
    crosswalk.update();
  }

  static void onDisableL() {
    Option crosswalk = getScenarioOptions(currentScenario!)["Crosswalk"]!
        .currentLaneType!
        .features![0]
        .options![0];
    crosswalk.altImages[0][0].enabled = true;
    crosswalk.altImages[1][0].enabled = false;
    crosswalk.update();
  }

  static void onEnableR() {
    Option crosswalk = getScenarioOptions(currentScenario!)["Crosswalk"]!
        .currentLaneType!
        .features![0]
        .options![0];
    crosswalk.altImages[0][1].enabled = false;
    crosswalk.altImages[1][1].enabled = true;
    crosswalk.update();
  }

  static void onDisableR() {
    Option crosswalk = getScenarioOptions(currentScenario!)["Crosswalk"]!
        .currentLaneType!
        .features![0]
        .options![0];
    crosswalk.altImages[0][1].enabled = true;
    crosswalk.altImages[1][1].enabled = false;
    crosswalk.update();
  }
}

class Parking {
  static String activeParkingWarning = "Parking\nalready active!";

  static void onEnableInnerL() {
    setLaneLocked(
        LaneNames.lane1, LaneTypeNames.parking, true, activeParkingWarning);
  }

  static void onDisableInnerL() {
    setLaneLocked(LaneNames.lane1, LaneTypeNames.parking, false);
  }

  static void onEnableOuterL() {
    setLaneLocked(
        LaneNames.lane2, LaneTypeNames.parking, true, activeParkingWarning);
  }

  static void onDisableOuterL() {
    setLaneLocked(LaneNames.lane2, LaneTypeNames.parking, false);
  }

  static void onEnableInnerR() {
    setLaneLocked(
        LaneNames.lane5, LaneTypeNames.parking, true, activeParkingWarning);
  }

  static void onDisableInnerR() {
    setLaneLocked(LaneNames.lane5, LaneTypeNames.parking, false);
  }

  static void onEnableOuterR() {
    setLaneLocked(
        LaneNames.lane4, LaneTypeNames.parking, true, activeParkingWarning);
  }

  static void onDisableOuterR() {
    setLaneLocked(LaneNames.lane4, LaneTypeNames.parking, false);
  }
}

class DiagonalParking {
  static String inadequateSpaceMessage =
      "Not enough\nspace!\nCause:\nDiagonal\nParking";

  static void onEnableInnerL() {
    setLockedOptionType(
        LaneNames.lane1, OptionTypes.wide.index, true, inadequateSpaceMessage);
  }

  static void onDisableInnerL() {
    unlockOptionsWithMessage(LaneNames.lane1, inadequateSpaceMessage);
  }

  static void onEnableOuterL() {
    setLaneState(LaneNames.lane2, LaneStates.shiftedState);

    setLockedOptionType(
        LaneNames.lane2, OptionTypes.wide.index, true, inadequateSpaceMessage);
  }

  static void onDisableOuterL() {
    setLaneState(LaneNames.lane2, LaneStates.defaultState);

    unlockOptionsWithMessage(LaneNames.lane2, inadequateSpaceMessage);
  }

  static void onEnableInnerR() {
    setLockedOptionType(
        LaneNames.lane5, OptionTypes.wide.index, true, inadequateSpaceMessage);
  }

  static void onDisableInnerR() {
    unlockOptionsWithMessage(LaneNames.lane5, inadequateSpaceMessage);
  }

  static void onEnableOuterR() {
    setLaneState(LaneNames.lane4, LaneStates.shiftedState);

    setLockedOptionType(
        LaneNames.lane4, OptionTypes.wide.index, true, inadequateSpaceMessage);
  }

  static void onDisableOuterR() {
    setLaneState(LaneNames.lane4, LaneStates.defaultState);

    unlockOptionsWithMessage(LaneNames.lane5, inadequateSpaceMessage);
  }
}

class BusLane {
  static String activeBusLaneWarning = "Bus Lane\nalready active!";

  static void onEnableInnerL() {
    setLockedOptionType(
        LaneNames.lane1, OptionTypes.wide.index, true, "Not enough\nspace!");

    setLaneLocked(
        LaneNames.lane1, LaneTypeNames.busLane, true, activeBusLaneWarning);
  }

  static void onDisableInnerL() {
    setLockedOptionType(LaneNames.lane1, OptionTypes.wide.index, false);
    setLaneLocked(LaneNames.lane1, LaneTypeNames.busLane, false);
  }

  static void onEnableOuterL() {
    setLaneState(LaneNames.lane2, LaneStates.shiftedState);
    setLockedOptionType(
        LaneNames.lane2, OptionTypes.wide.index, true, "Not enough\nspace!");

    setLaneLocked(
        LaneNames.lane2, LaneTypeNames.busLane, true, activeBusLaneWarning);
  }

  static void onDisableOuterL() {
    setLaneState(LaneNames.lane2, LaneStates.defaultState);
    setLockedOptionType(LaneNames.lane2, OptionTypes.wide.index, false);
    setLaneLocked(LaneNames.lane2, LaneTypeNames.busLane, false);
  }

  static void onEnableInnerR() {
    setLockedOptionType(
        LaneNames.lane5, OptionTypes.wide.index, true, "Not enough\nspace!");

    setLaneLocked(
        LaneNames.lane5, LaneTypeNames.busLane, true, activeBusLaneWarning);
  }

  static void onDisableInnerR() {
    setLockedOptionType(LaneNames.lane2, OptionTypes.wide.index, false);
    setLaneLocked(LaneNames.lane5, LaneTypeNames.busLane, false);
  }

  static void onEnableOuterR() {
    setLaneState(LaneNames.lane4, LaneStates.shiftedState);
    setLockedOptionType(
        LaneNames.lane4, OptionTypes.wide.index, true, "Not enough\nspace!");
    setLaneLocked(
        LaneNames.lane4, LaneTypeNames.busLane, true, activeBusLaneWarning);
  }

  static void onDisableOuterR() {
    setLaneState(LaneNames.lane4, LaneStates.defaultState);
    setLockedOptionType(LaneNames.lane5, OptionTypes.wide.index, false);
    setLaneLocked(LaneNames.lane4, LaneTypeNames.busLane, false);
  }
}

class BikeLane {
  static String activeBikeLaneWarning = "Bike Lane\nalready active!";

  static void onEnableInnerL() {
    setLaneLocked(
        LaneNames.lane1, LaneTypeNames.bikeLane, true, activeBikeLaneWarning);
  }

  static void onDisableInnerL() {
    setLaneLocked(LaneNames.lane1, LaneTypeNames.bikeLane, false);
  }

  static void onEnableOuterL() {
    setLaneLocked(
        LaneNames.lane2, LaneTypeNames.bikeLane, true, activeBikeLaneWarning);
  }

  static void onDisableOuterL() {
    setLaneLocked(LaneNames.lane2, LaneTypeNames.bikeLane, false);
  }

  static void onEnableInnerR() {
    setLaneLocked(
        LaneNames.lane5, LaneTypeNames.bikeLane, true, activeBikeLaneWarning);
  }

  static void onDisableInnerR() {
    setLaneLocked(LaneNames.lane5, LaneTypeNames.bikeLane, false);
  }

  static void onEnableOuterR() {
    setLaneLocked(
        LaneNames.lane4, LaneTypeNames.bikeLane, true, activeBikeLaneWarning);
  }

  static void onDisableOuterR() {
    setLaneLocked(LaneNames.lane4, LaneTypeNames.bikeLane, false);
  }
}

class Lane1 {
  static void onEnable() {
    return;
  }

  static void onDisable() {
    return;
  }
}

class Lane2 {
  static void onEnable() {
    return;
  }

  static void onDisable() {
    return;
  }
}

class Lane3 {
  static void onEnable() {
    return;
  }

  static void onDisable() {
    return;
  }
}

class Lane4 {
  static void onEnable() {
    return;
  }

  static void onDisable() {
    return;
  }
}

class Lane5 {
  static void onEnable() {
    return;
  }

  static void onDisable() {
    return;
  }
}

class Crosswalk {
  static void onEnable() {
    return;
  }

  static void onDisable() {
    return;
  }
}

class Buildings {
  static void onEnable() {
    return;
  }

  static void onDisable() {
    return;
  }
}

//PLAYER STATS TO LATER GET FROM SAVE DATA
const playerStartingCurrency = 750;

class PlayerCurrency {
  int total;
  int used;

  PlayerCurrency({required this.total, this.used = 0});
}

class PlayerInfo with ChangeNotifier {
  static final PlayerInfo _currencymanager = PlayerInfo._internal();

  DocumentSnapshot? user;
  CollectionReference? designs;
  int? designCount;

  PlayerCurrency currency = PlayerCurrency(total: playerStartingCurrency);

  Map<LaneManager, List<Option>> chosenOptions = {};
  Map<LaneManager, int> perLaneCosts = {};

  // List<Map<String, dynamic>> getOptionImagesJSON() {
  //   List<Map<String, dynamic>> tempJSON = [];

  //   Map<String, int> choices = {};

  //   for (List<Option> optionList in chosenOptions.values) {
  //     for (Option option in optionList) {
  //       for (OptionImage image in option.images) {
  //         if (image.enabled ?? false) {
  //           // tempJSON.add(image.toJson());
  //           choices[image.imagePath] = image.layer;
  //         }
  //       }
  //     }
  //   }

  //   for (Option option in staticOptions) {
  //     for (OptionImage image in option.images) {
  //       // tempJSON.add(image.toJson());
  //       choices[image.imagePath] = image.layer;
  //     }
  //   }

  //   //designs!.add(choices);

  //   return tempJSON;
  // }

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
    currency.used += amount;
    currency.total -= amount;
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

  static void getUser(PlayerInfo _currencymanager) async {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    _currencymanager.user = await users.doc(userID).get();
    _currencymanager.designs =
        _currencymanager.user!.reference.collection('designs');
    QuerySnapshot _myDoc = await _currencymanager.designs!.get();
    List myDocCount = _myDoc.docs;
    _currencymanager.designCount = myDocCount.length;
  }

  factory PlayerInfo() {
    getUser(_currencymanager);
    return _currencymanager;
  }

  PlayerInfo._internal();
}

class OptionsView extends StatefulWidget {
  final ChoiceManager? choiceManager;
  const OptionsView({Key? key, @required this.choiceManager}) : super(key: key);

  @override
  _OptionsViewState createState() => _OptionsViewState();
}

class _OptionsViewState extends State<OptionsView> {
  @override
  Widget build(BuildContext context) {
    widget.choiceManager!.addListener(() => {
          if (mounted) {setState(() {})}
        });
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        widget.choiceManager!.features!.length,
        (i) => OptionRow(
          row: i,
          choiceManager: widget.choiceManager!,
        ),
      ),
    );
  }
}

class OptionRow extends StatelessWidget {
  final int? row;
  final ChoiceManager? choiceManager;
  const OptionRow({Key? key, @required this.row, @required this.choiceManager})
      : super(key: key);

  void updateRow(int index) {
    choiceManager!.setChoice(row!, index);
  }

  @override
  Widget build(BuildContext context) {
    List<Option> options = choiceManager!.features![row!].options!;
    return Flexible(
        flex: 1,
        child: Row(
            mainAxisSize: MainAxisSize.max,
            children: List.generate(
                options.length,
                (i) => (options[i].previewImagePath != null)
                    ? OptionButton(
                        option: options[i],
                        index: i,
                        onpressed: updateRow,
                      )
                    : Container())));
  }
}

class OptionButton extends StatelessWidget {
  final Function? onpressed;
  final int? index;
  final Option? option;

  const OptionButton({
    Key? key,
    @required this.index,
    @required this.onpressed,
    @required this.option,
  }) : super(key: key);

  Color getBorderColor() {
    if (option!.locked) {
      return Colors.red;
    }

    if (option!.enabled) {
      if (option!.type == OptionTypes.extra.index) {
        return Colors.blue;
      } else {
        return Colors.yellow;
      }
    } else {
      return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => onpressed!(index),
        child: Container(
          margin: const EdgeInsets.all(5),
          width: 100,
          decoration: BoxDecoration(
              color: Colors.grey,
              border: Border.all(color: getBorderColor(), width: 3),
              borderRadius: const BorderRadius.all(Radius.circular(5))),
          child: Stack(
            children: [
              Image(
                width: 100,
                image: AssetImage(option!.previewImagePath!),
              ),
              if (option!.cost != 0)
                Positioned(
                    bottom: 0.0,
                    left: 25.0,
                    child: Text(option!.cost.toString(), style: borderedText)),
              if (option!.cost != 0)
                const Positioned(
                    bottom: 0.0,
                    child: Image(
                        width: 20,
                        image: AssetImage('assets/currency_icon.png'))),
              if (option!.message != null)
                Positioned(
                    top: 0.0,
                    child: Text(option!.message!, style: borderedText)),
            ],
          ),
        ));
  }
}

TextStyle borderedText =
    const TextStyle(inherit: true, color: Colors.white, shadows: [
  Shadow(
    // bottomLeft
    offset: Offset(-1.0, -1.0),
  ),
  Shadow(
    // bottomRight
    offset: Offset(1.0, -1.0),
  ),
  Shadow(
    // topRight
    offset: Offset(1.0, 1.0),
  ),
  Shadow(
    // topLeft
    offset: Offset(-1.0, 1.0),
  ),
]);

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    Key? key,
  }) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Colors.blue,
            Colors.deepOrange,
          ],
        )),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            const SizedBox(height: 24),
            ProfileWidget(
              imagePath: 'blank_profile.jpg',
              onClicked: () async {},
            ),
            const SizedBox(height: 24),
            buildName(),
            const SizedBox(height: 48),
            NumbersWidget(currencyManager: PlayerInfo()),
            const SizedBox(height: 48),
          ],
        ));
  }

  Widget buildName() => Column(
        children: [
          Text(
            'player_' + userID,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
          const SizedBox(height: 4),
          const Text(
            'Rank: Apprentice',
            style: TextStyle(color: Colors.black),
          )
        ],
      );
}

class ProfileWidget extends StatelessWidget {
  final String imagePath;
  final VoidCallback onClicked;

  const ProfileWidget({
    Key? key,
    required this.imagePath,
    required this.onClicked,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;

    return Center(
      child: Stack(
        children: [
          buildImage(),
          Positioned(
            bottom: 0,
            right: 4,
            child: buildEditIcon(color),
          ),
        ],
      ),
    );
  }

  Widget buildImage() {
    final image = AssetImage(imagePath);

    return ClipOval(
      child: Material(
        color: Colors.transparent,
        child: Ink.image(
          image: image,
          fit: BoxFit.cover,
          width: 128,
          height: 128,
          child: InkWell(onTap: onClicked),
        ),
      ),
    );
  }

  Widget buildEditIcon(Color color) => buildCircle(
        color: Colors.white,
        all: 3,
        child: buildCircle(
          color: color,
          all: 8,
          child: const Icon(
            Icons.edit,
            color: Colors.white,
            size: 20,
          ),
        ),
      );

  Widget buildCircle({
    required Widget child,
    required double all,
    required Color color,
  }) =>
      ClipOval(
        child: Container(
          padding: EdgeInsets.all(all),
          color: color,
          child: child,
        ),
      );
}

class NumbersWidget extends StatelessWidget {
  final PlayerInfo currencyManager;
  const NumbersWidget({Key? key, required this.currencyManager})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        buildImageTextButton(context, 'assets/currency_icon.png',
            currencyManager.currency.total.toString()),
        buildDivider(),
        buildTextButton(
            context, currencyManager.designCount.toString(), 'Designs'),
      ],
    );
  }

  Widget buildDivider() => const SizedBox(
        height: 24,
        child: VerticalDivider(),
      );

  Widget buildImageTextButton(
    BuildContext context,
    String imagePath,
    String text,
  ) =>
      MaterialButton(
        padding: const EdgeInsets.symmetric(vertical: 4),
        onPressed: () {},
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Image(image: AssetImage(imagePath)),
            const SizedBox(width: 4),
            Text(
              text,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );

  Widget buildTextButton(
    BuildContext context,
    String value,
    String text,
  ) =>
      MaterialButton(
        padding: const EdgeInsets.symmetric(vertical: 4),
        onPressed: () {},
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              value + ' ',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 2),
            Text(
              text,
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      );
}

const double? maxDimension = 625;

class VotingScreen extends StatefulWidget {
  const VotingScreen({Key? key}) : super(key: key);

  @override
  _VotingScreenState createState() => _VotingScreenState();
}

class _VotingScreenState extends State<VotingScreen> {
  int current = 0;

  @override
  Widget build(BuildContext context) {
    List<OptionImage> optionImages = [];

    // for (Map<String, dynamic> json in jsonTemp) {
    //   OptionImage optionImage = OptionImage.fromJson(json);
    //   optionImages.add(optionImage);
    // }

    optionImages.sort((a, b) => a.layer.compareTo(b.layer));

    // LoadingHandler loadingHandler = LoadingHandler();

    //If still loading, add a callback to run after loading is finished
    // if (loadingHandler.loading) {
    //   WidgetsBinding.instance!.addPostFrameCallback((_) {
    //     //Tell LoadingHandler that loading is finished
    //     loadingHandler.finishLoading();
    //   });
    // }

    return Stack(children: [
      Scaffold(
          appBar: const VotingAppBar(),
          body: Column(
            children: [
              Container(
                constraints: const BoxConstraints(
                    maxWidth: maxDimension ?? 200,
                    maxHeight: maxDimension ?? 200),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Stack(
                    children: List.generate(
                        optionImages.length,
                        (i) => Image(
                            image: AssetImage(optionImages[i].imagePath))),
                  ),
                ),
              ),
              Expanded(
                  child: Container(
                color: Colors.black,
                child: const VotingPrompt(),
              )),
            ],
          )),
      // const LoadingScreen()
    ]);
  }
}

class VotingAppBar extends StatefulWidget with PreferredSizeWidget {
  const VotingAppBar({Key? key}) : super(key: key);

  @override
  _VotingAppBarState createState() => _VotingAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _VotingAppBarState extends State<VotingAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      shadowColor: Colors.transparent,
      // backgroundColor: const Color(darkGrey),
      leading: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
      ),
      actions: [
        SizedBox(
            width: 90,
            child: Center(
                child: ElevatedButton(
                    onPressed: () {
                      // Done press action
                    },
                    child: const Text(
                      "Done",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.grey),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        ))))))
      ],
    );
  }
}

class VotingPrompt extends StatefulWidget {
  const VotingPrompt({Key? key}) : super(key: key);

  @override
  _VotingPromptState createState() => _VotingPromptState();
}

class _VotingPromptState extends State<VotingPrompt> {
  int current = 0;
  int? _rating;
  bool _visible = true;

  List<String> qualities = ['beauty', 'safety', 'walkability', 'frugality'];

  void fadeInText() async {
    await Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        if (current < qualities.length - 1) {
          current += 1;
        } else {
          showDialog(
              context: context,
              builder: (context) {
                PlayerInfo currencyManager = PlayerInfo();
                currencyManager.updateCurrency(-50);
                return AlertDialog(
                    title: const Text("Thanks for voting! You earned:"),
                    content: Row(
                      children: const [
                        Image(image: AssetImage('assets/currency_icon.png')),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          "50",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 24),
                        )
                      ],
                    ));
              });
          current = 0;
        }
        _visible = !_visible;
        _rating = -1;
      });
    });
  }

  void onRatingChosen(int rating) {
    setState(() {
      _visible = !_visible;
      _rating = rating;

      fadeInText();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
        opacity: _visible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 20),
              RichText(
                  text: TextSpan(
                      style: const TextStyle(color: Colors.white, fontSize: 22),
                      children: <TextSpan>[
                    const TextSpan(text: 'How would you rate this design on '),
                    TextSpan(
                        text: qualities[current] + '?',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ])),
              const SizedBox(height: 20),
              Wrap(
                children: List.generate(
                    10,
                    (i) => CircularNumberButton(
                          number: i + 1,
                          onPressed: _visible ? onRatingChosen : () {},
                          color:
                              (i + 1 == _rating) ? Colors.yellow : Colors.white,
                        )),
              )
            ]));
  }
}

class CircularNumberButton extends StatelessWidget {
  final int number;
  final Function onPressed;
  final Color color;
  const CircularNumberButton(
      {Key? key,
      required this.number,
      required this.onPressed,
      required this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(5.0),
        child: RawMaterialButton(
          onPressed: () => onPressed(number),
          elevation: 2.0,
          fillColor: color,
          child: Text(number.toString(),
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          padding: const EdgeInsets.all(20.0),
          shape: const CircleBorder(),
        ));
  }
}
