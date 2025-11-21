import 'package:flutter/material.dart';
import 'package:gym_app/dialogs.dart';
import 'package:gym_app/open_program.dart';
import 'package:gym_app/programs_page.dart';
import 'package:gym_app/workout_log.dart';
import 'main.dart';
import 'dart:async';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'movements.dart';
import 'notification.dart';

class HomeScreen extends StatefulWidget {
final Function(int) selectedPageCallback;
final Function() refreshPageCallback;
static int streakLength = 0;
static DateTime? lastStreakDay;

const HomeScreen({required this.selectedPageCallback, required this.refreshPageCallback});
  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {

  final PageController _pageController = PageController(
    viewportFraction: 0.8,
  );

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Program? currentProgram;
  Week? currentWeek;
  day? currentDay;
  int weekIndex = 0;
  double initalOffset = 0;

  int favoritesIndex = 0;
  bool subtractMonthNumber = false;
  List<MovementLog> favoriteMovements = [];
  List<InkWell> currentWeekSlider = [];
  List<Container> statsSliderItems = [];




  refreshHomePageCallback() {
  setState(() {

  });
  }

  @override
  void initState() {
    if (HomeScreen.lastStreakDay != null) {
      DateTime twoDaysAgo = DateUtils.dateOnly(DateTime.now()).subtract(const Duration(days: 2));

      if (DateUtils.dateOnly(HomeScreen.lastStreakDay!).isBefore(twoDaysAgo)) {
        HomeScreen.streakLength = 0;
        HomeScreen.lastStreakDay = null;
        SharedPreferences.getInstance().then((prefs) {prefs.remove("lastStreakDay");});
      }
    }

    favoriteMovements = LogPage.movementsLogged.where((log) => log.favorited == true).toList();
    super.initState();
  }



  @override
  Widget build(BuildContext context) {

  outerLoop:
  for(Program program in ProgramsPage.programsList) {
    if (program.isCurrentProgram) {
      currentProgram = program;
      for (Week week in program.weeks) {
        for (day thisDay in week.days) {
          if (!thisDay.checked) {
            currentWeek = week;
           weekIndex = program.weeks.indexOf(week);

            currentDay = thisDay;
            break outerLoop;
          }
        }
      }
    }
  }




  return Scaffold(
      resizeToAvoidBottomInset: false,
      key: _scaffoldKey,
    appBar: AppBar(
      flexibleSpace: Container(
        decoration: BoxDecoration(
            gradient: Styles.darkGradient(),
          boxShadow: const [
            BoxShadow(
              color: Colors.black54,
              spreadRadius: 1,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],

        ),
      ),
      shadowColor: Colors.black54,
      iconTheme: const IconThemeData(color: Colors.white),
      title:  Row(
        children: [
          Icon(Icons.local_fire_department_sharp, size: 40, color: HomeScreen.lastStreakDay == DateUtils.dateOnly(DateTime.now()) ?  Colors.white : Colors.white54),
          Text(HomeScreen.streakLength.toString(), style: Styles.labelText.copyWith(color: HomeScreen.lastStreakDay == DateUtils.dateOnly(DateTime.now()) ? Colors.white : Colors.white54)),
         const Spacer(),
        ]
      ),
      actions: [
        IconButton(onPressed: () {
        _scaffoldKey.currentState?.openEndDrawer();
        }, icon: const Icon(Icons.menu, color: Colors.white, size: 35))
      ],
    ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
              gradient: Styles.horizontal()
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                if(GlobalTimerWidgetState.movementIndexOfTimer != -1)
                  Align(alignment: Alignment.centerLeft,
                      child: GlobalTimerWidget(selectedPageCallback: widget.selectedPageCallback)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                     SizedBox(height: MediaQuery.of(context).size.height * 0.09),
                     Container(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height * 0.063,
                        decoration: const BoxDecoration(
                          color: Colors.black26,
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.white70,
                                width: 1.5
                              ),
                            ),
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10)
                            )
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            children: [
                              Container(
                                constraints: BoxConstraints(
                                    maxWidth: MediaQuery.of(context).size.width * 0.7
                                ),
                                child: Text(currentProgram != null
                                    ? currentProgram!.name
                                    : "Current Program",
                                  style: Styles.regularText,
                                ),
                              ),
                              Expanded(
                                child: Text(currentWeek != null
                                  ? currentWeek!.name
                                  : "Empty",
                                  style: Styles.smallTextWhite,
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                        )),
                     Container(
                      decoration: const BoxDecoration(
                          color: Colors.black26,
                          border: Border(
                              bottom: BorderSide(
                                  color: Colors.white70
                              ),
                          ),
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(10),
                              bottomRight: Radius.circular(10)
                          )
                      ),
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.2,
                      child: currentWeek != null && currentWeek!.days.isNotEmpty ? CarouselSlider.builder(
                        itemCount: currentWeek?.days.length,
                        itemBuilder: (context, index, realIndex) {
                          day? thisDay = currentWeek?.days[index];
                          String dayOfWeek = _getDayOfWeek(index + 1);
                          return InkWell(
                            onTap: () {
                              ProgramsPage.activeProgramIndex = ProgramsPage.programsList.indexOf(currentProgram!);
                              if (GlobalTimerWidgetState.localTimerActive) {
                                GlobalTimerWidgetState.stopLocalTimer();
                                GlobalTimerWidgetState.startTimer();
                              }

                              Navigator.push(context, MaterialPageRoute(builder: (context) => DayWidget(
                                dayIndex: index,
                                weekIndex: weekIndex,
                                refreshParent: () {
                                  setState(() {

                                  });
                                },
                              )));
                            },
                            child: Column(
                              children: [
                                if (thisDay == currentDay)...[
                                  SizedBox(height: MediaQuery.of(context).size.height * 0.040,
                                      child: const Align(alignment: Alignment.bottomCenter,
                                          child: Text("Next lift", style: Styles.regularText)
                                      )),
                                ]
                                else...[SizedBox(height: MediaQuery.of(context).size.height * 0.05)],


                                Container(
                                  width: MediaQuery.of(context).size.height * 0.15,
                                  height: MediaQuery.of(context).size.height * 0.12,
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  decoration: BoxDecoration(
                                    color: thisDay!.checked ? Colors.black26 : Colors.black12,
                                    border: Border.all(
                                      color: thisDay.checked ? Colors.white54 : Colors.white70,
                                    ),
                                    borderRadius: const BorderRadius.all(Radius.circular(15)),
                                  ),
                                  child: Center(
                                        child: Column(
                                          children: [
                                            Text(dayOfWeek, style: Styles.paragraph.copyWith(color: Colors.white, fontWeight: FontWeight.normal), textAlign: TextAlign.center),
                                            const Spacer(),
                                            if (thisDay.checked) Icon(Icons.check, color: Colors.white, size: MediaQuery.of(context).size.height * 0.05),
                                            const Spacer(),
                                            Text(thisDay.name, style: Styles.paragraph.copyWith(fontWeight: FontWeight.normal), textAlign: TextAlign.center),
                                          ],
                                        ),
                                      ),
                                ),
                              ],
                            ),
                          );
                        },
                        options: CarouselOptions(
                          height: double.infinity,
                          viewportFraction: 0.55,
                          enlargeCenterPage: true,
                          enableInfiniteScroll: false,
                          initialPage: currentWeek != null ? currentWeek!.days.indexOf(currentDay!) : 0,
                        ),
                      )
                          : Center(
                          child: Text(currentProgram != null ? "No data found in current program" : "Selected current program will appear here", style: Styles.paragraph, textAlign: TextAlign.center)
                      )
                    ),
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.10),
                Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.063,
                    decoration: const BoxDecoration(
                        color: Colors.black26,
                        border: Border(
                          bottom: BorderSide(
                              color: Colors.white70,
                              width: 1.5
                          ),
                        ),
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10)
                        )
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        children: [
                          const Text(
                              "Progress",
                              style: Styles.regularText,
                            ),
                          Expanded(
                            child: Text(favoriteMovements.isNotEmpty
                                ? favoriteMovements[favoritesIndex].name
                              : "Empty",
                              style: Styles.smallTextWhite,
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    )),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  height: favoriteMovements.isNotEmpty ? MediaQuery.of(context).size.height * 0.3 : MediaQuery.of(context).size.height * 0.2,
                  decoration: const BoxDecoration(
                      color: Colors.black26,
                      border: Border(
                        bottom: BorderSide(
                            color: Colors.white70
                        ),
                      ),
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10)
                      )
                  ),
                child: favoriteMovements.isNotEmpty ? PageView.builder(
                  controller: _pageController,
                  scrollDirection: Axis.vertical,
                  itemCount: favoriteMovements.length,
                  itemBuilder: (context, index) {
                    subtractMonthNumber = false;
                    List<ResultSetBlock> thisDatesBlocks = favoriteMovements[index].resultSetBlocks.where((block) => block.date.month == DateTime.now().month && block.date.year == DateTime.now().year).toList();
                    if (thisDatesBlocks.length <= 1) {
                      subtractMonthNumber = true;
                      thisDatesBlocks = favoriteMovements[index].resultSetBlocks.where((block) => block.date.month == (DateTime.now().month - 1) && block.date.year == DateTime.now().year).toList();
                    }
                    return ProgressChart(
                        subtractMonth: subtractMonthNumber == true ? true : null,
                        displaySmall: true,
                        refreshListLength: (){},
                        thisDatesBlocks: thisDatesBlocks,
                        refreshYearNumber: (){},
                        refreshMonthNumber: (){});
                  },

                  onPageChanged: (index) {
                    setState(() {
                      favoritesIndex = index;
                    });
                  },
                 )
                    : const Center(
                    child: Text("Favorite movements in your workout log will appear here",
                        style: Styles.paragraph, textAlign: TextAlign.center)),
                ),
                SizedBox(height: MediaQuery.of(context).size.height / 5)
             ],
            ),
          ),

        ),
    endDrawer:  Drawer(width: MediaQuery.of(context).size.width * 0.85,
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            body: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                  gradient: Styles.horizontal(),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [

                    const SizedBox(height: 60),
                    AppSettings(refreshPageCallback: widget.refreshPageCallback, refreshHomePageCallback: refreshHomePageCallback),

                    const SizedBox(height: 60),
                    MuscleGroups(),

                    /*
                    const SizedBox(height: 60),
                    const ListTile(
                    horizontalTitleGap: 5,
                    leading: Icon(Icons.help_center, color: Colors.white, size: 35),
                    title: Text("Help center", style: Styles.regularText)),
                    const Divider(height: 0),
                     */

                    ],
                ),
              ),
            )
        )
    )
  );
  }
}






