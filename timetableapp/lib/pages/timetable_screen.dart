import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timetableapp/components/event_model.dart';
import 'package:timetableapp/components/weekly_schedule_model.dart';
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
              scheduleProvider.fetchSchedule();
            },
          ),
        ],
      ),
      body: scheduleProvider.schedules.isEmpty
          ? Center(
              child: Text('Aucun cours trouvé'),
            )
          : _buildTimetable(scheduleProvider),
    );
  }

  /// Build a Day column with all the events and empty slots
  ///  it starts from earliest course to latest course of the whole schedule
  List<Widget> _buildDayView(List<Event> events) {
    List<Widget> slots = [];
    return List.generate(
      10,
      (index) {
        DateTime currentTime = DateTime(2021, 1, 1, 8, 0);
        currentTime = currentTime.add(Duration(minutes: index * 15));
        Event? currentEvent = events.firstWhere(
          (event) =>
              currentTime.isAfter(event.start) &&
              currentTime.isBefore(event.end),
          orElse: () => Event(
              summary: '',
              start: currentTime,
              end: currentTime,
              description: '', location: ''),
        );

        if (currentEvent.summary.isEmpty) {
          slots.add(_buildEmptySlot(15));
        } else {
          slots.add(_buildEventSlot(currentEvent, 15));
        }
        return Expanded(
          child: Column(
            children: slots,
          ),
        );
      },
    );
  }

  Widget _buildEmptySlot(int minutes) {
    int slotCount = (minutes / 15).ceil(); // 15 minutes par slot
    return Column(
      children: List.generate(
        slotCount,
        (index) => Container(
          height: 15, // Hauteur du slot de 15 minutes
          color: Colors
              .grey[300], // Couleur gris clair pour les périodes sans cours
        ),
      ),
    );
  }

  Widget _buildEventSlot(Event event, int minutes) {
    int slotCount = (minutes / 15).ceil();
    return Column(
      children: List.generate(
        slotCount,
        (index) => Container(
          height: 15, // Hauteur du slot de 15 minutes
          color: Colors.green, // Couleur du cours
          child: Text(
            index == 0
                ? event.summary
                : '', // Afficher le nom du cours uniquement sur le premier slot
            style: TextStyle(fontSize: 12, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildTimetable(ScheduleProvider scheduleProvider) {
    return PageView.builder(
      itemBuilder: (context, index) {
        return Column(
          children: [
            _buildColumnHeader(),
            _buildTimeColumnAndWeekView(scheduleProvider.schedules[index]),
          ],
        );
      },
      itemCount: scheduleProvider.schedules.length,
    );
  }

  Widget _buildColumnHeader() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 30,
            color: Colors.grey[300],
            child: Center(
              child: Text('Lundi'),
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 30,
            color: Colors.grey[300],
            child: Center(
              child: Text('Mardi'),
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 30,
            color: Colors.grey[300],
            child: Center(
              child: Text('Mercredi'),
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 30,
            color: Colors.grey[300],
            child: Center(
              child: Text('Jeudi'),
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 30,
            color: Colors.grey[300],
            child: Center(
              child: Text('Vendredi'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeColumnAndWeekView(WeeklySchedule schedule) {
    return Expanded(
        child: Row(
      children: [
        _buidTimeColumn(),
        _buildWeekView(schedule),
      ],
    ));
  }

  Widget _buidTimeColumn() {
    return Column(
      children: List.generate(
        10,
        (index) {
          return Container(
            height: 60,
            color: Colors.grey[300],
            child: Center(
                child: Text(
              '${index + 8}h',
              style: TextStyle(fontSize: 16),
            )),
          );
        },
      ),
    );
  }

  Widget _buildWeekView(WeeklySchedule schedule) {
    return Expanded(
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: _buildDayView(schedule.monday),
            ),
          ),
          Expanded(
            child: Column(
              children: _buildDayView(schedule.tuesday),
            ),
          ),
          Expanded(
            child: Column(
              children: _buildDayView(schedule.wednesday),
            ),
          ),
          Expanded(
            child: Column(
              children: _buildDayView(schedule.thursday),
            ),
          ),
          Expanded(
            child: Column(
              children: _buildDayView(schedule.friday),
            ),
          ),
        ],
      ),
    );
  }
}
