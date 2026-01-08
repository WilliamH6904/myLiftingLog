import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:showcaseview/showcaseview.dart';
import 'home_screen.dart';
import 'main.dart';
import 'open_program.dart';
import 'custom_program_screens.dart';
import 'dialogs.dart';
import 'preset_programs.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GlobalKey programCreationKey = GlobalKey();
final GlobalKey programsListKey = GlobalKey();
final GlobalKey editingProgramsKey = GlobalKey();


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
    if (!ShowcaseTemplate.previousSteps.contains(widget.stepID) && !ShowcaseTemplate.previousSteps.contains(-1)) {
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


class ProgramsPage extends StatefulWidget {
  static List<Program> programsList = Boxes.getPrograms().values.toList().cast<Program>();
  static int globalDayID = 0;
  static Future? setDayIDPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt("globalDayID", globalDayID);
  }

  static int activeProgramIndex = 0;

  @override
  State<ProgramsPage> createState() => _ProgramsPageState();
}

class _ProgramsPageState extends State<ProgramsPage> {
final box = Boxes.getPrograms();
final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

void updateProgramList (Program newProgram) {
    setState(() {
      box.add(newProgram);
      ProgramsPage.programsList.add(newProgram);
      if (ProgramsPage.programsList.length == 1) {
        ProgramsPage.programsList[0].isCurrentProgram = true;
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        ShowcaseView.get().startShowCase([programsListKey, editingProgramsKey]);
      });
    });
  }


void editLabel(editedText, identifier) {
  setState(() {
    if(editedText != "") {
      ProgramsPage.programsList[ProgramsPage.activeProgramIndex].name = editedText;
      ProgramsPage.programsList[ProgramsPage.activeProgramIndex].save();
    }
  });
}