class GlobalTimerWidget extends StatefulWidget {
final Function selectedPageCallback;

const GlobalTimerWidget({required this.selectedPageCallback});
  @override
  State<GlobalTimerWidget> createState() => GlobalTimerWidgetState();
}

class GlobalTimerWidgetState extends State<GlobalTimerWidget> {

  static day dayOfTimer = day(id: -1, name: "", movements: []);
  static Movement movementOfTimer = Movement(notes: 'notes', name: 'movementName', sets: 0, reps: '0', rir: '0', weight: 0, rest: const Duration(), remainingRestTime: const Duration(), resultSets: []);
  static int movementIndexOfTimer = -1;
  static int programIndexOfTimer = -1;

  static void getTimerData(int newProgramIndexOfTimer, day newDayOfTimer, int newIndexOfTimer, Movement newMovementOfTimer, Function newRefreshPageFunction) {
    if (movementIndexOfTimer != -1) {
      stopTimer(); // clear the last timer
    }

    dayOfTimer = newDayOfTimer;
    movementOfTimer = newMovementOfTimer;
    movementIndexOfTimer = newIndexOfTimer;
    programIndexOfTimer = newProgramIndexOfTimer;
  }

  static bool backgroundTimerActive = false;
  static Timer? secondsTimer;

  static void stopTimer() {
    backgroundTimerActive = false;
    secondsTimer?.cancel();
  }

