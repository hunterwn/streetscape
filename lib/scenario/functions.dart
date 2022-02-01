import 'Model/choice_manager.dart';
import 'Model/currency_manager.dart';
import 'Model/feature.dart';
import 'Model/option.dart';

void setLaneLocked(String lane, String type, bool val, [String? message]) {
  if (laneTypeManagers.containsKey(lane)) {
    for (ChoiceManager choiceManager in laneTypeManagers[lane]!.laneTypes!) {
      if (choiceManager.title == type) {
        choiceManager.setLocked(val, message);
      }
    }
  }
}

void setLaneState(String lane, int state) {
  if (laneTypeManagers.containsKey(lane)) {
    laneTypeManagers[lane]!.currentState = state;
    laneTypeManagers[lane]!.currentLaneType?.update();
  }
}

void setLockedOptionType(String lane, int type, bool val, [String? message]) {
  for (ChoiceManager choiceManager in laneTypeManagers[lane]!.laneTypes!) {
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
  for (ChoiceManager choiceManager in laneTypeManagers[lane]!.laneTypes!) {
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
  CurrencyManager currencyManager = CurrencyManager();
  String lowCurrencyWarning = "Not enough\ncurrency!";
  laneTypeManagers.forEach((key, laneTypeManager) {
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

class Sidewalk {
  static void onEnableL() {
    Option crosswalk = laneTypeManagers["Crosswalk"]!
        .currentLaneType!
        .features![0]
        .options![0];
    crosswalk.altImages[0][0].enabled = false;
    crosswalk.altImages[1][0].enabled = true;
    crosswalk.update();
  }

  static void onDisableL() {
    Option crosswalk = laneTypeManagers["Crosswalk"]!
        .currentLaneType!
        .features![0]
        .options![0];
    crosswalk.altImages[0][0].enabled = true;
    crosswalk.altImages[1][0].enabled = false;
    crosswalk.update();
  }

  static void onEnableR() {
    Option crosswalk = laneTypeManagers["Crosswalk"]!
        .currentLaneType!
        .features![0]
        .options![0];
    crosswalk.altImages[0][1].enabled = false;
    crosswalk.altImages[1][1].enabled = true;
    crosswalk.update();
  }

  static void onDisableR() {
    Option crosswalk = laneTypeManagers["Crosswalk"]!
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
