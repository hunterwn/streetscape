import 'package:json_annotation/json_annotation.dart';
import 'package:street_designer/scenario/Model/image_manager.dart';

import 'currency_manager.dart';
import 'feature.dart';
import 'option_image.dart';

enum OptionTypes { optionDefault, extra, noDisable, wide }

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
      CurrencyManager currencyManager = CurrencyManager();
      currencyManager.removeOption(this);
      for (OptionImage image in images) {
        image.enabled = false;
      }
      if (onDisable != null) {
        onDisable!();
      }
    }
  }

  void enable() {
    if (!locked && !enabled) {
      enabled = true;
      CurrencyManager currencyManager = CurrencyManager();
      currencyManager.addOption(this);
      for (OptionImage image in images) {
        image.enabled = true;
      }
      if (onEnable != null) {
        onEnable!();
      }
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
