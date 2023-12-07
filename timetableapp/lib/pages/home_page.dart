import 'package:flutter/material.dart';
import 'package:timetableapp/components/Event.dart';
import 'package:timetableapp/components/Timetable.dart';
import 'package:timetableapp/components/WeeklySchedule.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> lst = ["0", "1", "2", "3", "4", "5", "6", "7", "8"];
  final PageController _pageController = PageController(initialPage: 0);
  String appBarTitle = 'Schedule';
  List<WeeklySchedule> schedules = [];
  Timetable timetable = Timetable(url: "https://planning.univ-rennes1.fr/jsp/custom/modules/plannings/o35ex53R.shu");

  Event ev1 = Event(
      start: DateTime(2021, 10, 11, 8, 0),
      end: DateTime(2021, 10, 11, 9, 0),
      location: 'Room 1',
      description: 'Maths class',
      summary: "test111");

  Event ev2 = Event(
      start: DateTime(2021, 10, 11, 9, 0),
      end: DateTime(2021, 10, 11, 10, 0),
      location: 'Room 2',
      description: 'English class',
      summary: "test2");

  Event ev3 = Event(
      start: DateTime(2021, 10, 11, 10, 0),
      end: DateTime(2021, 10, 11, 11, 0),
      location: 'Room 3',
      description: 'French class',
      summary: "test3");

  Event ev4 = Event(
      start: DateTime(2021, 10, 11, 11, 0),
      end: DateTime(2021, 10, 11, 12, 0),
      location: 'Room 4',
      description: 'History class',
      summary: "test4");


  WeeklySchedule generateSchedle() {
    WeeklySchedule weekySh = WeeklySchedule(
      monday: [ev1, ev2, ev3, ev4],
      tuesday: [ev1],
      wednesday: [ev1, ev4],
      thursday: [ev1, ev2, ev3, ev4],
      friday: [ev1, ev3, ev4],
    );
    return weekySh;
  }

  Future<void> updateMultipleSchedules() async {
    // setState(() {
    //   schedules = [];
    //   for (var i = 0; i < 10; i++) {

    //     WeeklySchedule wkShuflled  = generateSchedle();
    //     wkShuflled.monday.shuffle();
    //     schedules.add( wkShuflled);
    // }
    // });
    var tpSchudles = await timetable.generateTimetable();
    
    setState(() {
      schedules = tpSchudles;  
    });
  }

  @override
  void initState() {
    super.initState();
    updateMultipleSchedules();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.launch),
            onPressed: () => {
              updateMultipleSchedules(),
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Days
          Row(
            children: [
              const SizedBox(width: 65), // Case vide avant le lundi
              for (var day in [
                'Lundi',
                'Mardi',
                'Mercredi',
                'Jeudi',
                'Vendredi'
              ])
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                    ),
                    padding: const EdgeInsets.all(1),
                    child: Center(
                      child: Text(
                        day,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),

          // Hours and courses
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 65,
                  color: Colors.grey[300],
                  child: Column(
                    children: [
                      for (var hour in [
                        '8:00',
                        '9:00',
                        '10:00',
                        '11:00',
                        '12:00',
                        '13:00',
                        '14:00',
                        '15:00',
                        '16:00',
                        '17:00',
                        '18:00',
                        '19:00',
                      ])

                        // Hours
                        Column(
                          children: [
                            Container(
                              color: Colors.grey[300],
                              padding: const EdgeInsets.all(2),
                              margin: const EdgeInsets.only(bottom: 2, left: 5),
                              alignment: Alignment.center,
                              child: Text(
                                hour,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              height: 28,
                              width: 5,
                              color: Colors.black,
                            ),
                          ],
                        ),
                    ],
                  ),
                ),

                // TimeTable
                Expanded(
                  flex: 5,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: schedules.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          for (var day in schedules[index].events)
                            Container(
                              child: Text
                              (day[0].summary),

                            )
                          // Container(
                          //   height: 100,
                          //   width: 100,
                          //   color: Colors.blue[300],
                          //   child: Center(child: 
                          //   Text(schedules[index].monday[1].summary)
                          //   ) 
                          // ),
                          // Container(
                          //   color: Colors.red[300],
                          //    height: 100,
                          //   width: 100,
                          //   child: Center(child: 
                          //   Text(schedules[index].monday[2].summary,)
                          //   ) 
                          // ),
                          
                        ],
                          

                          );
                          
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
