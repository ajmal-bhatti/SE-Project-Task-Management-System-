import 'dart:io';
import 'package:app/Taskcreation.dart';
import 'package:flutter/material.dart';
import 'package:app/updatetask.dart';
import 'package:app/taskcategory.dart';
import 'package:app/scheduletasks.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:app/main.dart';
import 'dart:convert';
import 'package:app/main.dart';
import 'package:app/feedback.dart';

void main() {
  runApp(MyApp());
}

int Ids = 0;
final TextEditingController new_Email = TextEditingController();
final TextEditingController new_Password = TextEditingController();
final TextEditingController new_First_Name = TextEditingController();
final TextEditingController new_Last_Name = TextEditingController();
final TextEditingController Email = TextEditingController();
final TextEditingController Password = TextEditingController();
final TextEditingController First_Name = TextEditingController();
final TextEditingController Last_Name = TextEditingController();
final TextEditingController search = TextEditingController();
final TextEditingController Category = TextEditingController();
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
      home: DashboardPage(),
    );
  }
}

class Task {
  final String title;
  final String task_category;
  final String created_at;
  final String description;
  final int Task_Id;
  final String Due_Date;
  final String Time;
  final int Priority;
  final String schedule_date;

  Task({
    required this.title,
    required this.task_category,
    required this.created_at,
    required this.description,
    required this.Task_Id,
    required this.Due_Date,
    required this.Time,
    required this.Priority,
    required this.schedule_date,
  });
// Factory constructor to create a Task object from a Map
}

List<Task> Tasks = [];
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

void navigateToTaskUpdateScreen(BuildContext context) {}
//This function is used to show the dialog box for the save changes
Future<void> savechanges(BuildContext context) async {
  print('Id: $Ids');
  print(new_Email.text);
  print(new_Password.text);
  print(new_First_Name.text);
  print(new_Last_Name.text);
  print(Created_At);
  print(Email.text);
  print(Password.text);
  print(First_Name.text);
  print(Last_Name.text);
  var res;
  if (Ids != "" &&
      new_Email.text != "" &&
      new_Password.text != "" &&
      new_First_Name.text != "" &&
      new_Last_Name.text != "" &&
      Email.text != "" &&
      Password.text != "" &&
      First_Name.text != "" &&
      Last_Name.text != "" &&
      Created_At != "") {
    var resp;
    try {
      String uri =
          "http://10.5.116.179/task_management_systems_api/updateduser.php";
      res = await http.post(Uri.parse(uri), body: {
        "Id": Ids.toString(),
        "Old_Email": Email.text,
        "Old_Password": Password.text,
        "Old_First_Name": First_Name.text,
        "Old_Last_Name": Last_Name.text,
        "New_Email": new_Email.text,
        "New_Password": new_Password.text,
        "New_First_Name": new_First_Name.text,
        "New_Last_Name": new_Last_Name.text,
        "Created_At": Created_At,
      });

      resp = jsonDecode(res.body);
      if (resp["success"] == "true" && resp["Exist"] == "false") {
        showTextDialog(context, "User Updated Successfully");
      }
      if (resp["success"] == "false" && resp["Exist"] == "false") {
        showTextDialog(context, "Something went wrong ");
      }
      if (resp["success"] == "false" && resp["Exist"] == "true") {
        showTextDialog(context, "Email already Registered");
      }
    } catch (e) {
      showTextDialog(context, e.toString());
      print(resp.body);

      String uris =
          "http://10.5.116.179/task_management_systems_api/insertlog.php";
      var res = await http.post(Uri.parse(uris), body: {
        "Log_Title": resp.body.toString(),
        "From_Table": "Users",
      });
    }
  } else {
    showTextDialog(context, "Please fill all the fields");
  }
}

//This function is used to add category
Future<void> categoryadd(BuildContext context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int Users_Id = prefs.getInt('Id') ?? 0;
  print(Users_Id);
  print(Category.text);
  var res;
  var response;
  if (Ids != "" && Category.text != "") {
    try {
      String uri =
          "http://10.5.116.179/task_management_systems_api/insertcategory.php";
      res = await http.post(Uri.parse(uri), body: {
        "category_name": Category.text,
        "User_Id": Users_Id.toString(),
      });
      response = jsonDecode(res.body);
      if (response["success"] == "true" && response["exist"] == "false") {
        showTextDialog(context, "Category Added Successfully");
        Category.text = "";
      }
      if (response["exist"] == "true" && response["success"] == "false") {
        showTextDialog(context, "Category Already Exists");
      }
    } catch (e) {
      showTextDialog(context, e.toString());
      String uris =
          "http://10.5.116.179/task_management_systems_api/insertlog.php";
      var res = await http.post(Uri.parse(uris), body: {
        "Log_Title": resp.body.toString(),
        "From_Table": "Category",
      });
    }
  } else {
    showTextDialog(context, "Please fill all the fields");
  }
}

