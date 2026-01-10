import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:gym_app/preset_programs.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';
import 'home_screen.dart';
import 'movements.dart';
import 'programs_page.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'workout_log.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'notification.dart';
part 'main.g.dart';

final GlobalKey templateKey = GlobalKey();
final GlobalKey programPageKey = GlobalKey();
final GlobalKey logPageKey = GlobalKey();

class ShowcaseTemplate extends StatefulWidget {
  final GlobalKey globalKey;
  final int stepID;
  final double radius;
  final Widget child;
  final String title;
  final String content;

  static Set<int> previousSteps = {};


  const ShowcaseTemplate({required this.radius, required this.globalKey, required this.stepID, required this.title, required this.content, required this.child});

  @override
  ShowcaseTemplateState createState() => ShowcaseTemplateState();
}

class ShowcaseTemplateState extends State<ShowcaseTemplate> {


  @override
  initState() {
    super.initState();

    () async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (prefs.getStringList('showcaseList') != null) {
        List<String> stringList = prefs.getStringList('showcaseList')!.toList();
        for (int i = 0; i < stringList.length; i ++) {
          ShowcaseTemplate.previousSteps.add(int.parse(stringList[i]));
        }
      }

      prefs.setStringList('showcaseList', ShowcaseTemplate.previousSteps.map((e) => e.toString()).toList());
    }();
  }

  @override
  Widget build(BuildContext context) {

    if (!ShowcaseTemplate.previousSteps.contains(widget.stepID) && !ShowcaseTemplate.previousSteps.contains(-1) && !(widget.stepID == 35 && (LogPage.movementsLogged.isNotEmpty || ProgramsPage.programsList.isNotEmpty))) {
      ShowcaseTemplate.previousSteps.add(widget.stepID);

      return Showcase(
        targetBorderRadius: BorderRadius.all(
          Radius.circular(widget.radius),
        ),
        titleTextAlign: TextAlign.center,
        descTextStyle: TextStyle(color: Styles.primaryColor),
        titleTextStyle: TextStyle(color: Styles.primaryColor, fontWeight: FontWeight.bold, fontSize: 18),
        descriptionTextAlign: TextAlign.center,
        title: widget.title,
        description: widget.content,
        key: widget.globalKey,
        child: widget.child,
      );
    } else {
      return widget.child;
    }
  }
}


Future main() async {
  await Hive.deleteFromDisk();
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  NotificationServices().initNotification();

  Future<void> getPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    HomeScreen.streakLength = prefs.getInt("streakLength") ?? prefs.getInt("streakLength") ?? 0;
    String? lastStreakDayString = prefs.getString("lastStreakDay");
    HomeScreen.lastStreakDay = lastStreakDayString != null ? DateTime.parse(lastStreakDayString) : null;
    MuscleGroups.muscleGroupsList = prefs.getStringList("muscleGroups") ?? prefs.getStringList("muscleGroups") ?? MuscleGroups.muscleGroupsList;
    PresetPrograms.easterEggDiscovered = prefs.getBool("easterEggDiscovered") ?? prefs.getBool("easterEggDiscovered") ?? false;
    ProgramsPage.globalDayID = prefs.getInt("globalDayID") ?? prefs.getInt("globalDayID") ?? 0;
    AppSettings.dateFormat = prefs.getString("dateFormat") ?? prefs.getString("dateFormat") ?? AppSettings.dateFormat;
    ChartSettings.selectedFormula = prefs.getString("selectedFormula") ?? prefs.getString("selectedFormula") ?? ChartSettings.selectedFormula;
    ChartSettings.lineColor = prefs.getString("lineColor") ?? prefs.getString("lineColor") ?? ChartSettings.lineColor;
    ChartSettings.dataDisplay = prefs.getString("dataDisplay") ?? prefs.getString("dataDisplay") ?? ChartSettings.dataDisplay;
    ProgressChart.yearViewActive = prefs.getBool("yearViewActive") ?? prefs.getBool("yearViewActive") ?? true;
    ProgressChart.dotsActive = prefs.getBool("dotsActive") ?? prefs.getBool("dotsActive") ?? false;
    AppSettings.rirActive = prefs.getBool("rirActive") ?? prefs.getBool("rirActive") ?? true;
    AppSettings.selectedUnit = prefs.getString("selectedUnit") ?? prefs.getString("selectedUnit") ?? AppSettings.selectedUnit;
    AppSettings.selectedTheme = prefs.getString("selectedTheme") ?? prefs.getString("selectedTheme") ?? AppSettings.selectedTheme;
    AppSettings.setColor();
  }


  await getPrefs();

  await Hive.initFlutter();

  Hive.registerAdapter(ResultSetAdapter());

  Hive.registerAdapter(MovementAdapter());

  Hive.registerAdapter(DayAdapter());

  Hive.registerAdapter(WeekAdapter());

  Hive.registerAdapter(ProgramAdapter());
  await Hive.openBox<Program>('programs');

  Hive.registerAdapter(ResultSetBlockAdapter());

  Hive.registerAdapter(GoalAdapter());

  Hive.registerAdapter(MovementLogAdapter());
  await Hive.openBox<MovementLog>('logs');

  /*
  Remember that the order in which you register the adapters is very important.
  You have to register the child adapter before the parent if a class has an object
  as a property. So for example, you have to register days before you can register weeks, and weeks before programs etc.
   */




  runApp(MyApp());
}

