import 'package:flutter/material.dart';
import 'main.dart';
import 'dialogs.dart';

class PresetPrograms extends StatefulWidget {
  final Function (Program) updateProgramList;
  static bool easterEggDiscovered = false;

  const PresetPrograms({required this.updateProgramList});

  @override
  State<PresetPrograms> createState() => PresetProgramsState();
}

class PresetProgramsState extends State<PresetPrograms> {
 static List <Program> programsList = [];


  @override
  void initState() {
      programsList = [];
      programData();
      super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Styles.primaryColor,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text("Program Templates", style: Styles.labelText),
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
            child: SingleChildScrollView(
              child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                itemExtent: 190,
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 50),
                itemCount: programsList.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
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
                             InkWell(
                               onTap: () {
                                 showDialog(
                                     context: context,
                                     builder: (BuildContext context) {
                                       return AddPreset(updateCallback: widget.updateProgramList, thisProgram: programsList[index]);
                                     }
                                 );
                               },

                               child: Container(
                                 padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                 decoration: BoxDecoration(
                                   borderRadius: const BorderRadius.only(
                                     topLeft: Radius.circular(20.0),
                                     topRight: Radius.circular(20.0),
                                   ),
                                   border: const Border(
                                     bottom: BorderSide(
                                       color: Colors.black,
                                       width: 4,
                                     ),
                                   ),
                                  color: Styles.secondaryColor,
                                 ),
                                 child: Row(
                                      children: [
                                        Text(programsList[index].name, style: Styles.regularText),
                                        const Spacer(),
                                        Text(
                                          programsList[index].experienceLevel,
                                          style: TextStyle(
                                            color: programsList[index].experienceLevel == "Beginner"
                                                ? Colors.green
                                                : programsList[index].experienceLevel == "Intermediate"
                                                ? Colors.orange
                                                : Colors.red,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                               ),
                             ),
                                const SizedBox(height: 10),
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text("Length: ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                                  Text("Frequency: ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text("${programsList[index].weeks.length} weeks", style: const TextStyle(color: Colors.white60, fontWeight: FontWeight.bold)),
                                  Text("${programsList[index].weeks[0].days.where((element) => element.name != "Rest" && element.name != "Functional").length} days per week", style: const TextStyle(color: Colors.white60, fontWeight: FontWeight.bold))
                                ],
                              ),
                              const Divider(),
                                 Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                   for (var day in programsList[index].weeks[0].days.where((day) => day.name != "Rest" && day.name != "Functional"))
                                           Text(day.name, style: const TextStyle(color: Colors.white60, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              const SizedBox(height: 10)
                            ],
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
        ),
      );
  }


 static addZoesProgram() {
    List<List<Movement>> zoesInitializer(){
      List<Movement> day1 = [
        Movement(
            resultSets: [],
            notes: "",
            name: "Barbell back squats",
            sets: 3,
            reps: "10",
            rir: "1-2",
            weight: 0,
            primaryMuscleGroups: ["Quads"],
            secondaryMuscleGroups: ["Hamstrings, Glutes"],
            rest: const Duration(minutes: 2),
            remainingRestTime: const Duration(minutes: 2)),

        Movement(
            resultSets: [],
            notes: "",
            name: "Dumbbell RDLs",
            sets: 3,
            reps: "10",
            rir: "1-2",
            weight: 0,
            primaryMuscleGroups: ["Hamstrings", "Glutes"],
            rest: const Duration(minutes: 2),
            remainingRestTime: const Duration(minutes: 2)),

        Movement(
            resultSets: [],
            notes: "",
            name: "Leg extensions",
            sets: 2,
            reps: "12",
            rir: "0-1",
            weight: 0,
            primaryMuscleGroups: ["Quads"],
            rest: const Duration(minutes: 1),
            remainingRestTime: const Duration(minutes: 1)),

        Movement(
            resultSets: [],
            notes: "",
            name: "Cable kickbacks",
            sets: 2,
            reps: "10",
            rir: "0-1",
            weight: 0,
            primaryMuscleGroups: ["Glutes"],
            rest: const Duration(minutes: 1, seconds: 30),
            remainingRestTime: const Duration(minutes: 1, seconds: 30)),

        Movement(
            resultSets: [],
            notes: "",
            name: "Calf raises",
            sets: 3,
            reps: "15",
            rir: "0-1",
            weight: 0,
            primaryMuscleGroups: ["Calves"],
            rest: const Duration(minutes: 1, seconds: 30),
            remainingRestTime: const Duration(minutes: 1, seconds: 30)),
      ];
      List<Movement> day2 = [
        Movement( resultSets: [],
            notes: "",
            name: "Dumbbell bench press",
            sets: 3,
            reps: "12",
            rir: "1-2",
            weight: 0,
            primaryMuscleGroups: ["Chest"],
            secondaryMuscleGroups: ["Triceps", "Shoulders"],
            rest: const Duration(minutes: 2),
            remainingRestTime: const Duration(minutes: 2)),

        Movement( resultSets: [],
            notes: "",
            name: "Dumbbell shoulder press",
            sets: 3,
            reps: "12",
            rir: "1-2", weight: 0,
            rest: const Duration(minutes: 2),
            remainingRestTime: const Duration(minutes: 2)),

        Movement( resultSets: [],
            notes: "",
            name: "Cable Tricep pushdowns",
            sets: 3,
            reps: "10",
            rir: "0-1", weight: 0,
            rest: const Duration(minutes: 1, seconds: 30),
            remainingRestTime: const Duration(minutes: 1, seconds: 30)),

        Movement( resultSets: [],
            notes: "",
            name: "Pec deck",
            sets: 3,
            reps: "12",
            rir: "0-1", weight: 0,
            rest: const Duration(minutes: 1),
            remainingRestTime: const Duration(minutes: 1)),

        Movement( resultSets: [],
            notes: "",
            name: "Dumbbell lateral raise",
            sets: 3,
            reps: "12",
            rir: "0", weight: 0,
            rest: const Duration(minutes: 1),
            remainingRestTime: const Duration(minutes: 1)),
      ];
      List<Movement> day3 = [
        Movement( resultSets: [],
            notes: "",
            name: "Lat-pulldown",
            sets: 3,
            reps: "10",
            rir: "1-2", weight: 0,
            rest: const Duration(minutes: 2),
            remainingRestTime: const Duration(minutes: 2)),

        Movement( resultSets: [],
            notes: "",
            name: "Low row",
            sets: 3,
            reps: "10",
            rir: "1-2", weight: 0,
            rest: const Duration(minutes: 2),
            remainingRestTime: const Duration(minutes: 2)),

        Movement( resultSets: [],
            notes: "retend like ur flexing and go twords your forehead the tippity top of it",
            name: "Face pulls",
            sets: 3,
            reps: "12",
            rir: "0-1", weight: 0,
            rest: const Duration(minutes: 1),
            remainingRestTime: const Duration(minutes: 1)),

        Movement( resultSets: [],
            notes: "",
            name: "Cable pullovers",
            sets: 2,
            reps: "12",
            rir: "0-1", weight: 0,
            rest: const Duration(minutes: 1, seconds: 30),
            remainingRestTime: const Duration(minutes: 1, seconds: 30)),

        Movement( resultSets: [],
            notes: "",
            name: "Dumbbell bicep curl",
            sets: 3,
            reps: "10",
            rir: "0", weight: 0,
            rest: const Duration(minutes: 1, seconds: 30),
            remainingRestTime: const Duration(minutes: 1, seconds: 30)),
      ];
      List<Movement> day4 = [
        Movement(
            resultSets: [],
            notes: "",
            name: "Barbell back squats",
            sets: 3,
            reps: "10",
            rir: "1-2",
            weight: 0,
            primaryMuscleGroups: ["Quads"],
            secondaryMuscleGroups: ["Hamstrings, Glutes"],
            rest: const Duration(minutes: 2),
            remainingRestTime: const Duration(minutes: 2)),

        Movement(
            resultSets: [],
            notes: "",
            name: "Hip thrust",
            sets: 3,
            reps: "10",
            rir: "1-2",
            weight: 0,
            primaryMuscleGroups: ["Glutes"],
            rest: const Duration(minutes: 2),
            remainingRestTime: const Duration(minutes: 2)),

        Movement(
            resultSets: [],
            notes: "",
            name: "Seated leg curl",
            sets: 2,
            reps: "12",
            rir: "0-1",
            weight: 0,
            primaryMuscleGroups: ["Hamstrings"],
            rest: const Duration(minutes: 1),
            remainingRestTime: const Duration(minutes: 1)),

        Movement(
            resultSets: [],
            notes: "",
            name: "Cable kickbacks",
            sets: 2,
            reps: "10",
            rir: "0-1",
            weight: 0,
            primaryMuscleGroups: ["Glutes"],
            rest: const Duration(minutes: 1, seconds: 30),
            remainingRestTime: const Duration(minutes: 1, seconds: 30)),

        Movement(
            resultSets: [],
            notes: "",
            name: "Calf raises",
            sets: 3,
            reps: "15",
            rir: "0-1",
            weight: 0,
            primaryMuscleGroups: ["Calves"],
            rest: const Duration(minutes: 1, seconds: 30),
            remainingRestTime: const Duration(minutes: 1, seconds: 30)),
      ];
      List<Movement> day5 = [
        Movement( resultSets: [],
            notes: "",
            name: "Lat-pulldown",
            sets: 3,
            reps: "10",
            rir: "1-2", weight: 0,
            rest: const Duration(minutes: 2),
            remainingRestTime: const Duration(minutes: 2)),

        Movement( resultSets: [],
            notes: "",
            name: "Low row",
            sets: 3,
            reps: "10",
            rir: "1-2", weight: 0,
            rest: const Duration(minutes: 2),
            remainingRestTime: const Duration(minutes: 2)),

        Movement( resultSets: [],
            notes: "",
            name: "Dumbbell bench press",
            sets: 3,
            reps: "12",
            rir: "1-2", weight: 0,
            rest: const Duration(minutes: 2),
            remainingRestTime: const Duration(minutes: 2)),

        Movement( resultSets: [],
            notes: "",
            name: "Dumbbell shoulder press",
            sets: 3,
            reps: "12",
            rir: "1-2", weight: 0,
            rest: const Duration(minutes: 2),
            remainingRestTime: const Duration(minutes: 2)),

        Movement( resultSets: [],
            notes: "",
            name: "Dumbbell bicep curl",
            sets: 3,
            reps: "10",
            rir: "0", weight: 0,
            rest: const Duration(minutes: 1, seconds: 30),
            remainingRestTime: const Duration(minutes: 1, seconds: 30)),
      ];
      List<Movement> rest = [];

      return [day1, day2, day3, day4, rest, day5, rest];
    }
    List<List<Movement>> zoesMovements = zoesInitializer();
    addProgram(8, "Zoe's program \u2764", <String> ["Legs", "Push", "Pull", "Legs", "Rest", "Upper", "Rest"], zoesMovements);
    programsList.last.experienceLevel = "Beginner";
    }

  programData() {
    if (PresetPrograms.easterEggDiscovered == true) {
      List<List<Movement>> zoesInitializer(){
        List<Movement> day1 = [
          Movement( resultSets: [],
              notes: "",
              name: "Barbell back squats",
              sets: 3,
              reps: "10",
              rir: "1-2",
              weight: 0,
              rest: const Duration(minutes: 2),
              remainingRestTime: const Duration(minutes: 2)),

          Movement( resultSets: [],
              notes: "",
              name: "Dumbbell RDLs",
              sets: 3,
              reps: "10",
              rir: "1-2",
              weight: 0,
              rest: const Duration(minutes: 2),
              remainingRestTime: const Duration(minutes: 2)),

          Movement( resultSets: [],
              notes: "",
              name: "Leg extensions",
              sets: 2,
              reps: "12",
              rir: "0-1",
              weight: 0,
              rest: const Duration(minutes: 1),
              remainingRestTime: const Duration(minutes: 1)),

          Movement( resultSets: [],
              notes: "",
              name: "Cable kickbacks",
              sets: 2,
              reps: "10",
              rir: "0-1",
              weight: 0,
              rest: const Duration(minutes: 1, seconds: 30),
              remainingRestTime: const Duration(minutes: 1, seconds: 30)),

          Movement( resultSets: [],
              notes: "",
              name: "Calf raises",
              sets: 3,
              reps: "15",
              rir: "0-1",
              weight: 0,
              rest: const Duration(minutes: 1, seconds: 30),
              remainingRestTime: const Duration(minutes: 1, seconds: 30)),
        ];
        List<Movement> day2 = [
          Movement( resultSets: [],
              notes: "",
              name: "Dumbbell bench press",
              sets: 3,
              reps: "12",
              rir: "1-2", weight: 0,
              rest: const Duration(minutes: 2),
              remainingRestTime: const Duration(minutes: 2)),

          Movement( resultSets: [],
              notes: "",
              name: "Dumbbell shoulder press",
              sets: 3,
              reps: "12",
              rir: "1-2", weight: 0,
              rest: const Duration(minutes: 2),
              remainingRestTime: const Duration(minutes: 2)),

          Movement( resultSets: [],
              notes: "",
              name: "Cable Tricep pushdowns",
              sets: 3,
              reps: "10",
              rir: "0-1", weight: 0,
              rest: const Duration(minutes: 1, seconds: 30),
              remainingRestTime: const Duration(minutes: 1, seconds: 30)),

          Movement( resultSets: [],
              notes: "",
              name: "Pec deck",
              sets: 2,
              reps: "12",
              rir: "0-1", weight: 0,
              rest: const Duration(minutes: 1),
              remainingRestTime: const Duration(minutes: 1)),

          Movement( resultSets: [],
              notes: "",
              name: "Dumbbell lateral raise",
              sets: 3,
              reps: "12",
              rir: "0", weight: 0,
              rest: const Duration(minutes: 1),
              remainingRestTime: const Duration(minutes: 1)),
        ];
        List<Movement> day3 = [
          Movement( resultSets: [],
              notes: "",
              name: "Lat-pulldown",
              sets: 3,
              reps: "10",
              rir: "1-2", weight: 0,
              rest: const Duration(minutes: 2),
              remainingRestTime: const Duration(minutes: 2)),

          Movement( resultSets: [],
              notes: "",
              name: "Low row",
              sets: 3,
              reps: "10",
              rir: "1-2", weight: 0,
              rest: const Duration(minutes: 2),
              remainingRestTime: const Duration(minutes: 2)),

          Movement( resultSets: [],
              notes: "retend like ur flexing and go twords your forehead the tippity top of it",
              name: "Face pulls",
              sets: 3,
              reps: "12",
              rir: "0-1", weight: 0,
              rest: const Duration(minutes: 1),
              remainingRestTime: const Duration(minutes: 1)),

          Movement( resultSets: [],
              notes: "",
              name: "Cable pullovers",
              sets: 2,
              reps: "12",
              rir: "0-1", weight: 0,
              rest: const Duration(minutes: 1, seconds: 30),
              remainingRestTime: const Duration(minutes: 1, seconds: 30)),

          Movement( resultSets: [],
              notes: "",
              name: "Dumbbell bicep curl",
              sets: 3,
              reps: "10",
              rir: "0", weight: 0,
              rest: const Duration(minutes: 1, seconds: 30),
              remainingRestTime: const Duration(minutes: 1, seconds: 30)),
        ];
        List<Movement> day4 = [
          Movement( resultSets: [],
              notes: "",
              name: "Barbell back squats",
              sets: 3,
              reps: "10",
              rir: "1-2",
              weight: 0,
              rest: const Duration(minutes: 2),
              remainingRestTime: const Duration(minutes: 2)),

          Movement( resultSets: [],
              notes: "",
              name: "Hip thrust",
              sets: 3,
              reps: "10",
              rir: "1-2",
              weight: 0,
              rest: const Duration(minutes: 2),
              remainingRestTime: const Duration(minutes: 2)),

          Movement( resultSets: [],
              notes: "",
              name: "Seated leg curl",
              sets: 2,
              reps: "12",
              rir: "0-1",
              weight: 0,
              rest: const Duration(minutes: 1),
              remainingRestTime: const Duration(minutes: 1)),

          Movement( resultSets: [],
              notes: "",
              name: "Cable kickbacks",
              sets: 2,
              reps: "10",
              rir: "0-1",
              weight: 0,
              rest: const Duration(minutes: 1, seconds: 30),
              remainingRestTime: const Duration(minutes: 1, seconds: 30)),

          Movement( resultSets: [],
              notes: "",
              name: "Calf raises",
              sets: 3,
              reps: "15",
              rir: "0-1",
              weight: 0,
              rest: const Duration(minutes: 1, seconds: 30),
              remainingRestTime: const Duration(minutes: 1, seconds: 30)),
        ];
        List<Movement> day5 = [
          Movement( resultSets: [],
              notes: "",
              name: "Lat-pulldown",
              sets: 3,
              reps: "10",
              rir: "1-2", weight: 0,
              rest: const Duration(minutes: 2),
              remainingRestTime: const Duration(minutes: 2)),

          Movement( resultSets: [],
              notes: "",
              name: "Low row",
              sets: 3,
              reps: "10",
              rir: "1-2", weight: 0,
              rest: const Duration(minutes: 2),
              remainingRestTime: const Duration(minutes: 2)),

          Movement( resultSets: [],
              notes: "",
              name: "Dumbbell bench press",
              sets: 3,
              reps: "12",
              rir: "1-2", weight: 0,
              rest: const Duration(minutes: 2),
              remainingRestTime: const Duration(minutes: 2)),

          Movement( resultSets: [],
              notes: "",
              name: "Dumbbell shoulder press",
              sets: 3,
              reps: "12",
              rir: "1-2", weight: 0,
              rest: const Duration(minutes: 2),
              remainingRestTime: const Duration(minutes: 2)),

          Movement( resultSets: [],
              notes: "",
              name: "Dumbbell bicep curl",
              sets: 3,
              reps: "10",
              rir: "0", weight: 0,
              rest: const Duration(minutes: 1, seconds: 30),
              remainingRestTime: const Duration(minutes: 1, seconds: 30)),
        ];
        List<Movement> rest = [];

        return [day1, day2, day3, day4, rest, day5, rest];
      }
      List<List<Movement>> zoesMovements = zoesInitializer();
      addProgram(8, "Zoe's program \u2764", <String> ["Legs", "Push", "Pull", "Legs", "Rest", "Upper", "Rest"], zoesMovements);
      programsList.last.experienceLevel = "Beginner";
    }

    List<List<Movement>> starterMovements() {
      List<Movement> day1 = [
        Movement(
            resultSets: [],
            notes: "",
            name: "Lat pulldown",
            sets: 3,
            reps: "10",
            rir: "1-2",
            weight: 0,
            primaryMuscleGroups: ["Back"],
            secondaryMuscleGroups: ["Biceps", "Forearms"],
            rest: const Duration(minutes: 2),
            remainingRestTime: const Duration(minutes: 2)),
        Movement(
            resultSets: [],
            notes: "",
            name: "Low row",
            sets: 3,
            reps: "10",
            rir: "1-2",
            weight: 0,
            primaryMuscleGroups: ["Back"],
            secondaryMuscleGroups: ["Forearms"],
            rest: const Duration(minutes: 2),
            remainingRestTime: const Duration(minutes: 2)),
        Movement(
            resultSets: [],
            notes: "",
            name: "Machine chest press",
            sets: 3,
            reps: "10",
            rir: "1-2",
            weight: 0,
            primaryMuscleGroups: ["Chest"],
            secondaryMuscleGroups: ["Triceps", "Shoulders"],
            rest: const Duration(minutes: 2),
            remainingRestTime: const Duration(minutes: 2)),
        Movement(
            resultSets: [],
            notes: "",
            name: "Machine shoulder press",
            sets: 3,
            reps: "10",
            rir: "1-2",
            weight: 0,
            primaryMuscleGroups: ["Shoulders"],
            secondaryMuscleGroups: ["Triceps"],
            rest: const Duration(minutes: 2),
            remainingRestTime: const Duration(minutes: 2)),
        Movement(
            resultSets: [],
            notes: "",
            name: "Dumbbell bicep curls",
            sets: 2,
            reps: "12",
            rir: "0-1",
            weight: 0,
            primaryMuscleGroups: ["Biceps"],
            secondaryMuscleGroups: ["Forearms"],
            rest: const Duration(minutes: 1, seconds: 30),
            remainingRestTime: const Duration(minutes: 1, seconds: 30)),
      ];

      List<Movement> day2 = [
        Movement(
            resultSets: [],
            notes: "",
            name: "Leg press",
            sets: 4,
            reps: "10",
            rir: "1-2",
            weight: 0,
            primaryMuscleGroups: ["Quads"],
            secondaryMuscleGroups: ["Glutes", "Hamstrings"],
            rest: const Duration(minutes: 2, seconds: 30),
            remainingRestTime: const Duration(minutes: 2, seconds: 30)),
        Movement(
            resultSets: [],
            notes: "",
            name: "Hamstring curls",
            sets: 3,
            reps: "12",
            rir: "1-2",
            weight: 0,
            primaryMuscleGroups: ["Hamstrings"],
            secondaryMuscleGroups: [],
            rest: const Duration(minutes: 2),
            remainingRestTime: const Duration(minutes: 2)),
        Movement(
            resultSets: [],
            notes: "",
            name: "Leg extensions",
            sets: 3,
            reps: "12",
            rir: "1-2",
            weight: 0,
            primaryMuscleGroups: ["Quads"],
            secondaryMuscleGroups: [],
            rest: const Duration(minutes: 2),
            remainingRestTime: const Duration(minutes: 2)),
        Movement(
            resultSets: [],
            notes: "",
            name: "Smith calf raises",
            sets: 3,
            reps: "15",
            rir: "0-1",
            weight: 0,
            primaryMuscleGroups: ["Calves"],
            secondaryMuscleGroups: [],
            rest: const Duration(minutes: 1),
            remainingRestTime: const Duration(minutes: 1)),
      ];

      List<Movement> day3 = day1; // Upper body repeat
      List<Movement> day4 = day2; // Lower body repeat
      List<Movement> rest = [];

      return [day1, day2, rest, day3, day4, rest, rest];
    }
    List<List<Movement>> pplMovements() {
      List<Movement> day1 = [
        Movement(
            resultSets: [],
            notes: "",
            name: "Barbell bench press",
            sets: 4,
            reps: "4-6",
            rir: "0-1",
            weight: 0,
            primaryMuscleGroups: ["Chest"],
            secondaryMuscleGroups: ["Triceps", "Shoulders"],
            rest: const Duration(minutes: 3),
            remainingRestTime: const Duration(minutes: 3)),
        Movement(
            resultSets: [],
            notes: "",
            name: "Dumbbell shoulder press",
            sets: 3,
            reps: "10-12",
            rir: "0-1",
            weight: 0,
            primaryMuscleGroups: ["Shoulders"],
            secondaryMuscleGroups: ["Triceps"],
            rest: const Duration(minutes: 2, seconds: 30),
            remainingRestTime: const Duration(minutes: 2, seconds: 30)),
        Movement(
            resultSets: [],
            notes: "",
            name: "Low-to-high chest flies",
            sets: 2,
            reps: "12",
            rir: "0",
            weight: 0,
            primaryMuscleGroups: ["Chest"],
            rest: const Duration(minutes: 1),
            remainingRestTime: const Duration(minutes: 1)),
        Movement(
            resultSets: [],
            notes: "",
            name: "Smith close-grip bench",
            sets: 2,
            reps: "12",
            rir: "0",
            weight: 0,
            primaryMuscleGroups: ["Triceps"],
            secondaryMuscleGroups: ["Chest"],
            rest: const Duration(minutes: 1, seconds: 30),
            remainingRestTime: const Duration(minutes: 1, seconds: 30)),
        Movement(
            resultSets: [],
            notes: "",
            name: "Dumbbell lateral raise",
            sets: 2,
            reps: "12",
            rir: "0",
            weight: 0,
            primaryMuscleGroups: ["Shoulders"],
            rest: const Duration(minutes: 1),
            remainingRestTime: const Duration(minutes: 1)),
      ];

      List<Movement> day2 = [
        Movement(
            resultSets: [],
            notes: "",
            name: "Weighted pull-ups",
            sets: 4,
            reps: "5-7",
            rir: "1-2",
            weight: 0,
            primaryMuscleGroups: ["Back"],
            secondaryMuscleGroups: ["Biceps", "Forearms"],
            rest: const Duration(minutes: 2, seconds: 30),
            remainingRestTime: const Duration(minutes: 2, seconds: 30)),
        Movement(
            resultSets: [],
            notes: "",
            name: "Barbell rows",
            sets: 3,
            reps: "10-12",
            rir: "1-2",
            weight: 0,
            primaryMuscleGroups: ["Back"],
            secondaryMuscleGroups: ["Forearms"],
            rest: const Duration(minutes: 2),
            remainingRestTime: const Duration(minutes: 2)),
        Movement(
            resultSets: [],
            notes: "",
            name: "Dumbbell pullovers",
            sets: 3,
            reps: "12",
            rir: "0-1",
            weight: 0,
            primaryMuscleGroups: ["Back"],
            rest: const Duration(minutes: 1, seconds: 30),
            remainingRestTime: const Duration(minutes: 1, seconds: 30)),
        Movement(
            resultSets: [],
            notes: "",
            name: "Face pulls",
            sets: 2,
            reps: "12",
            rir: "0-1",
            weight: 0,
            primaryMuscleGroups: ["Back", "Shoulders"],
            rest: const Duration(minutes: 1),
            remainingRestTime: const Duration(minutes: 1)),
        Movement(
            resultSets: [],
            notes: "",
            name: "Dumbbell hammer curls",
            sets: 3,
            reps: "8-10",
            rir: "0-1",
            weight: 0,
            primaryMuscleGroups: ["Biceps"],
            secondaryMuscleGroups: ["Forearms"],
            rest: const Duration(minutes: 2),
            remainingRestTime: const Duration(minutes: 2)),
        Movement(
            resultSets: [],
            notes: "",
            name: "Bayesian curl",
            sets: 2,
            reps: "12",
            rir: "0",
            weight: 0,
            primaryMuscleGroups: ["Biceps"],
            secondaryMuscleGroups: ["Forearms"],
            rest: const Duration(minutes: 1, seconds: 30),
            remainingRestTime: const Duration(minutes: 1, seconds: 30)),
      ];

      List<Movement> day3 = [
        Movement(
            resultSets: [],
            notes: "",
            name: "Barbell back squats",
            sets: 3,
            reps: "4-6",
            rir: "0-1",
            weight: 0,
            primaryMuscleGroups: ["Quads"],
            secondaryMuscleGroups: ["Glutes", "Hamstrings"],
            rest: const Duration(minutes: 3, seconds: 30),
            remainingRestTime: const Duration(minutes: 3, seconds: 30)),
        Movement(
            resultSets: [],
            notes: "",
            name: "Weighted back extensions",
            sets: 2,
            reps: "12",
            rir: "0-1",
            weight: 0,
            primaryMuscleGroups: ["Hamstrings", "Glutes"],
            secondaryMuscleGroups: ["Back"],
            rest: const Duration(minutes: 2),
            remainingRestTime: const Duration(minutes: 2)),
        Movement(
            resultSets: [],
            notes: "",
            name: "Smith calf raises",
            sets: 3,
            reps: "15-20",
            rir: "0",
            weight: 0,
            primaryMuscleGroups: ["Calves"],
            rest: const Duration(minutes: 2),
            remainingRestTime: const Duration(minutes: 2)),
      ];

      List<Movement> day4 = day1; // Upper body repeat
      List<Movement> day5 = day2; // Back + biceps repeat
      List<Movement> day6 = day3; // Lower body repeat
      List<Movement> rest = [];

      return [day1, day2, day3, day4, day5, day6, rest];
    }
    List<List<Movement>> arnoldMovements() {
      List<Movement> day1 = [
        Movement(
            resultSets: [],
            notes: "",
            name: "Lat pulldown",
            sets: 4,
            reps: "10",
            rir: "1-2",
            weight: 0,
            primaryMuscleGroups: ["Back"],
            secondaryMuscleGroups: ["Biceps", "Forearms"],
            rest: const Duration(minutes: 2, seconds: 30),
            remainingRestTime: const Duration(minutes: 2, seconds: 30)),
        Movement(
            resultSets: [],
            notes: "",
            name: "Chest supported row",
            sets: 3,
            reps: "10",
            rir: "1-2",
            weight: 0,
            primaryMuscleGroups: ["Back"],
            secondaryMuscleGroups: ["Forearms"],
            rest: const Duration(minutes: 2),
            remainingRestTime: const Duration(minutes: 2)),
        Movement(
            resultSets: [],
            notes: "",
            name: "Dumbbell pullovers",
            sets: 3,
            reps: "12",
            rir: "0-1",
            weight: 0,
            primaryMuscleGroups: ["Back"],
            rest: const Duration(minutes: 2),
            remainingRestTime: const Duration(minutes: 2)),
        Movement(
            resultSets: [],
            notes: "",
            name: "Barbell bench press",
            sets: 3,
            reps: "8-10",
            rir: "0",
            weight: 0,
            primaryMuscleGroups: ["Chest"],
            secondaryMuscleGroups: ["Shoulders", "Triceps"],
            rest: const Duration(minutes: 2),
            remainingRestTime: const Duration(minutes: 2, seconds: 30)),
        Movement(
            resultSets: [],
            notes: "",
            name: "Low-to-high chest flies",
            sets: 3,
            reps: "12",
            rir: "0",
            weight: 0,
            primaryMuscleGroups: ["Chest"],
            rest: const Duration(minutes: 1, seconds: 30),
            remainingRestTime: const Duration(minutes: 1, seconds: 30)),
      ];

      List<Movement> day2 = [
        Movement(
            resultSets: [],
            notes: "",
            name: "Preacher curls",
            sets: 3,
            reps: "10",
            rir: "1-2",
            weight: 0,
            primaryMuscleGroups: ["Biceps"],
            secondaryMuscleGroups: ["Forearms"],
            rest: const Duration(minutes: 2),
            remainingRestTime: const Duration(minutes: 2)),
        Movement(
            resultSets: [],
            notes: "",
            name: "Cable hammer curls",
            sets: 2,
            reps: "12",
            rir: "1-2",
            weight: 0,
            primaryMuscleGroups: ["Biceps"],
            secondaryMuscleGroups: ["Forearms"],
            rest: const Duration(minutes: 1, seconds: 30),
            remainingRestTime: const Duration(minutes: 1, seconds: 30)),
        Movement(
            resultSets: [],
            notes: "",
            name: "Dumbbell shoulder press",
            sets: 3,
            reps: "10",
            rir: "1-2",
            weight: 0,
            primaryMuscleGroups: ["Shoulders"],
            secondaryMuscleGroups: ["Triceps"],
            rest: const Duration(minutes: 2, seconds: 30),
            remainingRestTime: const Duration(minutes: 2, seconds: 30)),
        Movement(
            resultSets: [],
            notes: "",
            name: "Egyptian lateral raise",
            sets: 2,
            reps: "12",
            rir: "1-2",
            weight: 0,
            primaryMuscleGroups: ["Shoulders"],
            rest: const Duration(minutes: 1, seconds: 30),
            remainingRestTime: const Duration(minutes: 1, seconds: 30)),
        Movement(
            resultSets: [],
            notes: "",
            name: "Face pulls",
            sets: 3,
            reps: "12",
            rir: "0-1",
            weight: 0,
            primaryMuscleGroups: ["Back", "Shoulders"],
            rest: const Duration(minutes: 1, seconds: 30),
            remainingRestTime: const Duration(minutes: 1, seconds: 30)),
        Movement(
            resultSets: [],
            notes: "",
            name: "Tricep pushdowns",
            sets: 2,
            reps: "12",
            rir: "1-2",
            weight: 0,
            primaryMuscleGroups: ["Triceps"],
            rest: const Duration(minutes: 1, seconds: 30),
            remainingRestTime: const Duration(minutes: 1, seconds: 30)),
        Movement(
            resultSets: [],
            notes: "",
            name: "Overhead Tricep pushdowns",
            sets: 2,
            reps: "12",
            rir: "1-2",
            weight: 0,
            primaryMuscleGroups: ["Triceps"],
            rest: const Duration(minutes: 1, seconds: 30),
            remainingRestTime: const Duration(minutes: 1, seconds: 30)),
      ];
      day2[5].superset = true;

      List<Movement> day3 = [
        Movement(
            resultSets: [],
            notes: "",
            name: "Hamstring curls",
            sets: 2,
            reps: "12",
            rir: "1-2",
            weight: 0,
            primaryMuscleGroups: ["Hamstrings"],
            rest: const Duration(minutes: 1, seconds: 30),
            remainingRestTime: const Duration(minutes: 1, seconds: 30)),
        Movement(
            resultSets: [],
            notes: "",
            name: "Barbell back squats",
            sets: 3,
            reps: "10",
            rir: "1-2",
            weight: 0,
            primaryMuscleGroups: ["Quads"],
            secondaryMuscleGroups: ["Glutes", "Hamstrings"],
            rest: const Duration(minutes: 2, seconds: 30),
            remainingRestTime: const Duration(minutes: 2, seconds: 30)),
        Movement(
            resultSets: [],
            notes: "",
            name: "Dumbbell RDLs",
            sets: 3,
            reps: "10",
            rir: "0-1",
            weight: 0,
            primaryMuscleGroups: ["Hamstrings"],
            secondaryMuscleGroups: ["Glutes"],
            rest: const Duration(minutes: 2),
            remainingRestTime: const Duration(minutes: 2)),
        Movement(
            resultSets: [],
            notes: "",
            name: "Leg extensions",
            sets: 2,
            reps: "12",
            rir: "0",
            weight: 0,
            primaryMuscleGroups: ["Quads"],
            rest: const Duration(minutes: 1),
            remainingRestTime: const Duration(minutes: 1)),
        Movement(
            resultSets: [],
            notes: "",
            name: "Smith calf raises",
            sets: 4,
            reps: "15",
            rir: "0",
            weight: 0,
            primaryMuscleGroups: ["Calves"],
            rest: const Duration(minutes: 2),
            remainingRestTime: const Duration(minutes: 2)),
      ];

      List<Movement> day4 = day1; // Upper body repeat
      List<Movement> day5 = day2; // Arms + shoulders repeat
      List<Movement> day6 = day3; // Lower body repeat
      List<Movement> rest = [];

      return [day1, day2, day3, day4, day5, day6, rest];
    }
    List<List<Movement>> upperlowerMovements() {
      List<Movement> day1 = [
        Movement(
            resultSets: [],
            notes: "",
            name: "Barbell bench press",
            sets: 4,
            reps: "4-6",
            rir: "0-1",
            weight: 0,
            primaryMuscleGroups: ["Chest"],
            secondaryMuscleGroups: ["Triceps", "Shoulders"],
            rest: const Duration(minutes: 3),
            remainingRestTime: const Duration(minutes: 3)),
        Movement(
            resultSets: [],
            notes: "",
            name: "Dumbbell shoulder press",
            sets: 3,
            reps: "10-12",
            rir: "0-1",
            weight: 0,
            primaryMuscleGroups: ["Shoulders"],
            secondaryMuscleGroups: ["Triceps"],
            rest: const Duration(minutes: 2),
            remainingRestTime: const Duration(minutes: 2)),
        Movement(
            resultSets: [],
            notes: "",
            name: "Weighted pull-ups",
            sets: 3,
            reps: "6-8",
            rir: "0-1",
            weight: 0,
            primaryMuscleGroups: ["Back"],
            secondaryMuscleGroups: ["Biceps", "Forearms"],
            rest: const Duration(minutes: 2),
            remainingRestTime: const Duration(minutes: 2)),
        Movement(
            resultSets: [],
            notes: "",
            name: "Barbell rows",
            sets: 3,
            reps: "8-10",
            rir: "0-1",
            weight: 0,
            primaryMuscleGroups: ["Back"],
            secondaryMuscleGroups: ["Forearms"],
            rest: const Duration(minutes: 2),
            remainingRestTime: const Duration(minutes: 2)),
        Movement(
            resultSets: [],
            notes: "",
            name: "Dumbbell hammer curls",
            sets: 3,
            reps: "10-12",
            rir: "0",
            weight: 0,
            primaryMuscleGroups: ["Biceps"],
            secondaryMuscleGroups: ["Forearms"],
            rest: const Duration(minutes: 2),
            remainingRestTime: const Duration(minutes: 2)),
        Movement(
            resultSets: [],
            notes: "",
            name: "Tricep pushdowns",
            sets: 3,
            reps: "10-12",
            rir: "0",
            weight: 0,
            primaryMuscleGroups: ["Triceps"],
            rest: const Duration(minutes: 1, seconds: 30),
            remainingRestTime: const Duration(minutes: 1, seconds: 30)),
      ];

      List<Movement> day2 = [
        Movement(
            resultSets: [],
            notes: "",
            name: "Barbell back squats",
            sets: 4,
            reps: "4-6",
            rir: "0",
            weight: 0,
            primaryMuscleGroups: ["Quads"],
            secondaryMuscleGroups: ["Glutes", "Hamstrings"],
            rest: const Duration(minutes: 3, seconds: 30),
            remainingRestTime: const Duration(minutes: 3, seconds: 30)),
        Movement(
            resultSets: [],
            notes: "",
            name: "Weighted back extensions",
            sets: 2,
            reps: "12",
            rir: "0-1",
            weight: 0,
            primaryMuscleGroups: ["Hamstrings", "Glutes"],
            secondaryMuscleGroups: ["Back"],
            rest: const Duration(minutes: 2),
            remainingRestTime: const Duration(minutes: 2)),
        Movement(
            resultSets: [],
            notes: "",
            name: "Smith calf raises",
            sets: 3,
            reps: "15-20",
            rir: "0-1",
            weight: 0,
            primaryMuscleGroups: ["Calves"],
            rest: const Duration(minutes: 2),
            remainingRestTime: const Duration(minutes: 2)),
      ];

      List<Movement> day3 = [
        Movement(
            resultSets: [],
            notes: "",
            name: "Dumbbell shoulder press",
            sets: 4,
            reps: "6-8",
            rir: "0-1",
            weight: 0,
            primaryMuscleGroups: ["Shoulders"],
            secondaryMuscleGroups: ["Triceps"],
            rest: const Duration(minutes: 2, seconds: 30),
            remainingRestTime: const Duration(minutes: 2, seconds: 30)),
        Movement(
            resultSets: [],
            notes: "",
            name: "Barbell bench press",
            sets: 3,
            reps: "10-12",
            rir: "0-1",
            weight: 0,
            primaryMuscleGroups: ["Chest"],
            secondaryMuscleGroups: ["Triceps", "Shoulders"],
            rest: const Duration(minutes: 2),
            remainingRestTime: const Duration(minutes: 2)),
        Movement(
            resultSets: [],
            notes: "",
            name: "Barbell rows",
            sets: 3,
            reps: "6-8",
            rir: "0-1",
            weight: 0,
            primaryMuscleGroups: ["Back"],
            secondaryMuscleGroups: ["Forearms"],
            rest: const Duration(minutes: 2),
            remainingRestTime: const Duration(minutes: 2)),
        Movement(
            resultSets: [],
            notes: "",
            name: "Weighted pull-ups",
            sets: 3,
            reps: "8-10",
            rir: "0-1",
            weight: 0,
            primaryMuscleGroups: ["Back"],
            secondaryMuscleGroups: ["Forearms"],
            rest: const Duration(minutes: 2),
            remainingRestTime: const Duration(minutes: 2)),
        Movement(
            resultSets: [],
            notes: "",
            name: "Dumbbell hammer curls",
            sets: 3,
            reps: "10-12",
            rir: "0",
            weight: 0,
            primaryMuscleGroups: ["Biceps"],
            secondaryMuscleGroups: ["Forearms"],
            rest: const Duration(minutes: 2),
            remainingRestTime: const Duration(minutes: 2)),
        Movement(
            resultSets: [],
            notes: "",
            name: "Tricep pushdowns",
            sets: 3,
            reps: "10-12",
            rir: "0",
            weight: 0,
            primaryMuscleGroups: ["Triceps"],
            rest: const Duration(minutes: 1, seconds: 30),
            remainingRestTime: const Duration(minutes: 1, seconds: 30)),
      ];

      List<Movement> day4 = [
        Movement(
            resultSets: [],
            notes: "",
            name: "Barbell back squats",
            sets: 3,
            reps: "10-12",
            rir: "0",
            weight: 0,
            primaryMuscleGroups: ["Quads"],
            secondaryMuscleGroups: ["Glutes", "Hamstrings"],
            rest: const Duration(minutes: 2, seconds: 30),
            remainingRestTime: const Duration(minutes: 2, seconds: 30)),
        Movement(
            resultSets: [],
            notes: "",
            name: "Weighted back extensions",
            sets: 2,
            reps: "12",
            rir: "0-1",
            weight: 0,
            primaryMuscleGroups: ["Hamstrings", "Glutes"],
            secondaryMuscleGroups: ["Back"],
            rest: const Duration(minutes: 2),
            remainingRestTime: const Duration(minutes: 2)),
        Movement(
            resultSets: [],
            notes: "",
            name: "Smith calf raises",
            sets: 3,
            reps: "15-20",
            rir: "0-1",
            weight: 0,
            primaryMuscleGroups: ["Calves"],
            rest: const Duration(minutes: 2),
            remainingRestTime: const Duration(minutes: 2)),
      ];

      List<Movement> day5 = [
        Movement(
            resultSets: [],
            notes: "Form focused light benching",
            name: "Barbell bench press",
            sets: 3,
            reps: "15",
            rir: "5",
            weight: 0,
            primaryMuscleGroups: ["Chest"],
            secondaryMuscleGroups: ["Triceps", "Shoulders"],
            rest: const Duration(minutes: 2, seconds: 30),
            remainingRestTime: const Duration(minutes: 2, seconds: 30)),
        Movement(
            resultSets: [],
            notes: "",
            name: "Dumbbell lateral raise",
            sets: 3,
            reps: "15",
            rir: "0",
            weight: 0,
            primaryMuscleGroups: ["Shoulders"],
            rest: const Duration(minutes: 1),
            remainingRestTime: const Duration(minutes: 1)),
        Movement(
            resultSets: [],
            notes: "",
            name: "Bayesian curl",
            sets: 3,
            reps: "10-12",
            rir: "0-1",
            weight: 0,
            primaryMuscleGroups: ["Biceps"],
            rest: const Duration(minutes: 1, seconds: 30),
            remainingRestTime: const Duration(minutes: 1, seconds: 30)),
      ];

      List<Movement> rest = [];

      return [day1, day2, rest, day3, day4, day5, rest];
    }


    addProgram(8, "Starter 4-day", <String> ["Upper", "Lower", "Rest", "Upper", "Lower", "Rest", "Rest"], starterMovements());
    programsList.last.experienceLevel = "Beginner";

    addProgram(8, "Standard PPL", <String> ["Push", "Pull", "Legs", "Push", "Pull", "Legs", "Rest"], pplMovements());
    programsList.last.experienceLevel = "Intermediate";

    addProgram(5, "Arnold split", <String> ["Chack", "Arms", "Legs", "Chack", "Arms", "Legs", "Rest"], arnoldMovements());
    programsList.last.experienceLevel = "Intermediate";

    addProgram(8, "Upper/Lower", <String> ["Upper", "Lower", "Rest", "Upper", "Lower", "Filler", "Rest"], upperlowerMovements());
    programsList.last.experienceLevel = "Intermediate";
  }

  static void addProgram(numberOfWeeksInProgram, programName, trainingSplit, List<List<Movement>> movementsLists) {
    List<Week> weeks = [];
    List<day> days = [];
    int weekMultiplier = 0;

    for (int i = 0; i < numberOfWeeksInProgram; i++) {
      for (int j = 0; j < 7; j++) {
        List<Movement> thisDaysMovements = [];
        for (int x = 0; x < movementsLists[j].length; x++) {
          thisDaysMovements.add(
              Movement( resultSets: [], //movements list is a 2d list, hence the [j][x]
                  notes: movementsLists[j][x].notes,
                  name: movementsLists[j][x].name,
                  sets: movementsLists[j][x].sets,
                  reps: movementsLists[j][x].reps,
                  rir: movementsLists[j][x].rir,
                  weight: movementsLists[j][x].weight,
                  rest: movementsLists[j][x].rest,
                  primaryMuscleGroups: movementsLists[j][x].primaryMuscleGroups?.toList(),
                  secondaryMuscleGroups: movementsLists[j][x].secondaryMuscleGroups?.toList(),
                  remainingRestTime: movementsLists[j][x].remainingRestTime));
          if(movementsLists[j][x].superset == true) {
            thisDaysMovements.last.superset = true;
          }
        }

        days.add(day(id: -1, name: trainingSplit[j], movements: thisDaysMovements, muscleGroups: calcMuscleGroups(trainingSplit[j])));
      }

      List<day> weekDays = days.sublist((7 * weekMultiplier));
      weeks.add(Week(name: "Week ${i + 1}", days: weekDays));
      weekMultiplier++;
    }
    programsList.add(Program(weeks: weeks, date: DateTime.now(), name: programName));
  }


}

List<String> calcMuscleGroups(daysName) {
  /*
   since I (for some reason) made the days in the program a 2D list of movements,
   rather than just a list of days with movements, this is my quick solution to adding muscle groups to the days
   */

switch (daysName) {
  case "Upper":

  return ["Chest", "Back", "Shoulders", "Biceps", "Triceps", "Forearms"];

  case "Lower":

  return ["Hamstrings", "Quads", "Calves", "Glutes"];

  case "Push":

  return ["Chest", "Shoulders", "Triceps"];

  case "Pull":

  return ["Back", "Biceps", "Forearms"];

  case "Legs":

  return ["Hamstrings", "Quads", "Calves", "Glutes"];

  case "Chack":

  return ["Chest", "Back"];

  case "Arms":

  return ["Shoulders", "Triceps", "Biceps"];

  default:

  return [];
  }
}

