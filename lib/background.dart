import 'package:flutter/material.dart';
import 'package:app/notification.dart'; // Assuming NotificationHelper is defined in this file
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app/dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

final NotificationHelper notificationHelper = NotificationHelper();
void showNotification(String title, String body) {
  notificationHelper.showNotification(
    title,
    body,
  );
}

Future<void> getTaskCategory(BuildContext context) async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int userId = prefs.getInt('Id') ?? 0;

    if (userId != 0) {
      String categoryUri =
          "http://10.5.116.179/task_management_systems_api/gettaskcategory.php";

      var categoryResponse = await http.post(Uri.parse(categoryUri), body: {
        "Users_Id": userId.toString(),
      });

      var categoryData = jsonDecode(categoryResponse.body);

      if (categoryData != null) {
        for (var category in categoryData) {
          String taskName = category["task_name"];
          String taskCategory = category["task_category"];
          String scheduleDate = category["schedule_Date"].toString();

          var taskDetailsResponse = await searchTask(userId, taskName);

          if (taskDetailsResponse["Exists"] == "true") {
            var taskDetails = taskDetailsResponse;

            DateTime scheduleDateTime = DateTime.parse(scheduleDate);
            print(scheduleDateTime);

            if (scheduleDateTime.isAtSameMomentAs(DateTime.now())) {
              showNotification(taskName, taskCategory);
            }
          } else {
            showTextDialog(context, "Task Not Found");
          }
        }
      } else {
        throw Exception('Failed to load task categories');
      }
    }
  } catch (e) {
    print("Error: $e");
  }
}

Future<Map<String, dynamic>> searchTask(int userId, String taskName) async {
  try {
    String searchUri =
        "http://10.5.116.179/task_management_systems_api/searchtask.php";

    var searchResponse = await http.post(Uri.parse(searchUri), body: {
      'Title': taskName,
      'Users_Id': userId.toString(),
    });

    return jsonDecode(searchResponse.body);
  } catch (e) {
    throw e.toString();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      // The application is in the foreground, execute your continuous function here.
      getTaskCategory(context);
      _runContinuousFunction();
    }
  }

  void _runContinuousFunction() {
    print("Continuous function is running...");
  }

  Future<void> getData() async {
    var url = Uri.parse('https://jsonplaceholder.typicode.com/posts/1');
    var response = await http.get(url);
    var result = jsonDecode(response.body);
    print(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Continuous Function Example'),
      ),
      body: Center(
        child: Text('Your App Content Goes Here'),
      ),
    );
  }
}
