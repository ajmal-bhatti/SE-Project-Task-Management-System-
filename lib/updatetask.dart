import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/main.dart';

void main() {
  runApp(MyApp());
}

int Task_Id = 0;
String Title = "";
String Description = "";
String Date = "";
String Time = "";
int Priority = 0;
String Created_At = "";

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Task Management System',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TaskUpdateScreen(), // Replace with the actual task ID
    );
  }
}

final TextEditingController dateController = TextEditingController();
final TextEditingController timeController = TextEditingController();
final TextEditingController titleController = TextEditingController();
final TextEditingController descriptionController = TextEditingController();
String selectedPriority = 'Medium';
List<String> priorityOptions = ['High', 'Medium', 'Low'];

Future<void> getdata() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (Priority == 0) {
    selectedPriority = 'High';
  } else if (Priority == 1) {
    selectedPriority = 'Medium';
  } else if (Priority == 2) {
    selectedPriority = 'Low';
  }
  Task_Id = prefs.getInt('Id') ?? 0;
  Title = prefs.getString('Title') ?? "";
  Description = prefs.getString('Description') ?? "";
  Date = prefs.getString('Due_Date') ?? "";
  Time = prefs.getString('Time') ?? "";
  Priority = prefs.getInt('Priority') ?? 0;
  Created_At = prefs.getString('Created_At') ?? "";
  dateController.text = Date.toString();
  timeController.text = Time.toString();
  titleController.text = Title.toString();
  descriptionController.text = Description.toString();
}

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

Future<TimeOfDay?> selectTime(BuildContext context) async {
  TimeOfDay? selectedTime = TimeOfDay.now();

  selectedTime = await showTimePicker(
    context: context,
    initialTime: selectedTime!,
  );

  return selectedTime;
}

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

class TaskUpdateScreen extends StatefulWidget {
  @override
  _TaskUpdateScreenState createState() => _TaskUpdateScreenState();
}

class _TaskUpdateScreenState extends State<TaskUpdateScreen> {
  @override
  void initState() {
    getdata();
    super.initState();
    // Fetch task details using widget.taskId and populate controllers
    // You might use this information to populate the text fields and dropdowns
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Task'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: titleController as TextEditingController,
                decoration: InputDecoration(labelText: 'Task Title'),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: descriptionController as TextEditingController,
                decoration: InputDecoration(labelText: 'Task Description'),
                maxLines: 3,
              ),
              SizedBox(height: 24),
              TextFormField(
                controller: dateController as TextEditingController,
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
              DropdownButtonFormField<String>(
                value: selectedPriority,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedPriority = newValue!;
                  });
                },
                items: priorityOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'Select Priority',
                ),
              ),
              SizedBox(height: 24),
              TextFormField(
                controller: timeController as TextEditingController,
                decoration: InputDecoration(labelText: 'Task Time'),
                maxLines: 3,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  TimeOfDay? selectedTime = await selectTime(context);
                  if (selectedTime != null) {
                    setState(() {
                      timeController.text = selectedTime.format(context);
                    });
                  }
                },
                child: Text('Select Time'),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => updateTasks(context),
                child: Text('Update Task'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
