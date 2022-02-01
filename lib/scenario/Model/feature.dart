import 'option.dart';
import 'choice_manager.dart';

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