  static void startTimer() {
    backgroundTimerActive = true;
    secondsTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (movementOfTimer.remainingRestTime.inSeconds > 0) {
        movementOfTimer.remainingRestTime -= const Duration(milliseconds: 100);
      }
      else {
        NotificationServices().showNotification(title: "Timer Done", body: "Your rest time for '${movementOfTimer.name}' is done");
        stopTimer();
      }
      ProgramsPage.programsList[programIndexOfTimer].save();
    });
  }

  static bool localTimerActive = false;
  static Timer? localSecondsTimer;

  static void stopLocalTimer() {
    localTimerActive = false;
    localSecondsTimer?.cancel();
  }

  void startLocalTimer() {
    localTimerActive = true;
    localSecondsTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        if (movementOfTimer.remainingRestTime.inSeconds > 0) {
          movementOfTimer.remainingRestTime -= const Duration(milliseconds: 100);
        }
        else {
          NotificationServices().showNotification(title: "Timer Done", body: "Your rest time for '${movementOfTimer.name}' is done");
          stopLocalTimer();
        }
      });
      ProgramsPage.programsList[programIndexOfTimer].save();
    });
  }


  void navigate(BuildContext context) {
     if(localTimerActive == true) {
       stopLocalTimer(); backgroundTimerActive = true;
       // this is because dispose isn't called when you navigator.push,
       // so it stops the local timer and starts the global one again
     }

    ProgramsPage.activeProgramIndex = programIndexOfTimer;
    //Navigator.push(context, MaterialPageRoute(builder: (context) => openProgram()));

    bool dayFound = false; /* this is because I ran into a bug where the for loop would
                              continue to run even after the day was found and it would
                              open a bunch of copies of the same page
                           */
    for (int programIndex = 0; programIndex < ProgramsPage.programsList.length; programIndex++) {
      Program currentProgram = ProgramsPage.programsList[programIndex];

      for (int weekIndex = 0; weekIndex < currentProgram.weeks.length; weekIndex++) {
        Week currentWeek = currentProgram.weeks[weekIndex];

        for (int dayIndex = 0; dayIndex < currentWeek.days.length; dayIndex++) {
          if (currentWeek.days[dayIndex].id == dayOfTimer.id && dayFound != true) {
            dayFound = true;
            Navigator.push(context, MaterialPageRoute(
                builder: (context) => OpenMovement(
                    thisMovement: GlobalTimerWidgetState.movementOfTimer,
                    movementIndex: GlobalTimerWidgetState.movementIndexOfTimer,
                    currentDay: GlobalTimerWidgetState.dayOfTimer,
                    refreshPage: () {
                      setState(() {

                      });
                    }
                )));
          }
        }
      }
    }
  }


  @override
  void dispose() {
    if (localTimerActive == true) {
      GlobalTimerWidgetState.startTimer();
      stopLocalTimer();
    }
    super.dispose();
  }




  @override
  Widget build(BuildContext context) {
     if (GlobalTimerWidgetState.backgroundTimerActive == true) {
    startLocalTimer();
    GlobalTimerWidgetState.stopTimer();
  }

    String restSeconds = (movementOfTimer.remainingRestTime.inSeconds -
        60 * movementOfTimer.remainingRestTime.inMinutes).toString();
    if (restSeconds.length == 1) {
      restSeconds = "0$restSeconds";
    }


    return Column(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.03),
        InkWell(
             onTap: () {
               if(movementIndexOfTimer != -1) {
                 navigate(context);
               }
               else {
                 ScaffoldMessenger.of(context).showSnackBar(
                   SnackBar(
                     backgroundColor: Colors.white,
                     content: Text('No active movement',
                         style: TextStyle(
                             color: Styles.primaryColor)),
                     duration:
                     const Duration(milliseconds: 1500),
                   ),
                 );
               }
             },
         child: Container(
                 padding: const EdgeInsets.only(left: 5, right: 10, top: 5),
                 width: MediaQuery.of(context).size.width * 0.45,
                 height: 70,
                   decoration: const BoxDecoration(
                     color: Colors.black12,
                       borderRadius:  BorderRadius.only(
                             bottomRight: Radius.circular(20),
                             topRight: Radius.circular(20)
                       ),
                       border: Border(
                           top: BorderSide(
                               color: Colors.white54,
                               width: 2
                           ),
                           bottom: BorderSide(
                               color: Colors.white54,
                               width: 2
                           ),
                           right: BorderSide(
                               color: Colors.white54,
                               width: 2
                           ),
                       ),
                   ),
                   child: Column(
                     children: [
                        Text(movementOfTimer.name, style: Styles.paragraph.copyWith(overflow: TextOverflow.ellipsis, color: Colors.white)),
                        const Divider(color: Colors.white54),
                         Row(
                           mainAxisAlignment: MainAxisAlignment.center,
                         children: [
                           const Text("Rest:", style: Styles.smallTextWhite),
                           SizedBox(
                             width: 40,
                               child: Text("${movementOfTimer.remainingRestTime.inMinutes.toString()}:$restSeconds", style: Styles.smallTextWhite, textAlign: TextAlign.right)),
                         ],
                       ),
                        const Spacer(),
                     ],
                   )),
        ),
      ],
    );
  }
}



