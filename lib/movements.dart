import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gym_app/programs_page.dart';
import 'package:showcaseview/showcaseview.dart';
import 'main.dart';
import 'dart:async';
import 'dialogs.dart';
import 'workout_log.dart';
import 'home_screen.dart';
import 'notification.dart';


final GlobalKey movementListKey = GlobalKey();
final GlobalKey movementOptionsKey = GlobalKey();
final GlobalKey movementEditButtonsKey = GlobalKey();
final GlobalKey thisSessionKey = GlobalKey();
final GlobalKey thisSessionIconKey = GlobalKey();
final GlobalKey duplicateSessionKey = GlobalKey();
final GlobalKey lastSessionKey = GlobalKey();
final GlobalKey lastSessionIconKey = GlobalKey();
final GlobalKey notesIconKey = GlobalKey();
final GlobalKey completeIconKey = GlobalKey();






class MovementWidget extends StatefulWidget {
  static int thisLinesId = 0;
  final day currentDay;
  final int movementIndex;
  final Function refreshParent;
  final Function (int) removeThisMovement;


  const MovementWidget({required this.refreshParent, required this.currentDay, required this.movementIndex, required this.removeThisMovement});

  @override
  State<MovementWidget> createState() => _MovementWidgetState();

}

class _MovementWidgetState extends State<MovementWidget> {
  Program thisProgram = ProgramsPage.programsList[ProgramsPage.activeProgramIndex];

  void refreshPage() {
    setState(() {

    });
  }


