import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gym_app/WorkoutLogPageDirectory/workout_log.dart';
import 'main.dart';
import 'ProgramsPageDirectory/programs_page.dart';
import 'package:wheel_slider/wheel_slider.dart';
import 'dart:math' as math;
import 'dart:core';
import 'HomePageDirectory/home_screen.dart';

class ProgramNotes extends StatelessWidget {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final Program currentProgram = ProgramsPage.programsList[ProgramsPage.activeProgramIndex];

  @override
  Widget build(BuildContext context) {
    _focusNode.requestFocus();
    _textController.text = currentProgram.notes ?? currentProgram.notes ?? "";

    return PopScope(
        onPopInvokedWithResult: (bool didPop, dynamic result) {
          currentProgram.notes = _textController.text;
          currentProgram.save();
        },

        child: Scaffold(
            appBar: AppBar(
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: Styles.darkGradient()
                ),
              ),
              iconTheme: const IconThemeData(
                color: Colors.white54, //change your color here
              ),
              actions: <Widget>[
                TextButton( onPressed: () {
                  _focusNode.unfocus();
                }, child: const Text("Unfocus", style: Styles.paragraph)),
              ],
              backgroundColor: Styles.primaryColor,
              shape: const Border(
                bottom: BorderSide(
                  color: Colors.black45,
                  width: 2,
                ),
              ),
              shadowColor: Colors.black54,
              elevation: 10,
            ),
            body: Container(
                height: double.infinity,
                decoration: BoxDecoration(
                    gradient: Styles.horizontal()
                ),
                child: ListView(
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(
                        hintText: "Notes...",
                        hintStyle: TextStyle(color: Colors.white60),
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
        )
    );
  }
}



class MovementNotes extends StatelessWidget {
  final Movement thisMovement;
  MovementNotes({required this.thisMovement});

  final TextEditingController notesTextController = TextEditingController();
  final FocusNode notesFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    notesFocusNode.requestFocus();
    notesTextController.text = thisMovement.notes;


    return PopScope(
      onPopInvokedWithResult: (bool didPop, dynamic result) {
           thisMovement.notes = notesTextController.text;
           ProgramsPage.programsList[ProgramsPage.activeProgramIndex].save();
      },
          child: Scaffold(
                appBar: AppBar(
                  flexibleSpace: Container(
                    decoration: BoxDecoration(
                        gradient: Styles.darkGradient()
                    ),
                  ),
                  iconTheme: const IconThemeData(
                    color: Colors.white54, //change your color here
                  ),
                  actions: <Widget>[
                    TextButton( onPressed: () {
                      notesFocusNode.unfocus();
                    }, child: const Text("Unfocus", style: Styles.paragraph)),
                  ],
          backgroundColor: Styles.primaryColor,
          shape: const Border(
            bottom: BorderSide(
              color: Colors.black45,
              width: 2,
            ),
          ),
          shadowColor: Colors.black54,
          elevation: 10,
                ),
                body: Container(
          decoration: BoxDecoration(
            gradient: Styles.horizontal()
          ),
          child: ListView(
                 children: [
                   TextFormField(
                         decoration: const InputDecoration(
                           hintText: "Notes...",
                           hintStyle: TextStyle(color: Colors.white60),
                           border: InputBorder.none,
                         ),
                       maxLines: null,
                       controller: notesTextController,
                       focusNode: notesFocusNode,
                       style: Styles.regularText,
                       cursorColor: Colors.white,
                     )
              ]
          ),
                ),
               ),
    );
  }
}






class CreateMovement extends StatefulWidget {
  final day currentDay;
  final Function(Movement) addThisMovement;
  const CreateMovement({required this.currentDay, required this.addThisMovement});

  @override
  State<CreateMovement> createState() => _CreateMovementState();
}

class _CreateMovementState extends State<CreateMovement> {
  bool errorMessageActive = false;
  bool showAllMuscleGroups = false;
  bool selectionActive = false;
  int minutesValue = 1;
  int secondsValue = 0;
  String movementName = "";
  late FocusNode searchFocus = FocusNode();
  TextEditingController searchController = TextEditingController();

  late FocusNode weightFocus = FocusNode();
  TextEditingController weightController = TextEditingController();


  int setsValue = 0;
  int repsLowerValue = 0;
  int repsUpperValue = 0;
  int rirLowerValue = 0;
  int rirUpperValue = 0;
  bool setSelectionActive = false;
  bool repSelectionActive = false;
  bool rirSelectionActive = false;

  bool rirEmpty = true;

  List<MovementLog> rootList = [];
  List<MovementLog> displayList = [];

  sortDisplayList () {
    displayList.sort((a, b) {
      if (a.favorited != b.favorited) {
        return a.favorited ? -1 : 1;
      } else {
        return b.date.compareTo(a.date);
      }
    });
  }

