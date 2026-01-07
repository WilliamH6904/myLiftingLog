import 'package:flutter/services.dart';
import 'package:gym_app/home_screen.dart';
import 'package:gym_app/programs_page.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';
import 'main.dart';
import 'dialogs.dart';
import 'open_program.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:carousel_slider/carousel_slider.dart';


final GlobalKey addingMovementLogsKey = GlobalKey();
final GlobalKey movementLogKey = GlobalKey();
final GlobalKey editingMovementLogKey = GlobalKey();

final GlobalKey movementScreensKey = GlobalKey();
final GlobalKey navigatingScreensKey = GlobalKey();

final GlobalKey progressChartKey = GlobalKey();
final GlobalKey settingMonthKey = GlobalKey();
final GlobalKey chartSettingKey = GlobalKey();
final GlobalKey addingEntriesKey = GlobalKey();

final GlobalKey prHistoryKey = GlobalKey();
final GlobalKey movementStatsKey = GlobalKey();

final GlobalKey endGoalKey = GlobalKey();
final GlobalKey goalDateKey = GlobalKey();
final GlobalKey startGoalKey = GlobalKey();









class LogPage extends StatefulWidget {
  static List <MovementLog> movementsLogged = Boxes.getMovementLogs().values.toList().cast<MovementLog>();
  static int currentMovementLogIndex = 0;

  @override
  State<LogPage> createState() => _LogPageState();
}

class _LogPageState extends State<LogPage> {
  final box = Boxes.getMovementLogs();
  TextEditingController searchController = TextEditingController();
  FocusNode searchFocus = FocusNode();
  List <MovementLog> displayList = [];

  void updateLogOrder(MovementLog log) {
    setState(() {
      log.date = DateTime.now();
      log.save();
      sortLog();
    });
  }

  void sortLog() {
    setState(() {
      LogPage.movementsLogged.sort((a, b) {
        if (a.favorited != b.favorited) {
          return a.favorited ? -1 : 1;
        } else {
          return b.date.compareTo(a.date);
        }
      });
    });
  }


  @override
  void initState() {
    super.initState();

    sortLog();

    ShowcaseView.register();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (LogPage.movementsLogged.isNotEmpty) {
          ShowcaseView.get().startShowCase([addingMovementLogsKey, movementLogKey, editingMovementLogKey]);
        }
          else {
        ShowcaseView.get().startShowCase([addingMovementLogsKey]);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {

    displayList = List.from(LogPage.movementsLogged.where((element) => element.name.replaceAll(RegExp(r'\s+'), '').toLowerCase().contains(searchController.text.replaceAll(RegExp(r'\s+'), '').toLowerCase())));


    void addMovementLog(String logName, List<String> primaryMuscleGroups, List<String> secondaryMuscleGroups) {
      setState(() {
        LogPage.movementsLogged.add(MovementLog(
            primaryMuscleGroups: primaryMuscleGroups,
            secondaryMuscleGroups: secondaryMuscleGroups,
            date: DateTime.now(),
            favorited: false,
            name: logName,
            notes: "",
            resultSetBlocks: []));
        box.add(LogPage.movementsLogged.last);
        searchController.text = "";
      });

      sortLog();
    }

    return GestureDetector(
      onTap: () {
        searchFocus.unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
          appBar: AppBar(
            flexibleSpace: Container(
              decoration: BoxDecoration(
                  gradient: Styles.darkGradient()
              ),
            ),
            shape: const Border(
          bottom: BorderSide(
          color: Colors.white54,
            width: 1.5,
          ),
      ),
            title: Row(
              children: [
                const Text("Workout Log", style: Styles.labelText),
                const Spacer(),
                ShowcaseTemplate(
                  globalKey: addingMovementLogsKey,
                  radius: 20,
                  stepID: 18,
                  title: "Adding Movements",
                  content: "Click here to add a new custom movement to your workout log.",
                  child: IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return CreateOrEditMovementLog(addMovementLog: addMovementLog);
                        },
                      );
                    },
                    style: IconButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                     icon: const Icon(Icons.add_circle, color: Colors.white, size: 35),
                  ),
                )
              ],
            ),
          ),

          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: Styles.horizontal()
            ),

              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.only(top: 8),
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
                        child: TextField(
                          onTap: () {
                            setState(() {
                              if (searchFocus.hasFocus == true) {
                                searchFocus.unfocus();
                              }
                              else {
                                displayList = List.from(LogPage.movementsLogged.where((element) => element.name.replaceAll(RegExp(r'\s+'), '').toLowerCase().contains(searchController.text.replaceAll(RegExp(r'\s+'), '').toLowerCase())));
                              }
                            });
                          },
                          onChanged: (text) {
                            setState(() {
                              displayList = List.from(LogPage.movementsLogged.where((element) => element.name.replaceAll(RegExp(r'\s+'), '').toLowerCase().contains(text.replaceAll(RegExp(r'\s+'), '').toLowerCase())));
                            });
                          },
                          inputFormatters: <TextInputFormatter>[
                            LengthLimitingTextInputFormatter(20)
                          ],
                          controller: searchController,
                          focusNode: searchFocus,
                          decoration: const InputDecoration(
                            hintText: 'Search',
                            hintStyle: Styles.smallTextWhite,
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide.none,
                            ),
                          ),
                          style: Styles.regularText,
                          cursorColor: Colors.white,
                        ),
                      ),
                     if (searchFocus.hasFocus) Positioned( right: 0, top: 8,
                          child: IconButton(onPressed: () {
                            setState(() {
                              searchController.text = "";
                              searchFocus.unfocus();
                            });
                          },
                              icon: const Icon(Icons.close, color: Colors.white, size: 25)))
                    ],
                  ),
                  Expanded(
                    child: displayList.isNotEmpty
                        ? ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: displayList.length,
                        itemBuilder: (context, index) {
                          final label = displayList[index].name;
                          final resultIndex = LogPage.movementsLogged.indexOf(displayList[index]);
                          return ShowcaseTemplate(
                            radius: 0,
                            globalKey: movementLogKey,
                            title: "Movement Logs",
                            content: "This is where your movements are stored. Each movement has its own log for storing workout data for that movement. Tap the movement to open.",
                            stepID: 19,
                            child: InkWell(
                              onTap: () {
                                LogPage.currentMovementLogIndex = resultIndex;
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => ScreenManager(updateLogOrder: updateLogOrder, sortLog: sortLog),
                                  ),
                                );
                              },
                              child: Column(
                                children: [
                                  Container(
                                    height: 60,
                                    color: Colors.black12,
                                    child: Row(
                                        children: [
                                          if(LogPage.movementsLogged[resultIndex].favorited == true)
                                            ShaderMask(
                                              shaderCallback: (Rect bounds) {
                                                return const RadialGradient(
                                                  center: Alignment.center,
                                                  radius: 0.5,
                                                  colors: [
                                                    Color(0xFFFFFACD),
                                                    Color(0xFFFFD700),
                                                    Color(0xFFFFA500),
                                                    Color(0xFFFF8C00),
                                                  ],
                                                ).createShader(bounds);
                                              },
                                              child: const Icon(Icons.star, color: Colors.white, size: 30),
                                            ),
                                          const SizedBox(width: 10),
                                          Expanded(child: Text(label, style: Styles.regularText)),
                                          ShowcaseTemplate(
                                            globalKey: editingMovementLogKey,
                                            radius: 10,
                                            stepID: 20,
                                            title: "Editing Movements",
                                            content: "Click here to make changes to a movement. You can also favorite movements here so that they appear on your home screen and are sorted to the top of the workout log.",
                                            child: PopupMenuButton<ListTile>(
                                                itemBuilder: (context) {
                                                  return [
                                                    PopupMenuItem<ListTile>(
                                                      onTap: () {
                                                        setState(() {
                                                          displayList[index].favorited = !displayList[index].favorited;
                                                          sortLog();
                                                          LogPage.movementsLogged[resultIndex].save();
                                                        });
                                                      },
                                                      child: ListTile(
                                                        leading: Icon(LogPage.movementsLogged[resultIndex].favorited == false ? Icons.star_border : Icons.star, color: Styles.primaryColor),
                                                        title: Text("Favorite", style: TextStyle(color: Styles.primaryColor)),
                                                      ),
                                                    ),
                                                    PopupMenuItem<ListTile>(
                                                      onTap: () {
                                                        LogPage.currentMovementLogIndex = resultIndex;

                                                        showDialog(
                                                            context: context,
                                                            builder: (BuildContext context) {
                                                              return CreateOrEditMovementLog(
                                                                refreshParent: () {setState(() {});},
                                                                logToEdit: LogPage.movementsLogged[LogPage.currentMovementLogIndex],
                                                                insertName: LogPage.movementsLogged[LogPage.currentMovementLogIndex].name,
                                                              );
                                                            }
                                                        );
                                                      },

                                                      child: ListTile(
                                                        leading: Icon(Icons.edit, color: Styles.primaryColor),
                                                        title: Text('Edit', style: TextStyle(color: Styles.primaryColor)),
                                                      ),
                                                    ),
                                                    PopupMenuItem<ListTile>(
                                                      onTap: () {
                                                        List<void Function()> deleteFunctions = [];
                                                        int occurrences = 0;

                                                        for(int programIndex = 0; programIndex < ProgramsPage.programsList.length; programIndex ++) {

                                                          for (int weekIndex = 0; weekIndex < ProgramsPage.programsList[programIndex].weeks.length; weekIndex++) {

                                                            for (int dayIndex = 0; dayIndex < ProgramsPage.programsList[programIndex].weeks[weekIndex].days.length; dayIndex++) {

                                                              for (int movementIndex = 0; movementIndex < ProgramsPage.programsList[programIndex].weeks[weekIndex].days[dayIndex].movements.length; movementIndex++) {
                                                                if (ProgramsPage.programsList[programIndex].weeks[weekIndex].days[dayIndex].movements[movementIndex].name.replaceAll(RegExp(r'\s+'), '').toLowerCase() == displayList[index].name.replaceAll(RegExp(r'\s+'), '').toLowerCase()) {

                                                                  occurrences ++;
                                                                  deleteFunctions.add(() {
                                                                    ProgramsPage.programsList[programIndex].weeks[weekIndex].days[dayIndex].movements.remove(ProgramsPage.programsList[programIndex].weeks[weekIndex].days[dayIndex].movements[movementIndex]);

                                                                    ProgramsPage.programsList[programIndex].save();
                                                                  });
                                                                }
                                                              }
                                                            }
                                                          }
                                                        }

                                                        remove() {
                                                          setState(() {
                                                            for (VoidCallback function in deleteFunctions) {
                                                              function();
                                                            }

                                                            if (copiedWeeksDays != null) {
                                                              for (int dayIndex = 0; dayIndex < copiedWeeksDays!.length; dayIndex++) {
                                                                for (int movementIndex = copiedWeeksDays![dayIndex].movements.length - 1; movementIndex >= 0; movementIndex--) {
                                                                  if (copiedWeeksDays![dayIndex].movements[movementIndex].name == displayList[index].name) {
                                                                    copiedWeeksDays![dayIndex].movements.removeAt(movementIndex);
                                                                  }
                                                                }
                                                              }
                                                            }

                                                            if (copiedDay != null) {
                                                              for (int i = copiedDay!.movements.length - 1; i >= 0; i--) {
                                                                if (copiedDay!.movements[i].name == displayList[index].name) {
                                                                  copiedDay!.movements.removeAt(i);
                                                                }
                                                              }
                                                            }

                                                            if (copiedMovement != null && copiedMovement?.name == displayList[index].name) {
                                                              copiedMovement = null;
                                                            }


                                                            box.delete(LogPage.movementsLogged[resultIndex].key);
                                                            LogPage.movementsLogged.removeAt(resultIndex);
                                                          });
                                                        }
                                                        showDialog(
                                                            context: context,
                                                            builder: (BuildContext context) {
                                                              return ConfirmationDialog(content: occurrences > 0 ?
                                                              "Are you sure you want to delete this movement? This will also delete all '$occurrences' occurrences of it within your programs."
                                                                  : "Are you sure you want to delete this movement?",
                                                                  callbackFunction: remove);
                                                            }
                                                        );
                                                      },
                                                      child: ListTile(
                                                        leading: Icon(Icons.delete, color: Styles.primaryColor),
                                                        title: Text('Delete', style: TextStyle(color: Styles.primaryColor)),
                                                      ),
                                                    ),
                                                  ];
                                                },
                                                icon: const Icon(Icons.more_vert, color: Colors.white)),
                                          )
                                        ]
                                    ),
                                  ),
                                  const Divider(height: 0)
                                ],
                              ),
                            ),
                          );
                        }
                    )
                        : LogPage.movementsLogged.isNotEmpty
                        ? const Text("No results found", style: Styles.regularText, textAlign: TextAlign.center)
                        : const SizedBox()
                  ),
                ],
              )
          ),
      ),
    );
  }
}