class MyApp extends StatelessWidget {


  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          backgroundColor: Colors.white,
        ),
      ),
      home: PageManager()
    );
  }
}


class PageManager extends StatefulWidget {

  @override
  PageManagerState createState() => PageManagerState();
}

class PageManagerState extends State<PageManager> with WidgetsBindingObserver {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  DateTime? start;
  Duration? difference;
 static int selectedIndex = 1;
 List<Widget> _pages = <Widget>[];


  Future <void> onItemTapped(int index) async {
    setState(() {
      selectedIndex = index;
    });
  }

  refreshPageCallback() {
    setState(() {

    });
  }


  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    //this is to disable any timers that did not get disabled if the app abruptly closed
    for (int programIndex = 0; programIndex <
        ProgramsPage.programsList.length; programIndex ++) {
      for (int weekIndex = 0; weekIndex <
          ProgramsPage.programsList[programIndex].weeks.length; weekIndex++) {
        for (int dayIndex = 0; dayIndex <
            ProgramsPage.programsList[programIndex].weeks[weekIndex].days
                .length; dayIndex++) {
          for (int movementIndex = 0; movementIndex <
              ProgramsPage.programsList[programIndex].weeks[weekIndex]
                  .days[dayIndex].movements.length; movementIndex++) {
            ProgramsPage.programsList[programIndex].weeks[weekIndex]
                .days[dayIndex].movements[movementIndex].timerActive = false;
          }
        }
      }
    }
  }