class AppSettings extends StatefulWidget {
final Function() refreshPageCallback;
final Function() refreshHomePageCallback;
static bool rirActive = true;
static bool lbActive = true;
static String selectedUnit = "LB";
static String dateFormat = "M/dd/yy";
static String selectedTheme = "Blue";
static setColor () {
  switch (AppSettings.selectedTheme) {

    case "Dark":
      List<Color> verticalColors = [
        const Color(0xFF121212),
        const Color(0xFF1E1E1E),
        const Color(0xFF282828),
        const Color(0xFF303030),
        const Color(0xFF383838)
      ];

      List<Color> horizontalColors = [
        const Color(0xFF121212),
        const Color(0xFF1E1E1E),
        const Color(0xFF282828),
        const Color(0xFF303030),
        const Color(0xFF383838)
      ];

      List<Color> darkColors = [
        const Color(0xFF0D0D0D),
        const Color(0xFF191919),
        const Color(0xFF212121),
        const Color(0xFF2B2B2B)
      ];

      Styles.setVerticalColors(verticalColors);
      Styles.setDarkColors(darkColors);
      Styles.setHorizontalColors(horizontalColors);
      Styles.primaryColor = const Color(0xFF212121);
      Styles.chartColor = const Color(0xFF212121);
      Styles.secondaryColor = const Color(0xFF212121);
      break;

    case "Coral":
      List<Color> verticalColors = [
        const Color(0xFFD84C4C),
        const Color(0xFFE55A5A),
        const Color(0xFFE96969),
        const Color(0xFFE27B7B),
        const Color(0xFFEA9595)
      ];
      List<Color> horizontalColors = [
        const Color(0xFFD84C4C),
        const Color(0xFFE55A5A),
        const Color(0xFFE96969),
        const Color(0xFFE27B7B),
        const Color(0xFFEA9595)
      ];
      List<Color> darkColors = [
        const Color(0xFFC25151),
        const Color(0xFFD06767),
        const Color(0xFFD87777),
      ];


      Styles.setVerticalColors(verticalColors);
      Styles.setDarkColors(darkColors);
      Styles.setHorizontalColors(horizontalColors);
      Styles.primaryColor = const Color(0xFFD84C4C);
      Styles.chartColor = const Color(0xFFE96969);
      Styles.secondaryColor = const Color(0xFFD87777);
      break;

    case "Blue":
      List<Color> verticalColors = [
        const Color(0xFF0A1C43),
        const Color(0xFF0C2251),
        const Color(0xFF0D2B56),
        const Color(0xFF0C3A62),
        const Color(0xFF1E4E70)
      ];
      List<Color> horizontalColors = [
        const Color(0xFF0A1C43),
        const Color(0xFF0C2251),
        const Color(0xFF0D2B56),
        const Color(0xFF0C3A62),
        const Color(0xFF1E4E70)
      ];
      List<Color> darkColors = [
        const Color(0xFF01152b),
        const Color(0xFF03274f),
        const Color(0xFF042f5e),
        const Color(0xFF0a4482),
      ];

      Styles.setVerticalColors(verticalColors);
      Styles.setDarkColors(darkColors);
      Styles.setHorizontalColors(horizontalColors);
      Styles.primaryColor = const Color(0xFF10396A);
      Styles.chartColor = const Color(0xFF10396A);
      Styles.secondaryColor = const Color(0xFF042f5e);
      break;

    case "Pink":
      List<Color> verticalColors = [
        const Color(0xFFE1008C),
        const Color(0xFFE3009C),
        const Color(0xFFE400A6),
        const Color(0xFFE300C2),
        const Color(0xFFE700E5)
      ];
      List<Color> horizontalColors = [
        const Color(0xFFE1008C),
        const Color(0xFFE3009C),
        const Color(0xFFE400A6),
        const Color(0xFFE300C2),
        const Color(0xFFE700E5)
      ];
      List<Color> darkColors = [
        const Color(0xFFE3008A),
        const Color(0xFFE300AD),
        const Color(0xFFE400BD),
        const Color(0xFFE500E1),
      ];

      Styles.setVerticalColors(verticalColors);
      Styles.setDarkColors(darkColors);
      Styles.setHorizontalColors(horizontalColors);
      Styles.primaryColor = const Color(0xFFE400A6);
      Styles.chartColor = const Color(0xFFE400A6);
      Styles.secondaryColor = const Color(0xFFE400BD);
      break;

    case "Purple":
      List<Color> verticalColors = [
        const Color(0xFF6B207E),
        const Color(0xFF7A2C94),
        const Color(0xFF8A369F),
        const Color(0xFF9C43AF),
        const Color(0xFFAE53C1)
      ];
      List<Color> horizontalColors = [
        const Color(0xFF6B207E),
        const Color(0xFF7A2C94),
        const Color(0xFF8A369F),
        const Color(0xFF9C43AF),
        const Color(0xFFAE53C1)
      ];
      List<Color> darkColors = [
        const Color(0xFF7C0098),
        const Color(0xFF7A2C94),
        const Color(0xFF8A369F),
      ];


      Styles.setVerticalColors(verticalColors);
      Styles.setDarkColors(darkColors);
      Styles.setHorizontalColors(horizontalColors);
      Styles.primaryColor = const Color(0xFF6B207E);
      Styles.chartColor = const Color(0xFF6B207E);
      Styles.secondaryColor = const Color(0xFF6B207E);
      break;

    case "Dark yellow":
      List<Color> verticalColors = [
        const Color(0xFFB8860B),
        const Color(0xFFCD853F),
        const Color(0xFFDAA520),
        const Color(0xFFB8860B),
      ];
      List<Color> horizontalColors = [
        const Color(0xFFB8860B),
        const Color(0xFFCD853F),
        const Color(0xFFDAA520),
        const Color(0xFFB8860B),
      ];
      List<Color> darkColors = [
        const Color(0xFFB8860B),
        const Color(0xFFCD853F),
        const Color(0xFFDAA520),
        const Color(0xFFB8860B)
      ];

      Styles.setVerticalColors(verticalColors);
      Styles.setDarkColors(darkColors);
      Styles.setHorizontalColors(horizontalColors);
      Styles.primaryColor = const Color(0xFFDAA520);
      Styles.chartColor = const Color(0xFFDAA520);
      Styles.secondaryColor = const Color(0xFFDAA520);
      break;

    case "Red":
      List<Color> verticalColors = [
        const Color(0xFF8B0000),
        const Color(0xFFB22222),
        const Color(0xFFDC143C),
        const Color(0xFFA52A2A)
      ];
      List<Color> horizontalColors = [
        const Color(0xFF8B0000),
        const Color(0xFFB22222),
        const Color(0xFFDC143C),
        const Color(0xFFA52A2A)
      ];
      List<Color> darkColors = [
        const Color(0xFF8B0000),
        const Color(0xFFB22222),
        const Color(0xFFDC143C),
        const Color(0xFFA52A2A),
      ];

      Styles.setVerticalColors(verticalColors);
      Styles.setDarkColors(darkColors);
      Styles.setHorizontalColors(horizontalColors);
      Styles.primaryColor = const Color(0xFFB22222);
      Styles.chartColor = const Color(0xFFB22222);
      Styles.secondaryColor = const Color(0xFFB22222);
      break;

    case "Green":
      List<Color> verticalColors = [
        const Color(0xFF006400),
        const Color(0xFF008000),
        const Color(0xFF228B22),
        const Color(0xFF006400),
      ];
      List<Color> horizontalColors = [
        const Color(0xFF006400),
        const Color(0xFF008000),
        const Color(0xFF228B22),
        const Color(0xFF006400),
      ];
      List<Color> darkColors = [
        const Color(0xFF006400),
        const Color(0xFF008000),
        const Color(0xFF228B22),
        const Color(0xFF006400),
      ];

      Styles.setVerticalColors(verticalColors);
      Styles.setDarkColors(darkColors);
      Styles.setHorizontalColors(horizontalColors);
      Styles.primaryColor = const Color(0xFF008000);
      Styles.chartColor = const Color(0xFF008000);
      Styles.secondaryColor = const Color(0xFF006400);
      break;

    case "Orange":
      List<Color> verticalColors = [
        const Color(0xFFFF7F00),
        const Color(0xFFFF8C00),
        const Color(0xFFFFA500),
        const Color(0xFFFFBB33),
        const Color(0xFFFFD700)
      ];
      List<Color> horizontalColors = [
        const Color(0xFFFF7F00),
        const Color(0xFFFF8C00),
        const Color(0xFFFFA500),
        const Color(0xFFFFBB33),
        const Color(0xFFFFD700)
      ];
      List<Color> darkColors = [
        const Color(0xFFFF7F00),
        const Color(0xFFFF8C00),
        const Color(0xFFFFA500),
        const Color(0xFFFFBB33),
      ];

      Styles.setVerticalColors(verticalColors);
      Styles.setDarkColors(darkColors);
      Styles.setHorizontalColors(horizontalColors);
      Styles.primaryColor = const Color(0xFFFF8C00);
      Styles.chartColor = const Color(0xFFFF8C00);
      Styles.secondaryColor = const Color(0xFFFF7F00);
      break;

  }
}

const AppSettings({required this.refreshPageCallback, required this.refreshHomePageCallback});