class ScreenManager extends StatefulWidget {
  final Function? refreshScreen;
  static int screenIndex = 0;
  final Function updateLogOrder;
  final Function sortLog;

  const ScreenManager({super.key, required this.updateLogOrder, required this.sortLog, this.refreshScreen});
  
  @override
  State<ScreenManager> createState() => _ScreenManagerState();
}

class _ScreenManagerState extends State<ScreenManager> {
  MovementLog thisMovementLog = LogPage.movementsLogged[LogPage.currentMovementLogIndex];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List <Widget> screens = [];
  String currentScreenTitle = "";

  void addResultSetBlock (ResultSetBlock newResultSetBlock) {
    setState(() {
      double currentHighestWeight = 0;

      // find the result set with the highest weight
      for (int b = 0; b < thisMovementLog.resultSetBlocks.length; b ++) {
        if (thisMovementLog.resultSetBlocks[b].resultSets.any((set) => set.weight > currentHighestWeight)) {
          currentHighestWeight = thisMovementLog.resultSetBlocks[b].resultSets.where((set) => set.weight > currentHighestWeight).reduce((a, b) => a.weight > b.weight ? a : b).weight;
        }
      }

      ResultSet highestSet = ResultSet(reps: 0, weight: 0, rir: 0, setNumber: 0, idForKey: -1);

      // check if this block contains a result set with higher weight than the highest one in log
      for (int i = 0; i < newResultSetBlock.resultSets.length; i ++) {
        if (newResultSetBlock.resultSets[i].weight > currentHighestWeight && newResultSetBlock.resultSets[i].weight > highestSet.weight && newResultSetBlock.resultSets[i].reps > 0) {
         highestSet = ResultSet(
             reps: newResultSetBlock.resultSets[i].reps,
             setNumber: newResultSetBlock.resultSets[i].setNumber,
             rir: newResultSetBlock.resultSets[i].rir,
             weight: newResultSetBlock.resultSets[i].weight,
             idForKey: newResultSetBlock.resultSets[i].idForKey
         );
        }
      }

      // then add the highest one
      if (highestSet.weight > 0) {
        thisMovementLog.prHistory.add(ResultSetBlock(
            date: DateTime.now(),
            resultSets: [ResultSet(
                reps: highestSet.reps,
                setNumber: highestSet.setNumber,
                rir: highestSet.rir,
                weight: highestSet.weight,
                idForKey: highestSet.idForKey
            )]
        )
        );
      }


      thisMovementLog.resultSetBlocks.add(newResultSetBlock);

      widget.updateLogOrder(thisMovementLog);
      thisMovementLog.save();
    });
  }

  @override
  void initState() {
    super.initState();

    ShowcaseView.register();

    screens = [MovementLogScreen(addResultSetBlock: addResultSetBlock, updateLogOrder: widget.updateLogOrder, sortLog: widget.sortLog),
    MovementStatsScreen(updateLogOrder: widget.updateLogOrder),
    MovementGoalScreen(updateLogOrder: widget.updateLogOrder),
    MovementNotesScreen(updateLogOrder: widget.updateLogOrder)];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        ShowcaseView.get().startShowCase([movementScreensKey, navigatingScreensKey, progressChartKey, settingMonthKey, chartSettingKey, addingEntriesKey]);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    currentScreenTitle = ScreenManager.screenIndex == 0 ? "Log" : ScreenManager.screenIndex == 1 ? "Stats" : ScreenManager.screenIndex == 2 ? "Goal" : "Notes";


    return Scaffold(
      resizeToAvoidBottomInset: false,
      key: _scaffoldKey,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: Styles.darkGradient(),
          ),
        ),
        shape: Border(
          bottom:  BorderSide(
            color: ScreenManager.screenIndex == 0 ? Colors.white54 : Colors.black45,
            width: 1.5,
          ),
        ),
        shadowColor: Colors.black54,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: <Widget>[
          ShowcaseTemplate(
           globalKey: navigatingScreensKey,
           stepID: 22,
           radius: 10,
           title: "Navigating Screens",
            content: "Click here to navigate to the other screens of this movement.",
             child: IconButton(onPressed: () {
              _scaffoldKey.currentState?.openEndDrawer();
            }, icon: const Icon(Icons.menu, color: Colors.white, size: 33)),
          )
        ],
        title: ShowcaseTemplate(
          globalKey: movementScreensKey,
          radius: 10,
          stepID: 21,
          title: "$currentScreenTitle Screen",
            content: "You are currently in the $currentScreenTitle screen of this movement.",
            child: Text(currentScreenTitle, style: Styles.labelText)),
    automaticallyImplyLeading: false,
        leading: BackButton(
            onPressed: () {
              widget.refreshScreen?.call();
              Navigator.of(context).pop();
            },
          ),
      ),
      body: screens[ScreenManager.screenIndex],
      endDrawer: Drawer(width: MediaQuery.of(context).size.width * 0.85,
          child: Scaffold(
              resizeToAvoidBottomInset: false,
              appBar: AppBar(
                automaticallyImplyLeading: false,
                backgroundColor: Styles.primaryColor,
                iconTheme: const IconThemeData(color: Colors.white),
                title: Text(thisMovementLog.name, style: Styles.labelText),
                shape: const Border(
                  bottom: BorderSide(
                    color: Colors.black45,
                    width: 2,
                  ),
                ),
                shadowColor: Colors.black54,
              ),
              body: Container(
                  height: double.infinity,
                  decoration: BoxDecoration(
                      gradient: Styles.horizontal()
                  ),
                  child: Column(
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(15),
                              bottomRight: Radius.circular(15)
                          ),
                        ),
                        child: Column(
                          children: [
                            InkWell(
                              onTap: () {
                                setState(() {
                                  ScreenManager.screenIndex = 0;
                                  Navigator.of(context).pop();
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.04),
                                decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.only(
                                        bottomLeft: Radius.circular(15),
                                        bottomRight: Radius.circular(15)
                                    ),
                                    border: Border(
                                        bottom: ScreenManager.screenIndex == 0 ? const BorderSide(
                                            color: Colors.white,
                                            width: 2.5
                                        ) : const BorderSide(
                                            color: Colors.white54,
                                            width: 2
                                        )
                                    )
                                ),
                                child: const ListTile(
                                  leading: Icon(Icons.note_alt, color: Colors.white, size: 30),
                                  title: Text('Movement Log', style: Styles.regularText),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  ScreenManager.screenIndex = 1;
                                  Navigator.of(context).pop();
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.04),
                                decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.only(
                                        bottomLeft: Radius.circular(15),
                                        bottomRight: Radius.circular(15)
                                    ),
                                    border: Border(
                                        bottom: ScreenManager.screenIndex == 1 ? const BorderSide(
                                            color: Colors.white,
                                            width: 2.5
                                        ) : const BorderSide(
                                            color: Colors.white54,
                                            width: 2
                                        )
                                    )
                                ),
                                child: const ListTile(
                                  leading: Icon(Icons.insert_chart, color: Colors.white, size: 30),
                                  title: Text('Movement Stats', style: Styles.regularText),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  ScreenManager.screenIndex = 2;
                                  Navigator.of(context).pop();
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.04),
                                decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.only(
                                        bottomLeft: Radius.circular(15),
                                        bottomRight: Radius.circular(15)
                                    ),
                                    border: Border(
                                        bottom: ScreenManager.screenIndex == 2 ? const BorderSide(
                                            color: Colors.white,
                                            width: 2.5
                                        ) : const BorderSide(
                                            color: Colors.white54,
                                            width: 2
                                        )
                                    )
                                ),
                                child: const ListTile(
                                  leading: Icon(Icons.emoji_events, color: Colors.white, size: 30),
                                  title: Text('Movement Goal', style: Styles.regularText),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  ScreenManager.screenIndex = 3;
                                  Navigator.of(context).pop();
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.04),
                                decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.only(
                                        bottomLeft: Radius.circular(15),
                                        bottomRight: Radius.circular(15)
                                    ),
                                    border: Border(
                                        bottom: ScreenManager.screenIndex == 3 ? const BorderSide(
                                            color: Colors.white,
                                            width: 2.5
                                        ) : const BorderSide(
                                            color: Colors.white54,
                                            width: 2
                                        )
                                    )
                                ),
                                child: const ListTile(
                                  leading: Icon(Icons.emoji_events, color: Colors.white, size: 30),
                                  title: Text('Movement Notes', style: Styles.regularText),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      const Spacer(),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.calculate, color: Colors.white),
                        title: const Text('1RM calculator', style: Styles.regularText),
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return OneRMCalculator();
                              }
                          );
                        },
                      ),
                      const SizedBox(height: 100),
                    ],
                  )
              )
        )
      )
    );
  }
}