  @override
  void initState() {
    if(widget.currentDay.muscleGroups != null && widget.currentDay.muscleGroups!.isNotEmpty) {
      //get all the muscle movements that match the muscle groups in this day
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

    searchFocus.addListener(() {
      setState(() {
        if (!searchFocus.hasFocus) {
          searchController.text = movementName;
        }
      });
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
       Navigator.of(context).pop();
      },
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height/10),
          child: Dialog(
              child: GestureDetector(
                onTap: () {
                /*
                 this is so that the parent gesture detector's onTap function is not called
                 when you tap on the dialog. It's only executed when you tap outside of the dialog.
                  */
                },
                child: Container (
                  height: AppSettings.rirActive ? 425 : 375,
                  decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(
                  Radius.circular(20.0)
                     ),
                   color: Styles.secondaryColor,
                  ),
                      child: Stack(
                        children: [
                          Positioned(right: 10, top: 20,
                                child: Icon(searchFocus.hasFocus == false ? Icons.keyboard_arrow_down :Icons.keyboard_arrow_up, color: Colors.white, size: 30),
                          ),
                           Column(
                              children: [
                                Row(children: [
                                    Expanded(
                                     child: TextField(
                                       focusNode: searchFocus,
                                       onTap: () {
                                         selectMovementOnTap();
                                       },
                                       onChanged: (text) {
                                         setState(() {
                                           errorMessageActive = false;
                                           displayList = List.from(rootList.where((element) => element.name.replaceAll(RegExp(r'\s+'), '').toLowerCase().contains(text.replaceAll(RegExp(r'\s+'), '').toLowerCase())));
                                           sortDisplayList();
                                         });
                                       },
                                       inputFormatters: <TextInputFormatter>[
                                         LengthLimitingTextInputFormatter(27)
                                       ],
                                       controller: searchController,
                                       decoration: const InputDecoration(
                                         contentPadding: EdgeInsets.only(right: 40, left: 20, top: 15, bottom: 15),
                                         label: Text("Select Movement", style: Styles.paragraph),
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
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5),
                                  child: Column(children: [
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          weightFocus.unfocus();
                                          rirSelectionActive = false;
                                          repSelectionActive = false;
                                          setSelectionActive = true;
                                          if (setsValue == 0) {
                                            setsValue = 3;
                                          }
                                        });
                                      },
                                      child: SizedBox(
                                        height: 48,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                             if (setSelectionActive) IconButton(onPressed: () {
                                               setState(() {
                                                 if (setsValue > 0) {
                                                   setsValue --;
                                                 }
                                               });
                                             }, icon: const Icon(Icons.indeterminate_check_box, size: 28, color: Colors.white)),

                                              if (!setSelectionActive && setsValue == 0)
                                                  ...[ const Text("Sets", style: Styles.paragraph)]
                                              else...[Text(setsValue.toString(), style: Styles.regularText)],

                                             if (setSelectionActive) IconButton(onPressed: () {
                                               setState(() {
                                                 if (setsValue < 9) {
                                                   setsValue ++;
                                                 }
                                               });

                                             }, icon:  const Icon(Icons.add_box, size: 28, color: Colors.white)),
                                             if (!setSelectionActive) const Spacer(),
                                            ],
                                        ),
                                      ),
                                    ),
                                    Divider(height: 0, color: setSelectionActive ? Colors.white : Colors.white54),
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          weightFocus.unfocus();
                                          rirSelectionActive = false;
                                          setSelectionActive = false;
                                          repSelectionActive = true;
                                          if(repsLowerValue == 0 && repsUpperValue == 0) {
                                            repsLowerValue = 8;
                                            repsUpperValue = 10;
                                          }
                                        });
                                      },
                                      child: SizedBox(
                                        height: 48,
                                        child: Row(
                                          children: [
                                            if (repSelectionActive)...[
                                            IconButton(onPressed: () {
                                              setState(() {
                                                if (repsLowerValue > 0) {
                                                  repsLowerValue --;
                                                }
                                              });
                                            }, icon: const Icon(Icons.indeterminate_check_box, size: 25, color: Colors.white)),
                                            Text("$repsLowerValue", style: Styles.paragraph.copyWith(color: Colors.white)),
                                            IconButton(onPressed: () {
                                              setState(() {
                                                if (repsLowerValue < repsUpperValue) {
                                                  repsLowerValue ++;
                                                }
                                                else {
                                                  if (repsUpperValue < 50) {
                                                    repsLowerValue ++;
                                                    repsUpperValue ++;
                                                  }
                                                }
                                              });

                                            }, icon:  const Icon(Icons.add_box, size: 25, color: Colors.white)),
                                            const Expanded(child: Text("-", style: Styles.labelText, textAlign: TextAlign.center)),
                                            IconButton(onPressed: () {
                                              setState(() {
                                                if (repsUpperValue > repsLowerValue) {
                                                  repsUpperValue --;
                                                }
                                                else {
                                                  if (repsLowerValue > 0) {
                                                    repsUpperValue --;
                                                    repsLowerValue --;
                                                  }
                                                }
                                              });
                                            }, icon: const Icon(Icons.indeterminate_check_box, size: 25, color: Colors.white)),
                                            Text("$repsUpperValue", style: Styles.paragraph.copyWith(color: Colors.white)),
                                            IconButton(onPressed: () {
                                              setState(() {
                                                if (repsUpperValue < 69) {
                                                  repsUpperValue ++;
                                                }
                                              });

                                            }, icon:  const Icon(Icons.add_box, size: 25, color: Colors.white)),
                                            ],

                                            if (!repSelectionActive && (repsLowerValue == 0 && repsUpperValue == 0))...[const Text("Reps", style: Styles.paragraph),
                                              const Spacer()]
                                            else if (!repSelectionActive) ...[
                                              Text(repsLowerValue == repsUpperValue ? repsLowerValue.toString() : "$repsLowerValue-$repsUpperValue", style: Styles.regularText),
                                              const Spacer()
                                            ]
                                          ],
                                        ),
                                      ),
                                    ),
                                    Divider(height: 0, color: repSelectionActive ? Colors.white : Colors.white54),
                                    TextField(
                                      onTap: () {
                                        setState(() {
                                          repSelectionActive = false;
                                          setSelectionActive = false;
                                          rirSelectionActive = false;
                                        });
                                      },
                                      inputFormatters: <TextInputFormatter>[
                                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                                        LengthLimitingTextInputFormatter(5)
                                      ],
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      focusNode: weightFocus,
                                      controller: weightController,
                                      decoration: const InputDecoration(
                                        hintText: 'Weight',
                                        hintStyle: Styles.smallTextWhite,
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: Colors.white),
                                        ),
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: Colors.white60),
                                        ),
                                      ),
                                      style: Styles.regularText,
                                      cursorColor: Colors.white,
                                    ),
                                    if (AppSettings.rirActive) InkWell(
                                      onTap: () {
                                        setState(() {
                                          weightFocus.unfocus();
                                          setSelectionActive = false;
                                          repSelectionActive = false;
                                          rirSelectionActive = true;
                                          if(rirEmpty) {
                                            rirLowerValue = 0;
                                            rirUpperValue = 1;
                                            rirEmpty = false;
                                          }
                                        });
                                      },
                                      child: SizedBox(
                                        height: 48,
                                        child: Row(
                                          children: [
                                            if (rirSelectionActive)...[
                                              IconButton(onPressed: () {
                                                setState(() {
                                                  if (rirLowerValue > 0) {
                                                    rirLowerValue --;
                                                  }
                                                });
                                              }, icon: const Icon(Icons.indeterminate_check_box, size: 25, color: Colors.white)),
                                              Text("$rirLowerValue", style: Styles.paragraph.copyWith(color: Colors.white)),
                                              IconButton(onPressed: () {
                                                setState(() {
                                                  if (rirLowerValue < rirUpperValue) {
                                                    rirLowerValue ++;
                                                  }
                                                  else {
                                                    if (rirUpperValue < 50) {
                                                      rirLowerValue ++;
                                                      rirUpperValue ++;
                                                    }
                                                  }
                                                });

                                              }, icon:  const Icon(Icons.add_box, size: 25, color: Colors.white)),
                                              const Expanded(child: Text("-", style: Styles.labelText, textAlign: TextAlign.center)),
                                              IconButton(onPressed: () {
                                                setState(() {
                                                  if (rirUpperValue > rirLowerValue) {
                                                    rirUpperValue --;
                                                  }
                                                  else {
                                                    if (rirLowerValue > 0) {
                                                      rirUpperValue --;
                                                      rirLowerValue --;
                                                    }
                                                  }
                                                });
                                              }, icon: const Icon(Icons.indeterminate_check_box, size: 25, color: Colors.white)),
                                              Text("$rirUpperValue", style: Styles.paragraph.copyWith(color: Colors.white)),
                                              IconButton(onPressed: () {
                                                setState(() {
                                                  if (rirUpperValue < 69) {
                                                    rirUpperValue ++;
                                                  }
                                                });

                                              }, icon:  const Icon(Icons.add_box, size: 25, color: Colors.white)),
                                            ],

                                            if (!rirSelectionActive && rirEmpty)...[const Text("RIR", style: Styles.paragraph),
                                              const Spacer()]
                                            else if (!rirSelectionActive) ...[
                                              Text(rirLowerValue == rirUpperValue ? rirLowerValue.toString() : "$rirLowerValue-$rirUpperValue", style: Styles.regularText),
                                              const Spacer()
                                            ]
                                          ],
                                        ),
                                      ),
                                    ),
                                    Divider(height: 0, color: rirSelectionActive ? Colors.white : Colors.white54),

