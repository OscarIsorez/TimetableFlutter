import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> lst = ["0", "1", "2", "3", "4", "5", "6", "7", "8"];
  PageController _pageController = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Schedule'),
        actions: [
          IconButton(
            icon: const Icon(Icons.launch),
            onPressed: () => {
              setState(() {}),
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
              for (var day in ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi'])
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
                              color: Colors.grey[100],
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
                    itemCount: lst.length,
                    itemBuilder: (context, index) {
                      return Container(
                        child: Center(child: Text(lst[index])),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black,
                            width: 1,
                          ),
                        ),
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