class MovementLogScreen extends StatefulWidget {
final Function(ResultSetBlock) addResultSetBlock;
final Function updateLogOrder;
final Function sortLog;


const MovementLogScreen({required this.addResultSetBlock, required this.updateLogOrder, required this.sortLog});
  @override
  State<MovementLogScreen> createState() => MovementLogScreenState();
}

class MovementLogScreenState extends State<MovementLogScreen> {
  MovementLog thisMovementLog = LogPage.movementsLogged[LogPage.currentMovementLogIndex];
  static int yearNumber = DateTime.now().year;
  static int monthNumber = DateTime.now().month;
  static int loadedListItemsLength = 31;


  void deleteEntry(index) {
    setState(() {
      thisMovementLog.resultSetBlocks.removeAt(index);
      thisMovementLog.save();
    });
  }

  void updateYear (int newValue) {
    setState(() {
      yearNumber = newValue;
    });
  }

  void updateMonth (int newValue) {
    setState(() {
      monthNumber = newValue;
    });
  }

  void updateListLength(int newValue) {
    setState(() {
      loadedListItemsLength = 31;
    });
  }

  @override
  void initState() {
    super.initState();
    loadedListItemsLength = 31;
  }

  @override
  Widget build(BuildContext context) {
    List<ResultSetBlock> thisDatesBlocks = thisMovementLog.resultSetBlocks.where((block) => block.date.month == monthNumber && block.date.year == yearNumber).toList();

    return PopScope(
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        widget.sortLog();
      },
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: Styles.horizontal()
          ),
          child: Container(
            color: Colors.black12,
            child: Column(
              children: [
                ProgressChart(displaySmall: false, refreshListLength: updateListLength, refreshMonthNumber: updateMonth, refreshYearNumber: updateYear, thisDatesBlocks: thisDatesBlocks),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                          InkWell(onTap: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return CreateEntry(addResultSetBlock: widget.addResultSetBlock);
                                }
                            );
                          }, child: ShowcaseTemplate(
                            globalKey: addingEntriesKey,
                            radius: 10,
                            stepID: 26,
                            title: "Manual Entries",
                            content: "Here you can manually add entries to your workout log rather than logging sets from within your programs. Entries will be listed above here.",
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.black12,
                                borderRadius: const BorderRadius.all(Radius.circular(10)),
                                border: Border.all(
                                      color: Colors.white54,
                                    width: 2
                                )
                              ),
                                child: const Icon(Icons.add, color: Colors.white)),
                          )),
                                 ListView.builder(
                                        scrollDirection: Axis.vertical,
                                        physics: const NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemCount: loadedListItemsLength <= thisDatesBlocks.length ? loadedListItemsLength : thisDatesBlocks.length,
                                        itemBuilder: (context, index) {
                                          thisDatesBlocks.sort((a, b) => b.date.compareTo(a.date));
                                          final thisBlock = thisDatesBlocks[index];
                                           for(int i = 0; i < thisBlock.resultSets.length; i ++) {
                                             thisBlock.resultSets[i].setNumber = i + 1;
                                           }
                                        return SetBlockWidget(deleteEntry: deleteEntry, thisBlock: thisBlock, thisMovementLog: thisMovementLog);
                                          }
                                         ),
                        InkWell(
                            onTap: () {
                              setState(() {
                                loadedListItemsLength += 15;
                              });
                            },
                            child: loadedListItemsLength < thisDatesBlocks.length ? Container(
                              height: 55,
                              width: 150,
                              margin: const EdgeInsets.only(bottom: 30),
                              decoration: BoxDecoration(
                                color:  Styles.secondaryColor,
                                border: const Border(
                                  bottom: BorderSide(
                                      color: Colors.black38,
                                      width: 3
                                  ),
                                  left: BorderSide(
                                    color: Colors.black38,
                                    width: 2
                                  ),
                                    right: BorderSide(
                                        color: Colors.black38,
                                        width: 2
                                    )
                                ),
                                borderRadius: const BorderRadius.all(Radius.circular(20)),
                              ),

                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("Load more", style: Styles.regularText),
                                  Icon(Icons.keyboard_arrow_down, color: Colors.white)
                                ],
                              ),
                            )
                                : Container()
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
            ),
          ),
    );
      }
    }


class MovementStatsScreen extends StatefulWidget {
  final Function updateLogOrder;

  const MovementStatsScreen({required this.updateLogOrder});

  @override
  State<MovementStatsScreen> createState() => _MovementStatsScreenState();
}

class _MovementStatsScreenState extends State<MovementStatsScreen> {
  List <Widget> prSliderItems = [];
  int sliderIndex = 0;
  int repsPerformed = 0;
  double totalWeightLifted = 0;
  int timesDoneThisWeek = 0;
  MovementLog thisMovementLog = LogPage.movementsLogged[LogPage.currentMovementLogIndex];
  final CarouselSliderController _carouselController = CarouselSliderController();

@override
  void initState() {
  thisMovementLog.resultSetBlocks.sort((a, b) => a.date.compareTo(b.date));


  DateTime startOfWeek = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
  DateTime endOfWeek = DateTime.now().add(Duration(days: 6 - DateTime.now().weekday));

  for (ResultSetBlock block in thisMovementLog.resultSetBlocks) {
    if (block.date.isAfter(startOfWeek.subtract(const Duration(days: 1))) && block.date.isBefore(endOfWeek.add(const Duration(days: 1)))) {
      timesDoneThisWeek ++;
    }
  }

  for (int i = 0; i < thisMovementLog.resultSetBlocks.length; i++) {
    for (int r = 0; r < thisMovementLog.resultSetBlocks[i].resultSets.length; r++) {
      repsPerformed += thisMovementLog.resultSetBlocks[i].resultSets[r].reps;
      totalWeightLifted += thisMovementLog.resultSetBlocks[i].resultSets[r].weight;

    }
  }

  for(int i = 0; i < thisMovementLog.prHistory.length; i ++) {
    prSliderItems.add(Column(children: [
      Text("${thisMovementLog.prHistory[i].resultSets[0].weight} for ${thisMovementLog.prHistory[i].resultSets[0].reps} ${thisMovementLog.prHistory[i].resultSets[0].reps == 1 ? "rep" : "reps"}", style: Styles.regularText.copyWith(fontSize: 16)),
      const Spacer(),
      Text(DateUtils.dateOnly(thisMovementLog.prHistory[i].date).toString().substring(0, 10), style: Styles.smallTextWhite),
    ]));
  }

  if(prSliderItems.isNotEmpty) {
     sliderIndex = prSliderItems.length - 1;
   }

    super.initState();

  ShowcaseView.register();


  WidgetsBinding.instance.addPostFrameCallback((_) {
    Future.delayed(const Duration(milliseconds: 300), () {
      ShowcaseView.get().startShowCase([prHistoryKey, movementStatsKey]);
    });
  });
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: Styles.horizontal()
      ),
      child: Column(
          children: [
          const SizedBox(height: 50),
          const Text("PR History", style: Styles.regularText),
          const SizedBox(height: 5),
          ShowcaseTemplate(
            globalKey: prHistoryKey,
            radius: 10,
            stepID: 27,
            title: "PR History",
            content: "Anytime you perform a PR, it will appear here. You can swipe through and view your PR history anytime.",
            child: Container(
              width: MediaQuery.of(context).size.width * 0.75,
              height: 80,
              decoration: const BoxDecoration(
                color: Colors.black12,
                border: Border(
                    bottom: BorderSide(
                        color: Colors.white54,
                        width: 2
                    ),
                    left: BorderSide(
                        color: Colors.white54,
                        width: 2
                    ),
                    right: BorderSide(
                        color: Colors.white54,
                        width: 2
                    ),
                    top: BorderSide(
                        color: Colors.white54,
                        width: 1
                    )
                ),
                borderRadius: BorderRadius.all(Radius.circular(10)
                ),
              ),
              child: Stack(
                children: [
              if (prSliderItems.isNotEmpty) ...[
               if (prSliderItems.length > 1) const Positioned(left: 0, right: 0, top: 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(Icons.keyboard_double_arrow_left, color: Colors.white54),
                      Icon(Icons.keyboard_double_arrow_right, color: Colors.white54)
                    ]),
                ),
               CarouselSlider(
              carouselController: _carouselController,
                options: CarouselOptions(
                  onPageChanged: (int index, CarouselPageChangedReason reason) {
                    setState(() {
                      sliderIndex = index;
                    });
                  },
                  height: 130,
                  viewportFraction: 1,
                  enableInfiniteScroll: false,
                  initialPage: prSliderItems.length - 1,
                ),
                items: prSliderItems,
              ),
              ]
              else...[ const Center(child: Text("No sets found", style: Styles.smallTextWhite))],
                ],
              )
            ),
          ),
            const SizedBox(height: 30),
            InkWell(
              onTap: () {
                if(thisMovementLog.prHistory.isNotEmpty) {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return ConfirmationDialog(content: "Are you sure you want to remove this set from your PR history?", callbackFunction: () {
                          setState(() {
                            thisMovementLog.prHistory.removeAt(sliderIndex);
                            prSliderItems.removeAt(sliderIndex);
                            widget.updateLogOrder(thisMovementLog);
                          });
                        });
                      }
                  );
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black12,
                  border: Border.all(
                    color: thisMovementLog.prHistory.isNotEmpty ? Colors.white : Colors.white54
                  ),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(10)
                  )
                ),
                child: Text("Remove", style: Styles.smallTextWhite.copyWith(color: thisMovementLog.prHistory.isNotEmpty ? Colors.white : Colors.white54))
              ),
            ),
          const Spacer(),
          ShowcaseTemplate(
            globalKey: movementStatsKey,
            stepID: 28,
            radius: 10,
            title: "Movement Statistics",
            content: "Various statistics on this movement's history are also listed here.",
            child: Container(
              width: double.infinity,
              height: 400,
              padding: const EdgeInsets.only(top: 20),
              decoration: const BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20),
                  topLeft: Radius.circular(20)
                ),
                border: Border(
                  top: BorderSide(
                    color: Colors.white54,
                    width: 2
                  )
                )
              ),
              child: Column(
                children: [
                  Container(
                      width: MediaQuery.of(context).size.width * 0.85,
                      height: 50,
                      decoration: const BoxDecoration(
                        color: Colors.black12,
                        border: Border(
                            bottom: BorderSide(
                                color: Colors.white54,
                                width: 2
                            ),
                            left: BorderSide(
                                color: Colors.white54,
                                width: 2
                            ),
                            right: BorderSide(
                                color: Colors.white54,
                                width: 2
                            ),
                            top: BorderSide(
                                color: Colors.white54,
                                width: 1
                            )
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(10)
                        ),
                      ),
                      child: Center(child: Text("Total reps performed: $repsPerformed", style: Styles.regularText.copyWith(fontSize: 16)))),
                  const SizedBox(height: 30),
                  Container(
                      width: MediaQuery.of(context).size.width * 0.85,
                      height: 50,
                      decoration: const BoxDecoration(
                        color: Colors.black12,
                        border: Border(
                            bottom: BorderSide(
                                color: Colors.white54,
                                width: 2
                            ),
                            left: BorderSide(
                                color: Colors.white54,
                                width: 2
                            ),
                            right: BorderSide(
                                color: Colors.white54,
                                width: 2
                            ),
                            top: BorderSide(
                                color: Colors.white54,
                                width: 1
                            )
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(10)
                        ),
                      ),
                      child: Center(child: Text("Total ${AppSettings.selectedUnit}s lifted: ${totalWeightLifted.toStringAsFixed(totalWeightLifted.truncateToDouble() == totalWeightLifted ? 0 : 1)}", style: Styles.regularText.copyWith(fontSize: 16)))),
                  const SizedBox(height: 30),
                  Container(
                      width: MediaQuery.of(context).size.width * 0.85,
                      height: 50,
                      decoration: const BoxDecoration(
                        color: Colors.black12,
                        border: Border(
                            bottom: BorderSide(
                                color: Colors.white54,
                                width: 2
                            ),
                            left: BorderSide(
                                color: Colors.white54,
                                width: 2
                            ),
                            right: BorderSide(
                                color: Colors.white54,
                                width: 2
                            ),
                            top: BorderSide(
                                color: Colors.white54,
                                width: 1
                            )
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(10)
                        ),
                      ),
                      child: Center(child: Text("Total times done: ${thisMovementLog.resultSetBlocks.length}", style: Styles.regularText.copyWith(fontSize: 16)))),
                  const SizedBox(height: 30),
                  Container(
                      width: MediaQuery.of(context).size.width * 0.85,
                      height: 50,
                      decoration: const BoxDecoration(
                        color: Colors.black12,
                        border: Border(
                            bottom: BorderSide(
                                color: Colors.white54,
                                width: 2
                            ),
                            left: BorderSide(
                                color: Colors.white54,
                                width: 2
                            ),
                            right: BorderSide(
                                color: Colors.white54,
                                width: 2
                            ),
                            top: BorderSide(
                                color: Colors.white54,
                                width: 1
                            )
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(10)
                        ),
                      ),
                      child: Center(child: Text(timesDoneThisWeek > 0 || thisMovementLog.resultSetBlocks.isEmpty ? "Times done this week: $timesDoneThisWeek" : "Last done: ${DateUtils.dateOnly(thisMovementLog.resultSetBlocks.last.date).toString().substring(0, 10)}", style: Styles.regularText.copyWith(fontSize: 16)))),
                  const SizedBox(height: 75)
                ],
              ),
             ),
          ),
        ]
      ),
    );
  }
}