                                    const SizedBox(height: 50),
                                    Row(
                                        children: [
                                          const Text("Rest:", style: Styles.smallTextWhite),
                                          WheelSlider.number(
                                            enableAnimation: false,
                                            horizontal: false,
                                            verticalListHeight: 100,
                                            verticalListWidth: 60,
                                            itemSize: 45,
                                            perspective: 0.01,
                                            totalCount: 10,
                                            initValue: 1,
                                            selectedNumberStyle: Styles.labelText,
                                            unSelectedNumberStyle: Styles.smallTextWhite,
                                            currentIndex: minutesValue,
                                            onValueChanged: (val) {
                                              setState(() {
                                                minutesValue = val;
                                              });
                                            },
                                            hapticFeedbackType: HapticFeedbackType.heavyImpact,
                                          ),
                                          Container(
                                              padding: const EdgeInsets.only(bottom: 5),
                                              child: const Text(":", style: Styles.labelText)),
                                          WheelSlider.number(
                                            enableAnimation: false,
                                            horizontal: false,
                                            verticalListHeight: 100,
                                            verticalListWidth: 60,
                                            itemSize: 45,
                                            perspective: 0.01,
                                            totalCount: 59,
                                            initValue: 0,
                                            selectedNumberStyle: Styles.labelText,
                                            unSelectedNumberStyle: Styles.smallTextWhite,
                                            currentIndex: secondsValue,
                                            onValueChanged: (val) {
                                              setState(() {
                                                secondsValue = val;
                                              });
                                            },
                                            hapticFeedbackType: HapticFeedbackType.heavyImpact,
                                          ),
                                          const Spacer(),
                                          InkWell(onTap: () {
                                            setState(() {
                                              if(movementName != "") {
                                                if (weightController.text == "") {
                                                  weightController.text = "0";
                                                }
                                                Navigator.pop(context, true);
                                                widget.addThisMovement(Movement(
                                                    resultSets: [],
                                                    name: movementName,
                                                    sets: setsValue,
                                                    reps: repsLowerValue == repsUpperValue ? repsLowerValue.toString() : "$repsLowerValue-$repsUpperValue",
                                                    rir:  rirLowerValue == rirUpperValue ? rirLowerValue.toString() : "$rirLowerValue-$rirUpperValue",
                                                    notes: "",
                                                    weight: double.parse(weightController.text),
                                                    rest: Duration(minutes: minutesValue,
                                                        seconds: secondsValue),
                                                    remainingRestTime: Duration(
                                                        minutes: minutesValue,
                                                        seconds: secondsValue)
                                                ));
                                              }
                                              else {
                                                errorMessageActive = true;
                                              }
                                            });
                                          },
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                                decoration: BoxDecoration(
                                                  color: Colors.black12,
                                                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                                                  border: Border.all(
                                                   color: movementName.isNotEmpty ? Colors.white : Colors.white54
                                                  )
                                                ),
                                                  child: Text("Done", style: Styles.paragraph.copyWith(color: movementName.isNotEmpty ? Colors.white : Colors.white54)))
                                          ),
                                          const SizedBox(width: 20)
                                        ]
                                    ),
                                  ],),
                                ),
                              ],
                            ),
                          if (searchFocus.hasFocus == true) Positioned(left: 5, top: 65, right: 5,
                              child: Container(
                                  height: 250,
                                   decoration: BoxDecoration(
                                      color: Styles.secondaryColor,
                                       boxShadow: const [
                                         BoxShadow(
                                           color: Colors.black87,
                                           spreadRadius: 1,
                                           blurRadius: 3,
                                           offset: Offset(0, 1),
                                         ),
                                       ],
                                     borderRadius: const BorderRadius.all(Radius.circular(5)),
                                     border: const Border(
                                       bottom: BorderSide(
                                         color: Colors.black38,
                                           width: 1
                                       ),
                                       left: BorderSide(
                                           color: Colors.black38,
                                           width: 1
                                       ),
                                       right: BorderSide(
                                           color: Colors.black38,
                                           width: 1
                                       ),
                                     )
                                    ),
                                  child: Column(
                                    children: [
                                          if(displayList.isNotEmpty)...[
                                           Expanded(
                                            child: ListView.builder(
                                            scrollDirection: Axis.vertical,
                                            shrinkWrap: true,
                                            itemCount: displayList.length,
                                            itemBuilder: (context, index) {
                                              return InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    searchFocus.unfocus();
                                                    movementName = displayList[index].name;
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
                                                    child: Row(
                                                      children: [
                                                        if (displayList[index].favorited) ShaderMask(
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
                                                          child: const Icon(Icons.star, color: Colors.white, size: 20),
                                                        ),
                                                        Expanded(
                                                            child: Text(displayList[index].name, style: Styles.smallTextWhite.copyWith(color: Colors.white), textAlign: TextAlign.center)),
                                                      ],
                                                    )
                                                ),
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
                                                            setState(() {
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

                                      InkWell(
                                        onTap: () {
                                          setState(() {
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
                                            sortDisplayList();
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
                                  )
                              )
                          ),


                          if(errorMessageActive == true)
                           const Positioned(top: 5, left: 0, right: 0,
                                child: Text("Movement name required", textAlign: TextAlign.center, style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)))


                        ],
                      )
                  ),
              ),

          ),
        ),
      ),
    );
  }

  void selectMovementOnTap() {
    setState(() {
      setSelectionActive = false;
      repSelectionActive = false;
      errorMessageActive = false;
      if (searchFocus.hasFocus == true) {
        searchFocus.unfocus();
      }
      else {
        displayList = List.from(rootList.where((element) => element.name.replaceAll(RegExp(r'\s+'), '').toLowerCase().contains(searchController.text.replaceAll(RegExp(r'\s+'), '').toLowerCase())));
        sortDisplayList();
      }
    });
  }
}






class CreateOrEditMovementLog extends StatefulWidget {
  final MovementLog? logToEdit;
  final String? insertName;
  final Function? refreshParent;
  final Function? addMovementLog;

   const CreateOrEditMovementLog({this.insertName, this.logToEdit, this.refreshParent, this.addMovementLog});
  @override
  State<CreateOrEditMovementLog> createState() => _CreateOrEditMovementLogState();
}

class _CreateOrEditMovementLogState extends State<CreateOrEditMovementLog> {
  final FocusNode _focusNode = FocusNode();
  TextEditingController dialogController = TextEditingController();
  List <String> selectionList = [];
  List <String> primaryMuscleGroups = [];
  List <String> secondaryMuscleGroups = [];
  bool primarySelected = true;
  bool hasFocus = false;

  @override
  void initState() {
    _focusNode.requestFocus();
    hasFocus = true;

    if (widget.insertName != null) {
      dialogController.text = widget.insertName!;
    }

    if (widget.logToEdit != null) {
      primaryMuscleGroups = widget.logToEdit!.primaryMuscleGroups ?? [];
      secondaryMuscleGroups = widget.logToEdit!.secondaryMuscleGroups ?? [];
      dialogController.text = widget.logToEdit!.name;
    }

    for (String muscleGroup in MuscleGroups.muscleGroupsList) {
      if (widget.logToEdit != null) {
        if(!primaryMuscleGroups.contains(muscleGroup) && !secondaryMuscleGroups.contains(muscleGroup)) {
          selectionList.add(muscleGroup);
        }
      }
      else {
        selectionList.add(muscleGroup);
      }
    }
    super.initState();
  }


  @override
  Widget build(BuildContext context) {

    return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),

