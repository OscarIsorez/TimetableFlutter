import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timetableapp/components/event_model.dart';
import 'package:timetableapp/components/weekly_schedule_model.dart';
import 'package:timetableapp/constant.dart';
import 'package:timetableapp/providers/timetable_provider.dart';

class TimetableView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheduleProvider = Provider.of<ScheduleProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Emploi du temps'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              scheduleProvider
                  .fetchSchedule(); // Fonction pour actualiser l'emploi du temps
            },
          ),
        ],
      ),
      body: scheduleProvider.schedules.isEmpty
          ? const Center(
              child: Text('Actualisez votre emploi du temps'),
            )
          : _buildTimetable(scheduleProvider, context),
    );
  }

  /// Construit la vue d'un jour avec tous les événements et les créneaux vides
  Widget _buildDayView(List<Event> events, int startHour, int endHour) {
    List<Widget> daySlots = [];

    // Initialisation de l'heure de début pour vérifier les créneaux vides
    int currentHour = startHour;

    for (Event event in events) {
      // Ajout des créneaux vides si nécessaire
      if (event.start.hour > currentHour) {
        daySlots.add(
          Container(
            height: (event.start.hour - currentHour) * 60.0,
            color: Colors.grey[200],
            child: Center(child: Text('Créneau vide')),
          ),
        );
      }

      // Ajout des cours
      daySlots.add(
        Container(
          height: (event.end.difference(event.start).inMinutes).toDouble(),
          color: Colors.green,
          child: Center(
            child: Text(
                '${event.summary} (${event.start.hour}:${event.start.minute})'),
          ),
        ),
      );

      // Mise à jour de l'heure courante pour le prochain tour de boucle
      currentHour = event.end.hour;
    }

    // Si des créneaux sont vides après le dernier cours jusqu'à la fin de la journée
    if (currentHour < endHour) {
      daySlots.add(
        Container(
          height: (endHour - currentHour) * 60.0,
          color: Colors.grey[200],
          child: Center(child: Text('Créneau vide')),
        ),
      );
    }

    return Expanded(
      child: Column(children: daySlots),
    );
  }

  Widget _buildTimetable(ScheduleProvider scheduleProvider, context) {
    return Column(
      children: [
        _buildColumnHeader(),
        Expanded(
          child: Row(
            children: [
              _buildTimeColumn(scheduleProvider),
              Expanded(
                child: _buildWeeksPageView(scheduleProvider, context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Construit l'en-tête de colonnes avec les jours de la semaine
  Widget _buildColumnHeader() {
    return Row(
      children: [
        Container(
          width: Constant.columnWidth,
          height: 30,
          color: Colors.grey[300],
          child: const Center(
            child: Text('Heure'),
          ),
        ),
        for (String day in Constant.weekDaysShort)
          Expanded(
            child: Container(
              height: 30,
              color: Colors.grey[300],
              child: Center(
                child: Text(day),
              ),
            ),
          ),
      ],
    );
  }

  /// Construit la colonne des horaires
  Widget _buildTimeColumn(ScheduleProvider scheduleProvider) {
    return SizedBox(
      width: Constant.columnWidth,
      height: 800,
      child: Column(children: [
        for (var i = scheduleProvider.earliestCourse.hour;
            i <= scheduleProvider.latestCourse.hour;
            i++)
          Container(
            height: 60,
            color: Colors.grey[300],
            child: Center(
              child: Text('$i:00'),
            ),
          ),
      ]),
    );
  }

  /// PageView pour la navigation entre les semaines
  Widget _buildWeeksPageView(
      ScheduleProvider scheduleProvider, BuildContext context) {
    return Expanded(
      child: PageView.builder(
        itemCount: scheduleProvider.schedules.length,
        itemBuilder: (context, index) {
          return _buildWeekView(
              scheduleProvider.schedules[index],
              scheduleProvider.earliestCourse.hour,
              scheduleProvider.latestCourse.hour);
        },
      ),
    );
  }

  /// Construit la vue d'une semaine avec chaque jour
  Widget _buildWeekView(WeekSchedule week, int startHour, int endHour) {
    return Row(
      children: [
        _buildDayView(week.monday, startHour, endHour),
        _buildDayView(week.tuesday, startHour, endHour),
        _buildDayView(week.wednesday, startHour, endHour),
        _buildDayView(week.thursday, startHour, endHour),
        _buildDayView(week.friday, startHour, endHour),
      ],
    );
  }
}