class MovementNotesScreen extends StatefulWidget {

  final Function updateLogOrder;

  const MovementNotesScreen({required this.updateLogOrder});

  @override
  State<MovementNotesScreen> createState() => _MovementNotesScreenState();
}

class _MovementNotesScreenState extends State<MovementNotesScreen> {
  MovementLog thisMovementLog = LogPage.movementsLogged[LogPage.currentMovementLogIndex];
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool alreadyUpdated = false;

  @override
  void initState() {
   _textController.text = thisMovementLog.notes;
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    _focusNode.requestFocus();

    return Scaffold(
        body: Container(
            height: double.infinity,
            decoration: BoxDecoration(
                gradient: Styles.horizontal()
            ),
            child: ListView(
              children: [
                TextFormField(
                  onChanged: (value) {
                    if (alreadyUpdated == false) {
                      widget.updateLogOrder(thisMovementLog);
                      alreadyUpdated = true;
                    }
                    thisMovementLog.notes = value;
                    thisMovementLog.save();
                  },
                  decoration: InputDecoration(
                    hintText: "Tips for this movement...",
                    hintStyle: const TextStyle(color: Colors.white60),
                    border: InputBorder.none,
                  ),
                  maxLines: null,
                  controller: _textController,
                  focusNode: _focusNode,
                  style: Styles.regularText.copyWith(
                      fontWeight: FontWeight.bold),
                  cursorColor: Colors.white,
                )
              ],
            )
        )
    );
  }
}


class MovementGoalScreen extends StatefulWidget {

  final Function updateLogOrder;

  const MovementGoalScreen({required this.updateLogOrder});

  @override
  State<MovementGoalScreen> createState() => _MovementGoalScreenState();
}

class _MovementGoalScreenState extends State<MovementGoalScreen> {
  MovementLog thisMovementLog = LogPage.movementsLogged[LogPage.currentMovementLogIndex];
  List<List<dynamic>>? projectionValues = [];
  double totalIncrease = 0;
  int numberOfWeeks = 0;
  double increasePerWeek = 0;
  int daysRemaining = 0;
  bool roundUp = true;

  List<List<dynamic>>? generateProjectionValues (double? startWeight, double? endWeight, DateTime? startDate, DateTime? endDate) {
    if(startWeight != null && endWeight != null && startDate != null && endDate != null) {
      List<List<dynamic>> values = [];
      totalIncrease = endWeight - startWeight;
      int numberOfDays = DateUtils.dateOnly(endDate).difference(DateUtils.dateOnly(startDate)).inDays;
      int numberOfWeeks = (numberOfDays / 7).ceil();
      increasePerWeek = totalIncrease / numberOfWeeks;
      daysRemaining = endDate.difference(DateUtils.dateOnly(DateTime.now())).inDays;

      if (numberOfDays % 7 == 0) {
        for (int i = 0; i <= numberOfWeeks; i ++) {
          values.add([startDate.add(Duration(days: 7 * i)), increasePerWeek * i + startWeight]);
        }
      }
      else {
        for (int i = 0; i < numberOfWeeks; i ++) {
          values.add([startDate.add(Duration(days: 7 * i)), increasePerWeek * i + startWeight]);
        }
        values.add([startDate.add(Duration(days: 7 * (numberOfWeeks - 1) + numberOfDays % 7)), increasePerWeek * numberOfWeeks + startWeight]);
      }




      return values;
    }
    else {
      return null;
    }
  }

  @override
  void initState() {
    projectionValues = generateProjectionValues(thisMovementLog.goal.startWeight, thisMovementLog.goal.targetWeight, thisMovementLog.goal.startDate, thisMovementLog.goal.endDate);
    super.initState();

    ShowcaseView.register();


    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        ShowcaseView.get().startShowCase([endGoalKey, goalDateKey]);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    int? currentDatesIndex = projectionValues?.indexWhere(((projection) => projection[0] == DateTime.now()));

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
          gradient: Styles.horizontal()
      ),