              child: Container(
                        height: 550,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.0),
                            gradient: Styles.darkGradient()
                        ),
                        child: Column(
                          children: [
                             Container(
                               height: 60,
                               width: double.infinity,
                               decoration: BoxDecoration(
                                 color: Styles.primaryColor,
                                 borderRadius: const BorderRadius.only(
                                   topRight: Radius.circular(20),
                                   topLeft: Radius.circular(20)
                                 ),
                                 border: const Border(
                                   bottom: BorderSide(
                                     color: Colors.black54,
                                     width: 3
                                   )
                                 )
                               ),
                                padding: const  EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  child:  TextFormField(
                                    onTap: () {
                                      setState(() {
                                        hasFocus = true;
                                      });
                                    },
                                    inputFormatters: [LengthLimitingTextInputFormatter(27)],
                                    controller: dialogController,
                                    focusNode: _focusNode,
                                    cursorColor: Colors.white,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'Movement name...',
                                      hintStyle: Styles.smallTextWhite
                                    ),
                                    style: Styles.regularText,
                                    textAlign: hasFocus ? TextAlign.left : TextAlign.center
                                  ),
                                ),
                            const SizedBox(height: 40),
                            Row(
                              mainAxisAlignment:MainAxisAlignment.spaceAround,
                              children: [
                                 InkWell(
                                   onTap: () {
                                     setState(() {
                                       primarySelected = true;
                                       _focusNode.unfocus();
                                       hasFocus = false;
                                     });
                                   },
                                     child: Text("Primary", style: Styles.paragraph.copyWith(color: primarySelected ? Colors.white : Colors.white54))),
                                 InkWell(
                                   onTap: () {
                                     setState(() {
                                       primarySelected = false;
                                       _focusNode.unfocus();
                                       hasFocus = false;
                                     });
                                   },
                                     child: Text("Secondary", style: Styles.paragraph.copyWith(color: primarySelected ? Colors.white54 : Colors.white))),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                    child: Container(
                                      height: primarySelected ? 2 : 1,
                                      color: primarySelected ? Colors.white : Colors.white54,
                                    )),
                                Expanded(
                                    child: Container(
                                      height: primarySelected ? 1 : 2,
                                      color: primarySelected ? Colors.white54 : Colors.white,
                                    )),
                              ],
                            ),
                            Container(
                                height: 150,
                                decoration: const BoxDecoration(
                                    color: Colors.black12,
                                    borderRadius: BorderRadius.only(
                                    bottomRight: Radius.circular(20),
                                    bottomLeft: Radius.circular(20)
                                  ),
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.white54,
                                      width: 2
                                    )
                                  )
                                ),
                                child: primaryMuscleGroups.isNotEmpty && primarySelected || secondaryMuscleGroups.isNotEmpty && !primarySelected ?
                                GridView.builder(
                                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),

                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      mainAxisExtent: 45,
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 20,
                                      mainAxisSpacing: 20,
                                    ),
                                    itemCount: primarySelected ? primaryMuscleGroups.length : secondaryMuscleGroups.length,
                                    itemBuilder: (context, index) {
                                      return InkWell(
                                        onTap: () {
                                          setState(() {
                                            _focusNode.unfocus();
                                            hasFocus = false;
                                            if (primarySelected) {
                                              selectionList.add(primaryMuscleGroups[index]);
                                              primaryMuscleGroups.removeAt(index);
                                            }
                                            else {
                                              selectionList.add(secondaryMuscleGroups[index]);
                                              secondaryMuscleGroups.removeAt(index);
                                            }
                                          });
                                        },
                                        child: Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(10.0),
                                                    border: Border.all(
                                                      color: Colors.white,
                                                      width: 2.0,
                                                    ),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                        primarySelected ? primaryMuscleGroups[index] : secondaryMuscleGroups[index],
                                                        textAlign: TextAlign.center,
                                                        style: Styles.paragraph.copyWith(color: Colors.white)
                                                    ),
                                                  ),
                                                ),
                                      );
                                    }
                                )
                                    : const Center(
                                    child: Text("Add muscle groups", style: Styles.smallTextWhite))
                              ),
                            if (selectionList.isNotEmpty)...[
                            Expanded(
                              child: GridView.builder(
                                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),

                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    mainAxisExtent: 45,
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 20,
                                    mainAxisSpacing: 20,
                                  ),
                                  itemCount: selectionList.length,
                                  itemBuilder: (context, index) {
                                    return InkWell(
                                      onTap: () {
                                        setState(() {
                                          _focusNode.unfocus();
                                          hasFocus = false;
                                          if (primarySelected) {
                                            primaryMuscleGroups.add(selectionList[index]);
                                            selectionList.removeAt(index);
                                          }
                                          else {
                                            if (primaryMuscleGroups.isNotEmpty) {
                                              secondaryMuscleGroups.add(selectionList[index]);
                                              selectionList.removeAt(index);
                                            }
                                            else {
                                              primaryMuscleGroups.add(selectionList[index]);
                                              selectionList.removeAt(index);
                                              primarySelected = true;
                                            }
                                          }
                                        });
                                      },
                                      child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(10.0),
                                                  border: Border.all(
                                                    color: Colors.white,
                                                    width: 2.0,
                                                  ),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                      selectionList[index],
                                                      textAlign: TextAlign.center,
                                                      style: Styles.paragraph.copyWith(color: Colors.white)
                                                  ),
                                                ),
                                              ),
                                    );
                                  }
                              ),
                            ),
                              ]
                            else ...[
                               Text(MuscleGroups.muscleGroupsList.isEmpty ? "No muscle groups found." : "", style: Styles.smallTextWhite),
                               const Spacer(),
                            ],

                            GestureDetector(
                              onTap: () {
                                if(widget.logToEdit == null) {
                                  if (dialogController.text.trim() != "") {
                                    if (LogPage.movementsLogged.where((movementLog) => movementLog.name.replaceAll(RegExp(r'\s+'), '').toLowerCase() == dialogController.text.replaceAll(RegExp(r'\s+'), '').toLowerCase()).isEmpty) {
                                      widget.addMovementLog!(dialogController.text, primaryMuscleGroups, secondaryMuscleGroups);
                                      Navigator.of(context).pop();
                                    }
                                    else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          backgroundColor: Colors.white,
                                          content: Text('This movement is already in your workout log', style: TextStyle(color: Styles.primaryColor)),
                                          duration: const Duration(milliseconds: 1500),
                                        ),
                                      );
                                    }
                                  }
                                  else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor: Colors.white,
                                        content: Text('Movement name required', style: TextStyle(color: Styles.primaryColor)),
                                        duration: const Duration(milliseconds: 1500),
                                      ),
                                    );
                                  }
                                }
                                else {
                                  String currentName = LogPage.movementsLogged[LogPage.currentMovementLogIndex].name;

                                  renameInProgram() {

                                    for(int programIndex = 0; programIndex < ProgramsPage.programsList.length; programIndex ++) {

                                      for (int weekIndex = 0; weekIndex < ProgramsPage.programsList[programIndex].weeks.length; weekIndex++) {

                                        for (int dayIndex = 0; dayIndex < ProgramsPage.programsList[programIndex].weeks[weekIndex].days.length; dayIndex++) {

                                          for (int movementIndex = 0; movementIndex < ProgramsPage.programsList[programIndex].weeks[weekIndex].days[dayIndex].movements.length; movementIndex++) {

                                            if (ProgramsPage.programsList[programIndex].weeks[weekIndex].days[dayIndex].movements[movementIndex].name.replaceAll(RegExp(r'\s+'), '').toLowerCase() == currentName.replaceAll(RegExp(r'\s+'), '').toLowerCase()) {
                                              ProgramsPage.programsList[programIndex].weeks[weekIndex].days[dayIndex].movements[movementIndex].name = dialogController.text;
                                              ProgramsPage.programsList[programIndex].save();
                                            }
                                          }
                                        }
                                      }
                                    }

                                    if (copiedWeeksDays != null) {
                                      for (int dayIndex = 0; dayIndex < copiedWeeksDays!.length; dayIndex ++) {
                                        for (int movementIndex = 0; movementIndex < copiedWeeksDays![dayIndex].movements.length; movementIndex ++) {
                                          if (copiedWeeksDays![dayIndex].movements[movementIndex].name.replaceAll(RegExp(r'\s+'), '').toLowerCase() == currentName.replaceAll(RegExp(r'\s+'), '').toLowerCase()) {
                                            copiedWeeksDays![dayIndex].movements[movementIndex].name = dialogController.text;
                                          }
                                        }
                                      }
                                    }


                                    if (copiedDay != null) {
                                      for (int i = 0; i < copiedDay!.movements.length; i ++) {
                                        if (copiedDay!.movements[i].name.replaceAll(RegExp(r'\s+'), '').toLowerCase() == currentName.replaceAll(RegExp(r'\s+'), '').toLowerCase()) {
                                          copiedDay!.movements[i].name = dialogController.text;
                                        }
                                      }
                                    }

                                    if (copiedMovement != null && copiedMovement?.name.replaceAll(RegExp(r'\s+'), '').toLowerCase() == currentName.replaceAll(RegExp(r'\s+'), '').toLowerCase()) {
                                      copiedMovement?.name = dialogController.text;
                                    }
                                  }

                                  bool mergeDialogIsOpen = false;
                                  if(dialogController.text != "" && dialogController.text.replaceAll(RegExp(r'\s+'), '').toLowerCase() != LogPage.movementsLogged[LogPage.currentMovementLogIndex].name.replaceAll(RegExp(r'\s+'), '').toLowerCase()) {
                                    final box = Boxes.getMovementLogs();

                                    mergeInProgram(MovementLog existingLog) {
                                      for(int programIndex = 0; programIndex < ProgramsPage.programsList.length; programIndex ++) {

                                        for (int weekIndex = 0; weekIndex < ProgramsPage.programsList[programIndex].weeks.length; weekIndex++) {

                                          for (int dayIndex = 0; dayIndex < ProgramsPage.programsList[programIndex].weeks[weekIndex].days.length; dayIndex++) {

                                            for (int movementIndex = 0; movementIndex < ProgramsPage.programsList[programIndex].weeks[weekIndex].days[dayIndex].movements.length; movementIndex++) {
                                              if (ProgramsPage.programsList[programIndex].weeks[weekIndex].days[dayIndex].movements[movementIndex].name == currentName) {
                                                ProgramsPage.programsList[programIndex].weeks[weekIndex].days[dayIndex].movements[movementIndex].name = existingLog.name;
                                                ProgramsPage.programsList[programIndex].save();
                                              }
                                            }
                                          }
                                        }
                                      }

                                      if (copiedWeeksDays != null) {
                                        for (int dayIndex = 0; dayIndex < copiedWeeksDays!.length; dayIndex ++) {
                                          for (int movementIndex = 0; movementIndex < copiedWeeksDays![dayIndex].movements.length; movementIndex ++) {
                                            if (copiedWeeksDays![dayIndex].movements[movementIndex].name == currentName) {
                                              copiedWeeksDays![dayIndex].movements[movementIndex].name = existingLog.name;
                                            }
                                          }
                                        }
                                      }

                                      if (copiedDay != null) {
                                        for (int i = 0; i < copiedDay!.movements.length; i ++) {
                                          if (copiedDay!.movements[i].name == currentName) {
                                            copiedDay!.movements[i].name = existingLog.name;
                                          }
                                        }
                                      }

                                      if (copiedMovement != null && copiedMovement?.name == currentName) {
                                        copiedMovement?.name = existingLog.name;
                                      }
                                    }

                                    //renaming to a name that is not already being used
                                    if (LogPage.movementsLogged.where((log) => log.name.replaceAll(RegExp(r'\s+'), '').toLowerCase() == dialogController.text.replaceAll(RegExp(r'\s+'), '').toLowerCase()).isEmpty) {
                                      setState(() {

                                        LogPage.movementsLogged[LogPage.currentMovementLogIndex].name = dialogController.text;
                                        renameInProgram();
                                        widget.refreshParent!();
                                      });
                                    }
                                    //renaming to a name that is already being used
                                    else {
                                      MovementLog existingLog = LogPage.movementsLogged.where((log) => log.name.replaceAll(RegExp(r'\s+'), '').toLowerCase() == dialogController.text.replaceAll(RegExp(r'\s+'), '').toLowerCase()).first;
                                      mergeDialogIsOpen = true;
                                      callback () {
                                        Navigator.of(context).pop();
                                          mergeInProgram(existingLog);
                                          for (ResultSetBlock block in LogPage.movementsLogged[LogPage.currentMovementLogIndex].resultSetBlocks) {
                                            existingLog.resultSetBlocks.add(block);
                                          }
                                          existingLog.save();
                                          box.delete(LogPage.movementsLogged[LogPage.currentMovementLogIndex].key);
                                          LogPage.movementsLogged.remove(LogPage.movementsLogged[LogPage.currentMovementLogIndex]);
                                        widget.refreshParent!();
                                      }

                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return ConfirmationDialog(content: "'${existingLog.name}' already exists in your workout log. Would you like to merge '$currentName' with '${existingLog.name}'?", callbackFunction: callback);
                                          }
                                      );
                                    }
                                  }
                                  //changing the case (lowercase to uppercase or vice versa) in the name
                                  else {
                                    setState(() {
                                      //already checked that the name is the same, but case insensitively. So now this checks if case is the same
                                      if (dialogController.text != LogPage.movementsLogged[LogPage.currentMovementLogIndex].name) {
                                        LogPage.movementsLogged[LogPage.currentMovementLogIndex].name = dialogController.text;
                                        renameInProgram();
                                        widget.refreshParent?.call(); // calls only if not null
                                      }
                                    });
                                  }

                                  LogPage.movementsLogged[LogPage.currentMovementLogIndex].primaryMuscleGroups = primaryMuscleGroups;
                                  LogPage.movementsLogged[LogPage.currentMovementLogIndex].secondaryMuscleGroups = secondaryMuscleGroups;
                                  LogPage.movementsLogged[LogPage.currentMovementLogIndex].save();
                                  if(!mergeDialogIsOpen) {
                                    Navigator.of(context).pop();
                                  }
                                }
                              },
                              child: Container(
                                height: 60,
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 5),
                                decoration: BoxDecoration(
                                  color: Styles.primaryColor,
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(20),
                                    bottomRight: Radius.circular(20)
                                  ),
                                    border: const Border(
                                        top: BorderSide(
                                            color: Colors.black54,
                                            width: 3
                                        )
                                    )
                                ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(widget.logToEdit == null ? Icons.add_circle : Icons.edit, color: Colors.white, size: 25),
                                      const SizedBox(width: 5),
                                      Text(widget.logToEdit == null ? "Add" : "Done", style: Styles.regularText, textAlign: TextAlign.center),
                                      const SizedBox(width: 15),
                                  ]
                                ),
                              ),
                            ),
                          ],
                        ),
                  )
    );
  }
}




