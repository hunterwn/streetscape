import 'package:flutter/material.dart';

import 'widgets/appbar.dart';
import 'widgets/lane_buttons.dart';
import 'Model/image_manager.dart';
import 'Model/option.dart';
import 'Model/option_image.dart';
import 'Model/choice_manager.dart';
import 'Model/loading_handler.dart';

List laneOptionsList = getLaneOptionsList();

class ScenarioWidget extends StatelessWidget {
  const ScenarioWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(children: const [
      Scaffold(
          appBar: ScenarioAppBar(),
          body: ScenarioBody(
            maxDimension: 625,
          )),
      LoadingScreen()
    ]);
  }
}

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  final loadingHandler = LoadingHandler();

  @override
  Widget build(BuildContext context) {
    if (loadingHandler.loading) {
      loadingHandler.addListener(() {
        if (mounted) {
          setState(() {});
        }
      });
    }
    if (loadingHandler.loading) {
      return Container(
          color: Colors.black, child: const Center(child: Text("Loading...")));
    } else {
      return Container();
    }
  }
}

class ScenarioBody extends StatelessWidget {
  final double? maxDimension;
  const ScenarioBody({Key? key, @required this.maxDimension}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        const Divider(
          color: Colors.white,
          height: 2,
          thickness: 2,
        ),
        Container(
            decoration: const BoxDecoration(
                border: Border(
                    left: BorderSide(width: 2.0, color: Colors.white),
                    right: BorderSide(width: 2.0, color: Colors.white))),
            constraints: BoxConstraints(
                maxWidth: maxDimension ?? 200, maxHeight: maxDimension ?? 200),
            child: const AspectRatio(aspectRatio: 1, child: StreetView())),
        Container(
            decoration: const BoxDecoration(
                border: Border(
                    left: BorderSide(width: 2.0, color: Colors.white),
                    right: BorderSide(width: 2.0, color: Colors.white))),
            constraints:
                BoxConstraints(maxWidth: maxDimension ?? 200, maxHeight: 50),
            child: const LaneButtonRow()),
        Expanded(
            child: Container(
          child: const CategoriesView(),
          decoration: const BoxDecoration(
              border: Border(
            top: BorderSide(width: 2.0, color: Colors.white),
          )),
        ))
      ],
    );
  }
}

class StreetView extends StatelessWidget {
  const StreetView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    List<Widget> layerStack =
        List.generate(numLayers, (i) => ImageLayer(layer: i, key: keys[i]));

    layerStack.add(BuildingSelector());

    return Stack(children: layerStack);
  }
}

class BuildingSelector extends StatelessWidget {
  BuildingSelector({Key? key}) : super(key: key);

  final laneSelectionManager = LaneSelectionManager();

  void selectBuildings() {
    //select last entry in laneOptionsList (should always be the building options)
    laneSelectionManager.setSelection(laneOptionsList.length - 1);
  }

  void selectCrosswalk() {
    laneSelectionManager.setSelection(laneOptionsList.length - 2);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(flex: 4, child: Container()),
        Expanded(
            flex: 8,
            child: Row(
              children: [
                Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: selectBuildings,
                    )),
                Expanded(flex: 1, child: Container()),
                Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: selectBuildings,
                    )),
              ],
            )),
        Expanded(
            flex: 3,
            child: GestureDetector(
              onTap: selectCrosswalk,
            )),
      ],
    );
  }
}

class CategoriesView extends StatefulWidget {
  const CategoriesView({Key? key}) : super(key: key);

  @override
  _CategoriesViewState createState() => _CategoriesViewState();
}

List<Option> staticOptions = [
  Option([
    [OptionImage(layer: 0, imagePath: 'assets/sky_default.png')]
  ], null, 0),
  Option([
    [OptionImage(layer: 1, imagePath: 'assets/road.png')]
  ], null, 0),
  Option([
    [OptionImage(layer: 2, imagePath: 'assets/crosswalk_far_default.png')]
  ], null, 0),
  Option([
    [OptionImage(layer: 3, imagePath: 'assets/sidewalk_default.png')]
  ], null, 0),
  Option([
    [OptionImage(layer: 5, imagePath: 'assets/fog.png')]
  ], null, 0),
  Option([
    [OptionImage(layer: 6, imagePath: 'assets/traffic_signal.png')]
  ], null, 0),
];

void enableDefaultOptions() {
  laneTypeManagers.forEach((key, laneTypeManager) {
    for (ChoiceManager choiceManager in laneTypeManager.laneTypes!) {
      if (choiceManager.defaultEnabled) {
        for (int i = 0; i < choiceManager.features!.length; i++) {
          choiceManager.setChoice(i, 0);
        }
      }
    }
  });
}

void enableStaticOptions() {
  ImageLayerManager imageLayerManager = ImageLayerManager();

  for (Option option in staticOptions) {
    option.enable();
  }

  imageLayerManager.add(staticOptions);
}

void onBuildFinish() {
  enableDefaultOptions();
  enableStaticOptions();

  ImageLayerManager imageLayerManager = ImageLayerManager();
  imageLayerManager.updateAll();
}

class _CategoriesViewState extends State<CategoriesView> {
  int? selected;

  final laneSelectionManager = LaneSelectionManager();

  @override
  Widget build(BuildContext context) {
    LoadingHandler loadingHandler = LoadingHandler();

    //If scenario is loading, add a callback to run after loading is finished
    if (loadingHandler.loading) {
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        onBuildFinish();
        //Tell LoadingHandler that loading is finished
        loadingHandler.finishLoading();
      });
    }
    laneSelectionManager.addListener(() {
      if (mounted) {
        setState(() {
          selected = laneSelectionManager.selection;
        });
      }
    });
    return ListView(
      children: (selected != null) ? laneOptionsList.elementAt(selected!) : [],
    );
  }
}