          child: Column(
            children: [
              if (projectionValues != null)...[
               Container(
                  height: 175,
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 5),
                  decoration: const BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(10),
                        bottomLeft: Radius.circular(10)
                      ),
                      border: Border(
                     bottom: BorderSide(
                        color: Colors.white54,
                       width: 2
                      )
                    )
                  ),
                  child: Column(
                    children: [
                      Text("Total increase = ${stripDecimals(totalIncrease)}", style: Styles.smallTextWhite),
                      Text("Increase per week ≈ ${stripDecimals(increasePerWeek)}", style: Styles.smallTextWhite),
                      Expanded(
                        child: CarouselSlider.builder(
                          itemCount: projectionValues?.length,
                          itemBuilder: (context, index, realIndex) {
                            return Column(
                              children: [
                                const SizedBox(height: 20),
                                Container(
                                  width: 100,
                                  height: 80,
                                  decoration: BoxDecoration(
                                      color: Colors.black12,
                                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                                    border: Border.all(
                                      color: Colors.white60
                                    )
                                  ),
                                  child: Column(
                                      children: [
                                        Text(DateFormat(AppSettings.dateFormat).format(projectionValues?[index][0]), style: Styles.smallTextWhite.copyWith(color: Colors.white70)),
                                        const Spacer(),
                                          Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text("${stripDecimals(projectionValues![index][1])}", style: Styles.smallTextWhite.copyWith(color: Colors.white, overflow: TextOverflow.ellipsis)),
                                                Text(AppSettings.selectedUnit, style: Styles.smallTextWhite.copyWith(fontSize: 12))
                                              ],
                                            ),
                                        const Spacer()
                                      ],
                                    ),
                                ),
                              ],
                            );
                          },
                          options: CarouselOptions(
                            height: double.infinity,
                            viewportFraction: 0.3,
                            enableInfiniteScroll: false,
                              initialPage: currentDatesIndex ?? (DateTime.now().isBefore(thisMovementLog.goal.endDate!) ? 0 : 1)
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Text("Days remaining: $daysRemaining", style: Styles.paragraph)
              ],
               const Spacer(),
               Container(
                 width: double.infinity,
                 padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 15),
                 height: 400,
                 decoration: const BoxDecoration(
                   color: Colors.black12,
                   border: Border(
                     top: BorderSide(
                       width: 2,
                       color: Colors.white54
                     )
                   ),
                   borderRadius: BorderRadius.only(
                     topLeft: Radius.circular(20),
                     topRight: Radius.circular(20)
                   )
                 ),
                 child: Column(
                   children: [
                     const Row(
                         children: [
                           Text("End goal weight", style: Styles.paragraph),
                           Spacer(),
                           Text("End goal date", style: Styles.paragraph),
                         ]),
                     const SizedBox(height: 10),
                     Row(
                         children: [
                       ShowcaseTemplate(
                         globalKey: endGoalKey,
                         radius: 20,
                         stepID: 29,
                         title: "Goal Weight",
                         content: "This is where you set your goal weight for this movement.",
                         child: InkWell(
                           onTap: () {
                             editWeight (editedText, identifier) {
                               setState(() {
                                 if (editedText != "") {
                                   if (thisMovementLog.goal.startWeight == null) {
                                     thisMovementLog.goal.targetWeight = double.parse(editedText);
                                     projectionValues = generateProjectionValues(thisMovementLog.goal.startWeight, thisMovementLog.goal.targetWeight, thisMovementLog.goal.startDate, thisMovementLog.goal.endDate);
                                     widget.updateLogOrder(thisMovementLog);
                                   }
                                   else {
                                     if (double.parse(editedText) > 0) {
                                       if(double.parse(editedText) > thisMovementLog.goal.startWeight!) {
                                         thisMovementLog.goal.targetWeight = double.parse(editedText);
                                       }
                                       else {
                                         thisMovementLog.goal.targetWeight = double.parse(editedText);
                                         thisMovementLog.goal.startWeight = null;
                                       }


                                         projectionValues = generateProjectionValues(thisMovementLog.goal.startWeight, thisMovementLog.goal.targetWeight, thisMovementLog.goal.startDate, thisMovementLog.goal.endDate);
                                         widget.updateLogOrder(thisMovementLog);
                                     }
                                     else {
                                       ScaffoldMessenger.of(context).showSnackBar(
                                         SnackBar(
                                           backgroundColor: Colors.white,
                                           content: Text(
                                               'End weight must be greater than 0',
                                               style: TextStyle(color: Styles
                                                   .primaryColor)),
                                           duration: const Duration(
                                               milliseconds: 1500),
                                         ),
                                       );
                                     }
                                   }
                                 }
                               });
                             }
                             showDialog(
                                 context: context,
                                 builder: (BuildContext context) {
                                   return EditDialog(
                                       dataToEdit: "", identifier: "LB", editData: editWeight);
                                 }
                             );
                           },
                           child: Container(
                               width: 110,
                               height: 45,
                               decoration: BoxDecoration(
                                   color: Colors.black12,
                                   borderRadius: const BorderRadius.all(Radius.circular(20)),
                                 border: Border.all(
                                   color: Colors.white
                                 )
                               ),
                                 child: Row(
                                   mainAxisAlignment: MainAxisAlignment.center,
                                   children: [
                                     Text(thisMovementLog.goal.targetWeight != null ? "${stripDecimals(thisMovementLog.goal.targetWeight)}" : "Enter", style: Styles.smallTextWhite.copyWith(color: Colors.white)),
                                     if (thisMovementLog.goal.targetWeight != null) Text(AppSettings.selectedUnit,style: Styles.smallTextWhite.copyWith(fontSize: 12))
                                   ],
                                 )),
                         ),
                       ),
                       const Spacer(),
                       ShowcaseTemplate(
                         globalKey: goalDateKey,
                         radius: 20,
                         stepID: 30,
                         title: "Goal Date",
                         content: "This is where you set the date you would like to hit this goal by.",
                         child: InkWell(
                           onTap: () async {
                             DateTime? pickedDate = await showDatePicker(
                               context: context,
                               firstDate: DateTime(DateTime.now().year, DateTime.now().month + 1, DateTime.now().day),
                               lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                               builder: (BuildContext context, Widget? child) {
                                 return Theme(
                                   data: ThemeData.light().copyWith(
                                     colorScheme: ColorScheme.light(
                                       surface: Styles.primaryColor,
                                       primary: Colors.white,
                                       onPrimary: Styles.primaryColor,
                                       onSurface: Colors.white,
                                       error: Colors.white
                                     ),
                                     textSelectionTheme: const TextSelectionThemeData(
                                       cursorColor: Colors.white,
                                     ),
                                     inputDecorationTheme: const InputDecorationTheme(
                                       hintStyle: TextStyle(color: Colors.white54),
                                       labelStyle: TextStyle(color: Colors.white),
                                     ),
                                     textTheme: const TextTheme(
                                       displaySmall: TextStyle(
                                         color: Colors.white
                                       )
                                     ),
                                     dividerTheme: const DividerThemeData(
                                       color: Colors.white,
                                     ),
                                   ),
                                   child: child!,
                                 );
                               },
                             );

                             if(pickedDate != null) {
                               setState(() {
                                 int remainder = DateUtils.dateOnly(DateTime.now()).difference(DateUtils.dateOnly(pickedDate)).inDays % 7;
                                 if (remainder != 0) {
                                   bool round = false;
                                   showDialog(
                                       context: context,
                                       builder: (BuildContext context) {
                                         return ConfirmationDialog(
                                             content: "Would you like to round to the nearest whole week?",
                                             callbackFunction: () {
                                               setState(() {
                                                 if (remainder > 3) {
                                                   thisMovementLog.goal.endDate = DateUtils.dateOnly(pickedDate.subtract(Duration(days: 7 - remainder)));
                                                   projectionValues = generateProjectionValues(thisMovementLog.goal.startWeight, thisMovementLog.goal.targetWeight, thisMovementLog.goal.startDate, thisMovementLog.goal.endDate);
                                                   widget.updateLogOrder(thisMovementLog);
                                                 }
                                                 else {
                                                   thisMovementLog.goal.endDate = DateUtils.dateOnly(pickedDate.add(Duration(days: remainder)));
                                                   projectionValues = generateProjectionValues(thisMovementLog.goal.startWeight, thisMovementLog.goal.targetWeight, thisMovementLog.goal.startDate, thisMovementLog.goal.endDate);
                                                   widget.updateLogOrder(thisMovementLog);
                                                 }

                                                 round = true;
                                               });
                                             });
                                       }
                                   );
                                   if (round == false) {
                                     thisMovementLog.goal.endDate = DateUtils.dateOnly(pickedDate);
                                     projectionValues = generateProjectionValues(thisMovementLog.goal.startWeight, thisMovementLog.goal.targetWeight, thisMovementLog.goal.startDate, thisMovementLog.goal.endDate);
                                     widget.updateLogOrder(thisMovementLog);
                                   }
                                 }
                                 else {
                                   thisMovementLog.goal.endDate = DateUtils.dateOnly(pickedDate);
                                   projectionValues = generateProjectionValues(thisMovementLog.goal.startWeight, thisMovementLog.goal.targetWeight, thisMovementLog.goal.startDate, thisMovementLog.goal.endDate);
                                   widget.updateLogOrder(thisMovementLog);
                                 }
                               });
                             }
                           },
                           child: Container(
                              width: 110,
                               height: 45,
                               decoration: BoxDecoration(
                                   color: Colors.black12,
                                   borderRadius: const BorderRadius.all(Radius.circular(20)),
                                   border: Border.all(
                                       color: Colors.white
                                   )
                               ),
                               child: Center(
                                   child: Text(thisMovementLog.goal.endDate != null ? DateFormat(AppSettings.dateFormat + "yy").format(thisMovementLog.goal.endDate!) : "Enter", style: Styles.smallTextWhite.copyWith(color: Colors.white)))),
                         ),
                       ),
                     ]),
                     const Spacer(),
                     const Row(
                         children: [
                           Text("Start goal weight", style: Styles.paragraph),
                           Spacer(),
                           Text("Start goal date", style: Styles.paragraph),
                         ]),
                     const Divider(),
                     Row(children: [
                       SizedBox(
                         width: 110,
                               child: Row(
                                 mainAxisAlignment: MainAxisAlignment.center,
                                 children: [
                                   Text(thisMovementLog.goal.startWeight != null ? stripDecimals(thisMovementLog.goal.startWeight)! : "-", style: Styles.smallTextWhite),
                                   if (thisMovementLog.goal.startWeight != null) Text(AppSettings.selectedUnit, style: Styles.smallTextWhite.copyWith(fontSize: 12))
                                 ],
                               )),
                       const Spacer(),
                       SizedBox(
                         width: 110,
                           child: Center(
                               child: Text(thisMovementLog.goal.startDate != null ? DateFormat(AppSettings.dateFormat + "yy").format(thisMovementLog.goal.startDate!) : "-", style: Styles.smallTextWhite))),
                     ]),
                    const SizedBox(height: 60),
                     InkWell(
                         onTap: () {
                           if (thisMovementLog.goal.targetWeight != null && thisMovementLog.goal.endDate != null) {
                             setState(() {
                               ResultSet highestSet = ResultSet(reps: 0,
                                   weight: 0,
                                   rir: 0,
                                   setNumber: 0,
                                   idForKey: -1);
                               bool autofilled = false;

                               if (thisMovementLog.prHistory.isNotEmpty) {
                                 ResultSetBlock lastPrBlock = thisMovementLog.prHistory.last;
                                 for (int i = 0; i < lastPrBlock.resultSets.length; i ++) {
                                   if (lastPrBlock.resultSets[i].weight >
                                       highestSet.weight &&
                                       lastPrBlock.resultSets[i].reps > 0) {
                                     highestSet = ResultSet(
                                         reps: lastPrBlock.resultSets[i].reps,
                                         setNumber: lastPrBlock.resultSets[i].setNumber,
                                         rir: lastPrBlock.resultSets[i].rir,
                                         weight: lastPrBlock.resultSets[i].weight,
                                         idForKey: lastPrBlock.resultSets[i].idForKey
                                     );
                                   }
                                 }
                               }


                               TextEditingController textController = TextEditingController();
                               FocusNode focusNode = FocusNode();
                               focusNode.requestFocus();

                               if (highestSet.reps > 0 && highestSet.weight < (thisMovementLog.goal.targetWeight ?? 0) && highestSet.weight != thisMovementLog.goal.startWeight) {
                                 autofilled = true;
                                 textController.text = stripDecimals(highestSet.weight)!;
                               }

                               showDialog(
                                   context: context,
                                   builder: (BuildContext context) {
                                     return Dialog(
                                       insetPadding: const EdgeInsets.symmetric(
                                           horizontal: 60),
                                       shape: RoundedRectangleBorder(
                                         borderRadius: BorderRadius.circular(20.0),
                                       ),

                                       child: Stack(
                                         children: [
                                           Container(
                                               height: 90,
                                               decoration: BoxDecoration(
                                                   borderRadius: BorderRadius.circular(20.0),
                                                   gradient: Styles.darkGradient()
                                               ),
                                               child: Column(
                                                 children: [
                                                   const Padding(
                                                       padding: EdgeInsets.only(
                                                           bottom: 8, top: 5, left: 10),
                                                       child: Center(
                                                         child: Text("Goal starting weight",
                                                             style: Styles.regularText),
                                                       )),
                                                   const Divider(color: Colors.black54,
                                                       height: 6,
                                                       thickness: 2.5),
                                                   const SizedBox(height: 3),
                                                   EditableText(
                                                     textAlign: TextAlign.center,
                                                     keyboardType: const TextInputType
                                                         .numberWithOptions(decimal: true),
                                                     inputFormatters: [
                                                       FilteringTextInputFormatter.allow(
                                                           RegExp(r'^\d*\.?\d*')),
                                                       LengthLimitingTextInputFormatter(5)
                                                     ],
                                                     controller: textController,
                                                     focusNode: focusNode,
                                                     cursorColor: Colors.white,
                                                     style: Styles.regularText.copyWith(
                                                         fontWeight: FontWeight.bold),
                                                     backgroundCursorColor: Colors.white,
                                                   ),
                                                 ],
                                               )
                                           ),
                                           Positioned(right: 0, top: 38,
                                             child: IconButton(onPressed: () {
                                               if (textController.text.isNotEmpty) {
                                                 if (double.parse(textController.text) < (thisMovementLog.goal.targetWeight ?? 0)) {
                                                   setState(() {
                                                     thisMovementLog.goal.startWeight = double.parse(textController.text);
                                                     thisMovementLog.goal.startDate = DateUtils.dateOnly(DateTime.now());
                                                     projectionValues = generateProjectionValues(thisMovementLog.goal.startWeight, thisMovementLog.goal.targetWeight, thisMovementLog.goal.startDate, thisMovementLog.goal.endDate);
                                                     widget.updateLogOrder(thisMovementLog);
                                                     Navigator.of(context).pop();
                                                   });
                                                 }
                                                 else {
                                                   ScaffoldMessenger.of(context)
                                                       .showSnackBar(
                                                     SnackBar(
                                                       backgroundColor: Colors.white,
                                                       content: Text(
                                                           'Starting weight must be less than ending weight',
                                                           style: TextStyle(color: Styles
                                                               .primaryColor)),
                                                       duration: const Duration(
                                                           milliseconds: 1500),
                                                     ),
                                                   );
                                                 }
                                               }
                                             }, icon: const Icon(Icons.arrow_circle_right, color: Colors.white, size: 25)),
                                           ),
                                         ],
                                       ),
                                     );
                                   }
                               );
                               if (autofilled) {
                                 ScaffoldMessenger.of(context).showSnackBar(
                                   SnackBar(
                                     backgroundColor: Colors.white,
                                     content: Text('Auto-filled from PR history',
                                         style: TextStyle(color: Styles.primaryColor)),
                                     duration: const Duration(milliseconds: 1500),
                                   ),
                                 );
                               }
                             });
                           }
                           else {
                             ScaffoldMessenger.of(context).showSnackBar(
                               SnackBar(
                                 backgroundColor: Colors.white,
                                 content: Text('End goal parameters required', style: TextStyle(color: Styles.primaryColor)),
                                 duration: const Duration(milliseconds: 1500),
                               ),
                             );
                           }
                         },
                         child: ShowcaseTemplate(
                           globalKey: startGoalKey,
                           radius: 20,
                           stepID: 31,
                           title: "Starting Goal",
                           content: "Once you input the goal's data, you click here to display a roadmap of how to achieve that weight. This is to help give you an idea of how much you would need to increase your weight per week to reach this goal.",
                           child: Container(
                               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                               decoration: BoxDecoration(
                                   color: Colors.black12,
                                   borderRadius: const BorderRadius.all(Radius.circular(20)),
                                   border: Border.all(
                                       color: Colors.white
                                   )
                               ),
                               child: const Text("Start goal", style: Styles.regularText)),
                         )
                     ),
                     const SizedBox(height: 50)
                   ],
                 ),
               ),
            ],
          ),
    );
  }
}




