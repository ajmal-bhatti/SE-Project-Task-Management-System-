import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/main.dart';

void main() => runApp(MyApp());

final TextEditingController dateController = TextEditingController();
final TextEditingController timeController = TextEditingController();
final TextEditingController Title = TextEditingController();
final TextEditingController Description = TextEditingController();
String selectedOption = 'Medium';
List<String> options = ['High', 'Medium', 'Low'];

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Task Management System',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TaskCreationScreen(),
    );
  }
}

// This function is used to show the alert dialog box
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
              Navigator.pop(context); // Close the dialog
            },
            child: Text('OK'),
          ),
        ],
      );
    },
  );
}

//This function is used to select the time
Future<TimeOfDay?> selectTime(BuildContext context) async {
  TimeOfDay? selectedTime = TimeOfDay.now();

  selectedTime = await showTimePicker(
    context: context,
    initialTime: selectedTime!,
  );

  return selectedTime;
}

//This function is used to create the task
Future<void> createtask(BuildContext context) async {
  int priority = 0;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int Users_Id = prefs.getInt('Id') ?? 0;
  var resp;
  var res;
  if (Title.text != "" &&
      Description.text != "" &&
      dateController.text != "" &&
      timeController.text != "" &&
      selectedOption != "" &&
      Users_Id != 0) {
    try {
      if (selectedOption == 'High') {
        priority = 0;
      } else if (selectedOption == 'Medium') {
        priority = 1;
      } else if (selectedOption == 'Low') {
        priority = 2;
      }

      String uri =
          "http://10.5.116.179/task_management_systems_api/inserttask.php";
      res = await http.post(Uri.parse(uri), body: {
        "Title": Title.text,
        "Description": Description.text,
        "Due_Date": dateController.text,
        "Time": timeController.text,
        "Priority": priority.toString(),
        "Users_Id": Users_Id.toString(),
      });
      resp = jsonDecode(res.body);
      if (resp["success"] == "true" && resp["Exist"] == "false") {
        showTextDialog(context, "Task Created Successfully");
        Title.text = "";
        Description.text = "";
        dateController.text = "";
        timeController.text = "";
      }
      if (resp["Exist"] == "true" && resp["success"] == "false") {
        showTextDialog(context, "Task already existed");
      }
    } catch (e) {
      showTextDialog(context, e.toString());
      print(resp.body);
      String uris =
          "http://10.5.116.179/task_management_systems_api/insertlog.php";
      var res = await http.post(Uri.parse(uris), body: {
        "Log_Title": resp.body.toString(),
        "From_Table": "Task",
      });
    }
  } else {
    showTextDialog(context, "Please fill all the fields");
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

class TaskCreationScreen extends StatefulWidget {
  @override
  _TaskCreationScreenState createState() => _TaskCreationScreenState();
}

class _TaskCreationScreenState extends State<TaskCreationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Task'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: Title,
                decoration: InputDecoration(labelText: 'Task Title'),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: Description,
                decoration: InputDecoration(labelText: 'Task Description'),
                maxLines: 3,
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
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16),
                child: DropdownButtonFormField<String>(
                  value: selectedOption,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedOption = newValue!;
                    });
                  },
                  items: options.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    labelText: 'Select an option',
                  ),
                ),
              ),
              SizedBox(height: 24),
              TextFormField(
                controller: timeController,
                decoration: InputDecoration(labelText: 'Task Time'),
                maxLines: 3,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  TimeOfDay? selectedTime = await selectTime(context);
                  if (selectedTime != null) {
                    setState(() {
                      // Format the TimeOfDay and set it in the text controller
                      timeController.text = selectedTime.format(context);
                    });
                  }
                },
                child: Text('Select Time'),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => createtask(context),
                child: Text('Create Task'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