  @override
  State<AppSettings> createState() => _AppSettingsState();
}

class _AppSettingsState extends State<AppSettings> {


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const ListTile(
            horizontalTitleGap: 5,
            leading: Icon(Icons.settings, color: Colors.white, size: 35),
            title: Text("Preferences", style: Styles.regularText)),
        const Divider(height: 0),
        Container(
          height: 275,
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
            color: Colors.black12,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20)
            )
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Text("Color theme:", style: Styles.paragraph),
                  const Spacer(),
                  DropdownButton(
                      value: AppSettings.selectedTheme,
                      style: Styles.smallTextWhite,
                      dropdownColor: Styles.primaryColor,
                      items: const [
                        DropdownMenuItem(value: "Dark", child: Text("Dark")),
                        DropdownMenuItem(value: "Red", child: Text("Red")),
                        DropdownMenuItem(value: "Orange", child: Text("Orange")),
                        DropdownMenuItem(value: "Dark yellow", child: Text("Dark yellow")),
                        DropdownMenuItem(value: "Green", child: Text("Green")),
                        DropdownMenuItem(value: "Blue", child: Text("Blue")),
                        DropdownMenuItem(value: "Purple", child: Text("Purple")),
                        DropdownMenuItem(value: "Pink", child: Text("Pink")),
                        DropdownMenuItem(value: "Coral", child: Text("Coral")),
                      ], onChanged: (value) {
                    setState(() {
                      AppSettings.selectedTheme = value!;
                      AppSettings.setColor();
                      widget.refreshHomePageCallback();
                      widget.refreshPageCallback();
                        () async {
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        prefs.setString("selectedTheme", AppSettings.selectedTheme);
                      }();

                    });
                  }
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                  children: [
                    const Text("Date format:", style: Styles.paragraph),
                    const Spacer(),
                    DropdownButton(
                        value: AppSettings.dateFormat,
                        style: Styles.smallTextWhite,
                        dropdownColor: Styles.primaryColor,
                        items: const [
                          DropdownMenuItem(value: "dd/M/yy", child: Text("dd/M/yy")),
                          DropdownMenuItem(value: "M/dd/yy", child: Text("M/dd/yy")),
                        ], onChanged: (value) {
                      setState(() {
                        AppSettings.dateFormat = value!;
                        () async {
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          prefs.setString("dateFormat", AppSettings.dateFormat);
                        }();
                      });
                    }
                    ),
                  ]),
              const SizedBox(height: 10),
              Row(
                  children: [
                    const Text("Unit of mass:", style: Styles.paragraph),
                    const Spacer(),
                    DropdownButton(
                        value: AppSettings.selectedUnit,
                        style: Styles.smallTextWhite,
                        dropdownColor: Styles.primaryColor,
                        items: const [
                          DropdownMenuItem(value: "KG", child: Text("KG")),
                          DropdownMenuItem(value: "LB", child: Text("LB")),
                        ], onChanged: (value) {
                      setState(() {
                        AppSettings.selectedUnit = value!;
                          () async {
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          prefs.setString("selectedUnit", AppSettings.selectedUnit);
                        }();
                      });
                    }
                    ),
               ]
              ),
              const Spacer(),
              Row(
                  children: [
                    Switch(
                        activeColor: Colors.white,
                        inactiveThumbColor: Styles.primaryColor,
                        activeTrackColor: Colors.white38,
                        value: AppSettings.rirActive,
                        onChanged: (value) {
                          setState(() {
                            AppSettings.rirActive = value;
                              () async {
                              SharedPreferences prefs = await SharedPreferences.getInstance();
                              prefs.setBool("rirActive", AppSettings.rirActive);
                            }();
                          });
                        }),
                    const Text(" Include RIR", style: Styles.smallTextWhite),
                  ]),
            ],
          ),
        ),
      ],
    );
  }
}