class SetBlockWidget extends StatefulWidget {
 final ResultSetBlock thisBlock;
 final MovementLog thisMovementLog;
 final Function deleteEntry;

 const SetBlockWidget({required this.deleteEntry, required this.thisBlock, required this.thisMovementLog});
  @override
  State<SetBlockWidget> createState() => _SetBlockWidgetState();
}

class _SetBlockWidgetState extends State<SetBlockWidget> {


  @override
  Widget build(BuildContext context) {
    int index = widget.thisMovementLog.resultSetBlocks.indexOf(widget.thisBlock);
    return Column(
        children: [
          const SizedBox(height: 25),
           Container(
              width: MediaQuery.of(context).size.width * 0.95,
              decoration: BoxDecoration(
                border: const Border(
                  bottom: BorderSide(
                    color: Colors.black54,
                    width: 3
                  )
                ),
                  borderRadius: const BorderRadius.only(
                      topRight:  Radius.circular(20),
                      topLeft:  Radius.circular(20)
                  ),
                  color: Styles.primaryColor,
              ),
              child: Row(
                children: [
                  IconButton(onPressed: () {
                    remove() {
                      widget.deleteEntry(index);

                    }
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return ConfirmationDialog(content: "Are you sure you want to delete this entry?", callbackFunction: remove);
                        }
                    );
                  }, icon: const Icon(Icons.delete),
                      color: Colors.white),
                  const Spacer(),
                  Text(DateFormat(AppSettings.dateFormat == "M/dd/yy" ? "MMMM dd, yyyy" : "dd MMMM, yyyy").format((widget.thisBlock.date)), style: Styles.labelText),
                  const Spacer(),
                  IconButton(onPressed: ()  {
                    bool dayFound = false;  /* this is because I ran into a bug where the for loop would
                                          continue to run even after it navigated to the day and it would
                                          open a bunch of copies of the same page
                                       */
                    if (widget.thisBlock.dayIdForNavigation != -1) {

                      for(int programIndex = 0; programIndex < ProgramsPage.programsList.length; programIndex ++) {

                        for (int weekIndex = 0; weekIndex < ProgramsPage.programsList[programIndex].weeks.length; weekIndex++) {

                          for (int dayIndex = 0; dayIndex < ProgramsPage.programsList[programIndex].weeks[weekIndex].days.length; dayIndex++) {

                            if (ProgramsPage.programsList[programIndex].weeks[weekIndex].days[dayIndex].id == widget.thisBlock.dayIdForNavigation && dayFound != true) {
                              ProgramsPage.activeProgramIndex = programIndex;
                              dayFound = true;
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => DayWidget(
                                  dayIndex: dayIndex,
                                  weekIndex: weekIndex,
                                ),
                              ));
                            }

                          }
                        }
                      }
                    }

                    if (dayFound == false) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.white,
                          content: Text('Session not found in your programs', style: TextStyle(color: Styles.primaryColor)),
                          duration: const Duration(milliseconds: 1500),
                        ),
                      );
                    }
                  },
                      icon: const Icon(Icons.arrow_circle_right_rounded, size: 28),
                      color: Colors.white)
                ],
              ),
            ),
          Container(
            width: MediaQuery.of(context).size.width * 0.95,
            padding: const EdgeInsets.only(bottom: 5),
            decoration: BoxDecoration(
             gradient: Styles.darkGradient(),
                borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20)
                ),
            ),
            child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: widget.thisBlock.resultSets.length,
                itemBuilder: (context, index) {
                  final thisEntry = widget.thisBlock.resultSets[index];
                  return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(width: 65, child: Row(children: [Text(thisEntry.setType != "default" ? thisEntry.setType : "SET ${thisEntry.setNumber.toString()}:", style: Styles.smallTextWhite)])),
                        SizedBox(width: 120,child: Row(children: [Text("${stripDecimals(thisEntry.weight)}", style: Styles.regularText.copyWith(fontWeight: FontWeight.normal)), Text(AppSettings.selectedUnit, style: Styles.smallTextWhite)])),
                        SizedBox(width: 80, child: Row(children: [Text(thisEntry.reps.toString(), style: Styles.regularText.copyWith(fontWeight: FontWeight.normal)), const Text("REPS", style: Styles.smallTextWhite)])),
                        if(AppSettings.rirActive) SizedBox(width: 80, child: Row(children: [Text(thisEntry.rir.toString(), style: Styles.regularText.copyWith(fontWeight: FontWeight.normal)), const Text("RIR", style: Styles.smallTextWhite)])),
                      ]
                  );
                }
            ),

          ),

        ]
    );
  }
}

class ProgressChart extends StatefulWidget {
  final bool displaySmall;
  final bool? subtractMonth;
  final Function refreshListLength;
  final Function refreshYearNumber;
  final Function refreshMonthNumber;
  final List <ResultSetBlock> thisDatesBlocks;
  static bool dotsActive = true;
  static bool yearViewActive = false;

  const ProgressChart({this.subtractMonth, required this.displaySmall, required this.refreshListLength, required this.thisDatesBlocks, required this.refreshYearNumber, required this.refreshMonthNumber});

  @override
  State<ProgressChart> createState() => ProgressChartSettings();
}

class ProgressChartSettings extends State<ProgressChart> {
  bool tracking1RM = true;
  bool minimized = false;

  refreshChartSettings () {
    setState(() {

    });
  }


