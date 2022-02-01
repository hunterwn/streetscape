import 'package:flutter/material.dart';

import '../Model/choice_manager.dart';
import '../Model/option.dart';

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
