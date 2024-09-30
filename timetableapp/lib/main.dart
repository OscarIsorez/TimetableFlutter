import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timetableapp/components/App_Theme.dart';
import 'package:timetableapp/pages/home_page.dart';
import 'package:timetableapp/pages/settings_page.dart';
import 'package:timetableapp/pages/timetable_screen.dart';
import 'package:timetableapp/providers/timetable_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ScheduleProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Timetable',
      theme: AppTheme.lightTheme,
      // darkTheme: AppTheme.darkTheme,
      home: TimetableView(),
    );
  }
}