//ignore: must_be_immutable
class EditRestDialog extends StatefulWidget {
  Function (int, int) editRest;
  int minutes;
  int seconds;

  EditRestDialog({required this.editRest, required this.minutes, required this.seconds});


  @override
  State<EditRestDialog> createState() => _EditRestDialogState();
}

class _EditRestDialogState extends State<EditRestDialog> {

  @override
  Widget build(BuildContext context) {

    return PopScope(
        onPopInvokedWithResult: (bool didPop, dynamic result) {
          widget.editRest(widget.minutes, widget.seconds);
        },


            child: Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
            child: Container(
              height: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                gradient: Styles.vertical()
              ),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    WheelSlider.number(
                      enableAnimation: false,
                      horizontal: false,
                      verticalListHeight: double.infinity,
                      verticalListWidth: 60,
                      itemSize: 45,
                      perspective: 0.01,
                      totalCount: 9,
                      initValue: widget.minutes,
                      selectedNumberStyle: Styles.labelText,
                      unSelectedNumberStyle: Styles.smallTextWhite,
                      currentIndex: widget.minutes,
                      onValueChanged: (val) {
                        setState(() {
                          widget.minutes = val;
                        });
                      },
                      hapticFeedbackType: HapticFeedbackType.heavyImpact,
                    ),
                    const Text("min", style: Styles.smallTextWhite),
                  ],
                ),
                Row(
                  children: [
                    WheelSlider.number(
                      enableAnimation: false,
                      horizontal: false,
                      verticalListHeight: double.infinity,
                      verticalListWidth: 60,
                      itemSize: 45,
                      perspective: 0.01,
                      totalCount: 59,
                      initValue: widget.seconds,
                      selectedNumberStyle: Styles.labelText,
                      unSelectedNumberStyle: Styles.smallTextWhite,
                      currentIndex: widget.seconds,
                      onValueChanged: (val) {
                        setState(() {
                          widget.seconds = val;
                        });
                      },
                      hapticFeedbackType: HapticFeedbackType.heavyImpact,
                    ),
                    const Text("sec", style: Styles.smallTextWhite),
                  ],
                )
              ]
          ),
          )
      )
    );
  }
}




class EditDialog extends StatefulWidget {
  dynamic dataToEdit;
  String identifier;
  final Function (dynamic, String) editData;

  EditDialog({required this.dataToEdit, required this.identifier, required this.editData});

  @override
  State<EditDialog> createState() => _EditDialogState();
}

class _EditDialogState extends State<EditDialog> {
  final FocusNode _focusNode = FocusNode();
  TextEditingController dialogController = TextEditingController();

  @override
  void initState() {
    if (widget.identifier == "Week Name" && RegExp(r"^week\s\d+$").hasMatch(widget.dataToEdit.toString().toLowerCase())) {
      widget.dataToEdit = "";
    }


    displayIdentifier = widget.identifier.replaceAll("results", "");
    if (widget.dataToEdit.toString().replaceFirst(".0", "").length > 2 && widget.dataToEdit != 0.0) {
      dialogController.text = widget.dataToEdit.toString().replaceFirst(".0", "");
    }

    _focusNode.requestFocus();
    super.initState();
  }

  String displayIdentifier = "";
  double insets = 0;
  TextInputType keyboard = TextInputType.text;
  List<TextInputFormatter> currentInputFormatters = [];

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;


      if (widget.identifier == "Name") {
      insets = screenWidth * 0.10;
      currentInputFormatters = [LengthLimitingTextInputFormatter(27)];
    }
     else if (widget.identifier == "LB" || widget.identifier == "resultsLB") {
      insets = screenWidth * 0.38;
      keyboard = const TextInputType.numberWithOptions(decimal: true);
      currentInputFormatters = [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')), LengthLimitingTextInputFormatter(5)];
    }
    else if (widget.identifier == "SETS") {
      insets = screenWidth * 0.38;
      keyboard = const TextInputType.numberWithOptions();
      currentInputFormatters = [FilteringTextInputFormatter.allow(RegExp(r'^\d*\-?\d*')), LengthLimitingTextInputFormatter(1)];
    }
    else if (widget.identifier == "RIR") {
      insets = screenWidth * 0.38;
      keyboard = const TextInputType.numberWithOptions(signed: true);
      currentInputFormatters = [FilteringTextInputFormatter.allow(RegExp(r'^\d*\-?\d*')), LengthLimitingTextInputFormatter(3)];
    }
    else if (widget.identifier == "resultsRIR") {
      insets = screenWidth * 0.38;
      keyboard = TextInputType.number;
      currentInputFormatters = [FilteringTextInputFormatter.allow(RegExp(r'^[0-9]+$')), LengthLimitingTextInputFormatter(2)];
    }
    else if (widget.identifier == "resultsREPS") {
      insets = screenWidth * 0.38;
      keyboard = TextInputType.number;
      currentInputFormatters = [FilteringTextInputFormatter.allow(RegExp(r'^[0-9]+$')), LengthLimitingTextInputFormatter(2)];
    }
    else if (widget.identifier.contains("Day")) {
      insets = screenWidth * 0.10;
      currentInputFormatters = [LengthLimitingTextInputFormatter(20)];
      displayIdentifier = widget.identifier;
    }
    else if (widget.identifier == "Week Name") {
      insets = screenWidth * 0.10;
      currentInputFormatters = [LengthLimitingTextInputFormatter(15)];
    }
    else {
      insets = screenWidth * 0.35;
      keyboard = const TextInputType.numberWithOptions(signed: true);
      currentInputFormatters = [FilteringTextInputFormatter.allow(RegExp(r'^\d*\-?\d*')), LengthLimitingTextInputFormatter(5)];
    }

      return PopScope(
        onPopInvokedWithResult: (bool didPop, dynamic result) {
          setState(() {
            if (dialogController.text.trim() != ""){
              if (widget.identifier == "LB") {
                widget.editData(dialogController.text, widget.identifier);
              }
              if (widget.identifier.contains("result")) {
                if (widget.identifier.contains("LB")) {
                  widget.editData(
                      double.parse(dialogController.text), widget.identifier);
                } else {
                  widget.editData(
                      int.parse(dialogController.text), widget.identifier);
                }
              }
            }
          });
        },
        child: Dialog(
            insetPadding: EdgeInsets.symmetric(horizontal: insets),
                  child: Container(
                               decoration: BoxDecoration(
                                   borderRadius: BorderRadius.circular(10.0),
                                   gradient: Styles.horizontal()
                               ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.only(left: 5),
                                    height: 34.5,
                                    child: Text("${AppSettings.selectedUnit == "KG" && displayIdentifier == "LB" ? "KG" : displayIdentifier}: ", style: Styles.smallTextWhite),
                                  ),
                                  Expanded(
                                    child: TextField(
                                      keyboardType: keyboard,
                                      onSubmitted: (value) {
                                        if (dialogController.text.trim() != "" && !widget.identifier.contains("Day")) {

                                            if (widget.identifier == "SETS") {
                                              widget.editData(int.parse(dialogController.text), widget.identifier);
                                            }
                                            else {
                                              widget.editData(dialogController.text, widget.identifier);
                                          }
                                        }
                                        else {
                                          widget.editData(dialogController.text, widget.identifier.replaceAll(RegExp(r'[^0-9]'), ''));
                                        }
                                        Navigator.of(context).pop();
                                      },
                                      decoration: const InputDecoration(
                                        border: InputBorder.none, // Remove the underline
                                      ),
                                      style: Styles.regularText,
                                      focusNode: _focusNode,
                                      inputFormatters: currentInputFormatters,
                                      controller: dialogController,
                                      cursorColor: Colors.white,
                                    ),
                                  ),
                                ],
                              )
                           ),
              ),
      );
  }
}


