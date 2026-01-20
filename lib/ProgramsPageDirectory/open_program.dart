import 'package:flutter/material.dart';
import 'package:gym_app/HomePageDirectory/home_screen.dart';
import 'package:gym_app/WorkoutLogPageDirectory/workout_log.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';
import 'programs_page.dart';
import '../main.dart';
import 'movements.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../dialogs.dart';

final GlobalKey currentWeekKey = GlobalKey();
final GlobalKey daysListKey = GlobalKey();
final GlobalKey checkButtonKey = GlobalKey();
final GlobalKey weekOptionsKey = GlobalKey();
final GlobalKey dayOptionsKey = GlobalKey();
final GlobalKey addMovementKey = GlobalKey();
final GlobalKey pasteMovementKey = GlobalKey();



class OpenProgram extends StatefulWidget {
  @override
  State<OpenProgram> createState() => _OpenProgramState();
}

class _OpenProgramState extends State<OpenProgram> {
  BuildContext? drawerContext;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final CarouselSliderController _carouselController = CarouselSliderController();
  Program activeProgram = ProgramsPage.programsList[ProgramsPage.activeProgramIndex];
  int sliderIndex = 0;

  Map<String, Map<String, dynamic>> muscleGroupMap = {};
  int mapIndex = 0;
  int totalSets = 0;
  List<day> currentDaysInWeek = [];
  bool isExpanded = false;
  List sortedEntries = [];
  String chartSelection = "Muscle Groups";
  List <PieChartSectionData> repRangeSections = [];
  Map<String, int> repRangeMap = {};



  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        ShowcaseView.get().startShowCase([currentWeekKey, weekOptionsKey, daysListKey, checkButtonKey, dayOptionsKey]);
      });
    });


    outerLoop:
        for (Week week in activeProgram.weeks) {
          for (day thisDay in week.days) {
            if (!thisDay.checked) {
              sliderIndex = activeProgram.weeks.indexOf(week);
              break outerLoop;
            }
          }
        }

  }


  editWeekName(editedText, index) {
    setState(() {
      if (editedText != "") {
        activeProgram.weeks[sliderIndex].name = editedText;
        activeProgram.save();
      }

    });
  }

  initializeMuscleGroupChart() {
    totalSets = 0;
    mapIndex = 0;
    muscleGroupMap = {};



    for (var day in currentDaysInWeek) {
      for (int i = 0; i < day.movements.length; i++) {
        MovementLog thisMovementsLog = LogPage.movementsLogged.where((log) => log.name.replaceAll(RegExp(r'\s+'), '').toLowerCase() == day.movements[i].name.replaceAll(RegExp(r'\s+'), '').toLowerCase()).first;

        int sets = day.movements[i].sets;

        totalSets += sets;

        if (thisMovementsLog.primaryMuscleGroups != null) {
          for (var muscleGroup in thisMovementsLog.primaryMuscleGroups!) {
            if (!muscleGroupMap.containsKey(muscleGroup)) {
              muscleGroupMap[muscleGroup] = {'primary sets': 0, 'secondary sets': 0};
            }
            muscleGroupMap[muscleGroup]!['primary sets'] += sets;
          }

          if (thisMovementsLog.secondaryMuscleGroups != null) {
            for (var muscleGroup in thisMovementsLog.secondaryMuscleGroups!) {
              if (!muscleGroupMap.containsKey(muscleGroup)) {
                muscleGroupMap[muscleGroup] = {'primary sets': 0, 'secondary sets': 0};
              }
              muscleGroupMap[muscleGroup]!['secondary sets'] += sets;
            }
          }
        }

        if(thisMovementsLog.primaryMuscleGroups == null || thisMovementsLog.primaryMuscleGroups!.isEmpty) {
          if(!muscleGroupMap.containsKey("Unspecified")) {
            muscleGroupMap["Unspecified"] = {'primary sets': 0, 'secondary sets': 0};
          }
          muscleGroupMap["Unspecified"]!['primary sets'] += sets;
        }

      }
    }


    // get the percentages of total sets for each muscle group
    for (var entry in muscleGroupMap.entries) {
      if (muscleGroupMap.entries.length > 1) {
        if (entry.value['primary sets'] != 0) {
          entry.value['percentage'] = ((entry.value['primary sets'] + (entry.value['secondary sets'] * 0.2)) / totalSets) * 100;
        }
        else if (entry.value['secondary sets'] != 0) {
          entry.value['percentage'] = (entry.value['secondary sets'] * 0.2 / totalSets) * 100;
        }
      }
      else {
        entry.value['percentage'] = 100.0;
      }
    }
    if (muscleGroupMap.values.any((entry) => entry['percentage'] != null)) {
      sortedEntries = muscleGroupMap.entries.toList()..sort((a, b) => (b.value['percentage'] ?? 0).compareTo(a.value['percentage'] ?? 0));
    }
  }

  initializeRepRangeChart() {
    repRangeSections = [];
    repRangeMap = {};


    for (var day in currentDaysInWeek) {
      for (int i = 0; i < day.movements.length; i++) {
        int reps;

          if (day.movements[i].reps.contains('-')) {
            reps = (
                int.parse(day.movements[i].reps.split('-')[0])
                    +
                int.parse(day.movements[i].reps.split('-')[1])
                  ) ~/ 2;
          }

          else {
            reps = int.parse(day.movements[i].reps);
          }





          if (reps >= 1 && reps <= 5) {
            if (!repRangeMap.containsKey("1-5")) {
              repRangeMap["1-5"] = 0;
            }
            repRangeMap["1-5"] = (repRangeMap["1-5"] ?? 0) + day.movements[i].sets;
          }

          else if(reps >= 6 && reps <= 12) {
            if (!repRangeMap.containsKey("6-12")) {
              repRangeMap["6-12"] = 0;
            }
            repRangeMap["6-12"] = (repRangeMap["6-12"] ?? 0) + day.movements[i].sets;
          }

          else if (reps > 12) {
            if (!repRangeMap.containsKey("12+")) {
              repRangeMap["12+"] = 0;
            }
            repRangeMap["12+"] = (repRangeMap["12+"] ?? 0) + day.movements[i].sets;
          }
       }
    }
    
    
    // add map data to pie chart sections
    if (repRangeMap["1-5"] != null) {
      repRangeSections.add(
        PieChartSectionData(
          titlePositionPercentageOffset: 0.65,
          value: (repRangeMap["1-5"]! / totalSets) * 100,
          title: '1-5\nreps',
          color: Styles.secondaryColor,
          radius: MediaQuery.of(context).size.width * 0.28,
          titleStyle: Styles.paragraph.copyWith(color: Colors.white, fontSize: 12)
        ),
      );
    }

    if (repRangeMap["6-12"] != null) {
      repRangeSections.add(
        PieChartSectionData(
            titlePositionPercentageOffset: 0.65,
            value: (repRangeMap["6-12"]! / totalSets) * 100,
            title: "6-12\nreps",
            color: Color.lerp(Styles.secondaryColor, Colors.white, 0.1),
            radius: MediaQuery.of(context).size.width * 0.28,
            titleStyle: Styles.paragraph.copyWith(color: Colors.white, fontSize: 12)

        ),
      );
    }

    if (repRangeMap["12+"] != null) {
      repRangeSections.add(
        PieChartSectionData(
            titlePositionPercentageOffset: 0.65,
            value: (repRangeMap["12+"]! / totalSets) * 100,
            title: "12+\nreps",
            color: Color.lerp(Styles.secondaryColor, Colors.white, 0.2),
            radius: MediaQuery.of(context).size.width * 0.28,
            titleStyle: Styles.paragraph.copyWith(color: Colors.white, fontSize: 12)
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    currentDaysInWeek = activeProgram.weeks[sliderIndex].days;





    return Scaffold(
      resizeToAvoidBottomInset: false,
      key: _scaffoldKey,
      body: Container(
        decoration: BoxDecoration(
            gradient: Styles.horizontal(),
           ),
        child: Column(
          children: [
            Container(
                height: MediaQuery.of(context).size.height / 8,
                padding: const EdgeInsets.only(right: 5),
                width: double.infinity,
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            }, icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 27)),
                       ShowcaseTemplate(
                         radius: 5,
                            globalKey: currentWeekKey,
                            stepID: 2,
                            title: "Current Week",
                            content: "This is where the current week of your program is listed. You can swipe left and right to cycle through the weeks.",
                            child: Text(activeProgram.weeks[sliderIndex].name, style: Styles.labelText.copyWith(fontSize: 27))),
                        Spacer(),


                        ShowcaseTemplate(
                          radius: 5,
                         globalKey: weekOptionsKey,
                          stepID: 3,
                           title: "Making Changes To A Week",
                           content: "Open this menu if you would like to make changes to the current week or view metrics on its training content. \n\n (hint: use the duplication button to make quick changes to the rest of your program)",
                           child: IconButton(onPressed: () {
                            setState(() {
                              isExpanded = false;
                              initializeMuscleGroupChart();
                              initializeRepRangeChart();
                             });

                            _scaffoldKey.currentState?.openEndDrawer();
                            },
                              icon: const Icon(Icons.menu, color: Colors.white, size: 35)),
                        )
                        ],
                    ),
                  ],
                )),
            Expanded(
              child: CarouselSlider.builder(
                carouselController: _carouselController,
                options: CarouselOptions(
                  onPageChanged: (int index, CarouselPageChangedReason reason) {
                    setState(() {
                      sliderIndex = index;
                    });
                  },
                  height: double.infinity,
                  viewportFraction: 1,
                  enableInfiniteScroll: activeProgram.weeks.length > 1 ? true : false,
                  initialPage: sliderIndex,
                ),
                itemCount: activeProgram.weeks.length,
                itemBuilder: (BuildContext context, int index, int realIndex) {
                  return SliderPage(
                    currentWeekIndex: index,
                    currentProgram: activeProgram,
                    callbackFunction: () {
                      setState(() {

                      });
                    }
                  );
                },
              ),
            ),
            if(currentDaysInWeek.length < 7)...[
              InkWell(
                  onTap: () {
                    setState(() {
                      currentDaysInWeek.add(day(
                          id: ProgramsPage.globalDayID++,
                          name: "",
                          movements: []));
                      ProgramsPage.setDayIDPref();
                      activeProgram.save();
                    });
                  },
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
                      child: const Icon(Icons.add, color: Colors.white))
              ),
           const  SizedBox(height: 25),
            ],
            Container(
              height: MediaQuery.of(context).size.height / 8,
              width: double.infinity,
              padding: const EdgeInsets.only(bottom: 30, left: 15),
              decoration: BoxDecoration(
                  gradient: Styles.darkGradient(),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black54,
                    spreadRadius: 1,
                    blurRadius: 6,
                    offset: Offset(0, -3),
                  ),
                ],
              ),
              child: activeProgram.weeks.length > 1
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:
                          List.generate(activeProgram.weeks.length, (index) {
                        return Container(
                          width: 10.0,
                          height: 10.0,
                          margin: const EdgeInsets.symmetric(horizontal: 5.0),
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: sliderIndex == index
                                  ? Colors.white
                                  : Colors.white54),
                        );
                      }),
                    )
                  : const SizedBox(),
            ),
          ],
        ),
      ),

        endDrawer: Drawer(width: MediaQuery.of(context).size.width * 0.85,
            child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        gradient: Styles.horizontal(),
                      ),
                          child: Stack(
                            children: [
                              Column(
                                children: [
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    decoration: const BoxDecoration(
                                        color: Colors.black12,
                                        border: Border(
                                          top: BorderSide(
                                              color: Colors.white54,
                                          ),
                                          bottom: BorderSide(
                                            color: Colors.white54
                                          )
                                        ),
                                      ),
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.of(context).pop();
                                        copiedWeeksDays = [];
                                        for (int i = 0; i < currentDaysInWeek.length; i++) {
                                          List<Movement> newMovements = [];
                                          for (int j = 0; j < currentDaysInWeek[i].movements.length; j++) {
                                            newMovements.add(Movement(
                                                resultSets: [],
                                                superset: currentDaysInWeek[i].movements[j].superset,
                                                notes: "",
                                                name: currentDaysInWeek[i].movements[j].name,
                                                sets: currentDaysInWeek[i].movements[j].sets,
                                                reps: currentDaysInWeek[i].movements[j].reps,
                                                rir: currentDaysInWeek[i].movements[j].rir,
                                                weight: currentDaysInWeek[i].movements[j].weight,
                                                rest: currentDaysInWeek[i].movements[j].rest,
                                                remainingRestTime: currentDaysInWeek[i].movements[j].rest));
                                          }

                                          copiedWeeksDays!.add(
                                              day(
                                                  id: -1,
                                                  name: currentDaysInWeek[i].name,
                                                  muscleGroups: currentDaysInWeek[i].muscleGroups?.toList(),
                                                  movements: newMovements));
                                        }
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            backgroundColor: Colors.white,
                                            content: Text('Week copied',
                                                style: TextStyle(color: Styles.primaryColor)),
                                            duration: const Duration(milliseconds: 1500),
                                          ),
                                        );
                                      },
                                      child: const ListTile(
                                        horizontalTitleGap: 10,
                                        leading: Icon(Icons.copy,
                                            size: 35,
                                            color: Colors.white),
                                        title: Text('Copy',
                                            style: Styles.regularText),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    decoration: const BoxDecoration(
                                        color: Colors.black12,
                                        border: Border(
                                            bottom: BorderSide(
                                                color: Colors.white54
                                            )
                                        )
                                      ),
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.of(context).pop();
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return EditDialog(
                                                  dataToEdit: activeProgram.weeks[sliderIndex].name,
                                                  identifier: "Week Name",
                                                  editData: editWeekName);
                                            });
                                      },
                                      child: const ListTile(
                                        horizontalTitleGap: 10,
                                        leading: Icon(Icons.edit,
                                            size: 35,
                                            color: Colors.white),
                                        title: Text('Rename',
                                            style: Styles.regularText),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    decoration: const BoxDecoration(
                                        color: Colors.black12,
                                        border: Border(
                                            bottom: BorderSide(
                                                color: Colors.white54
                                            )
                                        )
                                    ),
                                    child: InkWell(
                                        onTap: () {
                                          Navigator.of(context).pop();
                                          if (copiedWeeksDays == null) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                backgroundColor: Colors.white,
                                                content: Text('No week copied',
                                                    style: TextStyle(
                                                        color: Styles.primaryColor)),
                                                duration:
                                                const Duration(milliseconds: 1500),
                                              ),
                                            );
                                          } else {
                                            callback () {
                                              setState(() {
                                                activeProgram.weeks[sliderIndex].days = [];

                                                for (int i = 0; i < copiedWeeksDays!.length; i++) {
                                                  activeProgram.weeks[sliderIndex].days.add(
                                                      day(id: ProgramsPage.globalDayID++,
                                                          name: copiedWeeksDays![i].name,
                                                          muscleGroups: copiedWeeksDays![i].muscleGroups,
                                                          movements: []));

                                                  for (int j = 0; j < copiedWeeksDays![i].movements.length; j++) {

                                                    activeProgram.weeks[sliderIndex].days[i].movements.add(
                                                        Movement(
                                                            resultSets: [],
                                                            superset: copiedWeeksDays![i].movements[j].superset,
                                                            notes: "",
                                                            name: copiedWeeksDays![i].movements[j].name,
                                                            sets: copiedWeeksDays![i].movements[j].sets,
                                                            reps: copiedWeeksDays![i].movements[j].reps,
                                                            rir: copiedWeeksDays![i].movements[j].rir,
                                                            weight: copiedWeeksDays![i].movements[j].weight,
                                                            rest: copiedWeeksDays![i].movements[j].rest,
                                                            remainingRestTime: copiedWeeksDays![i].movements[j].rest));
                                                  }
                                                }
                                                currentDaysInWeek = activeProgram.weeks[sliderIndex].days;

                                                ProgramsPage.setDayIDPref();
                                              });
                                              activeProgram.save();
                                            }
                                            showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return ConfirmationDialog(content:  "This will overwrite all existing data in this week. Would you like to proceed?", callbackFunction: callback);
                                                });
                                          }
                                        },
                                        child: const ListTile(
                                          horizontalTitleGap: 10,
                                          leading: Icon(Icons.content_paste_go,
                                              size: 35,
                                              color: Colors.white),
                                          title: Text('Paste',
                                              style: Styles.regularText),
                                        )),

                                  ),
                                  if (activeProgram.weeks.length > 1 && sliderIndex != activeProgram.weeks.length - 1)
                                  Container(
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                      decoration: const BoxDecoration(
                                          color: Colors.black12,
                                      ),
                                      child: InkWell(
                                        onTap: () {
                                            Navigator.of(context).pop();
                                            showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return DuplicationDialog(
                                                      indexOfWeekToDuplicate: sliderIndex);
                                                });
                                        },
                                        child: ListTile(
                                          horizontalTitleGap: 10,
                                          leading: Icon(Icons.copy_all, size: 35, color: sliderIndex != activeProgram.weeks.length - 1 ? Colors.white : Colors.grey),
                                          title: Text('Duplicate', style: Styles.regularText.copyWith(color: sliderIndex != activeProgram.weeks.length - 1 ? Colors.white : Colors.grey)),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              Column(
                                children: [
                                  SizedBox(height: MediaQuery.of(context).size.height * 0.08),
                                  Container(
                                       margin: EdgeInsets.only(right: MediaQuery.of(context).size.width * 0.014),
                                       child: ListTile(
                                            horizontalTitleGap: 5,
                                            leading: const Icon(Icons.pie_chart_rounded, color: Colors.white, size: 30),
                                            title: DropdownButton(
                                                      value: chartSelection,
                                                      elevation: 0,
                                                      style: Styles.regularText,
                                                      dropdownColor: Colors.black54,
                                                      iconEnabledColor: Colors.white,
                                                      underline: Container(),
                                                      isExpanded: true,
                                                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                                                      items: const [
                                                        DropdownMenuItem(value: "Muscle Groups", child: Text("Muscle Groups")),
                                                        DropdownMenuItem(value: "Rep Ranges", child: Text("Rep Ranges")),
                                                      ], onChanged: (value) {
                                                    setState(() {
                                                      chartSelection = value!;
                                                    });
                                                  }
                                                  ),
                                             ),
                                     ),
                                  const Divider(height: 0),
                                      Container(
                                      decoration: const BoxDecoration(
                                          color: Colors.black12,
                                          border: Border(
                                              bottom: BorderSide(
                                                  color: Colors.black,
                                                  width: 3
                                              )
                                          )
                                      ),
                                      child: chartSelection == "Muscle Groups"
                                          ? Column(
                                        children: [
                                          if(sortedEntries.isNotEmpty)...[
                                            CarouselSlider.builder(
                                              itemCount: muscleGroupMap.entries.length,
                                              itemBuilder: (context, index, realIndex) {
                                                return Container(
                                                    width: MediaQuery.of(context).size.width * 0.25,
                                                    decoration: const BoxDecoration(
                                                      color: Colors.black12,
                                                      borderRadius:  BorderRadius.all(Radius.circular(8)),
                                                    ),
                                                    child: Center(child: Text(sortedEntries[index].key, style: Styles.smallTextWhite.copyWith(color: Colors.white)))
                                                );
                                              },
                                              options: CarouselOptions(
                                                  enableInfiniteScroll: sortedEntries.length > 2 ? true : false,
                                                  height: 40,
                                                  enlargeCenterPage: true,
                                                  viewportFraction: 0.4,
                                                  onPageChanged: (index, reason) {
                                                    setState(() {
                                                      mapIndex = index;
                                                      if (sortedEntries[mapIndex].key == "Unspecified") {
                                                        isExpanded = false;
                                                      }
                                                    });
                                                  }
                                              ),
                                            ),
                                            SizedBox(
                                              height: MediaQuery.of(context).size.height * 0.30,
                                              child: PieChart(
                                                PieChartData(
                                                  sections: List.generate(sortedEntries.length, (index) {
                                                    final entry = sortedEntries[index];
                                                    return PieChartSectionData(
                                                        titlePositionPercentageOffset: 0.5,
                                                        value: entry.value['percentage'],
                                                        title: index == mapIndex ? '${entry.value['percentage'].toStringAsFixed(1)}%' : '',
                                                        color: Color.lerp(Styles.secondaryColor, Colors.white, index / 10),
                                                        radius: index == mapIndex ? MediaQuery.of(context).size.width * 0.14 : MediaQuery.of(context).size.width * 0.12,
                                                        titleStyle: Styles.paragraph.copyWith(color: Colors.white, fontSize: 12)
                                                    );
                                                  }).toList(),
                                                  sectionsSpace: 1.5,
                                                  centerSpaceRadius: MediaQuery.of(context).size.width * 0.15,
                                                ),
                                              ),
                                            ),
                                              if(isExpanded) const Divider(height: 0),
                                              Theme(
                                                data: ThemeData(
                                                    dividerColor: Colors.transparent
                                                ),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    gradient: isExpanded ? Styles.horizontal() : null,
                                                  ),
                                                  child: ExpansionTile(
                                                    onExpansionChanged: (value) {
                                                      setState(() {
                                                        isExpanded = value;
                                                      });
                                                    },
                                                    title: Text(isExpanded ? "total sets this week: $totalSets" : "", style: Styles.smallTextWhite.copyWith(color: Colors.white)),
                                                    collapsedIconColor: Colors.white,
                                                    iconColor: Colors.white,
                                                    backgroundColor: Colors.black26,

                                                    children: <Widget>[
                                                      if(sortedEntries[mapIndex].key != "Unspecified")...[
                                                        const SizedBox(height: 20),
                                                        Row(
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            children: [
                                                              const SizedBox(width: 10),
                                                              Text("${sortedEntries[mapIndex].value['primary sets']}", style: Styles.paragraph.copyWith(color: Colors.white)),
                                                              const SizedBox(width: 6),
                                                              Flexible(
                                                                child: Text("sets primarily target ${sortedEntries[mapIndex].key}", style: Styles.smallTextWhite,
                                                                  softWrap: true,
                                                                  overflow: TextOverflow.visible,
                                                                ),
                                                              ),
                                                              const SizedBox(width: 10),
                                                            ]),
                                                        const Divider(color: Colors.white54),
                                                        const SizedBox(height: 20),
                                                        Row(
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            children: [
                                                              const SizedBox(width: 10),
                                                              Text("${sortedEntries[mapIndex].value['secondary sets']}", style: Styles.paragraph.copyWith(color: Colors.white)),
                                                              const SizedBox(width: 6),
                                                              Flexible(
                                                                child: Text("sets secondarily target ${sortedEntries[mapIndex].key}", style: Styles.smallTextWhite,
                                                                  softWrap: true,
                                                                  overflow: TextOverflow.visible,
                                                                ),
                                                              ),
                                                              const SizedBox(width: 10),
                                                            ]),
                                                        const Divider(color: Colors.white54),
                                                        const SizedBox(height: 20),
                                                      ],
                                                      Row(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            const SizedBox(width: 10),
                                                            Text("${sortedEntries[mapIndex].value['percentage'].toStringAsFixed(1)}%", style: Styles.paragraph.copyWith(color: Colors.white)),
                                                            const SizedBox(width: 6),
                                                            Flexible(
                                                              child: Text(sortedEntries[mapIndex].key != "Unspecified" ? "of your training targets ${sortedEntries[mapIndex].key}" : "have no specified muscle group",
                                                                style: Styles.smallTextWhite,
                                                                softWrap: true,
                                                                overflow: TextOverflow.visible,
                                                              ),
                                                            ),
                                                            const SizedBox(width: 10),
                                                          ]),
                                                      const SizedBox(height: 10),
                                                    ],
                                                  ),
                                                ),
                                              )
                                          ]
                                          else ...[
                                           const Align(alignment: Alignment.center,
                                                child: Text("No data found", style: Styles.smallTextWhite))
                                          ]
                                        ],
                                      )
                                          : Column(
                                            children: [
                                              if(repRangeMap.isNotEmpty)...[
                                              SizedBox(
                                              height: MediaQuery.of(context).size.height * 0.30,
                                              child: PieChart(
                                              PieChartData(
                                                sections: repRangeSections,
                                                sectionsSpace: 1.5,
                                                centerSpaceRadius: 0,
                                               ),
                                              ),
                                             ),
                                              if(isExpanded) const Divider(height: 0),
                                              Theme(
                                                data: ThemeData(
                                                    dividerColor: Colors.transparent
                                                ),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    gradient: isExpanded ? Styles.horizontal() : null,
                                                  ),
                                                  child: ExpansionTile(
                                                    onExpansionChanged: (value) {
                                                      setState(() {
                                                        isExpanded = value;
                                                      });
                                                    },
                                                    title: Text(isExpanded ? "total sets this week: $totalSets" : "", style: Styles.smallTextWhite.copyWith(color: Colors.white)),
                                                    collapsedIconColor: Colors.white,
                                                    iconColor: Colors.white,
                                                    backgroundColor: Colors.black26,

                                                    children: <Widget>[
                                                      const SizedBox(height: 20),
                                                      Row(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            const SizedBox(width: 10),
                                                            Text(repRangeMap['6-12'] != null ? repRangeMap['6-12'].toString() : "0", style: Styles.paragraph.copyWith(color: Colors.white)),
                                                            const SizedBox(width: 6),
                                                            const Flexible(
                                                              child: Text("sets in the 6-12 rep range", style: Styles.smallTextWhite,
                                                                softWrap: true,
                                                                overflow: TextOverflow.visible,
                                                              ),
                                                            ),
                                                            const SizedBox(width: 10),
                                                          ]),
                                                      const Divider(color: Colors.white54),
                                                      const SizedBox(height: 20),
                                                      Row(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            const SizedBox(width: 10),
                                                            Text(repRangeMap['1-5']!= null ? repRangeMap['1-5'].toString() : "0", style: Styles.paragraph.copyWith(color: Colors.white)),
                                                            const SizedBox(width: 6),
                                                            const Flexible(
                                                              child: Text("sets in the 1-5 rep range", style: Styles.smallTextWhite,
                                                                softWrap: true,
                                                                overflow: TextOverflow.visible,
                                                              ),
                                                            ),
                                                            const SizedBox(width: 10),
                                                          ]),
                                                      const Divider(color: Colors.white54),
                                                      const SizedBox(height: 20),
                                                      Row(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            const SizedBox(width: 10),
                                                            Text(repRangeMap['12+'] != null ? repRangeMap['12+'].toString() : "0", style: Styles.paragraph.copyWith(color: Colors.white)),
                                                            const SizedBox(width: 6),
                                                            const Flexible(
                                                              child: Text("sets in the 12+ rep range", style: Styles.smallTextWhite,
                                                                softWrap: true,
                                                                overflow: TextOverflow.visible,
                                                              ),
                                                            ),
                                                            const SizedBox(width: 10),
                                                          ]),
                                                      const SizedBox(height: 10),
                                                    ],
                                                  ),
                                                ),
                                              )
                                              ]
                                              else ...[
                                                const Align(alignment: Alignment.center,
                                                    child: Text("No data found", style: Styles.smallTextWhite))
                                              ]
                                            ],
                                          ),
                                    )
                                  ]
                              )
                            ],
                          ),
                    )

        )
    );
  }
}



