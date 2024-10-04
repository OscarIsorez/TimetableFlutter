import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timetableapp/components/event_model.dart';
import 'package:timetableapp/components/weekly_schedule_model.dart';
import 'package:timetableapp/constant.dart';
import 'package:timetableapp/providers/timetable_provider.dart';
import 'package:timetableapp/utils.dart';

class TimetableView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheduleProvider = Provider.of<ScheduleProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Emploi du temps'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
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

  Widget _buildTimetable(ScheduleProvider scheduleProvider, context) {
    return Column(
      children: [
        _buildColumnHeader(),
        Expanded(
          // Ajout du SingleChildScrollView pour toute la Row (heures + cours)
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: 600, // Hauteur minimale à ajuster si nécessaire
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTimeColumn(scheduleProvider), // Colonne des heures
                Expanded(
                  child: _buildWeeksPageView(
                      scheduleProvider, context), // Cours de la semaine
                ),
              ],
            ),
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
      child: Column(
        children: [
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
        ],
      ),
    );
  }

  /// PageView pour la navigation entre les semaines
  Widget _buildWeeksPageView(
      ScheduleProvider scheduleProvider, BuildContext context) {
    return PageView.builder(
      itemCount: scheduleProvider.schedules.length,
      itemBuilder: (context, index) {
        return _buildWeekView(
            scheduleProvider.schedules[index],
            scheduleProvider.earliestCourse.hour,
            scheduleProvider.latestCourse.hour,
            scheduleProvider);
      },
    );
  }

  /// Construit la vue d'une semaine avec chaque jour
  Widget _buildWeekView(WeekSchedule week, int startHour, int endHour,
      ScheduleProvider provider) {
    return Row(
      children: [
        _buildDayView(week.monday, startHour, endHour, provider),
        _buildDayView(week.tuesday, startHour, endHour, provider),
        _buildDayView(week.wednesday, startHour, endHour, provider),
        _buildDayView(week.thursday, startHour, endHour, provider),
        _buildDayView(week.friday, startHour, endHour, provider),
      ],
    );
  }

  Widget _buildDayView(List<Event> events, int startHour, int endHour,
      ScheduleProvider provider) {
    List<Widget> daySlots = [];

    int currentHour = startHour;

    for (Event event in events) {
      if (event.start.hour > currentHour) {
        daySlots.add(
          SizedBox(
            height: ((event.start.hour - currentHour) * 60.0).toDouble(),
            child: const Center(child: Text("C")),
          ),
        );
      }

      daySlots.add(
        Container(
          height: ((event.end.hour - event.start.hour) * 60 +
                  (event.end.minute - event.start.minute))
              .toDouble(),
          // color: provider.getCourseColor(event.summary),
          decoration: BoxDecoration(
            color: provider.getCourseColor(event.summary),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Container(
            padding: const EdgeInsets.only(left: 4),
            child: Center(
              child: Text(
                '${event.summary} (${formatTime(event.start)} - ${formatTime(event.end)})',
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ),
        ),
      );

      currentHour = event.end.hour;
    }

    if (currentHour < endHour) {
      daySlots.add(
        SizedBox(
          height: (endHour - currentHour) * 60.0,
          child: const Center(child: Text("C")),
        ),
      );
    }

    return Expanded(
      child: Column(children: daySlots),
    );
  }
}