  refreshFormula(formula) {
    if(ProgressChart.yearViewActive == true) {
      for(int i = 0; i < LogPage.movementsLogged[LogPage.currentMovementLogIndex].resultSetBlocks.length; i++) {
        LogPage.movementsLogged[LogPage.currentMovementLogIndex].resultSetBlocks[i].oneRepMax = calcOneRepMax(
            LogPage.movementsLogged[LogPage.currentMovementLogIndex].resultSetBlocks[i].resultSets, ChartSettings.selectedFormula);
      }
    }
    else {
    for(int i = 0; i < widget.thisDatesBlocks.length; i++) {
      widget.thisDatesBlocks[i].oneRepMax = calcOneRepMax(
          widget.thisDatesBlocks[i].resultSets, ChartSettings.selectedFormula);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    refreshFormula(ChartSettings.selectedFormula);
    List<FlSpot> spotsList = [];
    List<ResultSetBlock> parallelList = [];
    List <ResultSetBlock> blocksInThisMonth = [];

    widget.thisDatesBlocks.sort((a, b) => a.date.compareTo(b.date));
    /*
    if you update this widget with setState,
    but you don't callback to its parent function,
    the "thisDatesBlock" list gets out of sort.
    This is because the list is sorted in the parent widget,
    so for it to be sorted you have to callback to that widget,
    or sort it in this child widget. The list being unsorted is
    only a problem with the way you set the charts color based on
    the value of the first day vs the last day. When you create the
    chart it's sorted by days anyways since day is the x value,
    that's why you don't notice the list being unsorted on the chart
     */



    if (ProgressChart.yearViewActive == true && widget.displaySmall == false) {
      for (int m = 1; m <= 12; m ++) {
       blocksInThisMonth = LogPage.movementsLogged[LogPage.currentMovementLogIndex].resultSetBlocks.
        where((block) => block.date.year == MovementLogScreenState.yearNumber && block.date.month == m).toList();

       Set<String> uniqueDates = blocksInThisMonth.map((block) => '${block.date.year}-${block.date.month}-${block.date.day}').toSet();

       if (uniqueDates.length > 1) {
         // make it so that it gets the highest one rep max day from each of these blocks
          blocksInThisMonth.sort((a, b) => a.date.compareTo(b.date));
          spotsList.add(FlSpot(blocksInThisMonth[0].date.month.toDouble() * 100 + blocksInThisMonth[0].date.day, blocksInThisMonth[0].oneRepMax));
              parallelList.add(blocksInThisMonth[0]);
              spotsList.add(FlSpot(blocksInThisMonth.last.date.month.toDouble() * 100 + blocksInThisMonth.last.date.day, blocksInThisMonth.last.oneRepMax));
              parallelList.add(blocksInThisMonth.last);
        }
      }
    }
    else {
      List <ResultSetBlock> thisDatesBlocks = widget.thisDatesBlocks;

      for (int i = 0; i < thisDatesBlocks.length; i++) {
        ResultSetBlock thisBlock = thisDatesBlocks[i];
        List <ResultSetBlock> multipleBlocks = thisDatesBlocks.where((element) =>
        element.date.day == thisBlock.date.day.toDouble() && element.date.month == thisBlock.date.month).toList();


        if (multipleBlocks.length > 1) {
          // checks if there are multiple blocks from the same day, then finds the highest weight day

          double highestWeight = multipleBlocks[0].oneRepMax;

          for (int s = 1; s < multipleBlocks.length; s ++) {
            if (multipleBlocks[s].oneRepMax > highestWeight) {
              highestWeight = multipleBlocks[s].oneRepMax;
              thisBlock = multipleBlocks[s];
            }
          }
        }

          if (!spotsList.any((element) => element.x == thisBlock.date.day.toDouble())) {
            spotsList.add(FlSpot(thisBlock.date.day.toDouble(), thisBlock.oneRepMax));
            parallelList.add(thisBlock);
        }
      }
    }

    Color positiveColor = Colors.green;
    Color negativeColor = Colors.red;
    
   if(ChartSettings.lineColor == "Green and red") {
      positiveColor = Colors.green;
      negativeColor = Colors.red;
   }
   else if (ChartSettings.lineColor == "White and black") {
      positiveColor = Colors.white;
      negativeColor = Colors.black87;
   }
   else {
      positiveColor = Colors.white;
      negativeColor = Colors.white;
   }
    return  Center(
        child: Column(
              children: [
                spotsList.length > 1 ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                   if (!widget.displaySmall)...[
                     Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                     decoration: BoxDecoration(
                       gradient: Styles.darkGradient(),
                       boxShadow: [
                         if(!minimized) const BoxShadow(
                           color: Colors.black54,
                           spreadRadius: 1,
                           blurRadius: 5,
                           offset: Offset(0, 3),
                         ),
                       ],

                       border: minimized ? const Border(
                         bottom: BorderSide(
                           color: Colors.black54,
                           width: 2
                         )
                       )
                           : const Border()
                     ),
                          child: Row(
                            children: [
                            const Text("PROGRESS CHART", style: Styles.paragraph),
                              const Spacer(),
                               IconButton(
                                 onPressed: () {
                                  setState(() {
                                    minimized = !minimized;
                                  });
                                 },
                                   icon: Icon(minimized ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up, color: Colors.white, size: 30))
                            ],
                          ),
                    ),
                    ],
                    if (minimized != true) Container(
                      decoration: BoxDecoration(
                        color: widget.displaySmall ? Styles.chartColor : Colors.black12,
                        borderRadius: widget.displaySmall ? const BorderRadius.all(Radius.circular(20)) : BorderRadius.zero,
                      ),
                      width: double.infinity,
                      height: widget.displaySmall ? MediaQuery.of(context).size.height / 5 : MediaQuery.of(context).size.height / 4,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                      child: LineChart(
                        LineChartData(
                          lineBarsData: [
                            LineChartBarData(
                              color: spotsList[spotsList.length - 1].y >= spotsList[0].y ? positiveColor : negativeColor,
                              spots: spotsList,
                              isCurved: false,
                              dotData: FlDotData(show: ProgressChart.dotsActive),
                              belowBarData: BarAreaData(show: false),
                            ),
                          ],
                          titlesData: const FlTitlesData(
                            topTitles: AxisTitles(),
                            rightTitles: AxisTitles(),
                            leftTitles: AxisTitles(),
                            bottomTitles: AxisTitles(),
                          ),
                          borderData: FlBorderData(show: false),
                          gridData: const FlGridData(show: true),


                          lineTouchData: LineTouchData(
                            touchTooltipData: LineTouchTooltipData(
                              fitInsideHorizontally: true,
                              fitInsideVertically: true,
                              getTooltipColor: (LineBarSpot spot) {return Colors.white;},
                              getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                                return touchedBarSpots.map((LineBarSpot touchedSpot) {
                                  List<ResultSet> parallelSets = parallelList[touchedSpot.spotIndex].resultSets;
                                 ResultSet oneRMParallelSet = parallelSets[findIndexOfOneRepMax(parallelSets, ChartSettings.selectedFormula)];
                                 return LineTooltipItem(
                                  formatTooltip(
                                    widget.subtractMonth,
                                    ProgressChart.yearViewActive,
                                    widget.displaySmall,
                                    ChartSettings.dataDisplay,
                                    touchedSpot,
                                    oneRMParallelSet,
                                  ),
                                   TextStyle(color: Styles.primaryColor, fontWeight: FontWeight.bold),
                                  );
                                }).toList();
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
                :  ShowcaseTemplate(
                  globalKey: progressChartKey,
                  stepID: 23,
                  radius: 0,
                  title: "Progress Chart",
                  content: "Your progress chart will appear here when you have two or more entries on at least two separate days.",
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: widget.displaySmall
                          ? const BorderRadius.all(Radius.circular(20))
                          : BorderRadius.zero,
                      gradient: !widget.displaySmall
                          ? Styles.darkGradient()
                          : null,
                      color: widget.displaySmall
                          ? Styles.chartColor
                          : null,
                      border: Border(
                        bottom: !widget.displaySmall
                            ? const BorderSide(
                          color: Colors.black54,
                          width: 2,
                        )
                            : BorderSide.none,
                      ),
                    ),

                    width: double.infinity,
                    height: widget.displaySmall ? MediaQuery.of(context).size.height / 5 : 45,
                    child: const Center(child: Text("(Not enough entries for progress chart)", style: Styles.smallTextWhite)),
                  ),
                ),


                if (!widget.displaySmall)...[
                  Container(
                   decoration: BoxDecoration(
                     gradient: Styles.darkGradient(),
                     boxShadow: [
                       !minimized &&  spotsList.length > 1 ? const BoxShadow(
                         color: Colors.black54,
                         spreadRadius: 3,
                         blurRadius: 5,
                         offset: Offset(0, 0),
                       )
                           : const BoxShadow(
                         color: Colors.black54,
                         spreadRadius: 1,
                         blurRadius: 5,
                         offset: Offset(0, 3),
                       )
                     ],
                   ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ShowcaseTemplate(
                        globalKey: settingMonthKey,
                        stepID: 24,
                        radius: 10,
                        title: "Setting Display Month",
                        content: "This is where you set the month to display. This is used to determine the progress chart's dataset and the log entries to display below.",
                        child: Row(
                            children: [
                          IconButton(onPressed: () {
                            widget.refreshListLength(31);
                            if (MovementLogScreenState.monthNumber > 1) {
                              widget.refreshMonthNumber(MovementLogScreenState.monthNumber - 1);
                            }
                            else {
                              widget.refreshMonthNumber(MovementLogScreenState.monthNumber = 12);
                            }
                          }, icon: const Icon(Icons.keyboard_double_arrow_left, color: Colors.white54, size: 35)),
                          Text(DateFormat('MMMM').format(DateTime(0, MovementLogScreenState.monthNumber)).toUpperCase(), style: Styles.regularText.copyWith(color: Colors.white54)),
                          IconButton(onPressed: () {
                            widget.refreshListLength(31);
                            if (MovementLogScreenState.monthNumber < 12) {
                              widget.refreshMonthNumber(MovementLogScreenState.monthNumber + 1);
                            } else {
                              widget.refreshMonthNumber(MovementLogScreenState.monthNumber = 1);
                            }
                          }, icon: const Icon(Icons.keyboard_double_arrow_right, color: Colors.white54, size: 35)),
                        ]),
                      ),

                      const Spacer(),
                      ShowcaseTemplate(
                        globalKey: chartSettingKey,
                        stepID: 25,
                        radius: 20,
                        title: "Chart Settings",
                        content: "This is where you can change various settings in your chart. This includes an option to set the current year to display, the 1RM formula used to determine your progress, and a year view toggle to see the entire year's data in the progress chart.",
                        child: IconButton(onPressed: () {
                         showDialog(
                           context: context,
                           builder: (BuildContext context) {
                             return ChartSettings(refreshFormula: refreshFormula, refreshListLength: widget.refreshListLength, refreshYearNumber: widget.refreshYearNumber, refreshChartSettings: refreshChartSettings);
                           },
                         );
                                             }, icon: const Icon(Icons.settings, color: Colors.white, size: 30)),
                      )
                    ],
                  ),
                ),
                ]
              ],
            )
    );

  }
    }


class CustomSpot {
  final FlSpot spot;
  final ResultSetBlock block;

  CustomSpot({required this.spot, required this.block});
}

class ChartSettings extends StatefulWidget {
  final Function refreshListLength;
  final Function refreshYearNumber;
  final Function refreshFormula;
  final Function refreshChartSettings;
  static String selectedFormula = "Brzycki's formula";
  static String lineColor = "Green and red";
  static String dataDisplay = "Calculated 1RM";

  const ChartSettings({required this.refreshFormula, required this.refreshListLength, required this.refreshChartSettings, required this.refreshYearNumber});

  @override
  State<ChartSettings> createState() => ChartSettingsState();
}

class ChartSettingsState extends State<ChartSettings> {

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  gradient: Styles.darkGradient()
              ),
              width: MediaQuery.of(context).size.width * 0.95,
              height: 360,
                child: Stack(
                  children: [
                    Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(20.0),
                                  topLeft: Radius.circular(20.0)
                              ),
                              border: const Border(
                                  bottom: BorderSide(
                                      color: Colors.black45,
                                      width: 2
                                  )
                              ),
                              color: Styles.primaryColor
                          ),
                          child: const Center(
                                 child: Text("Chart settings", style: Styles.labelText),
                              ),
                        ),
                        Material(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                                gradient: Styles.darkGradient()
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text("Selected year:", style: Styles.smallTextWhite.copyWith(color: Colors.white)),
                                    const Spacer(),
                                    IconButton(onPressed: () {
                                      widget.refreshListLength(31);
                                      widget.refreshYearNumber(MovementLogScreenState.yearNumber - 1);
                                      setState(() {
                                       //this is so you can actually see it updating on this dialog screen
                                      });
                                    }, icon: const Icon(Icons.indeterminate_check_box, color: Colors.white, size: 30)),
                                    Text(MovementLogScreenState.yearNumber.toString(), style: Styles.regularText),
                                    IconButton(onPressed: () {
                                      widget.refreshListLength(31);
                                      if(MovementLogScreenState.yearNumber != DateTime.now().year) {
                                        widget.refreshYearNumber(MovementLogScreenState.yearNumber + 1);
                                        setState(() {
                                          //this is so you can actually see it updating on this dialog screen
                                        });
                                      }
                                    }, icon: const Icon(Icons.add_box, color: Colors.white, size: 30)),
                                  ],
                                ),
                                Row(
                                  children: [
                                     Text("1RM formula:", style: Styles.smallTextWhite.copyWith(color: Colors.white)),
                                    const Spacer(),
                                    DropdownButton(
                                          value: ChartSettings.selectedFormula,
                                          style: Styles.smallTextWhite,
                                          dropdownColor: Styles.primaryColor,
                                          items: const [
                                            DropdownMenuItem(value: "Brzycki's formula", child: Text("Brzycki's formula")),
                                            DropdownMenuItem(value: "Lombardi's formula", child: Text("Lombardi's formula")),
                                            DropdownMenuItem(value: "Lander's formula", child: Text("Lander's formula")),
                                            DropdownMenuItem(value: "Epley's formula", child: Text("Epley's formula"))
                                          ], onChanged: (value) {
                                        setState(() {
                                          ChartSettings.selectedFormula = value!;
                                          widget.refreshFormula(value);
                                          widget.refreshChartSettings();
                                            () async {
                                            SharedPreferences prefs = await SharedPreferences.getInstance();
                                            prefs.setString("selectedFormula", ChartSettings.selectedFormula);
                                          }();
                                        });

                                      }
                                      ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text("Line color:", style: Styles.smallTextWhite.copyWith(color: Colors.white)),
                                    const Spacer(),
                                    DropdownButton(
                                        value: ChartSettings.lineColor,
                                        style: Styles.smallTextWhite,
                                        dropdownColor: Styles.primaryColor,
                                        items: const [
                                          DropdownMenuItem(value: "Green and red", child: Text("Green and red")),
                                          DropdownMenuItem(value: "White and black", child: Text("White and black")),
                                          DropdownMenuItem(value: "White", child: Text("White")),
                                        ], onChanged: (value) {
                                      setState(() {
                                        ChartSettings.lineColor = value!;
                                        widget.refreshChartSettings();
                                          ()async {
                                          SharedPreferences prefs = await SharedPreferences.getInstance();
                                          prefs.setString("lineColor", ChartSettings.lineColor);
                                        }();
                                      });

                                    }
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text("Data display:", style: Styles.smallTextWhite.copyWith(color: Colors.white)),
                                    const Spacer(),
                                    DropdownButton(
                                        value: ChartSettings.dataDisplay,
                                        style: Styles.smallTextWhite,
                                        dropdownColor: Styles.primaryColor,
                                        items: const [
                                          DropdownMenuItem(value: "Calculated 1RM", child: Text("Calculated 1RM")),
                                          DropdownMenuItem(value: "Weight and reps", child: Text("Weight and reps")),
                                        ], onChanged: (value) {
                                      setState(() {
                                        ChartSettings.dataDisplay = value!;
                                        widget.refreshChartSettings();
                                        ()async {
                                          SharedPreferences prefs = await SharedPreferences.getInstance();
                                          prefs.setString("dataDisplay", ChartSettings.dataDisplay);
                                        }();
                                      });

                                    }
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 10),
                                const Divider(),
                                Row(
                                    children: [
                                      Switch(
                                          activeColor: Colors.white,
                                          inactiveThumbColor: Styles.primaryColor,
                                          activeTrackColor: Colors.white38,
                                          value: ProgressChart.dotsActive,
                                          onChanged: (value) {
                                            setState(() {
                                              ProgressChart.dotsActive = value;
                                              widget.refreshChartSettings();
                                                () async {
                                                SharedPreferences prefs = await SharedPreferences.getInstance();
                                                prefs.setBool("dotsActive", ProgressChart.dotsActive);
                                              }();
                                            });
                                          }),
                                      const Text(" Data points", style: Styles.smallTextWhite),
                                      const Spacer(),
                                      Switch(
                                          activeColor: Colors.white,
                                          inactiveThumbColor: Styles.primaryColor,
                                          activeTrackColor: Colors.white38,
                                          value: ProgressChart.yearViewActive,
                                          onChanged: (value) {
                                            setState(() {
                                              ProgressChart.yearViewActive = value;
                                              widget.refreshChartSettings();
                                                ()async {
                                                SharedPreferences prefs = await SharedPreferences.getInstance();
                                                prefs.setBool("yearViewActive", ProgressChart.yearViewActive);
                                              }();
                                            });
                                          }),
                                      const Text(" Year view", style: Styles.smallTextWhite),
                                    ]),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                    Positioned(left: 0, top: 10,
                      child: IconButton(onPressed: () {
                        Navigator.of(context).pop();
                      },
                          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white)),
                    ),
                  ],
                ),
          ),
        ],
      ),
    );
  }
}