class MuscleGroups extends StatefulWidget {
  static List <String> muscleGroupsList = ["Chest", "Back", "Biceps", "Triceps", "Shoulders", "Forearms", "Legs", "Abs"];
  final List <String> defaultMuscleGroups = ["Chest", "Back", "Biceps", "Triceps", "Shoulders", "Forearms", "Legs", "Abs"];



  @override
  State<MuscleGroups> createState() => _MuscleGroupsState();
}

class _MuscleGroupsState extends State<MuscleGroups> {
  bool deletingActive = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const ListTile(
            horizontalTitleGap: 5,
            leading: Icon(Icons.fitness_center, color: Colors.white, size: 35),
            title: Text("Muscle groups", style: Styles.regularText)),
        const Divider(height: 0),

        Container(
          height: 275,
            width: double.infinity,
        decoration: const BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(20),
        bottomRight: Radius.circular(20)
        )
        ),
          child: Column(
            children: [
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),

                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    mainAxisExtent: 55,
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 20,
                  ),
                  itemCount: MuscleGroups.muscleGroupsList.length,
                  itemBuilder: (context, index) {
                    return Stack(
                            children: [
                              Positioned(bottom: 0, left: 0,
                                child: Container(
                                  height: 49,
                                  width: MediaQuery.of(context).size.width * 0.3,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
                                    border: Border.all(
                                      color: Colors.white54,
                                      width: 2.0,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      MuscleGroups.muscleGroupsList[index],
                                      textAlign: TextAlign.center,
                                      style: Styles.paragraph
                                    ),
                                  ),
                                ),
                              ),
                              if (deletingActive && !widget.defaultMuscleGroups.contains(MuscleGroups.muscleGroupsList[index]))
                                Positioned(
                                  bottom: 22, left: 105,
                                  child: IconButton(onPressed: () {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return ConfirmationDialog(content: "Are you sure you want to delete the '${MuscleGroups.muscleGroupsList[index]}' muscle group? This will remove it from all instances.", callbackFunction: () {
                                            setState(() {
                                              for (MovementLog log in LogPage.movementsLogged) {
                                                if (log.primaryMuscleGroups != null) {
                                                  for (int i = log.primaryMuscleGroups!.length - 1; i >= 0; i--) {
                                                    if (log.primaryMuscleGroups![i].replaceAll(RegExp(r'\s+'), '').toLowerCase() == MuscleGroups.muscleGroupsList[index].replaceAll(RegExp(r'\s+'), '').toLowerCase()) {
                                                      log.primaryMuscleGroups!.removeAt(i);
                                                    }
                                                  }
                                                }
                                                if (log.secondaryMuscleGroups != null) {
                                                  for (int i = log.secondaryMuscleGroups!.length - 1; i >= 0; i--) {
                                                    if (log.secondaryMuscleGroups![i].replaceAll(RegExp(r'\s+'), '').toLowerCase() == MuscleGroups.muscleGroupsList[index].replaceAll(RegExp(r'\s+'), '').toLowerCase()) {
                                                      log.secondaryMuscleGroups!.removeAt(i);
                                                    }
                                                  }
                                                }
                                              }

                                              for (Program program in ProgramsPage.programsList) {
                                                for (Week week in program.weeks) {
                                                  for (day thisDay in week.days) {
                                                     if (thisDay.muscleGroups != null) {
                                                       for (int i = thisDay.muscleGroups!.length - 1; i >= 0; i--) {
                                                         if (thisDay.muscleGroups![i].replaceAll(RegExp(r'\s+'), '').toLowerCase() == MuscleGroups.muscleGroupsList[index].replaceAll(RegExp(r'\s+'), '').toLowerCase()) {
                                                           thisDay.muscleGroups!.removeAt(i);
                                                         }
                                                       }
                                                     }
                                                  }
                                                }
                                              }
                                              if (copiedWeeksDays != null) {
                                                for (int dayIndex = 0; dayIndex < copiedWeeksDays!.length; dayIndex++) {
                                                  if (copiedWeeksDays![dayIndex].muscleGroups != null) {
                                                    for (int muscleGroupIndex = copiedWeeksDays![dayIndex].muscleGroups!.length - 1; muscleGroupIndex >= 0; muscleGroupIndex--) {
                                                      if (copiedWeeksDays![dayIndex].muscleGroups![muscleGroupIndex].replaceAll(RegExp(r'\s+'), '').toLowerCase() == MuscleGroups.muscleGroupsList[index].replaceAll(RegExp(r'\s+'), '').toLowerCase()) {
                                                        copiedWeeksDays![dayIndex].muscleGroups!.removeAt(muscleGroupIndex);
                                                      }
                                                    }
                                                  }
                                                }
                                              }

                                              if (copiedDay != null) {
                                                if(copiedDay!.muscleGroups != null) {
                                                  for (int muscleGroupIndex = copiedDay!.muscleGroups!.length - 1; muscleGroupIndex >= 0; muscleGroupIndex--) {
                                                    if (copiedDay!.muscleGroups![muscleGroupIndex].replaceAll(RegExp(r'\s+'), '').toLowerCase() == MuscleGroups.muscleGroupsList[index].replaceAll(RegExp(r'\s+'), '').toLowerCase()) {
                                                      copiedDay!.muscleGroups!.removeAt(muscleGroupIndex);
                                                    }
                                                  }
                                                }
                                              }



                                              MuscleGroups.muscleGroupsList.removeAt(index);
                                            });
                                          });
                                        }
                                    );

                                  }, icon: const Icon(Icons.remove_circle, color: Colors.white, size: 20)),
                                ),
                            ],
                          );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(onPressed: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return EditDialog(
                              identifier: "Name", dataToEdit: "", editData: (name, identifier) {
                                name = name.trim();
                            if (!MuscleGroups.muscleGroupsList.any((group) => group.replaceAll(RegExp(r'\s+'), '').toLowerCase() == name.replaceAll(RegExp(r'\s+'), '').toLowerCase())) {
                              if (name != "" && name.replaceAll(RegExp(r'\s+'), '').toLowerCase() != "unspecified") {
                                setState(() {
                                  MuscleGroups.muscleGroupsList.add(name);
                                  () async {
                                    SharedPreferences prefs = await SharedPreferences
                                        .getInstance();
                                    prefs.setStringList("muscleGroups",
                                        MuscleGroups.muscleGroupsList);
                                  }
                                  ();
                                });
                                 }
                                }
                                else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: Colors.white,
                                      content: Text('Already exists in your muscle groups',
                                          style: TextStyle(
                                              color: Styles.primaryColor)),
                                      duration:
                                      const Duration(milliseconds: 1500),
                                    ),
                                  );
                                }
                              });
                        }
                    );

                  }, icon: const Icon(Icons.add_circle, color: Colors.white, size: 30)),
                  IconButton(onPressed: () {
                    setState(() {
                      if (MuscleGroups.muscleGroupsList.length != widget.defaultMuscleGroups.length) {
                        deletingActive = !deletingActive;
                      }
                      else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.white,
                            content: Text('Cannot delete default muscle groups',
                                style: TextStyle(
                                    color: Styles.primaryColor)),
                            duration:
                            const Duration(milliseconds: 1500),
                          ),
                        );
                      }
                    });
                  }, icon: const Icon(Icons.delete, color: Colors.white, size: 30)),
                ],
              ),

            ],
          ),
        ),
      ],
    );
  }
}


String _getDayOfWeek(int weekday) {
  switch (weekday) {
    case 1:
      return 'Monday';
    case 2:
      return 'Tuesday';
    case 3:
      return 'Wednesday';
    case 4:
      return 'Thursday';
    case 5:
      return 'Friday';
    case 6:
      return 'Saturday';
    case 7:
      return 'Sunday';
    default:
      return '';
  }
}