class EditDay extends StatefulWidget {
  final day thisDay;
  final Function() refresh;

  const EditDay({required this.thisDay, required this.refresh});
  @override
  State<EditDay> createState() => _EditDayState();
}

class _EditDayState extends State<EditDay> {
  final FocusNode _focusNode = FocusNode();
  TextEditingController dialogController = TextEditingController();

@override
  void initState() {
  widget.thisDay.muscleGroups ??= [];
  dialogController.text = widget.thisDay.name;
super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        widget.refresh();
        widget.thisDay.name = dialogController.text;
        ProgramsPage.programsList[ProgramsPage.activeProgramIndex].save();
      },
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),

        child: Container(
          height: 450,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              gradient: Styles.darkGradient()
          ),
          child: Column(
                  children: [
                    Container(
                      height: 60,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: Styles.primaryColor,
                          borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(20),
                              topLeft: Radius.circular(20)
                          ),
                          border: const Border(
                              bottom: BorderSide(
                                  color: Colors.black54,
                                  width: 3
                              )
                          )
                      ),
                      padding: const  EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child:  TextFormField(
                          onTap: () {
                            setState(() {

                            });
                          },
                          inputFormatters: [LengthLimitingTextInputFormatter(27)],
                          controller: dialogController,
                          focusNode: _focusNode,
                          cursorColor: Colors.white,
                          decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Day name...',
                              hintStyle: Styles.smallTextWhite
                          ),
                          style: Styles.regularText,
                          textAlign: _focusNode.hasFocus ? TextAlign.left : TextAlign.center
                      ),
                    ),
                    const SizedBox(height: 40),
                    const Text("Muscle groups:", style: Styles.paragraph),
                    Expanded(
                      child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: const BoxDecoration(
                              color: Colors.black12,
                              borderRadius: BorderRadius.only(
                                  bottomRight: Radius.circular(20),
                                  bottomLeft: Radius.circular(20)
                              ),
                              border: Border(
                                top: BorderSide(
                                    color: Colors.white54,
                                    width: 1.5
                                ),
                              )
                          ),
                          child: Column(
                            children: [
                              Center(
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _focusNode.unfocus();
                                      widget.thisDay.muscleGroups = [];
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                    decoration: BoxDecoration(
                                        color: Colors.black12,
                                        borderRadius: const BorderRadius.all(Radius.circular(20)),
                                        border: Border.all(
                                            color: widget.thisDay.muscleGroups!.isEmpty ? Colors.white : Colors.white54
                                        )
                                    ),
                                    child: Text("Any", style: Styles.paragraph.copyWith(color: widget.thisDay.muscleGroups!.isEmpty ? Colors.white : Colors.white54)),
                                  ),
                                ),
                              ),
                              if (MuscleGroups.muscleGroupsList.isNotEmpty)...[
                                Expanded(
                                  child: GridView.builder(
                                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),

                                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                        mainAxisExtent: 45,
                                        crossAxisCount: 2,
                                        crossAxisSpacing: 20,
                                        mainAxisSpacing: 20,
                                      ),
                                      itemCount: MuscleGroups.muscleGroupsList.length,
                                      itemBuilder: (context, index) {
                                        return InkWell(
                                          onTap: () {
                                            setState(() {
                                              _focusNode.unfocus();
                                              if (!widget.thisDay.muscleGroups!.contains(MuscleGroups.muscleGroupsList[index])) {
                                                widget.thisDay.muscleGroups!.add(MuscleGroups.muscleGroupsList[index]);
                                              }
                                              else {
                                                widget.thisDay.muscleGroups!.remove(MuscleGroups.muscleGroupsList[index]);
                                              }
                                            });
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(10.0),
                                              border: Border.all(
                                                color: widget.thisDay.muscleGroups!.contains(MuscleGroups.muscleGroupsList[index]) ? Colors.white : Colors.white54,
                                                width: 2.0,
                                              ),
                                            ),
                                            child: Center(
                                              child: Text(
                                                  MuscleGroups.muscleGroupsList[index],
                                                  textAlign: TextAlign.center,
                                                  style: Styles.paragraph.copyWith(color: widget.thisDay.muscleGroups!.contains(MuscleGroups.muscleGroupsList[index]) ? Colors.white : Colors.white54)
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                  ),
                                ),
                              ]
                              else ...[
                                Text(MuscleGroups.muscleGroupsList.isEmpty ? "No muscle groups found." : "", style: Styles.smallTextWhite),
                                const Spacer(),
                              ]
                            ],
                          )
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}


class OneRMCalculator extends StatefulWidget {

  @override
  State<OneRMCalculator> createState() => _OneRMCalculatorState();
}

class _OneRMCalculatorState extends State<OneRMCalculator> {
 TextEditingController weightController = TextEditingController();
 TextEditingController repsController = TextEditingController();
 double oneRepMax = 0;
 String selectedFormula = "Brzycki's formula";

