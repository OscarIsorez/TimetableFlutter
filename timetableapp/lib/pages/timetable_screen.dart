import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timetableapp/components/event_model.dart';
import 'package:timetableapp/components/snackbarpopup.dart';
import 'package:timetableapp/components/weekly_schedule_model.dart';
import 'package:timetableapp/constants.dart';
import 'package:timetableapp/providers/timetable_provider.dart';
import 'package:timetableapp/utils.dart';

class TimetableView extends StatefulWidget {
  const TimetableView({super.key});

  @override
  State<TimetableView> createState() => _TimetableViewState();
}

class _TimetableViewState extends State<TimetableView> {
  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    _fetchSchedule();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchSchedule() async {
    final scheduleProvider =
        Provider.of<ScheduleProvider>(context, listen: false);
    if (!mounted) return;
    await scheduleProvider.fetchSchedule();
    if (!mounted) return;
    SnackBarPopUp.callSnackBar(
      getStringFromState(scheduleProvider.state),
      context,
      getColorFromState(scheduleProvider.state),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheduleProvider = Provider.of<ScheduleProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Emploi du temps'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              if (!mounted) return;
              scheduleProvider.fetchSchedule();
              SnackBarPopUp.callSnackBar(
                getStringFromState(scheduleProvider.state),
                context,
                getColorFromState(scheduleProvider.state),
              );
            },
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          try {
            return scheduleProvider.schedules.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : _buildTimetable(scheduleProvider, context);
          } catch (e) {
            return Center(
              child: Text('An error occurred: $e'),
            );
          }
        },
      ),
    );
  }

  Widget _buildTimetable(ScheduleProvider scheduleProvider, context) {
    return Column(
      children: [
        _buildColumnHeader(),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTimeColumn(scheduleProvider),
              _buildWeeksPageView(scheduleProvider, context),
            ],
          ),
          // ),
        ),
      ],
    );
  }

  /// Construit l'en-tête de colonnes avec les jours de la semaine
  Widget _buildColumnHeader() {
    return Row(
      children: [
        Container(
          width: Constants.columnWidth,
          height: 30,
          color: Colors.grey[300],
          child: const Center(
            child: Text('Heure'),
          ),
        ),
        for (String day in Constants.weekDaysShort)
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

  Widget _buildTimeColumn(ScheduleProvider scheduleProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = scheduleProvider.earliestCourse.hour;
            i <= scheduleProvider.latestCourse.hour;
            i++)
          SizedBox(
            height: Constants.hourHeight,
            width: Constants.columnWidth,
            // color: Colors.grey[300],
            child: Align(
              alignment: Alignment.topRight,
              child: Text('$i:00 -'),
            ),
          ),
      ],
    );
  }

  /// PageView pour la navigation entre les semaines
  Widget _buildWeeksPageView(
      ScheduleProvider scheduleProvider, BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
        ),
        child: PageView.builder(
          controller: PageController(viewportFraction: 1),
          itemCount: scheduleProvider.schedules.length,
          itemBuilder: (context, index) {
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _buildWeekView(
                  scheduleProvider.schedules[index],
                  scheduleProvider.earliestCourse.hour,
                  scheduleProvider.latestCourse.hour,
                  scheduleProvider),
            );
          },
        ),
      ),
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
            height: ((event.start.hour - currentHour) * 45.0).toDouble(),
            child: const Center(child: Text("")),
          ),
        );
      }

      daySlots.add(
        Container(
          height: ((event.end.hour - event.start.hour) * 60 +
                  (event.end.minute - event.start.minute))
              .toDouble(), // Calcul précis de la durée en pixels
          decoration: BoxDecoration(
            color: provider.getCourseColor(event.summary),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              '${event.summary} (${formatTime(event.start)} - ${formatTime(event.end)})',
              style: const TextStyle(fontSize: 12),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: daySlots,
      ),
    );
  }
}