int findIndexOfOneRepMax (List <ResultSet> resultSets, String? formula) {
  double currentMax = 0;
  int index = 0;

  for(int i = 0; i < resultSets.length; i ++) {
    double thisSetsMax = 0;

    switch (formula) {
      case "Epley's formula":
        thisSetsMax = resultSets[i].weight * (1 + 0.0333 * (resultSets[i].reps));
        break;

      case "Lander's formula":
        thisSetsMax = (100 * resultSets[i].weight) / (101.3 - (2.67123 * (resultSets[i].reps)));
        break;

      case "Lombardi's formula":
        thisSetsMax = resultSets[i].weight * math.pow((resultSets[i].reps), 0.1);
        break;

      case "Brzycki's formula":
        thisSetsMax = resultSets[i].weight / ( 1.0278 - (0.0278 * (resultSets[i].reps)));
        break;
    }

    if (thisSetsMax > currentMax && resultSets[i].reps > 0) {
      currentMax = thisSetsMax;
      index = i;
    }
  }

  return index;
}

double calcOneRepMax (List<ResultSet> resultSets, String? formula) {
  double currentMax = 0;

  for(int i = 0; i < resultSets.length; i ++) {
    double thisSetsMax = 0;

    switch (formula) {
      case "Epley's formula":
        thisSetsMax = resultSets[i].weight * (1 + 0.0333 * (resultSets[i].reps));
        break;

      case "Lander's formula":
        thisSetsMax = (100 * resultSets[i].weight) / (101.3 - (2.67123 * (resultSets[i].reps)));
        break;

      case "Lombardi's formula":
        thisSetsMax = resultSets[i].weight * math.pow((resultSets[i].reps), 0.1);
        break;

      case "Brzycki's formula":
        thisSetsMax = resultSets[i].weight / ( 1.0278 - (0.0278 * (resultSets[i].reps)));
        break;
    }

    if (thisSetsMax > currentMax && resultSets[i].reps > 0) {
      currentMax = thisSetsMax;
    }
  }

   return double.parse(currentMax.toStringAsFixed(2));
}

String formatTooltip(bool? subtractMonth, bool isYearViewActive, bool displaySmall, String dataDisplay, FlSpot touchedSpot, ResultSet parallelSet) {

  String date;
  if (isYearViewActive && !displaySmall) {
    if (touchedSpot.x.toString().length == 6) {
      int month = int.parse(touchedSpot.x.toString().substring(0, 2));
      int day = touchedSpot.x.toInt() - month * 100;
      date = "$month/$day";
      }
      else {
      int month = int.parse(touchedSpot.x.toString().substring(0, 1));
      int day = touchedSpot.x.toInt() - month * 100;
      date = "$month/$day";
      }

  } else {
    date = "${subtractMonth != null ? MovementLogScreenState.monthNumber - 1 : MovementLogScreenState.monthNumber}/${touchedSpot.x.toInt()}";
  }

  String data;
  if (dataDisplay == "Calculated 1RM") {
    data = touchedSpot.y == touchedSpot.y.truncateToDouble()
        ? touchedSpot.y.toStringAsFixed(0)
        : touchedSpot.y.toStringAsFixed(1);
  } else {
    data = "${parallelSet.weight == parallelSet.weight.truncateToDouble()
        ? parallelSet.weight.toStringAsFixed(0)
        : parallelSet.weight.toStringAsFixed(1)}x${parallelSet.reps}";
  }

  return "$data, $date";
}