  @override
  Widget build(BuildContext context) {
    Movement thisMovement = widget.currentDay.movements[widget.movementIndex];

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => OpenMovement(thisMovement: thisMovement, movementIndex: widget.movementIndex, currentDay: widget.currentDay, refreshPage: refreshPage),
          ),
        );
      },
      child: Column(
        children: [
          if(widget.movementIndex == 0) const SizedBox(height: 30),
          ColorFiltered(
          colorFilter: ColorFilter.mode(
          Colors.grey.withValues(alpha: thisMovement.hasBeenLogged == true ? 0.3 : 0),
          BlendMode.srcATop,
          ),
            child: ShowcaseTemplate(
              radius: 20,
              stepID: 9,
              globalKey: movementListKey,
              title: "Movements List",
              content: "This is where the movements of the day are listed. You can rearrange the list by holding down on a movement and then dragging up or down. Tap the movement to open it and make changes to it or add sets to its log.",
              child: Container(
                      width: MediaQuery.of(context).size.width - 30,
                      height: 90,
                      padding: const EdgeInsets.only(top: 4, left: 5, right: 5),
                      decoration: BoxDecoration(
                          gradient: Styles.horizontal(),
                          borderRadius: BorderRadius.circular(20),
                          border: const Border(
                              bottom: BorderSide(
                                  color: Colors.black45,
                                  width: 5
                              ),
                              right: BorderSide(
                                  color: Colors.black45,
                                  width: 3
                              ),
                              left: BorderSide(
                                color: Colors.black45,
                                width: 3
                              )
                          )
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    if(thisMovement.hasBeenLogged == true)
                                      const Icon(Icons.done_outline_sharp, color: Colors.white),
                                    const SizedBox(width: 10),
                                    Expanded(child: Text(thisMovement.name, style: Styles.regularText)),
                                  ],
                                ),
                                const Divider(thickness: 2, endIndent: 15),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Row(
                                      children: [
                                        Text("${thisMovement.sets}", style: Styles.smallTextWhite.copyWith(fontSize: 20, fontWeight: FontWeight.bold)),
                                        Text("x", style: Styles.smallTextWhite.copyWith(fontSize: 20, fontWeight: FontWeight.normal)),
                                        Text(thisMovement.reps, style: Styles.smallTextWhite.copyWith(fontSize: 20, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(thisMovement.weight.toStringAsFixed(thisMovement.weight.truncateToDouble() == thisMovement.weight ? 0 : 1),
                                            style: Styles.smallTextWhite.copyWith(fontSize: 20, fontWeight: FontWeight.bold)),
                                        Text(AppSettings.selectedUnit, style: Styles.smallTextWhite.copyWith(fontSize: 15, fontWeight: FontWeight.normal)),
                                      ],
                                    ),
                                      Row(
                                        children: [
                                          if (!AppSettings.rirActive) ...[
                                          Text("${thisMovement.rest.inMinutes}", style: Styles.smallTextWhite.copyWith(fontSize: 20, fontWeight: FontWeight.bold)),
                                          Text(":", style: Styles.smallTextWhite.copyWith(fontSize: 20,)),
                                          Text((thisMovement.rest.inSeconds % 60).toString().padLeft(2, '0'), style: Styles.smallTextWhite.copyWith(fontSize: 20, fontWeight: FontWeight.bold)),
                                          Text(" REST", style: Styles.smallTextWhite.copyWith(fontSize: 15)),
                                          ]
                                          else ...[
                                            Text(thisMovement.rir, style: Styles.smallTextWhite.copyWith(fontSize: 20, fontWeight: FontWeight.bold)),
                                            Text("RIR", style: Styles.smallTextWhite.copyWith(fontSize: 15))
                                          ]
                                        ],
                                      ),
                                  ],
                                )

                              ],
                            ),
                          ),
                          ShowcaseTemplate(
                            radius: 5,
                            globalKey: movementOptionsKey,
                            stepID: 10,
                            title: "Making Changes To The Movements List",
                            content: "Tap this button to make changes to the days list, such as adding supersets, or copying, deleting, and changing movements.",
                            child: PopupMenuButton<ListTile>(
                              padding: const EdgeInsets.all(0),
                                itemBuilder: (context) {
                                  return [
                                   if(thisMovement != widget.currentDay.movements.last) PopupMenuItem<ListTile>(
                                      onTap: () {
                                        setState(() {
                                          thisMovement.superset = !thisMovement.superset;
                                        });
                                        thisProgram.save();
                                      },
                                      child: ListTile(
                                        leading: Icon(thisMovement.superset == false ? Icons.add_box : Icons.indeterminate_check_box, color: Styles.primaryColor),
                                        title: Text('Superset', style: TextStyle(color: Styles.primaryColor)),
                                      ),
                                    ),
                                    PopupMenuItem<ListTile>(
                                        onTap: () {
                                          copiedMovement = Movement(
                                            resultSets: [],
                                            superset: thisMovement.superset,
                                            name: thisMovement.name,
                                            sets: thisMovement.sets,
                                            reps: thisMovement.reps,
                                            rir: thisMovement.rir,
                                            notes: "",
                                            weight: thisMovement.weight,
                                            rest: thisMovement.rest,
                                            remainingRestTime: thisMovement.rest,
                                          );
                                          ScaffoldMessenger.of(context).showSnackBar(
                                             SnackBar(
                                              backgroundColor: Colors.white,
                                              content: Text('Movement copied',
                                                  style: TextStyle(color: Styles.primaryColor)),
                                              duration: const Duration(milliseconds: 1500),
                                            ),
                                          );
                                        },
                                      child: ListTile(
                                        leading: Icon(Icons.copy, color: Styles.primaryColor),
                                        title: Text('Copy', style: TextStyle(color: Styles.primaryColor)),
                                      ),
                                    ),
                                    PopupMenuItem<ListTile>(
                                      onTap: () {
                                        final FocusNode focusNode = FocusNode();
                                        TextEditingController dialogController = TextEditingController();

                                        bool showAllMuscleGroups = false;

                                        late FocusNode searchFocus = FocusNode();
                                        TextEditingController searchController = TextEditingController();


                                        List<MovementLog> rootList = [];
                                        List<MovementLog> displayList = [];


                                          if(widget.currentDay.muscleGroups != null && widget.currentDay.muscleGroups!.isNotEmpty) {
                                            //get all the movements with muscle groups that match the muscle groups in this day
                                            rootList = LogPage.movementsLogged.where((log) {
                                              if ((log.primaryMuscleGroups == null && log.secondaryMuscleGroups == null) || widget.currentDay.muscleGroups == null) {
                                                return false;
                                              }

                                              bool primaryMatches = log.primaryMuscleGroups?.any((muscle) => widget.currentDay.muscleGroups!.contains(muscle)) ?? false;
                                              bool secondaryMatches = log.secondaryMuscleGroups?.any((muscle) => widget.currentDay.muscleGroups!.contains(muscle)) ?? false;

                                              return primaryMatches || secondaryMatches;
                                            }).toList();
                                          }
                                          else {
                                            showAllMuscleGroups = true;
                                            rootList = LogPage.movementsLogged;
                                          }


                                        displayList = List.from(rootList.where((element) => element.name.replaceAll(RegExp(r'\s+'), '').toLowerCase().contains(searchController.text.replaceAll(RegExp(r'\s+'), '').toLowerCase())));




                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {

                                              focusNode.requestFocus();
                                              dialogController.text = thisMovement.name;

                                              return  StatefulBuilder(
                                                  builder: (context, setDialogState) {
                                                  return Dialog(
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(20.0),
                                                    ),
                                                    insetPadding: const EdgeInsets.only(left: 30, right: 30),
                                                    child: Container(
                                                      height: MediaQuery.of(context).size.height * 0.4,
                                                        decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(20.0),
                                                            gradient: Styles.horizontal()
                                                        ),
                                                        child: Stack(
                                                          children: [
                                                            Column(
                                                              children: [
                                                                Row(children: [
                                                                  Expanded(
                                                                    child: TextField(
                                                                      focusNode: searchFocus,
                                                                      onTap: () {
                                                                        setDialogState(() {
                                                                          if (searchFocus.hasFocus == true) {
                                                                            searchFocus.unfocus();
                                                                          }
                                                                          else {
                                                                            displayList = List.from(rootList.where((element) => element.name.replaceAll(RegExp(r'\s+'), '').toLowerCase().contains(searchController.text.replaceAll(RegExp(r'\s+'), '').toLowerCase())));
                                                                          }
                                                                        });
                                                                      },
                                                                      onChanged: (text) {
                                                                        setDialogState(() {
                                                                          displayList = List.from(rootList.where((element) => element.name.replaceAll(RegExp(r'\s+'), '').toLowerCase().contains(text.replaceAll(RegExp(r'\s+'), '').toLowerCase())));
                                                                        });
                                                                      },
                                                                      inputFormatters: <TextInputFormatter>[
                                                                        LengthLimitingTextInputFormatter(27)
                                                                      ],
                                                                      controller: searchController,
                                                                      decoration: const InputDecoration(
                                                                        contentPadding: EdgeInsets.only(right: 40, left: 20, top: 15, bottom: 15),
                                                                        hintText: 'Search',
                                                                        hintStyle: Styles.smallTextWhite,
                                                                        focusedBorder: OutlineInputBorder(
                                                                          borderRadius: BorderRadius.all(Radius.circular(20)),
                                                                          borderSide: BorderSide(color: Colors.white),
                                                                        ),
                                                                        enabledBorder: OutlineInputBorder(
                                                                          borderRadius: BorderRadius.all(Radius.circular(20),
                                                                          ),
                                                                          borderSide: BorderSide(color: Colors.white60),
                                                                        ),
                                                                      ),
                                                                      style: Styles.regularText,
                                                                      cursorColor: Colors.white,
                                                                    ),
                                                                  )
                                                                ]),
                                                                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                                                                if(displayList.isNotEmpty)...[
                                                                  Expanded(
                                                                      child: ListView.builder(
                                                                          scrollDirection: Axis.vertical,
                                                                          shrinkWrap: true,
                                                                          itemCount: displayList.length,
                                                                          itemBuilder: (context, index) {
                                                                            return InkWell(
                                                                              onTap: () {
                                                                                setDialogState(() {
                                                                                  showDialog(
                                                                                    context: context,
                                                                                    builder: (BuildContext context) {
                                                                                      return ConfirmationDialog(content: "Change '${thisMovement.name}' to '${displayList[index].name}'?", callbackFunction: () {
                                                                                        thisMovement.name = displayList[index].name;
                                                                                        thisMovement.hasBeenLogged = false;
                                                                                        thisMovement.resultSets = [];
                                                                                        refreshPage();
                                                                                        Navigator.of(context).pop();
                                                                                      });
                                                                                    },
                                                                                  );
                                                                                });
                                                                              },
                                                                              child: Container(
                                                                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                                                                  decoration: BoxDecoration(
                                                                                    border: index != displayList.length - 1 ? const Border(
                                                                                        bottom: BorderSide(
                                                                                            color: Colors.white54,
                                                                                            width: 1
                                                                                        )
                                                                                    ) : displayList.length == 1 ? const Border(
                                                                                        bottom: BorderSide(
                                                                                            color: Colors.white54,
                                                                                            width: 2
                                                                                        )
                                                                                    ) : const Border(),
                                                                                  ),
                                                                                  child: Text(displayList[index].name, style: Styles.smallTextWhite.copyWith(color: Colors.white), textAlign: TextAlign.center)),
                                                                            );
                                                                          }
                                                                      ))
                                                                ] else...[
                                                                  if (searchController.text.isNotEmpty)... [
                                                                    const Text("No results found", style: Styles.regularText),
                                                                    if(!showAllMuscleGroups && LogPage.movementsLogged.where((log) => log.name.replaceAll(RegExp(r'\s+'), '').toLowerCase().contains(searchController.text.replaceAll(RegExp(r'\s+'), '').toLowerCase())).toList().isNotEmpty)Text("'${LogPage.movementsLogged.where((log) => log.name.replaceAll(RegExp(r'\s+'), '').toLowerCase().contains(searchController.text.replaceAll(RegExp(r'\s+'), '').toLowerCase())).toList().length}' results found outside of filter", style: Styles.smallTextWhite),
                                                                    if(LogPage.movementsLogged.where((log) => log.name.replaceAll(RegExp(r'\s+'), '').toLowerCase() == searchController.text.replaceAll(RegExp(r'\s+'), '').toLowerCase()).toList().isEmpty)... [
                                                                      Text("Add '${searchController.text}' to you workout log?", style: Styles.smallTextWhite),
                                                                      const SizedBox(height: 50),
                                                                      Row(
                                                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                                          children: [
                                                                            InkWell(
                                                                              onTap: () {
                                                                                String searchText = searchController.text; // this is because when you open the dialog it deletes the search controllers text
                                                                                void addMovementLogCallback(String logName, List<String> primaryMuscleGroups, List<String> secondaryMuscleGroups) {
                                                                                  setDialogState(() {
                                                                                    searchController.text = searchText;
                                                                                    LogPage.movementsLogged.add(MovementLog(
                                                                                        primaryMuscleGroups: primaryMuscleGroups,
                                                                                        secondaryMuscleGroups: secondaryMuscleGroups,
                                                                                        date: DateTime.now(),
                                                                                        favorited: false,
                                                                                        name: logName,
                                                                                        notes: "",
                                                                                        resultSetBlocks: []));
                                                                                    final box = Boxes.getMovementLogs();
                                                                                    box.add(LogPage.movementsLogged.last);

                                                                                    if (!showAllMuscleGroups) {
                                                                                      rootList = LogPage.movementsLogged.where((log) {
                                                                                        if ((log.primaryMuscleGroups == null && log.secondaryMuscleGroups == null) || widget.currentDay.muscleGroups == null) {
                                                                                          return false;
                                                                                        }

                                                                                        bool primaryMatches = log.primaryMuscleGroups?.any((muscle) => widget.currentDay.muscleGroups!.contains(muscle)) ?? false;
                                                                                        bool secondaryMatches = log.secondaryMuscleGroups?.any((muscle) => widget.currentDay.muscleGroups!.contains(muscle)) ?? false;

                                                                                        return primaryMatches || secondaryMatches;
                                                                                      }).toList();
                                                                                    }
                                                                                    else {
                                                                                      rootList = LogPage.movementsLogged;
                                                                                    }

                                                                                    displayList = List.from(rootList.where((element) => element.name.replaceAll(RegExp(r'\s+'), '').toLowerCase().contains(searchController.text.replaceAll(RegExp(r'\s+'), '').toLowerCase())));
                                                                                  });
                                                                                }

                                                                                showDialog(
                                                                                  context: context,
                                                                                  builder: (BuildContext context) {
                                                                                    return CreateOrEditMovementLog(addMovementLog: addMovementLogCallback, insertName: searchController.text);
                                                                                  },
                                                                                );
                                                                              },
                                                                              child: Container(
                                                                                width: 75,
                                                                                height: 50,
                                                                                decoration: const BoxDecoration(
                                                                                    color: Colors.white,
                                                                                    borderRadius: BorderRadius.all(
                                                                                        Radius.circular(20)
                                                                                    ),
                                                                                    border: Border(
                                                                                      bottom: BorderSide(
                                                                                          width: 2,
                                                                                          color: Colors.black54
                                                                                      ),
                                                                                      left: BorderSide(
                                                                                          width: 1,
                                                                                          color: Colors.black54
                                                                                      ),
                                                                                      right: BorderSide(
                                                                                          width: 1,
                                                                                          color: Colors.black54
                                                                                      ),
                                                                                      top: BorderSide(
                                                                                          width: .2,
                                                                                          color: Colors.black54
                                                                                      ),
                                                                                    )
                                                                                ),
                                                                                child: Center(
                                                                                    child: Text("Add", style: Styles.regularText.copyWith(color: Styles.primaryColor))
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ])
                                                                    ]
                                                                    else ... [
                                                                      const SizedBox(height: 50),
                                                                      if(LogPage.movementsLogged.where((log) => log.name.replaceAll(RegExp(r'\s+'), '').toLowerCase() == searchController.text.replaceAll(RegExp(r'\s+'), '').toLowerCase()).isNotEmpty)
                                                                        Text("'${searchController.text}' already exists in your log", style: Styles.paragraph)
                                                                    ]
                                                                  ]

                                                                  else... [
                                                                    const Text("No results found", style: Styles.regularText),
                                                                    const Text("Enter name to add to your workout log", style: Styles.smallTextWhite),
                                                                  ],
                                                                  const Spacer(),
                                                                ],

                                                                GestureDetector(
                                                                  onTap: () {
                                                                    setDialogState(() {
                                                                      if (showAllMuscleGroups) {
                                                                        showAllMuscleGroups = false;
                                                                        rootList = LogPage.movementsLogged.where((log) {
                                                                          if ((log.primaryMuscleGroups == null && log.secondaryMuscleGroups == null) || widget.currentDay.muscleGroups == null) {
                                                                            return false;
                                                                          }

                                                                          bool primaryMatches = log.primaryMuscleGroups?.any((muscle) => widget.currentDay.muscleGroups!.contains(muscle)) ?? false;
                                                                          bool secondaryMatches = log.secondaryMuscleGroups?.any((muscle) => widget.currentDay.muscleGroups!.contains(muscle)) ?? false;

                                                                          return primaryMatches || secondaryMatches;
                                                                        }).toList();
                                                                      }
                                                                      else {
                                                                        showAllMuscleGroups = true;
                                                                        rootList = LogPage.movementsLogged;
                                                                      }
                                                                      displayList = List.from(rootList.where((element) => element.name.replaceAll(RegExp(r'\s+'), '').toLowerCase().contains(searchController.text.replaceAll(RegExp(r'\s+'), '').toLowerCase())));
                                                                    });
                                                                  },
                                                                  child: Container(
                                                                      height: 40,
                                                                      decoration: BoxDecoration(
                                                                          color: Colors.black12,
                                                                          border: Border(
                                                                              top: BorderSide(
                                                                                  color: showAllMuscleGroups ? Colors.black : Colors.black54,
                                                                                  width: 1.5
                                                                              )
                                                                          )
                                                                      ),
                                                                      child: Center(
                                                                      child: Text("Show all muscle groups", style: Styles.paragraph.copyWith(color: showAllMuscleGroups ? Colors.white : Colors.white54)))),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        )
                                                    ),
                                                  );
                                                }
                                              );
                                            }
                                        );
                                      },
                                      child: ListTile(
                                        leading: Icon(Icons.edit, color: Styles.primaryColor),
                                        title: Text('Change', style: TextStyle(color: Styles.primaryColor)),
                                      ),
                                    ),
                                    PopupMenuItem<ListTile>(
                                      onTap: () {
                                        remove() {
                                          widget.removeThisMovement(widget.movementIndex);
                                        }
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return ConfirmationDialog(content: "Are you sure you want to delete this movement?", callbackFunction: remove);
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
                                icon: const Icon(Icons.more_vert, color: Colors.white, size: 30)),
                          ),
                        ],
                      )),
            ),
          ),
         if(thisMovement.superset == true && thisMovement != widget.currentDay.movements.last) ...[Row(
            children: [
              const SizedBox(width: 30),
              const Text("Superset:", style: Styles.regularText),
              const SizedBox(width: 20),
              Container(
                width: 3,
                height: 40,
                color: Colors.white,
              ),
            ],
          )]
          else ... [
            const SizedBox(height: 40)
         ]
        ],
      ),
    );
  }
}
















