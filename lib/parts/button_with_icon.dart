import 'dart:ui';

import 'package:flutter/material.dart';

class ButtonWithIcon extends StatelessWidget {
  final Icon icon;
  final VoidCallback onPressed;
  final String label;
  final Color color;

  ButtonWithIcon({this.label, this.icon, this.onPressed, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36.0,),
      child: SizedBox(
        height: 50.0,
        width: double.infinity,
        child: RaisedButton.icon(
          color: color,
          onPressed: onPressed,
          icon: icon,
          label: Text(label, style: TextStyle(fontSize: 18.0),),
       shape: RoundedRectangleBorder(
         borderRadius: BorderRadius.all(
          Radius.circular(15.0)),
       ),
        ),
      ),
    );
  }
}