//this function is used to search the task
Future<void> searchtask(BuildContext context) async {
  var resp;
  var response;
  if (Ids != 0 && search.text != "") {
    try {
      String uri =
          "http://10.5.116.179/task_management_systems_api/searchtask.php";
      response = await http.post(
        Uri.parse(uri),
        body: {
          'Title': search.text,
          'Users_Id': Ids.toString(),
        },
      );
      resp = jsonDecode(response.body);
      if (resp["Exists"] == "true") {
        showTextDialog(context, "Task Found");
        var Id = resp["Id"];
        var Description = resp["Description"];
        var Due_Date = resp["Due_Date"] as String;
        var Time = resp["Time"] as String;
        var Priority = resp["Priority"];
        var Createf_At = resp["Created_At"] as String;

        SharedPreferences pref = await SharedPreferences.getInstance();
        await pref.setInt('Id', Id);
        await pref.setString('Title', search.text);
        await pref.setString('Description', Description);
        await pref.setString('Due_Date', Due_Date);
        await pref.setString('Time', Time);
        await pref.setInt('Priority', Priority);
        await pref.setString('Created_At', Createf_At);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TaskUpdateScreen(),
          ),
        );
      }
      if (resp["Exists"] == "false") {
        showTextDialog(context, "Task Not Found");
      }
    } catch (e) {
      showTextDialog(context, e.toString());
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

//this function is used to update the task
Future<void> updatetask(BuildContext context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  Ids = prefs.getInt('Id') ?? 0;
  // Your user settings UI goes here
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Task Update'),
        content: Column(
          children: [
            TextField(
              controller: search as TextEditingController,
              decoration: InputDecoration(labelText: 'Search by Task Title'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => searchtask(context),
              child: Text('Search'),
            ),
          ],
        ),
      );
    },
  );
}

//this function is used to show the dialog box.
Future<void> showSettingsDialog(BuildContext context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  Ids = prefs.getInt('Id') ?? 0;
  Email.text = prefs.getString('Email') ?? '';
  Password.text = prefs.getString('Password') ?? '';
  First_Name.text = prefs.getString('FirstName') ?? '';
  Last_Name.text = prefs.getString('LastName') ?? '';
  Created_At = prefs.getString('Created_At') ?? '';
  new_Email.text = Email.text;
  new_Password.text = Password.text;
  new_First_Name.text = First_Name.text;
  new_Last_Name.text = Last_Name.text;
  // Your user settings UI goes here
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('User Settings'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: new_Email as TextEditingController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              SizedBox(height: 20),
              TextField(
                controller: new_Password as TextEditingController,
                decoration: InputDecoration(labelText: 'Password'),
              ),
              SizedBox(height: 20),
              TextField(
                controller: new_First_Name as TextEditingController,
                decoration: InputDecoration(labelText: 'First Name'),
              ),
              SizedBox(height: 20),
              TextField(
                controller: new_Last_Name as TextEditingController,
                decoration: InputDecoration(labelText: 'Last Name'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => savechanges(context),
                child: Text('Save changes'),
              ),
            ],
          ),
        ),
      );
    },
  );
}

