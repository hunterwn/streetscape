import 'package:flutter/material.dart';

import '../constants.dart';
import '../Model/currency_manager.dart';
import '../../main.dart';

class ScenarioAppBar extends StatefulWidget with PreferredSizeWidget {
  const ScenarioAppBar({Key? key}) : super(key: key);

  @override
  _ScenarioAppBarState createState() => _ScenarioAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _ScenarioAppBarState extends State<ScenarioAppBar> {
  final currencymanager = CurrencyManager();
  int? used;
  int? remaining;
  @override
  Widget build(BuildContext context) {
    used = currencymanager.used;
    remaining = currencymanager.remaining;
    currencymanager.addListener(() {
      if (mounted) {
        setState(() {
          used = currencymanager.used;
          remaining = currencymanager.remaining;
        });
      }
    });
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
            child: Text(used.toString()),
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
          // child: Text(remaining.toString()),
          child: Container(
            constraints: const BoxConstraints(minWidth: 25),
            child: Text(remaining.toString()),
          ),
        ),
        SizedBox(
            width: 90,
            child: Center(
                child: ElevatedButton(
                    onPressed: () {
                      jsonTemp = currencymanager.getOptionImagesJSON();
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
