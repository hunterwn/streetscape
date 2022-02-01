import 'package:flutter/material.dart';

import 'option.dart';
import 'option_image.dart';

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