@override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

 @override
 void didChangeAppLifecycleState(AppLifecycleState state) {

   super.didChangeAppLifecycleState(state);

   if (GlobalTimerWidgetState.localTimerActive || GlobalTimerWidgetState.backgroundTimerActive || OpenMovement.inMovementTimerActive) {
     if (state == AppLifecycleState.paused) {
       start = DateTime.now();
       NotificationServices().scheduleNotification(id: 0, title: "Timer Done", body: "Your rest time for '${GlobalTimerWidgetState.movementOfTimer.name}' is done", scheduledDate: DateTime.now().add(GlobalTimerWidgetState.movementOfTimer.remainingRestTime));
     }

     if (state == AppLifecycleState.resumed) {
       flutterLocalNotificationsPlugin.cancel(0);

       if (start != null) {
         difference = DateTime.now().difference(start!);
         if (GlobalTimerWidgetState.movementOfTimer.remainingRestTime - difference! > Duration(seconds: 0)) {
           GlobalTimerWidgetState.movementOfTimer.remainingRestTime -= difference!;
         }
         else {
           GlobalTimerWidgetState.movementOfTimer.remainingRestTime = Duration.zero;
         }

         start = null;
       }
     }
   }
 }

  @override
  Widget build(BuildContext context) {
    _pages = <Widget>[
      ProgramsPage(),
      HomeScreen(selectedPageCallback: onItemTapped, refreshPageCallback: refreshPageCallback),
      LogPage()
    ];

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: _pages[selectedIndex],

      bottomNavigationBar: Theme(
       data: Theme.of(context).copyWith(
       canvasColor: Colors.transparent
    ),
      child: Container(
            decoration: BoxDecoration(
              boxShadow: const [
                BoxShadow(
                 color: Colors.black87,
                 spreadRadius: 5,
                 blurRadius: 6,
                offset: Offset(0, 3),
                ),
              ],
              gradient: Styles.darkGradient()
            ),
        child: BottomNavigationBar(
          elevation: 0,
            items:  <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: ShowcaseTemplate(
                  globalKey: programPageKey,
                  stepID: 35,
                   title: "Programs Page",
                   content: "This is where you create your programs using the movements in your workout log.",
                   radius: 10,
                    child: Icon(Icons.format_list_bulleted_outlined)),
                label: 'Programs',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.home_filled),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: ShowcaseTemplate(
                    globalKey: logPageKey,
                    stepID: 36,
                    title: "Workout Log Page",
                    content: "This is where your movements are stored along with their data. You can create your own movements with custom names here.",
                    radius: 10,
                    child: Icon(Icons.note_alt_rounded)),
                label: 'Workout Log',
              ),
            ],
            currentIndex: selectedIndex,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white54,
            onTap: onItemTapped,
          ),
        ),
      )
   );
  }
}

day? copiedDay;
Movement? copiedMovement;
List<day>? copiedWeeksDays;

class Boxes {
  static Box<MovementLog> getMovementLogs() => Hive.box<MovementLog>('logs');

  static Box<Program> getPrograms() => Hive.box<Program>('programs');
}


@HiveType(typeId: 0)
class Program extends HiveObject {
  @HiveField(0)
  List<Week> weeks = [];
  @HiveField(1)
  DateTime date;
  @HiveField(2)
  String name;
  @HiveField(3)
  String? notes = "";
  @HiveField(4)
  bool isCurrentProgram = false;

  String experienceLevel = "Beginner";


  Program({this.notes, required this.weeks, required this.date, required this.name});
}


@HiveType(typeId: 1)
class MovementLog extends HiveObject {
  @HiveField(0)
  String name;
  @HiveField(1)
  bool favorited;
  @HiveField(2)
  List <ResultSetBlock> resultSetBlocks = [];
  @HiveField(3)
  DateTime date;
  @HiveField(4)
  List <ResultSetBlock> prHistory = [];
  @HiveField(5)
  Goal goal = Goal(startDate: null, endDate: null, startWeight: null, targetWeight: null);
  @HiveField(6)
  List <String>? primaryMuscleGroups;
  @HiveField(7)
  List <String>? secondaryMuscleGroups;
  @HiveField(8)
  String notes;
  MovementLog({this.secondaryMuscleGroups, this.primaryMuscleGroups, required this.date, required this.name, required this.resultSetBlocks, required this.favorited, required this.notes});
}


@HiveType(typeId: 2)
class Week {
  @HiveField(0)
  String name;
  @HiveField(1)
  List<day> days;

  Week({required this.name, required this.days});

}

@HiveType(typeId: 3)
class day {
  @HiveField(0)
  int id;
  @HiveField(1)
  String name;
  @HiveField(2)
  List<Movement> movements;
  @HiveField(3)
  bool checked;
  @HiveField(4)
  List <String>? muscleGroups;


  day({this.muscleGroups, this.checked = false, required this.id, required this.name, required this.movements});
}

@HiveType(typeId: 4)
class ResultSet {
  @HiveField(0)
  int idForKey = 0;
  @HiveField(1)
  int reps;
  @HiveField(2)
  int rir;
  @HiveField(3)
  int setNumber;
  @HiveField(4)
  double weight;
  @HiveField(5)
  String setType;

