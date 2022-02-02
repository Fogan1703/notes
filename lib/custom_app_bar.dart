import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget {
  final Widget? leading;
  final List<Widget>? actions;

  const CustomAppBar({
    this.leading,
    this.actions,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgets = [];
    if (leading != null) widgets.add(leading!);
    widgets.add(const Spacer());
    if (actions != null) {
      for(int i = 0; i < actions!.length; i++) {
        if(i != 0) widgets.add(const SizedBox(width: 20));
        widgets.add(actions![i]);
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 50),
      child: Row(
        children: widgets,
      ),
    );
  }
}
