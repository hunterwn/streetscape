import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:street_designer/get_scenario_options.dart';
import 'package:street_designer/scenario.dart';
import 'choice_manager.dart';
import 'package:street_designer/scenario/Model/loading_handler.dart';
import 'get_scenario_options.dart';

List<ScenarioDescription> scenarios = [
  ScenarioDescription(
      title: ScenarioTitles.cityStreet,
      description: 'Create a design for a bustling city street.',
      previewImagePath: 'assets/examplescene1.jpg'),
  ScenarioDescription(
      title: ScenarioTitles.suburbanStreet,
      description: 'Design the perfect suburban street.',
      previewImagePath: 'assets/examplescene2.jpg'),
  ScenarioDescription(
      title: ScenarioTitles.neighborhoodStreet,
      description: 'Design a street for this idyllic neighborhood.',
      previewImagePath: 'assets/examplescene3.jpg'),
];

class Menu extends StatefulWidget {
  const Menu({Key? key}) : super(key: key);

  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  int _selectedIndex = 0;

  void _onNavBarItemTapped(int index) {
    setState(() {
      switch (index) {
        case 0:
          _selectedIndex = index;
          break;
        case 1:
          LoadingHandler loadingHandler = LoadingHandler();
          loadingHandler.loading = true;
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const VotingScreen()));
          break;
        case 2:
          _selectedIndex = index;
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> cardList = List.generate(
        scenarios.length,
        (i) => ScenarioCard(
              title: scenarios[i].title,
              text: scenarios[i].description,
              imagePath: scenarios[i].previewImagePath,
            ));

    Widget content = Container();

    if (_selectedIndex == 0) {
      content = Container(
          decoration: const BoxDecoration(
            color: Colors.transparent,
            image: DecorationImage(
                fit: BoxFit.fitHeight,
                image: AssetImage('assets/mainmenubackground.jpg')),
          ),
          child: Row(children: [
            Expanded(child: Container()),
            SizedBox(
                width: 300,
                child: ListView(
                  children: cardList,
                )),
            Expanded(child: Container()),
          ]));
    } else if (_selectedIndex == 2) {
      content = const ProfilePage();
    }

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
        ),
        body: content,
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.border_color_sharp),
              label: 'Design',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.how_to_vote),
              label: 'Vote',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_box),
              label: 'Account',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.amber[800],
          onTap: _onNavBarItemTapped,
        ));
  }
}

class ScenarioCard extends StatelessWidget {
  final String title;
  final String text;
  final String imagePath;
  const ScenarioCard({
    Key? key,
    required this.title,
    required this.text,
    required this.imagePath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Card(
            elevation: 3.0,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Stack(
              children: [
                ShaderMask(
                  child: Image(image: AssetImage(imagePath)),
                  shaderCallback: (Rect bounds) {
                    return const LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Colors.white70, Colors.transparent],
                        stops: [0.3, 0.7]).createShader(bounds);
                  },
                  blendMode: BlendMode.srcATop,
                ),
                SizedBox(
                    height: 290,
                    child: Row(children: [
                      SizedBox(width: 20, child: Container()),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 12,
                              child: Container(),
                            ),
                            const Flexible(
                              flex: 2,
                              child: Text(
                                'Design Challenge',
                                style: TextStyle(
                                    color: Colors.deepOrange,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Flexible(
                              flex: 2,
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(title,
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold)),
                                    if (true) const Icon(Icons.check)
                                  ]),
                            ),
                            Flexible(
                              flex: 3,
                              child: SizedBox(
                                  width: 180,
                                  child: Text(
                                    text,
                                    overflow: TextOverflow.fade,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black54),
                                  )),
                            ),
                          ])
                    ])),
                Positioned(
                  bottom: 30,
                  right: 10,
                  child: ElevatedButton(
                      onPressed: () {
                        LoadingHandler loadingHandler = LoadingHandler();
                        loadingHandler.loading = true;
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Scenario(
                                      title: title,
                                    )));
                      },
                      child: const Icon(Icons.arrow_forward_ios_rounded,
                          color: Colors.white),
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(20),
                        primary: Colors.deepOrange,
                        onPrimary: Colors.white,
                      )),
                )
              ],
            )));
  }
}