class SliderPage extends StatefulWidget {
  final int currentWeekIndex;
  final Program currentProgram;
  final Function callbackFunction;
  const SliderPage({required this.callbackFunction, required this.currentWeekIndex, required this.currentProgram});

  @override
  State<SliderPage> createState() => _SliderPageState();
}

class _SliderPageState extends State<SliderPage> {
  List<day> currentDaysInWeek = [];


  @override
  void initState() {
    super.initState();


  }

  @override
  Widget build(BuildContext context) {
    currentDaysInWeek = widget.currentProgram.weeks[widget.currentWeekIndex].days;

    return  ReorderableListView(
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (oldIndex < newIndex) {
                    newIndex -= 1;
                  }
                  final day movedItem = currentDaysInWeek.removeAt(oldIndex);
                  currentDaysInWeek.insert(newIndex, movedItem);
                });
                widget.currentProgram.save();
              },
              proxyDecorator: (widget, _, __) {
                return Material(
                  color: Colors.black26,
                  child: widget,
                );
              },
              scrollController: ScrollController(),
              scrollDirection: Axis.vertical,
              padding: EdgeInsets.zero,
              children: List.generate(currentDaysInWeek.length, (index) {
                return ReorderableDelayedDragStartListener(
                  index: index,
                  key: ValueKey(index),
                  child: index == 0 ? ShowcaseTemplate(
                    radius: 0,
                     globalKey: daysListKey,
                    stepID:  4,
                     title: "Days List",
                     content: "This is where the days of your program's current week are listed. Tap to open any of the days.",
                     child: Container(
                      height: (MediaQuery.of(context).size.height - MediaQuery.of(context).size.height / 4) / 7,
                      padding:
                          const EdgeInsets.only(top: 10, bottom: 10, left: 5),
                      decoration: BoxDecoration(
                        color: currentDaysInWeek[index].checked ? Colors.black26 : Colors.black12,
                        border: index != 6
                            ? const Border(
                                bottom:
                                    BorderSide(color: Colors.white54, width: 2.0))
                            : const Border(),
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => DayWidget(
                              refreshParent: () {
                                setState(() {

                                });
                              },
                              dayIndex: index,
                              weekIndex: widget.currentWeekIndex,
                            ),
                          ));
                        },
                        child: Row(
                          children: [
                            ShowcaseTemplate(
                              radius: 10,
                             globalKey: checkButtonKey,
                               stepID: 5,
                              title: "Checking Off Days",
                              content: "Check off each day here as you go. This keeps your streak going and also determines the current day for quick navigation on the home page. \n\n (a day will be automatically checked off if all of its movements are.)",
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    currentDaysInWeek[index].checked = !currentDaysInWeek[index].checked;
                                    if (HomeScreen.lastStreakDay != DateUtils.dateOnly(DateTime.now())) {
                                      HomeScreen.lastStreakDay = DateUtils.dateOnly(DateTime.now());
                                      HomeScreen.streakLength ++;
                                      () async {
                                        SharedPreferences prefs = await SharedPreferences.getInstance();
                                        prefs.setInt("streakLength", HomeScreen.streakLength);
                                        prefs.setString("lastStreakDay", DateUtils.dateOnly(DateTime.now()).toIso8601String());
                                      }();
                                    }
                                  });
                                  widget.currentProgram.save();
                                },
                                child: Container(
                                    height: 40,
                                    width: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.check,
                                      color: currentDaysInWeek[index].checked == false
                                          ? Colors.grey
                                          : Styles.primaryColor,
                                      size: 40,
                                    ),
                                  ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "Day ${index + 1}: ${currentDaysInWeek[index].name}",
                                style: Styles.regularText,
                              ),
                            ),
                            ShowcaseTemplate(
                              radius: 5,
                              globalKey: dayOptionsKey,
                              stepID: 6,
                              title: "Making Changes To The Days List",
                              content: "Open this menu if you would like to make changes to a day. You may also change a day's muscle groups here.",
                              child: PopupMenuButton<ListTile>(
                                  itemBuilder: (context) {
                                    return [
                                      PopupMenuItem(
                                        child: InkWell(
                                          onTap: () {
                                            Navigator.pop(context);
                                            copiedDay = day(
                                              id: -1,
                                              muscleGroups: currentDaysInWeek[index].muscleGroups?.toList(),
                                              name: currentDaysInWeek[index].name,
                                              movements: List.from(currentDaysInWeek[index].movements,
                                              ),
                                            );
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                backgroundColor: Colors.white,
                                                content: Text('Day copied',
                                                    style: TextStyle(color: Styles.primaryColor)),
                                                duration: const Duration(milliseconds: 1500),
                                              ),
                                            );
                                          },
                                          child: ListTile(
                                            leading: Icon(Icons.copy,
                                                color: Styles.primaryColor),
                                            title: Text('Copy',
                                                style: TextStyle(
                                                    color: Styles.primaryColor)),
                                          ),
                                        ),
                                      ),
                                      PopupMenuItem(
                                        child: InkWell(
                                          onTap: () {
                                              if (copiedDay == null) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    backgroundColor: Colors.white,
                                                    content: Text('No day copied',
                                                        style: TextStyle(
                                                            color: Styles.primaryColor)),
                                                    duration:
                                                    const Duration(milliseconds: 1500),
                                                  ),
                                                );
                                              }
                                              else {
                                                callback () {
                                                  setState(() {
                                                    currentDaysInWeek[index] = day(
                                                      id: ProgramsPage.globalDayID++,
                                                      name: copiedDay!.name,
                                                      muscleGroups: copiedDay!.muscleGroups?.toList(),
                                                      movements: copiedDay!.movements.map((movement)
                                                      => Movement(
                                                        resultSets: [],
                                                        superset: movement.superset,
                                                        notes: "",
                                                        name: movement.name,
                                                        sets: movement.sets,
                                                        reps: movement.reps,
                                                        rir: movement.rir,
                                                        weight: movement.weight,
                                                        rest: movement.rest,
                                                        remainingRestTime: movement.rest,
                                                      )).toList(),
                                                    );
                                                  });
                                                  ProgramsPage.setDayIDPref();
                                                }
                                                Navigator.pop(context);

                                                showDialog(
                                                  context: context,
                                                  builder: (BuildContext context) {
                                                    return ConfirmationDialog(
                                                      content:
                                                      "This will overwrite all existing data in this day. Would you like to proceed?",
                                                      callbackFunction: callback,
                                                    );
                                                  },
                                                );
                                              }

                                            widget.currentProgram.save();
                                          },
                                          child: ListTile(
                                            leading: Icon(Icons.content_paste_go,
                                                color: Styles.primaryColor),
                                            title: Text('Paste',
                                                style: TextStyle(
                                                    color: Styles.primaryColor)),
                                          ),
                                        ),
                                      ),
                                      PopupMenuItem(
                                        child: InkWell(
                                          onTap: () {
                                            Navigator.pop(context);
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return EditDay(thisDay: currentDaysInWeek[index], refresh: () {setState(() {
                                                 });
                                                });
                                              },
                                            );
                                          },
                                          child: ListTile(
                                            leading: Icon(Icons.edit,
                                                color: Styles.primaryColor),
                                            title: Text("Edit",
                                                style: TextStyle(
                                                    color: Styles.primaryColor)),
                                          ),
                                        ),
                                      ),
                                      PopupMenuItem(
                                        child: InkWell(
                                          onTap: () {
                                            remove() {
                                              setState(() {
                                                currentDaysInWeek.removeAt(index);
                                                widget.callbackFunction();
                                              });
                                              widget.currentProgram.save();
                                            }

                                            Navigator.pop(context);
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return ConfirmationDialog(
                                                  content:
                                                      "Are you sure you want to delete this day?",
                                                  callbackFunction: remove,
                                                );
                                              },
                                            );
                                          },
                                          child: ListTile(
                                            leading: Icon(Icons.delete,
                                                color: Styles.primaryColor),
                                            title: Text('Delete',
                                                style: TextStyle(
                                                    color: Styles.primaryColor)),
                                          ),
                                        ),
                                      ),
                                    ];
                                  },
                                  child: const Icon(Icons.more_vert,
                                      color: Colors.white, size: 35)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ) : Container(
                    height: (MediaQuery.of(context).size.height - MediaQuery.of(context).size.height / 4) / 7,
                    padding:
                    const EdgeInsets.only(top: 10, bottom: 10, left: 5),
                    decoration: BoxDecoration(
                      color: currentDaysInWeek[index].checked ? Colors.black26 : Colors.black12,
                      border: index != 6
                          ? const Border(
                          bottom:
                          BorderSide(color: Colors.white54, width: 2.0))
                          : const Border(),
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => DayWidget(
                            refreshParent: () {
                              setState(() {

                              });
                            },
                            dayIndex: index,
                            weekIndex: widget.currentWeekIndex,
                          ),
                        ));
                      },
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {
                                currentDaysInWeek[index].checked = !currentDaysInWeek[index].checked;
                                if (HomeScreen.lastStreakDay != DateUtils.dateOnly(DateTime.now())) {
                                  HomeScreen.lastStreakDay = DateUtils.dateOnly(DateTime.now());
                                  HomeScreen.streakLength ++;
                                  () async {
                                    SharedPreferences prefs = await SharedPreferences.getInstance();
                                    prefs.setInt("streakLength", HomeScreen.streakLength);
                                    prefs.setString("lastStreakDay", DateUtils.dateOnly(DateTime.now()).toIso8601String());
                                  }();
                                }
                              });
                              widget.currentProgram.save();
                            },
                            child: Container(
                              height: 40,
                              width: 50,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.check,
                                color: currentDaysInWeek[index].checked == false
                                    ? Colors.grey
                                    : Styles.primaryColor,
                                size: 40,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "Day ${index + 1}: ${currentDaysInWeek[index].name}",
                              style: Styles.regularText,
                            ),
                          ),
                          PopupMenuButton<ListTile>(
                              itemBuilder: (context) {
                                return [
                                  PopupMenuItem(
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.pop(context);
                                        copiedDay = day(
                                          id: -1,
                                          muscleGroups: currentDaysInWeek[index].muscleGroups?.toList(),
                                          name: currentDaysInWeek[index].name,
                                          movements: List.from(currentDaysInWeek[index].movements,
                                          ),
                                        );
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            backgroundColor: Colors.white,
                                            content: Text('Day copied',
                                                style: TextStyle(color: Styles.primaryColor)),
                                            duration: const Duration(milliseconds: 1500),
                                          ),
                                        );
                                      },
                                      child: ListTile(
                                        leading: Icon(Icons.copy,
                                            color: Styles.primaryColor),
                                        title: Text('Copy',
                                            style: TextStyle(
                                                color: Styles.primaryColor)),
                                      ),
                                    ),
                                  ),
                                  PopupMenuItem(
                                    child: InkWell(
                                      onTap: () {
                                        if (copiedDay == null) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              backgroundColor: Colors.white,
                                              content: Text('No day copied',
                                                  style: TextStyle(
                                                      color: Styles.primaryColor)),
                                              duration:
                                              const Duration(milliseconds: 1500),
                                            ),
                                          );
                                        }
                                        else {
                                          callback () {
                                            setState(() {
                                              currentDaysInWeek[index] = day(
                                                id: ProgramsPage.globalDayID++,
                                                name: copiedDay!.name,
                                                muscleGroups: copiedDay!.muscleGroups?.toList(),
                                                movements: copiedDay!.movements.map((movement)
                                                => Movement(
                                                  resultSets: [],
                                                  superset: movement.superset,
                                                  notes: "",
                                                  name: movement.name,
                                                  sets: movement.sets,
                                                  reps: movement.reps,
                                                  rir: movement.rir,
                                                  weight: movement.weight,
                                                  rest: movement.rest,
                                                  remainingRestTime: movement.rest,
                                                )).toList(),
                                              );
                                            });
                                            ProgramsPage.setDayIDPref();
                                          }
                                          Navigator.pop(context);

                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return ConfirmationDialog(
                                                content:
                                                "This will overwrite all existing data in this day. Would you like to proceed?",
                                                callbackFunction: callback,
                                              );
                                            },
                                          );
                                        }

                                        widget.currentProgram.save();
                                      },
                                      child: ListTile(
                                        leading: Icon(Icons.content_paste_go,
                                            color: Styles.primaryColor),
                                        title: Text('Paste',
                                            style: TextStyle(
                                                color: Styles.primaryColor)),
                                      ),
                                    ),
                                  ),
                                  PopupMenuItem(
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.pop(context);
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return EditDay(thisDay: currentDaysInWeek[index], refresh: () {setState(() {
                                            });
                                            });
                                          },
                                        );
                                      },
                                      child: ListTile(
                                        leading: Icon(Icons.edit,
                                            color: Styles.primaryColor),
                                        title: Text("Edit",
                                            style: TextStyle(
                                                color: Styles.primaryColor)),
                                      ),
                                    ),
                                  ),
                                  PopupMenuItem(
                                    child: InkWell(
                                      onTap: () {
                                        remove() {
                                          setState(() {
                                            currentDaysInWeek.removeAt(index);
                                            widget.callbackFunction();
                                          });
                                          widget.currentProgram.save();
                                        }

                                        Navigator.pop(context);
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return ConfirmationDialog(
                                              content:
                                              "Are you sure you want to delete this day?",
                                              callbackFunction: remove,
                                            );
                                          },
                                        );
                                      },
                                      child: ListTile(
                                        leading: Icon(Icons.delete,
                                            color: Styles.primaryColor),
                                        title: Text('Delete',
                                            style: TextStyle(
                                                color: Styles.primaryColor)),
                                      ),
                                    ),
                                  ),
                                ];
                              },
                              child: const Icon(Icons.more_vert,
                                  color: Colors.white, size: 35)),
                        ],
                      ),
                    ),
                  ),
                );
               }
              ),
            );
  }
}








