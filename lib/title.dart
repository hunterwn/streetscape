import 'package:flutter/material.dart';

import 'menu.dart';

class TitleScreen extends StatelessWidget {
  const TitleScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: SizedBox(
            width: 75,
            height: 50,
            child: FloatingActionButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25)),
              backgroundColor: Colors.deepOrange,
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const Menu()));
              },
              child: const Text(
                "Play",
                style: TextStyle(fontSize: 18),
              ),
            )),
        body: Container(
            decoration: const BoxDecoration(
              color: Colors.transparent,
              image: DecorationImage(
                  fit: BoxFit.fitHeight, image: AssetImage('assets/title.jpg')),
            ),
            child: const SafeArea(
                child: Scaffold(
                    backgroundColor: Colors.transparent,
                    body: Text('Title')))));
  }
}