 double calculate1RM (double weight, double reps, String formula) {
   double sum = 0;

   if (weight != 0 && reps != 0) {
     switch (formula) {
       case "Epley's formula":
         sum = weight * (1 + 0.0333 * reps);
         break;

       case "Lander's formula":
         sum = (100 * weight) / (101.3 - (2.67123 * reps));
         break;

       case "Lombardi's formula":
         sum = weight * math.pow(reps, 0.1);
         break;

       case "Brzycki's formula":
         sum = weight / (1.0278 - (0.0278 * reps));
         break;
     }
   }

   return  sum;
 }

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Material(
            borderRadius: BorderRadius.circular(20),
            child: Container(
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
                                 margin: const EdgeInsets.only(bottom: 25),
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
                                     child: Text("1RM calculator", style: Styles.regularText, textAlign: TextAlign.center),
                                 ),
                               ),
                              Material(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 50),
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    gradient: Styles.darkGradient()
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Text("1RM formula:", style: Styles.smallTextWhite.copyWith(color: Colors.white)),
                                          const Spacer(),
                                          DropdownButton(
                                              value: selectedFormula,
                                              style: Styles.smallTextWhite,
                                              dropdownColor: Styles.primaryColor,
                                              items: const [
                                                DropdownMenuItem(value: "Brzycki's formula", child: Text("Brzycki's formula")),
                                                DropdownMenuItem(value: "Lombardi's formula", child: Text("Lombardi's formula")),
                                                DropdownMenuItem(value: "Lander's formula", child: Text("Lander's formula")),
                                                DropdownMenuItem(value: "Epley's formula", child: Text("Epley's formula"))
                                              ], onChanged: (value) {
                                            setState(() {
                                              selectedFormula = value!;
                                              oneRepMax = calculate1RM(double.parse(weightController.text != "" ? weightController.text : "0"), double.parse(repsController.text != "" ? repsController.text : "0"), selectedFormula);
                                            });
            
                                          }
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 30),
                                       TextFormField(
                                         keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                         controller: weightController,
                                            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')), LengthLimitingTextInputFormatter(5)],
                                            style: Styles.regularText,
                                            onChanged: (value) {
                                           setState(() {
                                             oneRepMax = calculate1RM(double.parse(weightController.text != "" ? weightController.text : "0"), double.parse(repsController.text != "" ? repsController.text : "0"), selectedFormula);
                                           });
                                            },
                                            decoration: const InputDecoration(
                                              labelText: 'Weight',
                                              labelStyle: Styles.smallTextWhite,
                                              contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 0), // set padding to minimum
                                              focusedBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(color: Colors.white)
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(color: Colors.white60), // Change underline color when not selected
                                              ),
                                            ),
                                            cursorColor: Colors.white,
                                          ),
                                       const SizedBox(height: 20),
                                       TextFormField(
                                         keyboardType: TextInputType.number,
                                         controller: repsController,
                                         inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^[0-9]+$')), LengthLimitingTextInputFormatter(2)],
                                        style: Styles.regularText,
                                         onChanged: (value) {
                                           setState(() {
                                             oneRepMax = calculate1RM(double.parse(weightController.text != "" ? weightController.text : "0"), double.parse(repsController.text != "" ? repsController.text : "0"), selectedFormula);
                                           });
                                         },
                                        decoration: const InputDecoration(
                                          labelText: 'Reps',
                                          labelStyle: Styles.smallTextWhite,
                                          contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 0), // set padding to minimum
                                          focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(color: Colors.white)
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.white60), // Change underline color when not selected
                                          ),
                                        ),
                                        cursorColor: Colors.white,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Divider(height: 15),
                              Center(
                                         child: Text(oneRepMax.toStringAsFixed(oneRepMax.truncateToDouble() == oneRepMax ? 0 : 1), style: Styles.regularText, textAlign: TextAlign.center),
                                      ),
                            ],
                          ),
                          Positioned(left: 0, top: 7,
                            child: IconButton(onPressed: () {
                              Navigator.of(context).pop();
                            },
                                icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 24)),
                          ),
                          const Positioned(bottom: 30.0, left: 5,
                              child: Text("Calculated 1RM:", style: Styles.smallTextWhite,))
                        ],
                      ),
                ),
          ),
        ],
      ),
    );
  }
}


class CreateEntry extends StatefulWidget {
  final Function(ResultSetBlock) addResultSetBlock;

  const CreateEntry({required this.addResultSetBlock});
  @override
  State<CreateEntry> createState() => _CreateEntryState();
}

class _CreateEntryState extends State<CreateEntry>{
  ResultSetBlock thisResultSetBlock = ResultSetBlock(date: DateTime.now(), resultSets: []);
  int wheelSliderValue = 3;

  @override
  Widget build(BuildContext context) {
    for (int i = thisResultSetBlock.resultSets.length; i < wheelSliderValue; i ++) {
      thisResultSetBlock.resultSets.add(ResultSet(reps: 0,
          setNumber: 0,
          rir: 0,
          weight: 0,
          idForKey: 0));
    }
    if (thisResultSetBlock.resultSets.length > wheelSliderValue) {
      thisResultSetBlock.resultSets.removeAt(thisResultSetBlock.resultSets.length - 1);
    }

    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.12),
      child: SingleChildScrollView(
        child: Center(
              child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                    width: MediaQuery.of(context).size.width * 0.95,
                    child: DefaultTextStyle(
                        style: Styles.regularText,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                          Stack(
                            children: [
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.only(
                                        topRight: Radius.circular(20.0),
                                        topLeft: Radius.circular(20.0)
                                      ),
                                    border: const Border(
                                      bottom: BorderSide(
                                        color: Colors.black45,
                                        width: 3
                                      )
                                    ),
                                    gradient: Styles.darkGradient()
                                  ),
                                  child: Column(
                                        children: [
                                          const Text("NUMBER OF SETS", style: Styles.labelText, textAlign: TextAlign.center,),
                                          const Divider(color: Colors.white54, thickness: 2),
                                          WheelSlider.number(
                                            enableAnimation: false,
                                            perspective: 0.01,
                                            itemSize: 90,
                                            selectedNumberStyle: Styles.labelText.copyWith(fontSize: 35),
                                            unSelectedNumberStyle: Styles.smallTextWhite,
                                            currentIndex: wheelSliderValue,
                                            totalCount: 8,
                                            initValue: 3,
                                            onValueChanged: (val) {
                                              setState(() {
                                                wheelSliderValue = val;
                                              });
                                            },
                                            hapticFeedbackType: HapticFeedbackType.heavyImpact,
                                          ),
                                        ],
                                      ),
                              ),
                              Positioned(right: 5, top: 1,
                                  child: IconButton(onPressed: () {
                                    {
                                      for (int i = thisResultSetBlock.resultSets
                                          .length - 1; i >= 0; i--) {
                                        if (thisResultSetBlock.resultSets[i].weight ==
                                            0.0 &&
                                            thisResultSetBlock.resultSets[i].reps ==
                                                0) {
                                          thisResultSetBlock.resultSets.removeAt(i);
                                        }
                                      }
                                      if (thisResultSetBlock.resultSets.isNotEmpty) {
                                        widget.addResultSetBlock(thisResultSetBlock);
                                      }
                                      Navigator.of(context).pop();
                                    }
                                  }, icon: const Icon(Icons.arrow_circle_right, size: 30, color: Colors.white))),
                            ],
                          ),
                          SingleChildScrollView(
                            child: Container(
                              constraints: const BoxConstraints(
                                maxHeight: 250
                              ),
                              decoration: BoxDecoration(
                                gradient: Styles.darkGradient()
                              ),
                              child: ListView.builder(
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                  itemCount: wheelSliderValue,
                                  itemBuilder: (context, index) {
                                    return Card(
                                      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                        color: Styles.secondaryColor,
                                      child: Row(
                                        children: [
                                          SizedBox(width: 100, child: Text("SET ${index + 1}: ", style: Styles.labelText)),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: TextFormField(
                                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')), LengthLimitingTextInputFormatter(5)],
                                                onChanged: (value) {
                                                  if (value != "") {
                                                    thisResultSetBlock.resultSets[index].weight = double.parse(value);
                                                  }
                                                },
                                                style: Styles.regularText,
                                                decoration: InputDecoration(
                                                  labelText: AppSettings.selectedUnit,
                                                  labelStyle: Styles.smallTextWhite,
                                                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0), // set padding to minimum
                                                  focusedBorder: const OutlineInputBorder(
                                                      borderSide: BorderSide(color: Colors.white)
                                                  ),
                                                  enabledBorder: const OutlineInputBorder(
                                                    borderSide: BorderSide(color: Colors.white60), // Change underline color when not selected
                                                  ),
                                                ),
                                                cursorColor: Colors.white,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: TextFormField(
                                                keyboardType: TextInputType.number,
                                                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^[0-9]+$')), LengthLimitingTextInputFormatter(2)],
                                                onChanged: (value) {
                                                  if (value != "") {
                                                    thisResultSetBlock.resultSets[index].reps = int.parse(value);
                                                  }
                                                },
                                                style: Styles.regularText,
                                                decoration: const InputDecoration(
                                                  labelText: 'REPS',
                                                  labelStyle: Styles.smallTextWhite,
                                                  contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 0), // set padding to minimum
                                                  focusedBorder: OutlineInputBorder(
                                                      borderSide: BorderSide(color: Colors.white)
                                                  ),
                                                  enabledBorder: OutlineInputBorder(
                                                    borderSide: BorderSide(color: Colors.white60), // Change underline color when not selected
                                                  ),
                                                ),
                                                cursorColor: Colors.white,
                                              ),
                                            ),
                                          ),
                                          if (AppSettings.rirActive) Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: TextFormField(
                                                keyboardType: TextInputType.number,
                                                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^[0-9]+$')), LengthLimitingTextInputFormatter(2)],
                                                onChanged: (value) {
                                                  if (value != "") {
                                                    thisResultSetBlock.resultSets[index].rir = int.parse(value);
                                                  }
                                                },
                                                style: Styles.regularText,
                                                decoration: const InputDecoration(
                                                  labelText: 'RIR',
                                                  labelStyle: Styles.smallTextWhite,
                                                  contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                                                  focusedBorder: OutlineInputBorder(
                                                      borderSide: BorderSide(color: Colors.white)
                                                  ),
                                                  enabledBorder: OutlineInputBorder(
                                                    borderSide: BorderSide(color: Colors.white60), // Change underline color when not selected
                                                  ),
                                                ),
                                                cursorColor: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    );
                                  }
                              ),
                            ),
                          ),
                                ],
                              ),
                  )
                 )
              ),
      ),
    );

  }
}



