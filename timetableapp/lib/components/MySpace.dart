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
    return Flexible(
      flex: flex ?? 1,
      child: Padding(
        padding: const EdgeInsets.only(top: 1),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color:  color,
            
          ),
        ),
      ),
    );
  }
}
