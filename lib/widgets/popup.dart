import 'package:flutter/material.dart';
import '../colorscheme.dart';

class Popup {
  static Future<T?> show<T>({
    required BuildContext context,
    bool barrierDismissible = true,
    String? text,
    List<PopupAction>? actions,
  }) {
    return showDialog(
        context: context,
        barrierDismissible: barrierDismissible,
        builder: (context) {
          return Center(
              child: PopupContainer(
            text: text,
            backButtonEnabled: !barrierDismissible,
            actions: actions,
          ));
        });
  }
}

class PopupContainer extends StatelessWidget {
  final String? text;
  final bool backButtonEnabled;
  final List<PopupAction>? actions;
  const PopupContainer(
      {Key? key, this.text, this.actions, required this.backButtonEnabled})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    const double height = 150;
    return Material(
        type: MaterialType.transparency,
        child: Container(
          width: 300,
          height: height,
          color: MyColorScheme.popupBackground,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (text != null)
                    Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          text!,
                          style: const TextStyle(
                            fontSize: 18,
                            color: MyColorScheme.textAlt,
                          ),
                        )),
                  if (backButtonEnabled) const BackButton()
                ],
              ),
              const SizedBox(height: height - 100),
              if (actions != null)
                Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: List.generate(
                      actions!.length,
                      (i) => Padding(
                          padding: const EdgeInsets.all(10),
                          child: actions![i]),
                    )),
            ],
          ),
        ));
  }
}

class PopupAction extends StatelessWidget {
  final Widget? child;
  final void Function()? onPressed;
  const PopupAction({Key? key, this.child, required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: child,
    );
  }
}

class BackButton extends StatelessWidget {
  const BackButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 30,
        width: 30,
        child: MaterialButton(
            padding: const EdgeInsets.all(10),
            onPressed: () {
              Navigator.pop(context);
            },
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            child: const Icon(Icons.close)));
  }
}
