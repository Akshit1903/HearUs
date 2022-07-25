import 'package:HearUs/style/colors.dart';
import 'package:HearUs/style/fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../services/database.dart';

class Tasks extends StatefulWidget {
  String userId;
  List taskListWidget;
  int completedIndex;
  Tasks(this.userId, this.taskListWidget, this.completedIndex);
  @override
  _TasksState createState() => _TasksState();
}

class _TasksState extends State<Tasks> {
  Future<DocumentSnapshot> userMapFuture;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    userMapFuture = DatabaseMethods().getUserData(widget.userId);
  }

  var taskList = [];
  var completedIndex = -1;
  // @override
  // void initState() {

  //   // TODO: implement initState
  //   print(widget.taskListWidget);
  //   if (widget.taskListWidget != null) {
  //     taskList = widget.taskListWidget;
  //     print(taskList);
  //   }
  //   if (widget.completedIndex != null) {
  //     completedIndex = widget.completedIndex;
  //   }
  // }

  // var taskList = [
  // {
  //   "name": "Tell mark zuckerburg hi",
  //   "time": DateTime.now(),
  //   "description": "My brain hurts and this is a cry for help",
  //   "done": false
  // },
  // {
  //   "name": "Tell mark zuckerburg bye",
  //   "time": DateTime.now(),
  //   "description": "My brain hurts and this is a cry for help",
  //   "done": false,
  // },
  // ];
  // taskAdder() {
  //   showDialog(context: context, builder: (ctx) => AlertDialog());
  // }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: time,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));

    if (picked != null && picked != time) {
      final temp = new DateTime(picked.year, picked.month, picked.day,
          timeOfDay.hour, timeOfDay.minute);
      setState(() {
        time = temp;
      });
    }
  }

  var name = "";
  var timeOfDay = TimeOfDay.now();
  var time = DateTime.now();
  var description = "";
  bool onceFlag = true;
  bool showNewTask = false;
  final now = DateTime.now();
  @override
  Widget build(BuildContext context) {
    // if (widget.taskListWidget != null) {
    //   taskList = [...taskList, ...widget.taskListWidget];
    // }

    return FutureBuilder<DocumentSnapshot>(
        future: userMapFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LinearProgressIndicator();
          }
          if (snapshot.data.data()["taskList"] != null && onceFlag) {
            taskList = [...snapshot.data.data()["taskList"]];
          }
          if (snapshot.data.data()["completedIndex"] != null && onceFlag) {
            completedIndex = snapshot.data.data()["completedIndex"];
            onceFlag = false;
          }
          return Column(
            // crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Row(
                  children: [
                    Text(
                      "Upcoming Tasks",
                      style: AppTextStyle().headingStyleWhite,
                    ),
                    Spacer(),
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          showNewTask = true;
                        });
                      },
                      icon: Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                      label: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Text(
                          "Add new",
                          style: AppTextStyle().headingStyleWhiteSmall,
                        ),
                      ),
                      style: TextButton.styleFrom(),
                    ),
                  ],
                ),
              ),
              if (showNewTask)
                Container(
                  margin: EdgeInsets.all(12),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(
                        Radius.circular(16),
                      )),
                  child: Column(
                    children: [
                      TextField(
                        onChanged: (val) {
                          name = val;
                        },
                        decoration: InputDecoration(hintText: "Enter topic"),
                      ),
                      TextField(
                        onChanged: (val) {
                          description = val;
                        },
                        decoration:
                            InputDecoration(hintText: "Enter description"),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              FocusScope.of(context)
                                  .requestFocus(new FocusNode());
                              TimeOfDay picked = await showTimePicker(
                                  context: context, initialTime: timeOfDay);
                              if (picked != null && picked != time) {
                                setState(() {
                                  timeOfDay = picked;
                                });
                              }
                            },
                            child: Text(
                              "Time-${DateFormat.jm().format(DateTime(
                                now.year,
                                now.month,
                                now.day,
                                timeOfDay.hour,
                                timeOfDay.minute,
                              ))}",
                              style: AppTextStyle().headingStyle,
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              await _selectDate(context);
                            },
                            child: Text(
                              "Date:${time.day}-${time.month}-${time.year}",
                              style: AppTextStyle().headingStyle,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            label: Text(
                              "Cancel",
                              style: TextStyle(color: AppColor().mainBackColor),
                            ),
                            icon: Icon(
                              Icons.cancel,
                              color: AppColor().mainBackColor,
                            ),
                            onPressed: () {
                              setState(() {
                                showNewTask = false;
                                name = "";
                                description = "";
                              });
                            },
                          ),
                          TextButton.icon(
                            label: Text(
                              "DONE",
                              style: TextStyle(color: AppColor().mainBackColor),
                            ),
                            icon: Icon(Icons.done,
                                color: AppColor().mainBackColor),
                            onPressed: () async {
                              if (name != "" && description != "") {
                                print(taskList);
                                setState(() {
                                  taskList.insert(
                                    0,
                                    {
                                      "name": name,
                                      "description": description,
                                      "time": new DateTime(
                                          time.year,
                                          time.month,
                                          time.day,
                                          timeOfDay.hour,
                                          timeOfDay.minute),
                                      "done": false
                                    },
                                  );
                                });
                                print(taskList);
                                if (completedIndex != -1) completedIndex++;

                                name = "";
                                description = "";
                                showNewTask = false;

                                await DatabaseMethods().setTaskList(
                                    taskList, completedIndex, widget.userId);
                                setState(() {});
                              } else {
                                showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                          title: Text("Fields empty!"),
                                          content: Text(
                                              "Make sure you dont leave any field empty"),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: Text("Okay"),
                                            ),
                                          ],
                                        ));
                              }
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              if (taskList.length == 0)
                Expanded(
                  child: Center(
                    child: Container(
                      child: FittedBox(
                        child: Text(
                          "Add a new task!",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      width: MediaQuery.of(context).size.width * 0.7,
                    ),
                  ),
                ),
              if (taskList.length != 0)
                Expanded(
                  child: Container(
                    child: ListView.builder(
                      itemCount: taskList.length,
                      itemBuilder: (ctx, index) {
                        //int index = taskList.length - i - 1;

                        DateTime time;
                        try {
                          time = DateTime.parse(
                              taskList[index]["time"].toDate().toString());
                        } catch (e) {
                          time = taskList[index]["time"];
                        }
                        // if (taskList[index]["time"] == DateTime) {

                        // } else {
                        //   time = DateTime.parse(
                        //       taskList[index]["time"].toDate().toString());
                        // }

                        return Column(
                          children: [
                            if (index == completedIndex)
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Text(
                                      "Completed Tasks",
                                      style: AppTextStyle().headingStyleWhite,
                                    ),
                                  ],
                                ),
                              ),
                            Container(
                              // padding: EdgeInsets.all(15),
                              margin: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(16),
                                  )),
                              child: ExpansionTile(
                                // backgroundColor: Colors.white,
                                // collapsedBackgroundColor: Colors.white,
                                title: Text(
                                  taskList[index]["name"],
                                  style: GoogleFonts.alegreya(
                                    textStyle: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        decoration: taskList[index]["done"]
                                            ? TextDecoration.lineThrough
                                            : TextDecoration.none),
                                  ),
                                ),
                                children: [
                                  Text(
                                    taskList[index]["description"],
                                    style: GoogleFonts.alegreya(
                                      textStyle: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                          decoration: taskList[index]["done"]
                                              ? TextDecoration.lineThrough
                                              : TextDecoration.none),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.alarm,
                                          color: Colors.black,
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          (DateTime.parse(time.toString())
                                                  .isBefore(DateTime.now()
                                                      .subtract(
                                                          Duration(days: 1))))
                                              ? DateFormat.yMEd().format(time)
                                              : DateFormat.jm().format(time),
                                          style: AppTextStyle().bodyTextFinal,
                                        ),
                                        Spacer(),
                                        // IconButton(
                                        //   onPressed: () {},
                                        //   icon: Icon(
                                        //     Icons.delete,
                                        //     size: 50,
                                        //   ),
                                        // ),
                                        if (!taskList[index]["done"])
                                          GestureDetector(
                                            onTap: () async {
                                              setState(() {
                                                taskList[index]["done"] = true;
                                              });
                                              final temp = taskList[index];
                                              if (completedIndex == -1) {
                                                completedIndex =
                                                    taskList.length - 1;
                                                taskList.removeAt(index);
                                                taskList.add(temp);
                                              } else {
                                                completedIndex--;
                                                taskList.removeAt(index);
                                                taskList.insert(
                                                    completedIndex, temp);
                                              }

                                              await DatabaseMethods()
                                                  .setTaskList(
                                                      taskList,
                                                      completedIndex,
                                                      widget.userId);
                                            },
                                            child: SvgPicture.asset(
                                              "assets/dashboard/check-mark-svgrepo-com.svg",
                                              height: 30,
                                            ),
                                          ),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        if (taskList[index]["done"])
                                          IconButton(
                                            onPressed: () async {
                                              if (index ==
                                                  taskList.length - 1) {
                                                if (!taskList[index - 1]
                                                    ["done"])
                                                  completedIndex = -1;
                                              }
                                              setState(() {
                                                taskList.removeAt(index);
                                              });

                                              await DatabaseMethods()
                                                  .setTaskList(
                                                      taskList,
                                                      completedIndex,
                                                      widget.userId);
                                            },
                                            icon: Icon(
                                              Icons.delete,
                                              color: Colors.black,
                                            ),
                                          ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              // Padding(
              //   padding: const EdgeInsets.all(8.0),
              //   child: Row(
              //     children: [
              //       Text(
              //         "Completed Tasks",
              //         style: AppTextStyle().headingStyleWhite,
              //       ),
              //     ],
              //   ),
              // ),
              // if (taskList.length != 0)
              //   Expanded(
              //     child: Container(
              //       child: ListView.builder(
              //         itemCount: taskList.length,
              //         itemBuilder: (ctx, i) {
              //           int index = taskList.length - i - 1;

              //           DateTime time;
              //           try {
              //             time = DateTime.parse(
              //                 taskList[index]["time"].toDate().toString());
              //           } catch (e) {
              //             time = taskList[index]["time"];
              //           }
              //           // if (taskList[index]["time"] == DateTime) {

              //           // } else {
              //           //   time = DateTime.parse(
              //           //       taskList[index]["time"].toDate().toString());
              //           // }

              //           return (taskList[index]["done"])
              //               ? Container(
              //                   // padding: EdgeInsets.all(15),
              //                   margin: EdgeInsets.all(12),
              //                   decoration: BoxDecoration(
              //                       color: Colors.white,
              //                       borderRadius: BorderRadius.all(
              //                         Radius.circular(16),
              //                       )),
              //                   child: ExpansionTile(
              //                     // backgroundColor: Colors.white,
              //                     // collapsedBackgroundColor: Colors.white,
              //                     title: Text(
              //                       taskList[index]["name"],
              //                       style: GoogleFonts.alegreya(
              //                         textStyle: TextStyle(
              //                             fontSize: 15,
              //                             fontWeight: FontWeight.bold,
              //                             color: Colors.black,
              //                             decoration: taskList[index]["done"]
              //                                 ? TextDecoration.lineThrough
              //                                 : TextDecoration.none),
              //                       ),
              //                     ),
              //                     children: [
              //                       Text(
              //                         taskList[index]["description"],
              //                         style: GoogleFonts.alegreya(
              //                           textStyle: TextStyle(
              //                               fontSize: 15,
              //                               fontWeight: FontWeight.bold,
              //                               color: Colors.black,
              //                               decoration: taskList[index]["done"]
              //                                   ? TextDecoration.lineThrough
              //                                   : TextDecoration.none),
              //                         ),
              //                       ),
              //                       Padding(
              //                         padding: const EdgeInsets.all(8.0),
              //                         child: Row(
              //                           children: [
              //                             Icon(
              //                               Icons.alarm,
              //                               color: Colors.black,
              //                             ),
              //                             SizedBox(
              //                               width: 10,
              //                             ),
              //                             Text(
              //                               (DateTime.parse(time.toString()).isBefore(
              //                                       DateTime.now()
              //                                           .subtract(Duration(days: 1))))
              //                                   ? DateFormat.yMEd().format(time)
              //                                   : DateFormat.jm().format(time),
              //                               style: AppTextStyle().bodyTextFinal,
              //                             ),
              //                             Spacer(),
              //                             // IconButton(
              //                             //   onPressed: () {},
              //                             //   icon: Icon(
              //                             //     Icons.delete,
              //                             //     size: 50,
              //                             //   ),
              //                             // ),

              //                             IconButton(
              //                               onPressed: () {
              //                                 setState(() {
              //                                   taskList.removeAt(index);
              //                                 });
              //                               },
              //                               icon: Icon(
              //                                 Icons.delete,
              //                                 color: Colors.black,
              //                               ),
              //                             ),
              //                             // SizedBox(
              //                             //   width: 20,
              //                             // ),
              //                           ],
              //                         ),
              //                       )
              //                     ],
              //                   ),
              //                 )
              //               : Container();
              //         },
              //       ),
              //     ),
              //   ),
            ],
          );
        });
  }
}
