
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class MySpace extends StatelessWidget {
  Color? color;
  double? height;

  MySpace({super.key, required this.color, required  this.height});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 1),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: color,
        ),
      ),
    );
  }
}