class DuplicationDialog extends StatelessWidget {
final int indexOfWeekToDuplicate;
const DuplicationDialog({required this.indexOfWeekToDuplicate});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Styles.primaryColor,
      content: Text("Are you sure you want to duplicate this week? This will overwrite the content of all the subsequent weeks in this program.", style: Styles.paragraph.copyWith(color: Colors.white)),

    actions: [
        TextButton(
          onPressed: () {
            Program currentProgram = ProgramsPage.programsList[ProgramsPage.activeProgramIndex];


            // iterates through the weeks
            for(int i = 0; i < currentProgram.weeks.length; i ++){
              if (i > indexOfWeekToDuplicate) {
                Week newWeek = Week(
                    name: currentProgram.weeks[i].name, days: []);
                // iterates through the days
                for (int j = 0; j <
                    currentProgram.weeks[indexOfWeekToDuplicate].days
                        .length; j ++) {
                  List <Movement> todaysMovements = [];

                  // iterates through the movements
                  for (int x = 0; x <
                      currentProgram.weeks[indexOfWeekToDuplicate].days[j]
                          .movements.length; x++) {
                    todaysMovements.add(Movement(
                        resultSets: [],
                        superset: currentProgram.weeks[indexOfWeekToDuplicate]
                            .days[j].movements[x].superset,
                        notes: "",
                        name: currentProgram.weeks[indexOfWeekToDuplicate]
                            .days[j].movements[x].name,
                        sets: currentProgram.weeks[indexOfWeekToDuplicate]
                            .days[j].movements[x].sets,
                        reps: currentProgram.weeks[indexOfWeekToDuplicate]
                            .days[j].movements[x].reps,
                        rir: currentProgram.weeks[indexOfWeekToDuplicate]
                            .days[j].movements[x].rir,
                        weight: currentProgram.weeks[indexOfWeekToDuplicate]
                            .days[j].movements[x].weight,
                        rest: currentProgram.weeks[indexOfWeekToDuplicate]
                            .days[j].movements[x].rest,
                        remainingRestTime: currentProgram
                            .weeks[indexOfWeekToDuplicate].days[j].movements[x]
                            .rest));
                  }

                  newWeek.days.add(day(
                    id: ProgramsPage.globalDayID ++,
                    // I could do this if I want the days to keep the same ID "currentProgram.weeks[0].days[j].ID"
                    name: currentProgram.weeks[indexOfWeekToDuplicate].days[j]
                        .name,
                    movements: todaysMovements,
                    muscleGroups: currentProgram.weeks[indexOfWeekToDuplicate]
                        .days[j].muscleGroups?.toList(),
                  ));
                }
                currentProgram.weeks[i] = newWeek;
              }
            }
            ProgramsPage.setDayIDPref();
            Navigator.of(context).pop();
            currentProgram.save();
          },
          child: const Text('Yes', style: Styles.regularText),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('No', style: Styles.regularText),
        ),
      ],
    );
  }
}


class ConfirmationDialog extends StatelessWidget {
  final String content;
  final Function() callbackFunction;

  const ConfirmationDialog({required this.content, required this.callbackFunction});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Styles.primaryColor,
      content: Text(content, style: Styles.paragraph.copyWith(color: Colors.white)),
      actions: [
        TextButton(
          onPressed: () {
            callbackFunction();
            Navigator.of(context).pop();
          },
          child: const Text('Yes', style: Styles.regularText),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('No', style: Styles.regularText),
        ),
      ],
    );
  }
}

class AddPreset extends StatelessWidget {
  final Function(Program) updateCallback;
  final Program thisProgram;

   const AddPreset({required this.updateCallback, required this.thisProgram});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Styles.primaryColor,
      content: Text("Would you like to automatically fill your '${thisProgram.name}' program with movements?", style: Styles.paragraph.copyWith(color: Colors.white)),
      actions: [
        TextButton(
          onPressed: () {
            for(int i = 0; i < thisProgram.weeks.length; i ++) {
              for (int j = 0; j < thisProgram.weeks[i].days.length; j ++) {
                thisProgram.weeks[i].days[j].id = ProgramsPage.globalDayID ++;
              }
            }


              for (int weekIndex = 0; weekIndex < thisProgram.weeks.length; weekIndex++) {

                for (int dayIndex = 0; dayIndex < thisProgram.weeks[weekIndex].days.length; dayIndex++) {

                  for (int movementIndex = 0; movementIndex < thisProgram.weeks[weekIndex].days[dayIndex].movements.length; movementIndex++) {
                    if (!LogPage.movementsLogged.any((movementLog) => movementLog.name.replaceAll(RegExp(r'\s+'), '').toLowerCase() == thisProgram.weeks[weekIndex].days[dayIndex].movements[movementIndex].name.replaceAll(RegExp(r'\s+'), '').toLowerCase())) {
                      LogPage.movementsLogged.add(MovementLog(
                          date: DateTime.now(),
                          name: thisProgram.weeks[weekIndex].days[dayIndex].movements[movementIndex].name,
                          primaryMuscleGroups: thisProgram.weeks[weekIndex].days[dayIndex].movements[movementIndex].primaryMuscleGroups?.toList(),
                          secondaryMuscleGroups: thisProgram.weeks[weekIndex].days[dayIndex].movements[movementIndex].secondaryMuscleGroups?.toList(),
                          resultSetBlocks: [],
                          notes: "",
                          favorited: false));
                        Boxes.getMovementLogs().add(LogPage.movementsLogged.last);
                    }
                  }
                }
              }


            ProgramsPage.setDayIDPref();
            updateCallback(thisProgram);
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
          child: const Text('Yes', style: Styles.regularText),
        ),
        TextButton(
          onPressed: () {
            for(int i = 0; i < thisProgram.weeks.length; i ++) {
              for (int j = 0; j < thisProgram.weeks[i].days.length; j ++) {
                thisProgram.weeks[i].days[j].id = ProgramsPage.globalDayID ++;
              }
            }



            ProgramsPage.setDayIDPref();
            updateCallback(removeMovements(thisProgram));
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
          child: const Text('No', style: Styles.regularText),
        ),
      ],
    );
  }
}

Program removeMovements(thisProgram) {
  for (int weekIndex = 0; weekIndex < thisProgram.weeks.length; weekIndex++) {

    for (int dayIndex = 0; dayIndex < thisProgram.weeks[weekIndex].days.length; dayIndex++) {

      for (int movementIndex = thisProgram.weeks[weekIndex].days[dayIndex].movements.length - 1; movementIndex >= 0; movementIndex--) {
        thisProgram.weeks[weekIndex].days[dayIndex].movements.removeAt(movementIndex);
      }
    }
  }

  return thisProgram;
}

/*
class NotesDialog extends StatefulWidget {
  final String notes;
  final int index;
  final Function(String, int) editNote;

  const NotesDialog({required this.index, required this.notes, required this.editNote});

  @override
  _NotesDialogState createState() => _NotesDialogState();
}

class _NotesDialogState extends State<NotesDialog> {
  TextEditingController notesTextController = TextEditingController();
  FocusNode notesFocusNode = FocusNode();

  @override
  void initState() {
    if(widget.notes.trim() != "") {
      notesTextController.text = widget.notes;
    }
    notesFocusNode.requestFocus();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return PopScope(
      onPopInvoked: (bool didPop) {
        widget.editNote(notesTextController.text, widget.index);
      },
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Container(
          height: 300,
          width: 500,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            gradient: myStyles.horizontal(),
          ),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      gradient: myStyles.darkGradient(),
                      borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(20.0),
                          topLeft: Radius.circular(20.0)
                      ),
                      border: const Border(
                          bottom: BorderSide(
                              width: 3,
                              color: Colors.black45
                          )
                      )
                  ),
                  child: const Text("Notes", style: myStyles.labelText, textAlign: TextAlign.center)),
              Expanded(
                child: ListView(
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                      maxLines: null,
                      controller: notesTextController,
                      focusNode: notesFocusNode,
                      style: myStyles.regularText,
                      cursorColor: Colors.white,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

*/