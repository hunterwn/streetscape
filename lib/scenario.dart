import 'package:flutter/material.dart';
import 'colorscheme.dart';
import 'scenario/model/loading_handler.dart';
import 'widgets/popup.dart';
import 'choice_manager.dart';
import 'scenario/widgets/lane_buttons.dart';
import 'scenario/widgets/expandablelistview.dart';
import 'get_scenario_options.dart';

class ScenarioDescription {
  final String title;
  final String description;
  final String previewImagePath;

  ScenarioDescription(
      {required this.title,
      required this.description,
      required this.previewImagePath});
}

class Scenario extends StatefulWidget {
  final String title;
  const Scenario({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  _ScenarioState createState() => _ScenarioState();
}

class _ScenarioState extends State<Scenario> {
  final loadingHandler = LoadingHandler();
  final playerInfo = PlayerInfo();
  List? laneOptionsList;
  @override
  Widget build(BuildContext context) {
    LoadingHandler loadingHandler = LoadingHandler();

    //If scenario is loading, add a callback to run after loading is finished
    if (loadingHandler.loading) {
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        onBuildFinish(widget);
        //Tell LoadingHandler that loading is finished
        loadingHandler.finishLoading();
      });
    }
    currentScenario = widget.title;
    return Stack(children: [
      Scaffold(
          appBar: buildAppBar(context: context),
          body: buildScenarioBody(context: context, maxDimension: 650))

      // LoadingScreen()
    ]);
  }

  AppBar buildAppBar({required BuildContext context}) {
    return AppBar(
      shadowColor: Colors.transparent,
      backgroundColor: MyColorScheme.appbarBackground,
      leading: IconButton(
        onPressed: () {
          ImageLayerManager imageLayerManager = ImageLayerManager();
          LoadingHandler loadingHandler = LoadingHandler();
          getScenarioOptions(currentScenario!).forEach((laneName, laneManager) {
            laneManager.forceDisable();
          });
          unlockAllOptions();
          imageLayerManager.updateAll();
          loadingHandler.loading = true;
          Navigator.pop(context);
        },
        icon: const Icon(Icons.arrow_back_ios_rounded,
            color: MyColorScheme.buttonIcons),
      ),
      actions: [
        const Center(
            child: SizedBox(
                width: 50,
                height: 25,
                child: Image(image: AssetImage('assets/currency_icon.png')))),
        const Center(
            child: Text(
          'USED: ',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        )),
        Center(
          child: Container(
            constraints: const BoxConstraints(minWidth: 25),
            child: Text(playerInfo.currency.used.toString()),
          ),
        ),
        const Center(
            child: SizedBox(
                width: 50,
                height: 25,
                child: Image(image: AssetImage('assets/currency_icon.png')))),
        const Center(
            child: Text(
          'REMAINING: ',
          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
        )),
        Center(
          child: Container(
            constraints: const BoxConstraints(minWidth: 25),
            child: Text(playerInfo.currency.total.toString()),
          ),
        ),
        SizedBox(
            width: 90,
            child: Center(
                child: ElevatedButton(
                    onPressed: () {
                      Popup.show(
                          context: context,
                          barrierDismissible: false,
                          text: "Are you ready to submit?",
                          actions: [
                            PopupAction(
                                child: const Text("Submit"),
                                onPressed: () {
                                  //return all the way to main menu
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                })
                          ]);
                    },
                    child: const Text(
                      "Done",
                      style: TextStyle(color: MyColorScheme.textMain),
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

  Column buildScenarioBody(
      {required BuildContext context, double? maxDimension}) {
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
                maxWidth: maxDimension ?? 650, maxHeight: maxDimension ?? 650),
            child: const AspectRatio(aspectRatio: 1, child: StreetView())),
        Container(
            decoration: const BoxDecoration(
                border: Border(
                    left: BorderSide(width: 2.0, color: Colors.white),
                    right: BorderSide(width: 2.0, color: Colors.white))),
            constraints:
                BoxConstraints(maxWidth: maxDimension ?? 650, maxHeight: 50),
            child: const LaneButtonRow()),
        Expanded(
            child: Container(
          child: CategoriesView(
            scenario: widget,
          ),
          decoration: const BoxDecoration(
              border: Border(
            top: BorderSide(width: 2.0, color: Colors.white),
          )),
        ))
      ],
    );
  }
}

class CategoriesView extends StatefulWidget {
  final Scenario scenario;
  // final List laneOptionsList;
  const CategoriesView({
    Key? key,
    required this.scenario,
    // required this.laneOptionsList
  }) : super(key: key);

  @override
  _CategoriesViewState createState() => _CategoriesViewState();
}

void onBuildFinish(Scenario scenario) {
  ImageLayerManager imageLayerManager = ImageLayerManager();

  //enable default options
  getScenarioOptions(scenario.title).forEach((key, laneTypeManager) {
    for (ChoiceManager choiceManager in laneTypeManager.laneTypes!) {
      if (choiceManager.defaultEnabled) {
        for (int i = 0; i < choiceManager.features!.length; i++) {
          choiceManager.setChoice(i, 0);
        }
      }
    }
  });

  List<Option> staticOptions = getStaticOptions(scenario.title);

  //enable static options
  for (Option option in staticOptions) {
    option.enable();
  }

  imageLayerManager.add(staticOptions);

  imageLayerManager.updateAll();
}

class _CategoriesViewState extends State<CategoriesView> {
  int? selected;

  final laneSelectionManager = LaneSelectionManager();

  @override
  Widget build(BuildContext context) {
    laneSelectionManager.addListener(() {
      if (mounted) {
        setState(() {
          selected = laneSelectionManager.selection;
        });
      }
    });
    return ListView(
      children: (selected != null)
          ? getLaneOptionsList(currentScenario!).elementAt(selected!)
          : [],
    );
  }
}

List<dynamic> getLaneOptionsList(String title) {
  List<List<ChoiceManager>> managers = [];

  getScenarioOptions(title).forEach((key, laneTypeManager) {
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

  void selectBuildings(int laneOptionsLength) {
    laneSelectionManager.setSelection(laneOptionsLength - 1);
  }

  void selectCrosswalk(int laneOptionsLength) {
    laneSelectionManager.setSelection(laneOptionsLength - 2);
  }

  @override
  Widget build(BuildContext context) {
    int laneOptionsLength = getScenarioOptions(currentScenario!).length;
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
                      onTap: () => selectBuildings(laneOptionsLength),
                    )),
                Expanded(flex: 1, child: Container()),
                Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: () => selectBuildings(laneOptionsLength),
                    )),
              ],
            )),
        Expanded(
            flex: 3,
            child: GestureDetector(
              onTap: () => selectCrosswalk(laneOptionsLength),
            )),
      ],
    );
  }
}
