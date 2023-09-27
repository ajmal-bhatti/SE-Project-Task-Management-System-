import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:app/notification.dart';
import 'package:app/main.dart';

void main() {
  runApp(MyApp());
}

final TextEditingController dateController = TextEditingController();

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Task Management System',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TaskSelectionScreen(),
    );
  }
}

//This function is used to select the date
Future<DateTime?> selectDate(BuildContext context) async {
  DateTime? selectedDate = DateTime.now();

  await showDatePicker(
    context: context,
    initialDate: selectedDate!,
    firstDate: DateTime(2000),
    lastDate: DateTime(2101),
    builder: (BuildContext context, Widget? child) {
      return Theme(
        data: ThemeData.light(), // You can customize the theme if needed
        child: child!,
      );
    },
  ).then((pickedDate) {
    if (pickedDate != null && pickedDate != selectedDate) {
      selectedDate = pickedDate;
    }
  });

  return selectedDate;
}

//This function is used to show the alert dialog
void showTextDialog(BuildContext context, String text) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.error,
              color: Colors.red,
            ),
            SizedBox(width: 8),
            Text('Alert'),
          ],
        ),
        content: Text(text),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text('OK'),
          ),
        ],
      );
    },
  );
}

var resp;
String task = "";
String category = "";
Future<void> givedata(String selectedtask, String selectedcategory) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int Users_Id = prefs.getInt('Id') ?? 0;
  var res;
  var resp;
  print(selectedtask);
  print(selectedcategory);
  print(Users_Id.toString());
  if (selectedtask != "" &&
      selectedcategory != "" &&
      dateController.text != "") {
    try {
      String uri =
          "http://10.5.116.179/task_management_systems_api/inserttaskcategory.php";
      res = await http.post(Uri.parse(uri), body: {
        "task_name": selectedtask,
        "task_category": selectedcategory,
        "Users_Id": Users_Id.toString(),
        "schedule_Date": dateController.text,
      });
      resp = jsonDecode(res.body);
      if (resp["success"] == "true" && resp["Exist"] == "false") {
        print("Task is Scheduled at selected date");
        dateController.text = "";
      }
      if (resp["success"] == "false" && resp["Exist"] == "true") {
        print("Task is expired at selected date");
      }
    } catch (e) {
      print(e.toString());
      print(resp.body);
      String uris =
          "http://10.5.116.179/task_management_systems_api/insertlog.php";
      var res = await http.post(Uri.parse(uris), body: {
        "Log_Title": resp.body.toString(),
        "From_Table": "Task_Category",
      });
    }
  } else {
    print("Please fill all the fields");
  }
}

final NotificationHelper notificationHelper = NotificationHelper();

class TaskSelectionScreen extends StatefulWidget {
  @override
  _TaskSelectionScreenState createState() => _TaskSelectionScreenState();
}

class _TaskSelectionScreenState extends State<TaskSelectionScreen> {
  String selectedTask = '';
  List<String> tasks = [];
  String selectedcategory = '';
  List<String> category = [];

  @override
  void initState() {
    super.initState();
    fetchData();
    fetchData1();
  }

  void showNotification(String title, String body) {
    notificationHelper.showNotification(
      title,
      body,
    );
  }

//This function is used to fetch the data from the database
  Future<void> fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int userId = prefs.getInt('Id') ?? 0;
    var res;
    var response;
    if (userId != 0) {
      try {
        String uri =
            "http://10.5.116.179/task_management_systems_api/gettask.php";
        res = await http.post(Uri.parse(uri), body: {
          "Users_Id": userId.toString(),
        });
        print("geo");
        response = jsonDecode(res.body);
        print("Hellogh");
        if (response != null) {
          print("hey");
          for (String taskName in response) {
            print(taskName);
            tasks.add(taskName);
          }
          print("buy");
          setState(() {
            selectedTask = tasks.isNotEmpty ? tasks[0] : '';
          });
        }
        if (response == null) {
          print("No Task");
        }
      } catch (e) {
        print(e);
        print(response?.body);
        String uris =
            "http://10.5.116.179/task_management_systems_api/insertlog.php";
        var res = await http.post(Uri.parse(uris), body: {
          "Log_Title": resp.body.toString(),
          "From_Table": "Task",
        });
      }
    } else {
      // Handle the case when userId is 0
    }
  }

//This function is used to fetch the data from the database
  Future<void> fetchData1() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int userId = prefs.getInt('Id') ?? 0;
    var res;
    var response;
    if (userId != 0) {
      try {
        String uri =
            "http://10.5.116.179/task_management_systems_api/getcategory.php";
        res = await http.post(Uri.parse(uri), body: {
          "Users_Id": userId.toString(),
        });
        print("geo");
        response = jsonDecode(res.body);
        print("Hellogh");
        if (response != null) {
          print("hey");
          for (String taskName in response) {
            print(taskName);
            category.add(taskName);
          }
          print("buy");
          setState(() {
            selectedcategory = category.isNotEmpty ? category[0] : '';
          });
        }
        if (response == null) {
          print("No Task");
        }
      } catch (e) {
        print(e);
        print(response?.body);
        String uris =
            "http://10.5.116.179/task_management_systems_api/insertlog.php";
        var res = await http.post(Uri.parse(uris), body: {
          "Log_Title": resp.body.toString(),
          "From_Table": "Category",
        });
      }
    } else {
      // Handle the case when userId is 0
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DropdownButton<String>(
              value: selectedTask,
              onChanged: (String? newValue) {
                setState(() {
                  selectedTask = newValue!;
                });
              },
              items: tasks.map((String task) {
                return DropdownMenuItem<String>(
                  value: task,
                  child: Row(
                    children: [
                      Icon(Icons.task), // Replace with the desired icon
                      SizedBox(width: 8),
                      Text(task),
                    ],
                  ),
                );
              }).toList(),
              hint: Row(
                children: [
                  Icon(Icons.task),
                  SizedBox(width: 8),
                  Text('Select Task'),
                ],
              ),
            ),
            SizedBox(height: 24),
            DropdownButton<String>(
              value: selectedcategory,
              onChanged: (String? newValue) {
                setState(() {
                  selectedcategory = newValue!;
                });
              },
              items: category.map((String task) {
                return DropdownMenuItem<String>(
                  value: task,
                  child: Row(
                    children: [
                      Icon(Icons.category), // Replace with the desired icon
                      SizedBox(width: 8),
                      Text(task),
                    ],
                  ),
                );
              }).toList(),
              hint: Row(
                children: [
                  Icon(Icons.category),
                  SizedBox(width: 8),
                  Text('Select Category'),
                ],
              ),
            ),
            SizedBox(height: 24),
            TextFormField(
              controller: dateController,
              decoration: InputDecoration(labelText: 'Task Date'),
              onTap: () async {
                DateTime? selectedDate = await selectDate(context);
                if (selectedDate != null) {
                  dateController.text =
                      selectedDate.toLocal().toString().split(' ')[0];
                }
              },
              maxLines: 3,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => givedata(
                  selectedTask.toString(), selectedcategory.toString()),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check), // Replace with the desired icon
                  SizedBox(width: 8),
                  Text('Continue'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