  ResultSet({
    this.setType = "default",
    required this.reps,
    required this.setNumber,
    required this.rir,
    required this.weight,
    required this.idForKey
  });
}

List<DropdownMenuItem<String>> setTypes = [
  DropdownMenuItem(value: "default", child: Text("Default")),
  DropdownMenuItem(value: "Dropset:", child: Text("Dropset")),
  DropdownMenuItem(value: "Partials:", child: Text("Partials")),
  DropdownMenuItem(value: "Left side:", child: Text("Left side")),
  DropdownMenuItem(value: "Right side:", child: Text("Right side")),
];

@HiveType(typeId: 5)
class ResultSetBlock {
  @HiveField(0)
  double oneRepMax = 0;
  @HiveField(1)
  DateTime date;
  @HiveField(2)
  int dayIdForNavigation;
  @HiveField(3)
  List<ResultSet> resultSets;



  ResultSetBlock({this.dayIdForNavigation = -1, required this.date, required this.resultSets});
}

@HiveType(typeId: 6)
class Movement {
  @HiveField(0)
  bool hasBeenLogged;
  @HiveField(1)
  bool timerActive;
  @HiveField(2)
  String name;
  @HiveField(3)
  int sets;
  @HiveField(4)
  String reps;
  @HiveField(5)
  String rir;
  @HiveField(6)
  double weight;
  @HiveField(7)
  Duration rest;
  @HiveField(8)
  Duration remainingRestTime;
  @HiveField(9)
  String notes;
  @HiveField(10)
  bool superset;
  @HiveField(11)
  List<ResultSet> resultSets;
  @HiveField(12)
  List<String>? primaryMuscleGroups;
  @HiveField(13)
  List<String>? secondaryMuscleGroups;

  Movement({
    this.secondaryMuscleGroups,
    this.primaryMuscleGroups,
    this.hasBeenLogged = false,
    this.timerActive = false,
    this.superset = false,
    required this.resultSets,
    required this.notes,
    required this.name,
    required this.sets,
    required this.reps,
    required this.rir,
    required this.weight,
    required this.rest,
    required this.remainingRestTime
  });
}

@HiveType(typeId: 7)
class Goal extends HiveObject {
  @HiveField(0)
  DateTime? startDate;
  @HiveField(1)
  DateTime? endDate;
  @HiveField(2)
  double? startWeight;
  @HiveField(3)
  double? targetWeight;

  Goal({required this.startDate, required this.endDate, required this.startWeight, required this.targetWeight});
}



String? stripDecimals(double? data) {
  return data?.toStringAsFixed(data.truncateToDouble() == data ? 0 : 1);
}

