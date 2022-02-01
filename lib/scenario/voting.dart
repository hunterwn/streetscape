import 'package:flutter/material.dart';
import 'package:street_designer/scenario/Model/currency_manager.dart';
import 'package:street_designer/scenario/Model/option_image.dart';

import 'scenario.dart';
import '../constants.dart';
import 'Model/loading_handler.dart';
import '../../main.dart';

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

    for (Map<String, dynamic> json in jsonTemp) {
      OptionImage optionImage = OptionImage.fromJson(json);
      optionImages.add(optionImage);
    }

    optionImages.sort((a, b) => a.layer.compareTo(b.layer));

    LoadingHandler loadingHandler = LoadingHandler();

    //If still loading, add a callback to run after loading is finished
    if (loadingHandler.loading) {
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        //Tell LoadingHandler that loading is finished
        loadingHandler.finishLoading();
      });
    }

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
      const LoadingScreen()
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
      backgroundColor: const Color(darkGrey),
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
                CurrencyManager currencyManager = CurrencyManager();
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