class OpenMovement extends StatefulWidget {
final Function() refreshPage;
static bool inMovementTimerActive = false;
final day currentDay;
final int movementIndex;
final Movement thisMovement;
const OpenMovement({required this.thisMovement, required this.movementIndex, required this.currentDay, required this.refreshPage});

  @override
  State<OpenMovement> createState() => _OpenMovementState();
}

class _OpenMovementState extends State<OpenMovement> {
  Program thisProgram = ProgramsPage.programsList[ProgramsPage.activeProgramIndex];
  int resultSetIndex = 0; //this is to track which set was clicked to edit
  Timer? secondsTimer;


  @override
  void dispose() {
  super.dispose();
  }

  @override
  void initState() {
    super.initState();
    ShowcaseView.register();


    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        ShowcaseView.get().startShowCase([movementEditButtonsKey, thisSessionKey, thisSessionIconKey, lastSessionKey, lastSessionIconKey, notesIconKey, completeIconKey]);
      });
    });

    if (GlobalTimerWidgetState.backgroundTimerActive == true && GlobalTimerWidgetState.movementOfTimer == widget.thisMovement) {
      startTimer();
     GlobalTimerWidgetState.stopTimer();
    }
  }

  // This method is to allow the workout log to refresh the page when you open and close it from the "Last Session" button
  void refreshPage() {
    setState(() {
      if (GlobalTimerWidgetState.backgroundTimerActive == true && GlobalTimerWidgetState.movementOfTimer == widget.thisMovement) {
        startTimer();
        GlobalTimerWidgetState.stopTimer();
      }
    });
  }

void stopTimer () {
  widget.thisMovement.timerActive = false;
  OpenMovement.inMovementTimerActive = false;
  secondsTimer?.cancel();
}