void initWorkoutLog() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool firstLaunch = prefs.getBool("firstLaunch") ?? true;

    if (firstLaunch && LogPage.movementsLogged.isEmpty) {
      final box = Boxes.getMovementLogs();
      List<MovementLog> defaultMovementLogs = [

        MovementLog(
          name: "Barbell bench press",
          primaryMuscleGroups: ["Chest"],
          secondaryMuscleGroups: ["Triceps", "Shoulders"],
          favorited: false,
          resultSetBlocks: [],
          date: DateTime.now(),
          notes: "",
        ),

        MovementLog(
          name: "Machine chest press",
          primaryMuscleGroups: ["Chest"],
          secondaryMuscleGroups: ["Triceps", "Shoulders"],
          favorited: false,
          resultSetBlocks: [],
          date: DateTime.now(),
          notes: "",
        ),

        MovementLog(
          name: "Low-to-high chest flies",
          primaryMuscleGroups: ["Chest"],
          secondaryMuscleGroups: [],
          favorited: false,
          resultSetBlocks: [],
          date: DateTime.now(),
          notes: "",
        ),


        MovementLog(
          name: "Lat pulldown",
          primaryMuscleGroups: ["Back"],
          secondaryMuscleGroups: ["Biceps", "Forearms"],
          favorited: false,
          resultSetBlocks: [],
          date: DateTime.now(),
          notes: "",
        ),

        MovementLog(
          name: "Dumbbell rows",
          primaryMuscleGroups: ["Back"],
          secondaryMuscleGroups: ["Biceps", "Forearms"],
          favorited: false,
          resultSetBlocks: [],
          date: DateTime.now(),
          notes: "",
        ),

        MovementLog(
          name: "Barbell rows",
          primaryMuscleGroups: ["Back"],
          secondaryMuscleGroups: ["Forearms"],
          favorited: false,
          resultSetBlocks: [],
          date: DateTime.now(),
          notes: "",
        ),

        MovementLog(
          name: "Low row",
          primaryMuscleGroups: ["Back"],
          secondaryMuscleGroups: ["Forearms"],
          favorited: false,
          resultSetBlocks: [],
          date: DateTime.now(),
          notes: "",
        ),


        MovementLog(
          name: "Dumbbell shoulder press",
          primaryMuscleGroups: ["Shoulders"],
          secondaryMuscleGroups: ["Triceps"],
          favorited: false,
          resultSetBlocks: [],
          date: DateTime.now(),
          notes: "",
        ),

        MovementLog(
          name: "Machine shoulder press",
          primaryMuscleGroups: ["Shoulders"],
          secondaryMuscleGroups: ["Triceps"],
          favorited: false,
          resultSetBlocks: [],
          date: DateTime.now(),
          notes: "",
        ),

        MovementLog(
          name: "Dumbbell lateral raise",
          primaryMuscleGroups: ["Shoulders"],
          secondaryMuscleGroups: [],
          favorited: false,
          resultSetBlocks: [],
          date: DateTime.now(),
          notes: "",
        ),

        MovementLog(
          name: "Face pulls",
          primaryMuscleGroups: ["Back", "Shoulders"],
          secondaryMuscleGroups: [],
          favorited: false,
          resultSetBlocks: [],
          date: DateTime.now(),
          notes: "",
        ),


        MovementLog(
          name: "Dumbbell bicep curls",
          primaryMuscleGroups: ["Biceps"],
          secondaryMuscleGroups: ["Forearms"],
          favorited: false,
          resultSetBlocks: [],
          date: DateTime.now(),
          notes: "",
        ),

        MovementLog(
          name: "Dumbbell hammer curls",
          primaryMuscleGroups: ["Biceps"],
          secondaryMuscleGroups: ["Forearms"],
          favorited: false,
          resultSetBlocks: [],
          date: DateTime.now(),
          notes: "",
        ),

        MovementLog(
          name: "Preacher curls",
          primaryMuscleGroups: ["Biceps"],
          secondaryMuscleGroups: ["Forearms"],
          favorited: false,
          resultSetBlocks: [],
          date: DateTime.now(),
          notes: "",
        ),

        MovementLog(
          name: "Ez-bar skullcrushers",
          primaryMuscleGroups: ["Triceps"],
          secondaryMuscleGroups: [],
          favorited: false,
          resultSetBlocks: [],
          date: DateTime.now(),
          notes: "",
        ),

        MovementLog(
          name: "Cable tricep extensions",
          primaryMuscleGroups: ["Triceps"],
          secondaryMuscleGroups: [],
          favorited: false,
          resultSetBlocks: [],
          date: DateTime.now(),
          notes: "",
        ),

        MovementLog(
          name: "Barbell back squats",
          primaryMuscleGroups: ["Quads"],
          secondaryMuscleGroups: ["Hamstrings", "Glutes"],
          favorited: false,
          resultSetBlocks: [],
          date: DateTime.now(),
          notes: "",
        ),

        MovementLog(
          name: "Barbell RDLs",
          primaryMuscleGroups: ["Hamstrings"],
          secondaryMuscleGroups: ["Glutes"],
          favorited: false,
          resultSetBlocks: [],
          date: DateTime.now(),
          notes: "",
        ),

        MovementLog(
          name: "Barbell deadlifts",
          primaryMuscleGroups: ["Hamstrings"],
          secondaryMuscleGroups: ["Glutes", "Quads"],
          favorited: false,
          resultSetBlocks: [],
          date: DateTime.now(),
          notes: "",
        ),

        MovementLog(
          name: "Leg press",
          primaryMuscleGroups: ["Quads"],
          secondaryMuscleGroups: ["Glutes", "Hamstrings"],
          favorited: false,
          resultSetBlocks: [],
          date: DateTime.now(),
          notes: "",
        ),

        MovementLog(
          name: "Hamstring curls",
          primaryMuscleGroups: ["Hamstrings"],
          secondaryMuscleGroups: [],
          favorited: false,
          resultSetBlocks: [],
          date: DateTime.now(),
          notes: "",
        ),

        MovementLog(
          name: "Leg extensions",
          primaryMuscleGroups: ["Quads"],
          secondaryMuscleGroups: [],
          favorited: false,
          resultSetBlocks: [],
          date: DateTime.now(),
          notes: "",
        ),

        MovementLog(
          name: "Smith calf raises",
          primaryMuscleGroups: ["Calves"],
          secondaryMuscleGroups: [],
          favorited: false,
          resultSetBlocks: [],
          date: DateTime.now(),
          notes: "",
        ),
      ];


      for (var movement in defaultMovementLogs) {
        LogPage.movementsLogged.add(movement);
        box.add(movement);
      }
    }
}

