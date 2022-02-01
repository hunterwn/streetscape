import 'package:flutter/material.dart';

import '../../constants.dart';

class ExpandableListView extends StatefulWidget {
  final String? title;
  final Widget? childWidget;

  const ExpandableListView({Key? key, this.title, this.childWidget})
      : super(key: key);

  @override
  _ExpandableListViewState createState() => _ExpandableListViewState();
}

class _ExpandableListViewState extends State<ExpandableListView> {
  bool expandFlag = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 1.0),
      child: Column(
        children: <Widget>[
          Container(
            color: const Color(darkGrey),
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                IconButton(
                    icon: SizedBox(
                      height: 50.0,
                      width: 50.0,
                      child: Center(
                        child: Icon(
                          expandFlag
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: Colors.white,
                          size: 30.0,
                        ),
                      ),
                    ),
                    onPressed: () {
                      if (mounted) {
                        setState(() {
                          expandFlag = !expandFlag;
                        });
                      }
                    }),
                Text(
                  widget.title!,
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                )
              ],
            ),
          ),
          ExpandableContainer(expanded: expandFlag, child: widget.childWidget)
        ],
      ),
    );
  }
}

class ExpandableContainer extends StatelessWidget {
  final bool? expanded;
  final double? collapsedHeight;
  final double? expandedHeight;
  final Widget? child;
  const ExpandableContainer({
    Key? key,
    @required this.child,
    this.collapsedHeight = 0.0,
    this.expandedHeight = 200.0,
    this.expanded = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      width: screenWidth,
      height: expanded! ? expandedHeight : collapsedHeight,
      child: Container(
        child: child,
        decoration:
            BoxDecoration(border: Border.all(width: 1.0, color: Colors.grey)),
      ),
    );
  }
}