@override
  void initState() {
    super.initState();

    ShowcaseView.register();

    WidgetsBinding.instance.addPostFrameCallback(
          (_) {
            if (ProgramsPage.programsList.isNotEmpty) {
              ShowcaseView.get().startShowCase([programCreationKey, programsListKey, editingProgramsKey]);
            }
            else {
              ShowcaseView.get().startShowCase([programCreationKey]);
            }
          }
    );
  }

  @override
  Widget build(BuildContext context) {
    ProgramsPage.programsList.sort((a, b) {
      if (a.isCurrentProgram != b.isCurrentProgram) {
        return a.isCurrentProgram ? -1 : 1;
      } else {
        return b.date.compareTo(a.date);
      }
    });




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
          toolbarHeight: 70,
          automaticallyImplyLeading: false,

          actions: [
              Expanded(
                  child: Column(
                    children: [
                      ShowcaseTemplate(
                        radius: 20,
                          globalKey: programCreationKey,
                          stepID: 0, title: "Creating Programs",
                          content: "These are your options for making new programs. You can choose from a predefined template, or make your own custom split.",
                          child: Row(
                        children: [
                          Container(
                            width: 150,
                            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 3),
                            decoration: BoxDecoration(
                              gradient: Styles.darkGradient(),
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(20.0),
                                bottomRight: Radius.circular(20.0),
                              ),
                              border: const Border(
                                top:  BorderSide(color: Colors.black54, width: 1.0),

                                right: BorderSide(color: Colors.black54, width: 4),
                                bottom: BorderSide(color: Colors.black54, width: 5),
                              ),
                            ),

                            child: GestureDetector(
                                onTap: () {
                                  _scaffoldKey.currentState?.openDrawer();
                                },
                                child: const Text("Template", style: Styles.labelText, textAlign: TextAlign.center)
                            ),
                          ),
                          const Spacer(),
                          Container(
                            width: 150,
                            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 3),
                            decoration: BoxDecoration(
                              gradient: Styles.darkGradient(),
                              borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  bottomLeft: Radius.circular(20)
                              ),
                              border: const Border(
                                top:  BorderSide(color: Colors.black54, width: 1.0),
                                left: BorderSide(color: Colors.black54, width: 4),
                                bottom: BorderSide(color: Colors.black54, width: 5),
                              ),
                              color: Styles.secondaryColor,
                            ),

                            child: GestureDetector(
                                onTap: () {
                                  _scaffoldKey.currentState?.openEndDrawer();
                                },
                                child: const Text("Custom", style: Styles.labelText, textAlign: TextAlign.center)
                            ),
                          ),
                        ],
                      ))
                    ],
                  ),
              ),
            ],
        ),
       drawer:  Drawer(width: MediaQuery.of(context).size.width * 0.85,
           child: PresetPrograms(updateProgramList: updateProgramList)),
       endDrawer: Drawer(width: MediaQuery.of(context).size.width * 0.85,
           child: CustomProgramScreens(updateProgramList: updateProgramList)),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: Styles.horizontal()
          ),
          child: Column(
            children: [
               Expanded(
                  child: ListView.builder(
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                itemCount: ProgramsPage.programsList.length,
                                itemBuilder: (context, index) {
                                  String label = ProgramsPage.programsList[index].name;


                                  return InkWell(
                                    onTap: () {
                                      ProgramsPage.activeProgramIndex = index; // this is so when you click this button the index of this item in the listView is passed to the activeProgramIndex
                                      Navigator.of(context).push(              // so that the rest of the app knows which program inside of the Programs list to open
                                        MaterialPageRoute(
                                          builder: (context) => OpenProgram(),
                                        ),
                                      );
                                    },
                                      child: ShowcaseTemplate(
                                        radius: 0,
                                        globalKey: programsListKey,
                                        stepID: 1,
                                        title: "Programs List",
                                        content: "Your programs will be listed here, where you can tap to open them.",
                                       child: Container(
                                          color: ProgramsPage.programsList[index].isCurrentProgram ? Colors.black26 : Colors.black12,
                                          height: 100,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                                Row(
                                                  children: [
                                                         Expanded(child: Text(label, style: Styles.labelText)),
                                                        ShowcaseTemplate(
                                                          globalKey: editingProgramsKey,
                                                          radius: 10,
                                                          stepID: 34,
                                                          title: "Editing Programs",
                                                          content: "This is where you can edit program properties and set your current program.",
                                                          child: PopupMenuButton<ListTile>(
                                                                 itemBuilder: (context) {
                                                                   return [
                                                                     PopupMenuItem<ListTile>(
                                                                       onTap: () {
                                                                         setState(() {
                                                                           for (Program program in ProgramsPage.programsList) {
                                                                             if(program != ProgramsPage.programsList[index] && program.isCurrentProgram == true) {
                                                                               program.isCurrentProgram = false;
                                                                               program.save();
                                                                             }
                                                                           }

                                                                           ProgramsPage.programsList[index].isCurrentProgram = !ProgramsPage.programsList[index].isCurrentProgram;
                                                                           ProgramsPage.programsList[index].save();
                                                                         });
                                                                       },
                                                                       child: ListTile(
                                                                         leading: Icon(ProgramsPage.programsList[index].isCurrentProgram == true ? Icons.check_box : Icons.check_box_outlined, color: Styles.primaryColor),
                                                                         title: Text('Current program', style: TextStyle(color: Styles.primaryColor)),
                                                                       ),
                                                                     ),
                                                                     PopupMenuItem<ListTile>(
                                                                       onTap: () {
                                                                         ProgramsPage.activeProgramIndex = index;
                                                                         Navigator.of(context).push(
                                                                           MaterialPageRoute(
                                                                             builder: (context) =>  ProgramNotes(),
                                                                           ),
                                                                         );
                                                                       },
                                                                       child: ListTile(
                                                                         leading: Icon(Icons.assignment, color: Styles.primaryColor),
                                                                         title: Text('Program notes', style: TextStyle(color: Styles.primaryColor)),
                                                                       ),
                                                                     ),
                                                                     PopupMenuItem<ListTile>(
                                                                       onTap: () {
                                                                         ProgramsPage.activeProgramIndex = index;
                                                                         showDialog(
                                                                             context: context,
                                                                             builder: (BuildContext context) {
                                                                               return EditDialog(dataToEdit: label, identifier: "Name", editData: editLabel);
                                                                             }
                                                                         );
                                                                       },
                                                                       child: ListTile(
                                                                         leading: Icon(Icons.edit, color: Styles.primaryColor),
                                                                         title: Text('Rename', style: TextStyle(color: Styles.primaryColor)),
                                                                       ),
                                                                     ),
                                                                     PopupMenuItem<ListTile>(
                                                                       onTap: () {
                                                                         remove() {
                                                                           setState(() {
                                                                             box.delete(ProgramsPage.programsList[index].key);
                                                                             ProgramsPage.programsList.removeAt(index);
                                                                           });
                                                                         }
                                                                         showDialog(
                                                                             context: context,
                                                                             builder: (BuildContext context) {
                                                                               return ConfirmationDialog(content: "Are you sure you want to delete this program?", callbackFunction: remove);
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
                                                        )
                                                   ]
                                                ),
                                              const Spacer(),
                                                Row(
                                                children: [
                                                 if(ProgramsPage.programsList[index].isCurrentProgram) const Text("Current Program", style: Styles.smallTextWhite),
                                                 const Spacer(),
                                                  Text(
                                                    DateFormat("${AppSettings.dateFormat}yy").format(DateUtils.dateOnly(ProgramsPage.programsList[index].date)).toString(),
                                                    style: Styles.smallTextWhite,
                                                  ),
                                                ],
                                              ),
                                               Divider(height: 0, color: ProgramsPage.programsList[index].isCurrentProgram ? Colors.white : Colors.white54),
                                            ],
                                          ),
                                        ),
                                      ),
                                  );
                                }
                              ),
                ),
            ],
          ),
        )
    );
  }
}




