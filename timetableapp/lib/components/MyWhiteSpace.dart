import 'package:flutter/material.dart';

class MyWhiteSpace extends StatelessWidget {
  const MyWhiteSpace({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(top: 1),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: Colors.blue[100],
          ),
        ),
      ),
    );
  }
}
