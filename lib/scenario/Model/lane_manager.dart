import 'choice_manager.dart';

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
