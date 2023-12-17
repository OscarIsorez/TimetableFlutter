import 'package:flutter/material.dart';
import 'package:timetableapp/components/Event.dart';

class Course_Tile extends StatelessWidget {
  final Event event;
  final double height;

  const Course_Tile({
    super.key,
    required this.event,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: height,
        // width: double.infinity,
        child: Text(event.summary,

          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),        
        ));
  }
}