class DayWidget extends StatefulWidget {
  final Program currentProgram = ProgramsPage.programsList[ProgramsPage.activeProgramIndex];
  final int dayIndex;
  final int weekIndex;
  final Function()? refreshParent;

  DayWidget({this.refreshParent, required this.dayIndex, required this.weekIndex});



  @override
  DayWidgetState createState() => DayWidgetState();
}

class DayWidgetState extends State<DayWidget> {
  static bool showcasePartiallyShown = false;
  late day currentDay;
  ScrollController myScrollController = ScrollController();

  void showSecondPartOfShowcase() {
    ShowcaseView.get().startShowCase([movementListKey, movementOptionsKey]);
  }

  @override
  void initState() {
    super.initState();
    currentDay = widget.currentProgram.weeks[widget.weekIndex].days[widget.dayIndex];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (currentDay.movements.isNotEmpty) {
          ShowcaseView.get().startShowCase([addMovementKey, pasteMovementKey, movementListKey, movementOptionsKey]);
         if (showcasePartiallyShown == true){
           showSecondPartOfShowcase();
         }
        }
        else {
          showcasePartiallyShown = true;
          ShowcaseView.get().startShowCase([addMovementKey, pasteMovementKey]);
        }
      });
    });

    myScrollController = ScrollController();
  }

  @override
  void dispose() {
    myScrollController.dispose();
    super.dispose();
  }


  void refreshPage() {
    setState(() {});
  }

  void addThisMovement(Movement? thisMovement) {
    if (thisMovement != null) {
      setState(() {
        currentDay.movements.add(Movement(
            resultSets: [],
            superset: thisMovement.superset,
            name: thisMovement.name,
            sets: thisMovement.sets,
            reps: thisMovement.reps,
            rir: thisMovement.rir,
            notes: "",
            weight: thisMovement.weight,
            rest: thisMovement.rest,
            remainingRestTime: thisMovement.rest));
      });
      widget.currentProgram.save();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Wait one more frame after the new item is rendered
        WidgetsBinding.instance.addPostFrameCallback((_) {
          myScrollController.animateTo(
            currentDay.movements.length < 10 ? myScrollController.position.maxScrollExtent
                : myScrollController.position.maxScrollExtent + 100,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        });
      });

    }

    if (currentDay.movements.length == 1) {
     showSecondPartOfShowcase();
    }
  }

  void removeThisMovement(int thisMovementIndex) {
    setState(() {
      currentDay.movements.removeAt(thisMovementIndex);
    });
    widget.currentProgram.save();
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            if (!currentDay.movements.any((movement) => !movement.hasBeenLogged) && currentDay.movements.isNotEmpty && currentDay.checked == false) {
              currentDay.checked = true;
              if (HomeScreen.lastStreakDay != DateUtils.dateOnly(DateTime.now())) {
                HomeScreen.lastStreakDay = DateUtils.dateOnly(DateTime.now());
                HomeScreen.streakLength ++;
                () async {
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  prefs.setInt("streakLength", HomeScreen.streakLength);
                  prefs.setString("lastStreakDay", DateUtils.dateOnly(DateTime.now()).toIso8601String());
                }();
              }
              widget.currentProgram.save();
            }
          if(widget.refreshParent != null) {
            widget.refreshParent!();
          }
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
        title: Text(currentDay.name, style: Styles.labelText),
      ),
      body: Container(
          height: double.infinity,
          width: double.infinity,
          decoration: BoxDecoration(gradient: Styles.darkGradient()),
          child: Container(
            color: Colors.black12,
            child: ReorderableListView(
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (oldIndex < newIndex) {
                    newIndex -= 1;
                  }
                  final Movement movedItem =
                      currentDay.movements.removeAt(oldIndex);
                  currentDay.movements.insert(newIndex, movedItem);
                });
                widget.currentProgram.save();
              },
              proxyDecorator: (widget, _, __) {
                return Material(
                  color: Colors.black26,
                  child: widget,
                );
              },
              scrollController: myScrollController,
              scrollDirection: Axis.vertical,
              padding: EdgeInsets.zero,
              children: List.generate(currentDay.movements.length, (index) {
                return ReorderableDelayedDragStartListener(
                    index: index,
                    key: ValueKey(index),
                    child: MovementWidget(
                        refreshParent: () {
                          setState(() {

                          });
                        },
                        currentDay: currentDay,
                        movementIndex: index,
                        removeThisMovement: removeThisMovement));
              }),
            ),
          ),
        ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(top: 10, left: 50, right: 50),
        height: MediaQuery.of(context).size.height / 8,
        decoration: BoxDecoration(
            boxShadow: const [
              BoxShadow(
                color: Colors.black54,
                spreadRadius: 1,
                blurRadius: 6,
                offset: Offset(0, -3),
              ),
            ], gradient: Styles.darkGradient()),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
              InkWell(
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return CreateMovement(
                              currentDay: currentDay,
                              addThisMovement: addThisMovement);
                        });
                  },
                  child: Column(
                      children: [
                        ShowcaseTemplate(
                          radius: 5,
                            globalKey: addMovementKey,
                            stepID: 7,
                            title: "Adding Movements",
                            content: "Tap this button to add a movement to this day. You can search through the movements in your movement log, or create a new one here.",
                            child: const Icon(Icons.add_box, color: Colors.white, size: 35)),
                        const Text("Add", style: Styles.smallTextWhite),
                      ],
                    ),
                  ),


            InkWell(
                  onTap: () {
                    if (copiedMovement == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.white,
                          content: Text('No movement copied',
                              style: TextStyle(color: Styles.primaryColor)),
                          duration: const Duration(milliseconds: 1500),
                        ),
                      );
                    } else {
                      addThisMovement(copiedMovement);
                    }
                  },
                   child: Column(
                      children: [
                        ShowcaseTemplate(
                          radius: 5,
                            globalKey: pasteMovementKey,
                            stepID: 8,
                            title: "Pasting Movements",
                            content: "Tap this button to paste a copied movement to this day.",
                            child: const Icon(Icons.content_paste_go, color: Colors.white, size: 35)),
                        const Text("Paste", style: Styles.smallTextWhite),
                      ],
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