//This function is used to get the task category
Future<void> gettaskcategory(BuildContext context) async {
  Tasks.clear();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int Users_Id = prefs.getInt('Id') ?? 0;
  var res;
  var response;

  try {
    String uri =
        "http://10.5.116.179/task_management_systems_api/gettaskcategory.php";
    res = await http.post(Uri.parse(uri), body: {
      "Users_Id": Users_Id.toString(),
    });
    response = jsonDecode(res.body);
    if (response != null) {
      for (var num in response) {
        String task_name = num["task_name"];
        String task_category = num["task_category"];
        String created_at = num["created_at"];
        String schedule_date = num["schedule_Date"].toString();
        var Task_Id;
        var Description;
        var Due_Date;
        var Time;
        var Priority;

        var resp;
        var response;

        if (Users_Id != 0 && task_name != "") {
          try {
            String uri =
                "http://10.5.116.179/task_management_systems_api/searchtask.php";
            response = await http.post(
              Uri.parse(uri),
              body: {
                'Title': task_name,
                'Users_Id': Users_Id.toString(),
              },
            );
            resp = jsonDecode(response.body);
            if (resp["Exists"] == "true") {
              Task_Id = resp["Id"];
              Description = resp["Description"];
              Due_Date = resp["Due_Date"];
              Time = resp["Time"];
              Priority = resp["Priority"];
            }
            if (resp["Exists"] == "false") {
              showTextDialog(context, "Task Not Found");
            }
          } catch (e) {
            showTextDialog(context, e.toString());
          }
        }
        DateTime scheduleDate = DateTime.parse(schedule_date);
        print(scheduleDate);
        if (!scheduleDate
            .isBefore(DateTime.now().subtract(Duration(days: 1)))) {
          Tasks.add(Task(
            title: task_name,
            task_category: task_category,
            created_at: created_at,
            Task_Id: Task_Id,
            description: Description,
            Due_Date: Due_Date,
            Time: Time,
            Priority: Priority,
            schedule_date: schedule_date,
          ));
        } else {
          var dp;
          var dps;
          try {
            String uri =
                "http://10.5.116.179/task_management_systems_api/deletescheduletask.php";
            dp = await http.post(Uri.parse(uri), body: {
              "created_at": created_at.toString(),
            });
            dps = jsonDecode(dp.body);
            if (dps["success"] == "true") {
              print("Task Deleted");
            }
            if (dps["success"] == "false") {
              print("Task Not Deleted");
            }
          } catch (e) {
            print(e.toString());
            print(dps.body);
          }
        }
      }
    } else {
      // If the server did not return a 200 OK response, throw an exception.
      throw Exception('Failed to load tasks');
    }
  } catch (e) {
    // Handle the etask_namexception
    print("Error: $e");
  }

  Tasks.forEach((element) {
    print(element.title);
    print(element.task_category);
    print(element.created_at);
    print(element.Task_Id);
    print(element.description);
    print(element.Due_Date);
    print(element.Time);
    print(element.Priority);
  });
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ScheduleTasks(tasks: Tasks),
    ),
  );
}

//This function is used to add the category
Future<void> category(BuildContext context) async {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Add Category'),
        content: Column(
          children: [
            TextField(
              controller: Category as TextEditingController,
              decoration: InputDecoration(labelText: 'Category Name'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => categoryadd(context),
              child: Text('Add'),
            ),
          ],
        ),
      );
    },
  );
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('User Settings'),
    ),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => showSettingsDialog(context),
            child: Text('Open Settings'),
          ),
        ],
      ),
    ),
  );
}

class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task Dashboard'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Task Management',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                // Navigate to the home page or perform other actions
                Navigator.pop(context);
              },
            ),
            ListTile(
                leading: Icon(Icons.add),
                title: Text('Create Tasks'),
                onTap: () {
                  // Navigate to the tasks page or perform other actions
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TaskCreationScreen(),
                    ),
                  );
                }),
            ListTile(
                leading: Icon(Icons.edit),
                title: Text('Update Tasks'),
                onTap: () => updatetask(context)),
            ListTile(
              leading: Icon(Icons.category),
              title: Text('Category'),
              onTap: () => category(context),
            ),
            ListTile(
              leading: Icon(Icons.schedule),
              title: Text('Schedule Tasks'),
              onTap: () => gettaskcategory(context),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () => showSettingsDialog(context),
            ),
            ListTile(
              leading: Icon(Icons.feedback),
              title: Text('Feedback'),
              onTap: () {
                // Pop from the current screen to return to the first screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FeedbackScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                // Pop from the current screen to return to the first screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DashBoardScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Text(
          'Welcome to the Task Management Dashboard!',
          style: TextStyle(fontSize: 20),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Handle the plus button press, for example, navigate to the task creation screen.
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TaskSelectionScreen(),
              ));
        },
        tooltip: 'Add Task',
        child: Icon(Icons.add),
      ),
    );
  }
}