class Styles {
  static List<Color> verticalColors = [
    const Color(0xFF0A1C43),
    const Color(0xFF0C2251),
    const Color(0xFF0D2B56),
    const Color(0xFF0C3A62),
    const Color(0xFF1E4E70)
  ];
  static List<Color> horizontalColors = [
    const Color(0xFF0A1C43),
    const Color(0xFF0C2251),
    const Color(0xFF0D2B56),
    const Color(0xFF0C3A62),
    const Color(0xFF1E4E70)
  ];
  static List<Color> darkColors = [
    const Color(0xFF01152b),
    const Color(0xFF03274f),
    const Color(0xFF042f5e),
    const Color(0xFF0a4482),
  ];



  static LinearGradient vertical() {
    return LinearGradient(
      colors: verticalColors,
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
  }

  static void setVerticalColors(List<Color> colors) {
    verticalColors = colors;
  }




  static LinearGradient darkGradient() {
    return LinearGradient(
      colors: darkColors,
      begin: Alignment.topLeft,
      end: Alignment.topRight,
    );
  }

  static void setDarkColors(List<Color> colors) {
    darkColors = colors;
  }




  static LinearGradient horizontal() {
    return LinearGradient(
      colors: horizontalColors,
      begin: Alignment.topRight,
      end: Alignment.topLeft,
    );
  }

  static void setHorizontalColors(List<Color> colors) {
    horizontalColors = colors;
  }

  static Color secondaryColor = const Color(0xFF042f5e);
  static Color primaryColor = const Color(0xFF10396A);
  static Color chartColor = const Color(0xFF10396A);

  static const TextStyle regularText = TextStyle(
      fontSize: 20,
      color: Colors.white,
      fontWeight: FontWeight.bold,
      overflow: TextOverflow.ellipsis
  );
  static const TextStyle paragraph = TextStyle(
    fontSize: 15,
    color: Colors.white70,
    fontWeight: FontWeight.bold,
  );
  static const TextStyle labelText = TextStyle(
      fontSize: 25,
      fontWeight: FontWeight.bold,
      color: Colors.white,
      overflow: TextOverflow.ellipsis
  );
  static const TextStyle smallTextBlack = TextStyle(
      fontSize: 15,
      color: Colors.black54,
      overflow: TextOverflow.ellipsis
  );
  static const TextStyle smallTextWhite = TextStyle(
      fontSize: 15,
      color: Colors.white60,
      overflow: TextOverflow.ellipsis
  );

/* static LinearGradient mainGradient() {
    return const LinearGradient(
      colors: [
        Color(0xFF0f57a8),
        Color(0xFF0c5b9c),
        Color(0xFF0e65ad),
        Color(0xFF1976D2),
        Color(0xFF1E88E5),
        Color(0xFF1ba6f7)
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
  }*/

}

