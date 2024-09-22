import 'package:flutter/material.dart';
import 'package:timetableapp/components/App_Theme.dart';
import 'package:timetableapp/components/Event.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timetableapp/components/Timetable.dart';

class SettingsPage extends StatefulWidget {
  final List<String> listOfUniqueSummariesEvents;
  SettingsPage({super.key, required this.listOfUniqueSummariesEvents});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Map pour stocker les couleurs sélectionnées pour chaque cours
  Map<String, Color?> selectedColors = {};

  @override
  void initState() {
    super.initState();
    _loadSelectedColors();
  }

  // Charger les couleurs sélectionnées à partir des préférences partagées
  Future<void> _loadSelectedColors() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      for (var course in widget.listOfUniqueSummariesEvents) {
        final colorIndex = prefs.getInt(course) ?? 0;
        selectedColors[course] = AppTheme.listOfColorsForCourses[colorIndex];
      }
    });
  }

  // Sauvegarder les couleurs sélectionnées dans les préférences partagées
  Future<void> _saveSelectedColor(String course, int colorIndex) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(course, colorIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView.builder(
        itemCount: widget.listOfUniqueSummariesEvents.length,
        itemBuilder: (context, index) {
          final course = widget.listOfUniqueSummariesEvents[index];
          return ListTile(
            title: Text(course),
            trailing: DropdownButton<Color?>(
              value: selectedColors[course],
              items: AppTheme.listOfColorsForCourses.map((Color? color) {
                return DropdownMenuItem<Color?>(
                  value: color,
                  child: Container(
                    width: 24,
                    height: 24,
                    color: color,
                  ),
                );
              }).toList(),
              onChanged: (Color? newColor) {
                setState(() {
                  selectedColors[course] = newColor;
                  final colorIndex =
                      AppTheme.listOfColorsForCourses.indexOf(newColor);
                  _saveSelectedColor(course, colorIndex);
                });
              },
            ),
          );
        },
      ),
    );
  }
}
