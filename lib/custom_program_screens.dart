import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gym_app/home_screen.dart';
import 'package:gym_app/programs_page.dart';
import 'package:wheel_slider/wheel_slider.dart';
import 'main.dart';
import 'preset_programs.dart';
import 'package:shared_preferences/shared_preferences.dart';


class CustomProgramScreens extends StatefulWidget {
  final Function (Program) updateProgramList;
  const CustomProgramScreens({required this.updateProgramList});


  @override
  State<CustomProgramScreens> createState() => _CustomProgramScreensState();
}

class _CustomProgramScreensState extends State<CustomProgramScreens> {
  final FocusNode _focusNode = FocusNode();
  final FocusNode _focusNode2 = FocusNode();


  int currentValueWeeksWheel = 0; // for the wheel slider
  List <String> dayNames = [];
  List <List<String>> daysMuscleGroups = [[], [], [], [], [], [], []];
  int num = 1; // this is for when the user is choosing the day names so you can keep track of the day they're picking
  int activePage = 1;

  TextEditingController myController = TextEditingController();

@override
  void dispose() {
   myController.dispose();
     _focusNode.dispose();
    _focusNode2.dispose();
    super.dispose();
  }


  void createProgram(numberOfWeeksInProgram, programName, dayNames) {
    List<Week> weeks = [];
    List<day> days = [];

    int weekMultiplier = 0;

    for (int i = 0; i < numberOfWeeksInProgram; i++) {
      for (int j = 0; j < 7; j++) {
        days.add(day(name: dayNames[j], movements: [], id: ProgramsPage.globalDayID ++, muscleGroups: daysMuscleGroups[j]));
      }

      List<day> weekDays = days.sublist((7 * weekMultiplier)); // this is so that you don't add the entire days array to each week in "Weeks.add"
      weeks.add(Week(name: "Week ${i + 1}", days: weekDays));
      weekMultiplier++;
    }
    ProgramsPage.setDayIDPref();
widget.updateProgramList(
        Program(
        weeks: weeks,
        name: programName,
        date: DateTime.now()
       ));
  }

double borderWidth3 = 4;
double borderWidth2 = 4;
double borderWidth1 = 4;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
           backgroundColor: Styles.primaryColor,
            automaticallyImplyLeading: false,
              iconTheme: const IconThemeData(color: Colors.white),
              title: (const Text("Custom Program", style: Styles.labelText)),
            shape: const Border(
              bottom: BorderSide(
                color: Colors.black45,
                width: 2,
              ),
            ),
            shadowColor: Colors.black54,
            flexibleSpace: Container(
              color: Styles.primaryColor.withOpacity(1.0),
            ),
          ),
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: Styles.horizontal()
            ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.06),
                  if(activePage == 1) ...[
                    Container(
                        alignment: Alignment.center,
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        height: MediaQuery.of(context).size.height * 0.55,
                        decoration: BoxDecoration(
                          border: const Border(
                              bottom: BorderSide(
                                  color: Colors.black54,
                                  width: 2
                              )
                          ),
                          borderRadius: BorderRadius.circular(20.0),
                          gradient: Styles.darkGradient(),
                        ),
                        child: Column(
                            children: [
                              Container(
                          width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            decoration: BoxDecoration(
                              border: const Border(
                                bottom: BorderSide(
                                  color: Colors.black,
                                  width: 4
                                )
                              ),
                               borderRadius: const BorderRadius.only(
                                 topLeft: Radius.circular(20),
                                 topRight: Radius.circular(20)
                               ),
                              color: Styles.secondaryColor,
                            ),
                            child: Text("Day $num:", style: Styles.regularText, textAlign: TextAlign.center)),
                              const SizedBox(height: 20),
                              InkWell(
                                  onTap: () {
                                    _focusNode.requestFocus();
                              },
                                  child: const Text("Name:", style: Styles.paragraph)),
                              Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: const BoxDecoration(
                              color: Colors.black12,
                              borderRadius: BorderRadius.only(
                                bottomRight: Radius.circular(5),
                                bottomLeft: Radius.circular(5)
                              ),
                              border: Border(
                              top: BorderSide(
                                color: Colors.white54,
                                width: 1.5
                              ),
                            )
                          ),
                          child: EditableText(
                           textAlign: TextAlign.center,
                           inputFormatters: [LengthLimitingTextInputFormatter(20)],
                           onChanged: (text) {
                             setState(() {}); // this is so it updates the button from 'skip' to 'next' and vice versa
                             if(PresetPrograms.easterEggDiscovered == false && text.toLowerCase() == "zoe’s program please") {
                               PresetProgramsState.addZoesProgram();
                               Program thisProgram = PresetProgramsState.programsList.last;
                               for(int i = 0; i < thisProgram.weeks.length; i ++) {
                                 for (int j = 0; j < thisProgram.weeks[i].days.length; j ++) {
                                   thisProgram.weeks[i].days[j].id = ProgramsPage.globalDayID ++;
                                 }
                               }
                               ProgramsPage.setDayIDPref();
                               widget.updateProgramList(thisProgram);
                               () async {
                                 SharedPreferences prefs = await SharedPreferences.getInstance();
                                 prefs.setBool("easterEggDiscovered", true);
                               }();
                               PresetPrograms.easterEggDiscovered = true;
                               Navigator.of(context).pop();
                               ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                   backgroundColor: Colors.white,
                                   content: Text("Easter egg 'Zoe's Program' has been added!", style: TextStyle(color: Styles.primaryColor)),
                                   duration: const Duration(milliseconds: 3000),
                                 ),
                               );
                             }
                           },
                           controller: myController,
                           focusNode: _focusNode,
                           cursorColor: Colors.white,
                           style: Styles.regularText,
                           backgroundCursorColor: Colors.white,
                             ),
                        ),
                              const SizedBox(height: 50),
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
                                              daysMuscleGroups[num - 1] = [];
                                            });
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                            decoration: BoxDecoration(
                                              color: Colors.black12,
                                              borderRadius: const BorderRadius.all(Radius.circular(20)),
                                              border: Border.all(
                                                color: daysMuscleGroups[num - 1].isEmpty ? Colors.white : Colors.white54
                                              )
                                            ),
                                            child: Text("Any", style: Styles.paragraph.copyWith(color: daysMuscleGroups[num - 1].isEmpty ? Colors.white : Colors.white54)),
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

                                                      if (!daysMuscleGroups[num - 1].contains(MuscleGroups.muscleGroupsList[index])) {
                                                        daysMuscleGroups[num - 1].add(MuscleGroups.muscleGroupsList[index]);
                                                      }
                                                      else {
                                                        daysMuscleGroups[num - 1].remove(MuscleGroups.muscleGroupsList[index]);
                                                      }
                                                    });
                                                  },
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(10.0),
                                                      border: Border.all(
                                                        color: daysMuscleGroups[num - 1].contains(MuscleGroups.muscleGroupsList[index]) ? Colors.white : Colors.white54,
                                                        width: 2.0,
                                                      ),
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                          MuscleGroups.muscleGroupsList[index],
                                                          textAlign: TextAlign.center,
                                                          style: Styles.paragraph.copyWith(color: daysMuscleGroups[num - 1].contains(MuscleGroups.muscleGroupsList[index]) ? Colors.white : Colors.white54)
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
                            ]
                        )
                     ),
                    const Spacer()
                  ],
                  if(activePage < 2) ... [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        if (num > 1) GestureDetector(
                          onTapUp: (b) {
                            setState(() {
                              borderWidth3 = 4;
                            });
                          },
                          onTapDown: (b) {
                            setState(() {
                              borderWidth3 = 2 ;
                              //_focusNode.requestFocus();
                              //_focusNode2.requestFocus();
                              num --;
                              myController.text = dayNames.last;
                              dayNames.removeLast();
                              daysMuscleGroups[num] = [];
                            });
                          },
                          child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                              decoration: BoxDecoration(
                                gradient: Styles.horizontal(),
                                border: Border(
                                    bottom: BorderSide(
                                        color: Colors.black54,
                                        width: borderWidth3 + 1
                                    ),
                                    left: BorderSide(
                                        color: Colors.black54,
                                        width: borderWidth3
                                    ),
                                    right: BorderSide(
                                        color: Colors.black54,
                                        width: borderWidth3
                                    )

                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text("Back", style: Styles.labelText)),
                        ),
                        GestureDetector(
                          onTapUp: (b) {
                            setState(() {
                              borderWidth1 = 4;
                            });
                          },
                           onTapDown: (b) {
                            setState(() {
                              borderWidth1 = 2;
                              //_focusNode.requestFocus();
                              //_focusNode2.requestFocus();

                                  if(num <= 7) {
                                    if (myController.text != "") {
                                      dayNames.add(myController.text);
                                      myController.text = "";
                                      num ++;
                                    }
                                    else if (daysMuscleGroups[num - 1].isNotEmpty) {

                                    }
                                    else {
                                      dayNames.add("Rest");
                                      myController.text = "";
                                      num ++;
                                    }
                                  }

                                  if (num > 7) {
                                    activePage ++;
                                  }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                            decoration: BoxDecoration(
                              gradient: Styles.horizontal(),
                              border: Border(
                                bottom: BorderSide(
                                    color: Colors.black54,
                                    width: borderWidth1 + 1
                                ),
                                left: BorderSide(
                                    color: Colors.black54,
                                    width: borderWidth1
                                ),
                                right: BorderSide(
                                    color: Colors.black54,
                                    width: borderWidth1
                                )

                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                              child: Text(num <= 7 && myController.text == "" && daysMuscleGroups[num - 1].isEmpty ? 'Skip' : 'Next', style: Styles.labelText)),
                        ),
                      ],
                    ),
                    const Spacer()
                  ],
                  if(activePage == 2) ... [
                    Container(
                        alignment: Alignment.center,
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        height: MediaQuery.of(context).size.height * 0.18,
                        decoration: BoxDecoration(
                            border: const Border(
                                bottom: BorderSide(
                                    color: Colors.black54,
                                    width: 2
                                )
                            ),
                            borderRadius: BorderRadius.circular(20.0),
                            gradient: Styles.darkGradient()
                        ),
                        child: Column(
                            children: [
                              Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  decoration: BoxDecoration(
                                    border: const Border(
                                        bottom: BorderSide(
                                            color: Colors.black,
                                            width: 4
                                        )
                                    ),
                                    borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(20),
                                        topRight: Radius.circular(20)
                                    ),
                                    color: Styles.secondaryColor,
                                  ),
                                  child: Text("Name Your Program", style: Styles.regularText.copyWith(fontSize: 18), textAlign: TextAlign.center)
                              ),
                              const Spacer(),
                              const Text("Title:", style: Styles.smallTextWhite),
                              const Divider(color: Colors.white54),
                              EditableText(
                                textAlign: TextAlign.center,
                                inputFormatters: [LengthLimitingTextInputFormatter(27)],
                                controller: myController,
                                focusNode: _focusNode2,
                                cursorColor: Colors.white,
                                style: Styles.regularText,
                                backgroundCursorColor: Colors.white,
                              ),
                              const SizedBox(height: 8),
                            ]
                        )
                    ),
                    const Spacer(),
                    Container(
                        alignment: Alignment.center,
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        height: MediaQuery.of(context).size.height * 0.18,
                        decoration: BoxDecoration(
                          border: const Border(
                              bottom: BorderSide(
                                  color: Colors.black54,
                                  width: 2
                              )
                          ),
                          borderRadius: BorderRadius.circular(20.0),
                          gradient: Styles.darkGradient()
                        ),
                        child: Column(
                            children: [
                              Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  decoration: BoxDecoration(
                                    border: const Border(
                                        bottom: BorderSide(
                                            color: Colors.black,
                                            width: 4
                                        )
                                    ),
                                    borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(20),
                                        topRight: Radius.circular(20)
                                    ),
                                    color: Styles.secondaryColor,
                                  ),
                                  child: Text("Number of weeks in program", textAlign: TextAlign.center, style: Styles.regularText.copyWith(fontSize: 18)),
                              ),
                              Expanded(
                                child: WheelSlider.number(
                                  perspective: 0.01,
                                  totalCount: 14,
                                  initValue: 0,
                                  itemSize: 70,
                                  selectedNumberStyle: Styles.labelText.copyWith(fontSize: 35),
                                  unSelectedNumberStyle: Styles.smallTextWhite,
                                  currentIndex: currentValueWeeksWheel,
                                  onValueChanged: (val) {
                                    setState(() {
                                      _focusNode2.unfocus();
                                      currentValueWeeksWheel = val;
                                    });
                                  },
                                  hapticFeedbackType: HapticFeedbackType.heavyImpact,
                                ),
                              )
                            ]
                        )
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.06),
                  GestureDetector(
                    onTapUp: (b) {
                      setState(() {
                         borderWidth2 = 4;
                        });
                      },
                      onTapDown: (b) {
                        setState(() {
                          borderWidth2 = 2;
                          if (myController.text != "" && currentValueWeeksWheel != 0) {
                            createProgram(currentValueWeeksWheel, myController.text, dayNames);
                            Navigator.pop(context, true);
                          }
                        });
                      },
                        child: Container(
                          height: 60,
                        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                        decoration: BoxDecoration(
                          border: Border(
                            left: BorderSide(
                                color: Colors.black54,
                                width: borderWidth2
                            ),
                            right: BorderSide(
                                color: Colors.black54,
                                width: borderWidth2
                            ),
                            bottom: BorderSide(
                                color: Colors.black54,
                                width: borderWidth2 + 1
                            ),

                          ),
                        gradient: Styles.horizontal(),
                        borderRadius: BorderRadius.circular(20),
                        ),
                      child: const Text('Create', style: Styles.labelText)),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.08),
                  ]
                ],
               ),
          )
         );
  }
}