void startTimer() {
  OpenMovement.inMovementTimerActive = true;
  widget.thisMovement.timerActive = true;
    secondsTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        setState(() {
          if (widget.thisMovement.remainingRestTime.inSeconds > 0) {
            widget.thisMovement.remainingRestTime -= const Duration(milliseconds: 100);
          }
          else {
            NotificationServices().showNotification(title: "Timer Done", body: "Your rest time for '${widget.thisMovement.name}' is done");
            stopTimer();
          }
        });
        thisProgram.save();
    });

    GlobalTimerWidgetState.getTimerData(ProgramsPage.activeProgramIndex, widget.currentDay, widget.movementIndex, widget.thisMovement, widget.refreshPage);

}

  @override
  Widget build(BuildContext context) {
    List <ResultSet> lastSessionResultSets = [];

    OuterLoop:
    for (int w = 0; w < ProgramsPage.programsList[ProgramsPage.activeProgramIndex].weeks.length; w ++) {
      Week currentWeek = ProgramsPage.programsList[ProgramsPage.activeProgramIndex].weeks[w];

      for (int d = 0; d < currentWeek.days.length; d ++) {
        day currentDay = currentWeek.days[d];

        for (int m = 0; m < currentDay.movements.length; m ++) {
          Movement currentMovement = currentDay.movements[m];

          if (currentMovement == widget.thisMovement) {
            break OuterLoop;
          }
          else if (currentMovement.name == widget.thisMovement.name && currentMovement.resultSets.isNotEmpty) {
            lastSessionResultSets = currentMovement.resultSets;
          }
        }
      }
    }

    int existingLogIndex = LogPage.movementsLogged.indexWhere((log) =>log.name.replaceAll(RegExp(r'\s+'), '').toLowerCase() == widget.thisMovement.name.replaceAll(RegExp(r'\s+'), '').toLowerCase());

    Icon timerIcon;
    String restSeconds = (widget.thisMovement.remainingRestTime.inSeconds - 60 * widget.thisMovement.remainingRestTime.inMinutes).toString();
    if (restSeconds.length == 1) {
      restSeconds = "0$restSeconds";
    }

   ButtonStyle buttonStyle = ButtonStyle(
      backgroundColor: WidgetStateProperty.all<Color>(Styles.primaryColor),
      padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
        const EdgeInsets.symmetric(horizontal: 10, vertical: 12)
      ),
    );

    editRest(editedMinutes, editedSeconds) {
      setState(() {
        widget.thisMovement.remainingRestTime =
            Duration(minutes: editedMinutes, seconds: editedSeconds);
        widget.thisMovement.rest =
            Duration(minutes: editedMinutes, seconds: editedSeconds);
      });
      thisProgram.save();
    }

    editText(editedText, identifier) {
      setState(() {
        if (identifier == "Movement Name") {
          widget.thisMovement.name = editedText;
        }
        if (identifier == "SETS") {
          widget.thisMovement.sets = editedText;
        }
        if (identifier == "REPS") {
          widget.thisMovement.reps = editedText;
        }
        if (identifier == "LB") {
          widget.thisMovement.weight = double.parse(editedText);
        }
        if (identifier == "RIR") {
          widget.thisMovement.rir = editedText;
        }

        if (identifier == "resultsRIR") {
          widget.thisMovement.resultSets[resultSetIndex].rir = editedText;
        }
        if (identifier == "resultsREPS") {
          widget.thisMovement.resultSets[resultSetIndex].reps = editedText;
        }
        if (identifier == "resultsLB") {
          widget.thisMovement.resultSets[resultSetIndex].weight = editedText;
        }
      });
      thisProgram.save();
    }

    if (widget.thisMovement.timerActive == false) {
      if (widget.thisMovement.remainingRestTime.inMilliseconds > 999) {
        timerIcon = const Icon(Icons.play_arrow, size: 25, color: Colors.white);
      }

      else {
        timerIcon = const Icon(Icons.restart_alt_rounded, size: 25, color: Colors.white);
      }
    }
    else {
      timerIcon = const Icon(Icons.pause, size: 25, color: Colors.white);
    }


    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            if (widget.thisMovement.timerActive == true) {
              GlobalTimerWidgetState.startTimer();
              stopTimer();
            }
              widget.refreshPage();
            Navigator.of(context).pop();
          },
        ),
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
        title: Text(widget.thisMovement.name, style: Styles.labelText),
      ),
      body: Container(
          decoration: BoxDecoration(
            gradient: Styles.horizontal()
          ),
          height: double.infinity,
          width: double.infinity,

              child: Column(
                children: [
                  ShowcaseTemplate(
                    globalKey: movementEditButtonsKey,
                    content: "These buttons are for editing different properties of the movement, like sets, reps, etc.",
                    title: "Editing Movement Properties",
                    stepID: 11,
                    radius: 15.0,
                    child: Container(
                      decoration: const BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(20),
                            bottomLeft: Radius.circular(20)
                          ),
                          border: Border(
                          bottom: BorderSide(
                            color: Colors.white54,
                          )
                        )
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                            style: buttonStyle,
                            onPressed: () {
                              int sets = widget.thisMovement.sets;
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return PopScope(
                                    onPopInvokedWithResult: (bool didPop, dynamic result) {
                                      setState(() {
                                        widget.thisMovement.sets = sets;
                                      });
                                    },
                                    child: Dialog(
                                      child: Container(
                                        height: 60,
                                        width: 100,
                                        decoration: BoxDecoration(
                                          gradient: Styles.horizontal(),
                                          borderRadius: const BorderRadius.all(Radius.circular(20)),
                                        ),
                                        child: StatefulBuilder(
                                          builder: (BuildContext context, StateSetter setDialogState) {
                                            return Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                IconButton(
                                                  onPressed: () {
                                                    setDialogState(() {
                                                      if (sets > 0) {
                                                        sets--;
                                                      }
                                                    });
                                                  },
                                                  icon: const Icon(Icons.indeterminate_check_box, size: 30, color: Colors.white),
                                                ),
                                                Text(sets.toString(), style: Styles.regularText),
                                                IconButton(
                                                  onPressed: () {
                                                    setDialogState(() {
                                                      if (sets < 9) {
                                                        sets++;
                                                      }
                                                    });
                                                  },
                                                  icon: const Icon(Icons.add_box, size: 30, color: Colors.white),
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            child: Row(
                              children: [
                                Text(widget.thisMovement.sets.toString(), style: Styles.regularText),
                                const Text(" SETS ", style: Styles.smallTextWhite),
                              ],
                            ),
                          ),

                              ElevatedButton(
                        style: buttonStyle,
                        onPressed: () {
                          int repsLowerValue = 0;
                          int repsUpperValue = 0;

                          if (widget.thisMovement.reps.contains('-')) {
                            repsLowerValue = int.parse(widget.thisMovement.reps.split('-')[0]);
                            repsUpperValue = int.parse(widget.thisMovement.reps.split('-')[1]);
                          }

                          else {
                            repsLowerValue = int.parse(widget.thisMovement.reps);
                            repsUpperValue = int.parse(widget.thisMovement.reps);
                          }

                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return PopScope(
                                onPopInvokedWithResult: (bool didPop, dynamic result) {
                                  setState(() {
                                    if (repsLowerValue == repsUpperValue) {
                                      widget.thisMovement.reps = repsLowerValue.toString();
                                    }

                                    else {
                                      widget.thisMovement.reps = "$repsLowerValue-$repsUpperValue";
                                    }
                                  });
                                },
                                child: Dialog(
                                  child: Container(
                                    height: 60,
                                    width: 100,
                                    decoration: BoxDecoration(
                                      gradient: Styles.horizontal(),
                                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                                    ),
                                    child: StatefulBuilder(
                                      builder: (BuildContext context, StateSetter setDialogState) {
                                        return Row(
                                          children: [
                                            IconButton(
                                              onPressed: () {
                                                setDialogState(() {
                                                  if (repsLowerValue > 0) {
                                                    repsLowerValue--;
                                                  }
                                                });
                                              },
                                              icon: const Icon(Icons.indeterminate_check_box, size: 25, color: Colors.white),
                                            ),
                                            Text(
                                              "$repsLowerValue",
                                              style: Styles.paragraph.copyWith(color: Colors.white),
                                            ),
                                            IconButton(
                                              onPressed: () {
                                                setDialogState(() {
                                                  if (repsLowerValue < repsUpperValue) {
                                                    repsLowerValue++;
                                                  } else {
                                                    if (repsUpperValue < 50) {
                                                      repsLowerValue++;
                                                      repsUpperValue++;
                                                    }
                                                  }
                                                });
                                              },
                                              icon: const Icon(Icons.add_box, size: 25, color: Colors.white),
                                            ),
                                            const Expanded(
                                              child: Text(
                                                "-",
                                                style: Styles.labelText,
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () {
                                                setDialogState(() {
                                                  if (repsUpperValue > repsLowerValue) {
                                                    repsUpperValue--;
                                                  } else {
                                                    if (repsLowerValue > 0) {
                                                      repsUpperValue--;
                                                      repsLowerValue--;
                                                    }
                                                  }
                                                });
                                              },
                                              icon: const Icon(Icons.indeterminate_check_box, size: 25, color: Colors.white),
                                            ),
                                            Text(
                                              "$repsUpperValue",
                                              style: Styles.paragraph.copyWith(color: Colors.white),
                                            ),
                                            IconButton(
                                              onPressed: () {
                                                setDialogState(() {
                                                  if (repsUpperValue < 69) {
                                                    repsUpperValue++;
                                                  }
                                                });
                                              },
                                              icon: const Icon(Icons.add_box, size: 25, color: Colors.white),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        child: Row(
                          children: [
                            Text(widget.thisMovement.reps, style: Styles.regularText),
                            const Text(" REPS ", style: Styles.smallTextWhite),
                          ],
                        ),
                      ),


                              ElevatedButton(
                                  style: buttonStyle,
                                  onPressed: () {showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return EditDialog(
                                            dataToEdit: widget.thisMovement.weight, identifier: "LB", editData: editText);
                                      }
                                  );
                                  },
                                  child: Row(children:[Text(widget.thisMovement.weight.toStringAsFixed(widget.thisMovement.weight.truncateToDouble() == widget.thisMovement.weight ? 0 : 1), style: Styles.regularText),  Text(" ${AppSettings.selectedUnit}", style: Styles. smallTextWhite)]))
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                              mainAxisAlignment: AppSettings.rirActive ? MainAxisAlignment.spaceEvenly : MainAxisAlignment.start,
                              children: [
                                if (!AppSettings.rirActive) const SizedBox(width: 120),
                                ElevatedButton(
                                    style: buttonStyle,
                                    onPressed: () {
                                      setState(() {
                                        if (widget.thisMovement.timerActive == false) {
                                          if (widget.thisMovement.remainingRestTime.inSeconds > 0) {
                                            startTimer();
                                          }
                                          else {
                                            widget.thisMovement.remainingRestTime = widget.thisMovement.rest;
                                            if (widget.thisMovement.rest.inSeconds == 0) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  backgroundColor: Colors.white,
                                                  content: Text("Timer's base value is set to 0:00", style: TextStyle(color: Styles.primaryColor)),
                                                  duration: const Duration(milliseconds: 1500),
                                                ),
                                              );
                                            }
                                          }
                                        }
                                        else {
                                          stopTimer();
                                        }
                                      });
                                    }, child: timerIcon
                                ),
                                if (!AppSettings.rirActive) const SizedBox(width: 40),
                                ElevatedButton(
                                    style: buttonStyle,
                                    onPressed: () {
                                      setState(() {
                                        stopTimer();
                                      });
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return EditRestDialog(editRest: editRest,
                                                minutes: widget.thisMovement.remainingRestTime.inMinutes,
                                                seconds: int.parse(restSeconds));
                                          }
                                      );
                                    },
                                    child: Row(
                                        children: [
                                          SizedBox( width: 50, child: Text("${widget.thisMovement.remainingRestTime.inMinutes.toString()}:$restSeconds", style: Styles.regularText)), const Text(" REST  ", style: Styles. smallTextWhite)])),
                                if (AppSettings.rirActive == true) ...[ ElevatedButton(
                                    style: buttonStyle,
                                    onPressed: () {
                                      int rirLowerValue = 0;
                                      int rirUpperValue = 0;

                                      if (widget.thisMovement.rir.contains('-')) {
                                        rirLowerValue = int.parse(widget.thisMovement.rir.split('-')[0]);
                                        rirUpperValue = int.parse(widget.thisMovement.rir.split('-')[1]);
                                      }

                                      else {
                                        rirLowerValue = int.parse(widget.thisMovement.rir);
                                        rirUpperValue = int.parse(widget.thisMovement.rir);
                                      }

                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return PopScope(
                                            onPopInvokedWithResult: (bool didPop, dynamic result) {
                                              setState(() {
                                                if (rirLowerValue == rirUpperValue) {
                                                  widget.thisMovement.rir = rirLowerValue.toString();
                                                }

                                                else {
                                                  widget.thisMovement.rir = "$rirLowerValue-$rirUpperValue";
                                                }
                                              });
                                            },
                                            child: Dialog(
                                              child: Container(
                                                height: 60,
                                                width: 100,
                                                decoration: BoxDecoration(
                                                  gradient: Styles.horizontal(),
                                                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                                                ),
                                                child: StatefulBuilder(
                                                  builder: (BuildContext context, StateSetter setDialogState) {
                                                    return Row(
                                                      children: [
                                                        IconButton(
                                                          onPressed: () {
                                                            setDialogState(() {
                                                              if (rirLowerValue > 0) {
                                                                rirLowerValue--;
                                                              }
                                                            });
                                                          },
                                                          icon: const Icon(Icons.indeterminate_check_box, size: 25, color: Colors.white),
                                                        ),
                                                        Text(
                                                          "$rirLowerValue",
                                                          style: Styles.paragraph.copyWith(color: Colors.white),
                                                        ),
                                                        IconButton(
                                                          onPressed: () {
                                                            setDialogState(() {
                                                              if (rirLowerValue < rirUpperValue) {
                                                                rirLowerValue++;
                                                              } else {
                                                                if (rirUpperValue < 50) {
                                                                  rirLowerValue++;
                                                                  rirUpperValue++;
                                                                }
                                                              }
                                                            });
                                                          },
                                                          icon: const Icon(Icons.add_box, size: 25, color: Colors.white),
                                                        ),
                                                        const Expanded(
                                                          child: Text(
                                                            "-",
                                                            style: Styles.labelText,
                                                            textAlign: TextAlign.center,
                                                          ),
                                                        ),
                                                        IconButton(
                                                          onPressed: () {
                                                            setDialogState(() {
                                                              if (rirUpperValue > rirLowerValue) {
                                                                rirUpperValue--;
                                                              } else {
                                                                if (rirLowerValue > 0) {
                                                                  rirUpperValue--;
                                                                  rirLowerValue--;
                                                                }
                                                              }
                                                            });
                                                          },
                                                          icon: const Icon(Icons.indeterminate_check_box, size: 25, color: Colors.white),
                                                        ),
                                                        Text(
                                                          "$rirUpperValue",
                                                          style: Styles.paragraph.copyWith(color: Colors.white),
                                                        ),
                                                        IconButton(
                                                          onPressed: () {
                                                            setDialogState(() {
                                                              if (rirUpperValue < 69) {
                                                                rirUpperValue++;
                                                              }
                                                            });
                                                          },
                                                          icon: const Icon(Icons.add_box, size: 25, color: Colors.white),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    child: Row(children:[Text(widget.thisMovement.rir, style: Styles.regularText), const Text("  RIR ", style: Styles. smallTextWhite)])),
                                ]
                              ]
                          ),
                          const SizedBox(height: 15),
                        ],
                      ),
                    ),
                  ),
                 Expanded(
                   child: SingleChildScrollView(
                         child: Column(
                           children: [
                            const SizedBox(height: 20),
                             ShowcaseTemplate(
                               radius: 10,
                               stepID: 12,
                               globalKey: thisSessionKey,
                               title: "Inputting Sets",
                               content: "Below this is where you input the sets you perform so that they can be added to your log.",
                               child: Row(
                               children: [
                                 const SizedBox(width: 5),
                                 const Text("This session", style: Styles.labelText),
                                 if(widget.thisMovement.hasBeenLogged == false && widget.thisMovement.resultSets.length < 8) ...[
                                   ShowcaseTemplate(
                                     radius: 10,
                                     stepID: 13,
                                     globalKey: thisSessionIconKey,
                                     title: "Adding Sets",
                                     content: "Click here to add a new set to this session.",
                                     child: IconButton(onPressed: () {
                                       setState(() {
                                         widget.thisMovement.resultSets.add(ResultSet(setNumber: 0, idForKey: MovementWidget.thisLinesId ++, reps: 0, rir: 0, weight: 0));
                                       });
                                       thisProgram.save();
                                     },
                                         icon: const Icon(Icons.add_circle, size: 30),
                                         color: Colors.white
                                     ),
                                   ),
                                   Spacer(),
                                   ShowcaseTemplate(
                                     radius: 10,
                                     stepID: 79,
                                     globalKey: duplicateSessionKey,
                                     title: "Duplicating Sets",
                                     content: "Click here to add a duplicate of your latest set to this session.",
                                     child: IconButton(onPressed: () {
                                       setState(() {
                                         widget.thisMovement.resultSets.add(ResultSet(
                                             setNumber: widget.thisMovement.resultSets.last.setNumber,
                                             idForKey: MovementWidget.thisLinesId ++,
                                             reps: widget.thisMovement.resultSets.last.reps,
                                             rir: widget.thisMovement.resultSets.last.rir,
                                             weight: widget.thisMovement.resultSets.last.weight
                                         ));
                                         widget.thisMovement.resultSets.last.setType =  widget.thisMovement.resultSets[widget.thisMovement.resultSets.length - 2].setType;
                                       });
                                       thisProgram.save();
                                     },
                                         icon: const Icon(Icons.control_point_duplicate_sharp, size: 30),
                                         color: Colors.white
                                     ),
                                   ),
                                   const SizedBox(width: 20)
                                 ],
                               ],
                               ),
                             ),
                             const SizedBox(height: 20),
                             Container(
                               decoration: BoxDecoration(
                                   color: Colors.black12,
                                   borderRadius: const BorderRadius.only(
                                       topLeft: Radius.circular(20),
                                       topRight: Radius.circular(20)
                                   ),
                                   border: widget.thisMovement.resultSets.isNotEmpty ?
                                   const Border(
                                       top: BorderSide(
                                           color: Colors.white54
                                       ),
                                       bottom: BorderSide(
                                           color: Colors.white54
                                       )
                                   ) : const Border(
                                     top: BorderSide(
                                         color: Colors.white54
                                     ),
                                   )
                               ),
                               child: ListView.builder(
                                 physics: const NeverScrollableScrollPhysics(),
                                 scrollDirection: Axis.vertical,
                                 shrinkWrap: true,
                                 itemExtent: 75,
                                 itemCount: widget.thisMovement.resultSets.length,
                                 itemBuilder: (context, index) {
                                   final thisResultSet = widget.thisMovement.resultSets[index];
                                   return widget.thisMovement.hasBeenLogged ?
                                   Row(
                                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                       children: [
                                        if(!widget.thisMovement.hasBeenLogged)...[
                                          DropdownButton<String>(
                                            isDense: true,
                                            borderRadius: BorderRadius.all(Radius.circular(15)),
                                            iconSize: 20,
                                            dropdownColor: Styles.primaryColor,
                                            style: Styles.smallTextWhite,
                                            value: thisResultSet.setType,
                                            items: setTypes,

                                            selectedItemBuilder: (BuildContext context) {
                                              return setTypes.map((item) {
                                                String displayText;

                                                if (item.value == "default") {
                                                  displayText = "SET ${index + 1}:";
                                                } else {
                                                  String text = (item.child as Text).data ?? "";
                                                  displayText = text.endsWith(":") ? text : "$text:";
                                                }

                                                return Text(displayText, style: Styles.smallTextWhite);
                                              }).toList();
                                            },

                                            onChanged: (value) {
                                              setState(() {
                                                thisResultSet.setType = value!;
                                              });
                                            },
                                          )
                                        ]
                                         else ...[
                                           Container(
                                               margin: const EdgeInsets.only(left: 10),
                                               child: Text(thisResultSet.setType != "default" ? thisResultSet.setType : "SET ${index + 1}:", style: Styles.smallTextWhite))
                                          ],
                                         ElevatedButton(
                                             style: buttonStyle,
                                             onPressed: () {},
                                             child: Row(children: [Text(widget.thisMovement.resultSets[index].weight.toStringAsFixed(widget.thisMovement.resultSets[index].weight.truncateToDouble() == widget.thisMovement.resultSets[index].weight ? 0 : 1), style: Styles.regularText),  Text(" ${AppSettings.selectedUnit}", style: Styles. smallTextWhite)])),
                                         ElevatedButton(
                                             style: buttonStyle,
                                             onPressed: () {},
                                             child: Row( children: [Text(widget.thisMovement.resultSets[index].reps.toString(), style: Styles.regularText), const Text(" REPS", style: Styles. smallTextWhite)])),
                                   if (AppSettings.rirActive == true) ...[
                                         ElevatedButton(
                                             style: buttonStyle,
                                             onPressed: () {},
                                             child: Row( children: [Text(widget.thisMovement.resultSets[index].rir.toString(), style: Styles.regularText), const Text(" RIR", style: Styles. smallTextWhite)])),
                                       const SizedBox(width: 1)
                                   ] else ...[
                                         const SizedBox(width: 60),
                                   ]
                                    ]
                                   )
                                       :
                                   Dismissible(
                                     key: Key(thisResultSet.idForKey.toString()),
                                     background: Container(
                                       decoration: const BoxDecoration(
                                           borderRadius: BorderRadius.all(Radius.circular(20)),
                                         color: Colors.red,
                                       ),
                                       child: const Align(
                                         alignment: Alignment.centerRight,
                                         child: Icon(
                                           Icons.delete,
                                           color: Colors.white,
                                         ),
                                       ),
                                     ),
                                     direction: DismissDirection.endToStart,
                                     onDismissed: (direction) {
                                       setState(() {
                                         widget.thisMovement.resultSets.removeAt(index);
                                       });

                                       thisProgram.save();

                                     },

                                     child: SizedBox(
                                       height: 100,
                                       child: Row(
                                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                           children: [
                                             Container(
                                                 margin: const EdgeInsets.only(left: 10),
                                                     child: !widget.thisMovement.hasBeenLogged
                                                         ? DropdownButton<String>(
                                                           isDense: true,
                                                           borderRadius: BorderRadius.all(Radius.circular(15)),
                                                           iconSize: 20,
                                                           dropdownColor: Styles.primaryColor,
                                                           style: Styles.smallTextWhite,
                                                           value: thisResultSet.setType,
                                                           items: setTypes,

                                                       selectedItemBuilder: (BuildContext context) {
                                                         return setTypes.map((item) {
                                                           String displayText;

                                                           if (item.value == "default") {
                                                             displayText = "SET ${index + 1}:";
                                                           } else {
                                                             String text = (item.child as Text).data ?? "";
                                                             displayText = text.endsWith(":") ? text : "$text:";
                                                           }

                                                           return Text(displayText, style: Styles.smallTextWhite);
                                                          }).toList();
                                                       },

                                                       onChanged: (value) {
                                                         setState(() {
                                                           thisResultSet.setType = value!;
                                                         });
                                                       },
                                                     )
                                                         : Container(
                                                           margin: const EdgeInsets.only(left: 10),
                                                           child: Text(thisResultSet.setType != "default" ? thisResultSet.setType : "SET ${index + 1}:", style: Styles.smallTextWhite))

                                             ),
                                             if(!widget.thisMovement.hasBeenLogged)...[

                                             ElevatedButton(
                                                 style: buttonStyle,
                                                 onPressed: () {
                                                   setState(() {
                                                     resultSetIndex = index;
                                                   });
                                                   showDialog(
                                                       context: context,
                                                       builder: (BuildContext context) {
                                                         return EditDialog(
                                                             dataToEdit: widget.thisMovement.resultSets[index].weight, identifier: "resultsLB", editData: editText);
                                                       }
                                                   );
                                                 },
                                                 child: Row (children: [Text(widget.thisMovement.resultSets[index].weight.toStringAsFixed(widget.thisMovement.resultSets[index].weight.truncateToDouble() == widget.thisMovement.resultSets[index].weight ? 0 : 1), style: Styles.regularText), Text(" ${AppSettings.selectedUnit}", style: Styles. smallTextWhite)])),
                                             ElevatedButton(
                                                 style: buttonStyle,
                                                 onPressed: () {
                                                   setState(() {
                                                     resultSetIndex = index;
                                                   });
                                                   showDialog(
                                                       context: context,
                                                       builder: (BuildContext context) {
                                                         return EditDialog(
                                                             dataToEdit: widget.thisMovement.resultSets[index].reps, identifier: "resultsREPS", editData: editText);
                                                       }
                                                   );
                                                 },
                                                 child: Row( children: [Text(widget.thisMovement.resultSets[index].reps.toString(), style: Styles.regularText), const Text(" REPS", style: Styles. smallTextWhite)])),
                                             if (AppSettings.rirActive == true) ...[
                                               ElevatedButton(
                                                 style: buttonStyle,
                                                 onPressed: () {
                                                   setState(() {
                                                     resultSetIndex = index;
                                                   });
                                                   showDialog(
                                                       context: context,
                                                       builder: (BuildContext context) {
                                                         return EditDialog(
                                                             dataToEdit: widget.thisMovement.resultSets[index].rir, identifier: "resultsRIR", editData: editText);
                                                       }
                                                   );
                                                 },
                                                 child: Row( children: [Text(widget.thisMovement.resultSets[index].rir.toString(), style: Styles.regularText), const Text(" RIR", style: Styles. smallTextWhite)])),

                                               const SizedBox(width: 1)
                                             ] else ...[const SizedBox(width: 60)]
                                         ]
                                        ]
                                       ),
                                     ),
                                   );
                                 },
                               ),
                             ),
                             const SizedBox(height: 20),
                             ShowcaseTemplate(
                               stepID: 14,
                               globalKey: lastSessionKey,
                               title: "Previous Lifts",
                               content: "The data from the last time you performed this movement will appear below here.",
                               radius: 10,
                               child: Row(
                                 children: [
                                   const SizedBox(width: 5),
                                   const Text("Last session", style: Styles.labelText),
                                   ShowcaseTemplate(
                                     globalKey: lastSessionIconKey,
                                     radius: 20,
                                     stepID: 15,
                                     title: "Movement Log Shortcut",
                                     content: "You can click here to go to this movement's log.",
                                     child: IconButton(onPressed: () {
                                       setState(() {
                                         LogPage.currentMovementLogIndex = existingLogIndex;
                                         ScreenManager.screenIndex = 0;
                                         LogPage.movementsLogged[existingLogIndex].resultSetBlocks.sort((a, b) => a.date.compareTo(b.date));


                                         if (LogPage.movementsLogged[existingLogIndex].resultSetBlocks.isNotEmpty) {
                                           ResultSetBlock lastBlockInExistingLog = LogPage.movementsLogged[existingLogIndex].resultSetBlocks.last;
                                           MovementLogScreenState.monthNumber = lastBlockInExistingLog.date.month;
                                           MovementLogScreenState.yearNumber = lastBlockInExistingLog.date.year;
                                         }
                                         else {
                                           MovementLogScreenState.monthNumber = DateTime.now().month;
                                           MovementLogScreenState.yearNumber = DateTime.now().year;
                                         }

                                         if (widget.thisMovement.timerActive == true) {
                                           GlobalTimerWidgetState.startTimer();
                                           stopTimer();
                                         }

                                         Navigator.of(context).push(
                                           MaterialPageRoute(
                                             builder: (context) => ScreenManager(refreshScreen: refreshPage, sortLog: (){}, updateLogOrder: (MovementLog log) {
                                               log.date = DateTime.now();
                                             }),
                                           ),
                                         );
                                       });
                                     },
                                         icon: const Icon(Icons.arrow_circle_right_rounded, size: 30),
                                         color: Colors.white
                                     ),
                                   ),
                                 ],
                               ),
                             ),
                             const SizedBox(height: 20),
                             if(LogPage.movementsLogged[existingLogIndex].resultSetBlocks.isNotEmpty || lastSessionResultSets.isNotEmpty)... [
                               Container(
                                 decoration: const BoxDecoration(
                                     color: Colors.black12,
                                     borderRadius: BorderRadius.only(
                                       topLeft: Radius.circular(20),
                                       topRight: Radius.circular(20)
                                     ),
                                     border: Border(
                                     top: BorderSide(
                                         color: Colors.white54
                                     ),
                                     bottom: BorderSide(
                                         color: Colors.white54
                                     )
                                   )
                                 ),
                                 child: ListView.builder(
                                 physics: const NeverScrollableScrollPhysics(),
                                 scrollDirection: Axis.vertical,
                                 shrinkWrap: true,
                                 itemCount: lastSessionResultSets.isNotEmpty ? lastSessionResultSets.length : LogPage.movementsLogged[existingLogIndex].resultSetBlocks.last.resultSets.length,
                                 itemBuilder: (context, index) {
                                   final pastResultSet = lastSessionResultSets.isNotEmpty ? lastSessionResultSets[index] : LogPage.movementsLogged[existingLogIndex].resultSetBlocks.last.resultSets[index];
                                   return SizedBox(
                                     height: 50,
                                     child: Row(
                                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                         children: [
                                           Container(
                                               margin: const EdgeInsets.only(left: 10),
                                               child: Text(pastResultSet.setType != "default" ? pastResultSet.setType : "SET ${index + 1}:", style: Styles.smallTextWhite)),
                                           const Spacer(),
                                           SizedBox(
                                               width: 120,
                                               child: Row(
                                                 children: [
                                                   Text(pastResultSet.weight.toStringAsFixed(pastResultSet.weight.truncateToDouble() == pastResultSet.weight ? 0 : 1), style: Styles.regularText),
                                                   Text(AppSettings.selectedUnit, style: Styles.smallTextWhite)
                                                 ],
                                               )),
                                           SizedBox(
                                               width: 90,
                                               child: Row(
                                                 children: [
                                                   Text("${pastResultSet.reps}", style: Styles.regularText),
                                                   const Text("REPS", style: Styles.smallTextWhite)
                                                 ],
                                               )),
                                          if(AppSettings.rirActive == true) ...[ SizedBox(
                                               width: 90,
                                               child: Row(
                                                 children: [
                                                   Text("${pastResultSet.rir}", style: Styles.regularText),
                                                   const Text("RIR", style: Styles.smallTextWhite)
                                                 ],
                                               )),
                                        ] else ...[const SizedBox(width: 90)]
                                         ]
                                     ),
                                   );
                                 },
                                 ),
                               ),
                             ]
                             else ... [
                               const Divider(color: Colors.white54)
                             ],
                           ],
                         ),
                   ),
                 )
                ],
              ),

        ),
      bottomNavigationBar: Container(
            decoration: BoxDecoration(
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black,
                    spreadRadius: 5,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
                gradient: Styles.darkGradient()
            ),
            padding: const EdgeInsets.only(top: 10, left: 50, right: 50),
            height: MediaQuery.of(context).size.height / 8,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => MovementNotes(thisMovement: widget.thisMovement),
                      ),
                    );
                  },
                  child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ShowcaseTemplate(
                              globalKey: notesIconKey,
                              stepID: 16,
                              radius: 10,
                              title: "Writing Notes",
                              content: "This is where you can add notes on this movement in the current session. These notes are unique to each instance of the movement.",
                              child: const Icon(Icons.assignment_outlined, color: Colors.white, size: 30)),
                          const Text("Notes", style: Styles.smallTextWhite)]
                    ),
                ),
                InkWell(
                  onTap: () {
                    List<ResultSet> nonZeroResultSets = widget.thisMovement.resultSets.where((result) {return result.reps != 0 || result.weight != 0;}).toList();
                    if (nonZeroResultSets.isNotEmpty && widget.thisMovement.hasBeenLogged == false) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            backgroundColor: Styles.primaryColor,
                            title: const Text('Log this movement?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            content: const Text("This movement will be completed and you will no longer be able to log it.", style: TextStyle(color: Colors.white)),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                   setState(() {
                                  for (int l = widget.thisMovement.resultSets.length - 1; l >= 0; l--) {
                                    if (widget.thisMovement.resultSets[l].weight == 0 && widget.thisMovement.resultSets[l].reps == 0) {
                                      widget.thisMovement.resultSets.removeAt(l);
                                    }
                                  }

                                  widget.thisMovement.hasBeenLogged = true;
                                });
                                 if (existingLogIndex > -1){
                                   double currentHighestWeight = 0;
                                   for (int b = 0; b < LogPage.movementsLogged[existingLogIndex].resultSetBlocks.length; b ++) {
                                     if (LogPage.movementsLogged[existingLogIndex].resultSetBlocks[b].resultSets.any((set) => set.weight > currentHighestWeight)) {
                                       currentHighestWeight = LogPage.movementsLogged[existingLogIndex].resultSetBlocks[b].resultSets.where((set) => set.weight > currentHighestWeight).reduce((a, b) => a.weight > b.weight ? a : b).weight;
                                     }
                                   }

                                   ResultSet highestSet = ResultSet(reps: 0, weight: 0, rir: 0, setNumber: 0, idForKey: -1);

                                   // check if this block contains a result set with higher weight than the highest one in log
                                   for (int i = 0; i < nonZeroResultSets.length; i ++) {
                                     if (nonZeroResultSets[i].weight > currentHighestWeight && nonZeroResultSets[i].weight > highestSet.weight && nonZeroResultSets[i].reps > 0) {
                                       highestSet = ResultSet(
                                           reps: nonZeroResultSets[i].reps,
                                           setNumber: nonZeroResultSets[i].setNumber,
                                           rir: nonZeroResultSets[i].rir,
                                           weight: nonZeroResultSets[i].weight,
                                           idForKey: nonZeroResultSets[i].idForKey,
                                           setType: nonZeroResultSets[i].setType,
                                       );
                                     }
                                   }

                                   // then add the highest one
                                   if (highestSet.weight > 0) {
                                     LogPage.movementsLogged[existingLogIndex].prHistory.add(ResultSetBlock(
                                         date: DateTime.now(),
                                         resultSets: [ResultSet(
                                             reps: highestSet.reps,
                                             setNumber: highestSet.setNumber,
                                             rir: highestSet.rir,
                                             weight: highestSet.weight,
                                             idForKey: highestSet.idForKey,
                                             setType: highestSet.setType,
                                         )]
                                     )
                                     );
                                     ScaffoldMessenger.of(context).showSnackBar(
                                       SnackBar(
                                         backgroundColor: Colors.white,
                                         content: Text('New PR! Added to PR history', style: TextStyle(color: Styles.primaryColor)),
                                         duration: const Duration(milliseconds: 1500),
                                       ),
                                     );
                                   }

                                  LogPage.movementsLogged[existingLogIndex].resultSetBlocks.add(
                                      ResultSetBlock(
                                          dayIdForNavigation: widget.currentDay.id,
                                          date: DateTime.now(),
                                          resultSets: []));
                                   for(int i = 0; i < nonZeroResultSets.length; i ++) {
                                     LogPage.movementsLogged[existingLogIndex].resultSetBlocks.last.resultSets.add(
                                       ResultSet(
                                           reps: nonZeroResultSets[i].reps,
                                           setNumber: nonZeroResultSets[i].setNumber,
                                           rir: nonZeroResultSets[i].rir,
                                           weight: nonZeroResultSets[i].weight,
                                           idForKey: nonZeroResultSets[i].idForKey,
                                           setType: nonZeroResultSets[i].setType,
                                       )
                                     );
                                   }
                                   LogPage.movementsLogged[existingLogIndex].resultSetBlocks.sort((a, b) => a.date.compareTo(b.date));
                                  thisProgram.save();
                                  LogPage.movementsLogged[existingLogIndex].save();
                                }

                                ScaffoldMessenger.of(context).showSnackBar(
                                   SnackBar(
                                    backgroundColor: Colors.white,
                                    content: Text('Added to workout log', style: TextStyle(color: Styles.primaryColor)),
                                    duration: const Duration(milliseconds: 1500),
                                  ),
                                );
                                Navigator.of(context).pop();
                                },
                                child: Text('Yes', style: Styles.regularText),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('No', style: Styles.regularText),
                              ),
                            ],
                          );
                        },
                      );
                    }
                    else {
                      if (widget.thisMovement.hasBeenLogged == true) {
                        ScaffoldMessenger.of(context).showSnackBar(
                           SnackBar(
                            backgroundColor: Colors.white,
                            content: Text('Movement already logged',
                                style: TextStyle(color: Styles.primaryColor)),
                            duration: const Duration(milliseconds: 1500),
                          ),
                        );
                      } else {
                        if (widget.thisMovement.resultSets.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                             SnackBar(
                              backgroundColor: Colors.white,
                              content: Text('Sets must be added',
                                  style: TextStyle(color: Styles.primaryColor)),
                              duration: const Duration(milliseconds: 1500),
                            ),
                          );
                        }
                        else {
                          ScaffoldMessenger.of(context).showSnackBar(
                             SnackBar(
                              backgroundColor: Colors.white,
                              content: Text('Reps and weight must be entered',
                                  style: TextStyle(color: Styles.primaryColor)),
                              duration: const Duration(milliseconds: 1500),
                            ),
                          );
                        }
                      }
                    }
                  },
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ShowcaseTemplate(
                            globalKey: completeIconKey,
                            radius: 10,
                            stepID: 17,
                            title: "Completing a Movement",
                            content: "Click here when you are done with this movement, and you would like to add the sets to your movement log. Keep in mind that once a movement's sets are added to the log, you can no longer edit the sets or re-log them.",
                            child: Icon(Icons.check_box, color: widget.thisMovement.hasBeenLogged == true ? Colors.white54 : Colors.white, size: 30)),
                        const Text("Complete", style: Styles.smallTextWhite)],
                    ),
                ),
              ],
            )
         ),
      );
  }
}

