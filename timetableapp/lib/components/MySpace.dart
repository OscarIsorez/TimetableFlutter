import 'package:flutter/material.dart';

// ignore: must_be_immutable
class MySpace extends StatelessWidget {

  Color? color;
  int flex = 1;

  MySpace({super.key, 
    
    required this.color,
    flex,
  });

  @override
  Widget build(BuildContext context) {
    return 
      Padding(
        padding: const EdgeInsets.only(top: 1),
        child: Container(
          height: 14,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color:  color,
            
          ),
        ),
      );
  }
}
