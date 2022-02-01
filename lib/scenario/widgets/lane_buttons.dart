import 'package:flutter/material.dart';

import '../../constants.dart';

class LaneSelectionManager with ChangeNotifier {
  static final LaneSelectionManager _choicemanager =
      LaneSelectionManager._internal();
  int _selection = -1;
  int get selection => _selection;
  set selection(int value) {
    _selection = value;
    notifyListeners();
  }

  void setSelection(int value) {
    _selection = value;
    notifyListeners();
  }

  factory LaneSelectionManager() {
    return _choicemanager;
  }
  LaneSelectionManager._internal();
}

class LaneButton extends StatelessWidget {
  final Function? onPressed;
  final int? color;
  final int? index;
  const LaneButton({
    Key? key,
    @required this.onPressed,
    @required this.color,
    @required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ButtonTheme(
      minWidth: double.infinity,
      height: double.infinity,
      child: MaterialButton(
        shape: const ContinuousRectangleBorder(
          side: BorderSide(color: Colors.white, width: 2),
        ),
        onPressed: () => onPressed!(index!),
        child: Text(
          (index! + 1).toString(),
          style: const TextStyle(color: Colors.white),
        ),
        color: Color(color!),
      ),
    );
  }
}

class LaneButtonRow extends StatefulWidget {
  const LaneButtonRow({Key? key}) : super(key: key);

  @override
  _LaneButtonRowState createState() => _LaneButtonRowState();
}

class _LaneButtonRowState extends State<LaneButtonRow> {
  int? selected;

  final laneSelectionManager = LaneSelectionManager();

  List<int> buttonSizes = [1, 1, 2, 1, 1];

  @override
  Widget build(BuildContext context) {
    // laneSelectionManager.addListener(() => setState(() {
    //       selected = laneSelectionManager.selection;
    //     }));
    laneSelectionManager.addListener(() {
      if (mounted) {
        setState(() {
          selected = laneSelectionManager.selection;
        });
      }
    });

    return Row(
        children: List.generate(
      5,
      (i) => Expanded(
          flex: buttonSizes[i],
          child: LaneButton(
            onPressed: laneSelectionManager.setSelection,
            color: (i == selected) ? yellow : mediumGrey,
            index: i,
          )),
    ));
  }
}
