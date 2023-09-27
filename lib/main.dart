import 'dart:convert';
import 'package:app/Delete.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/logo.dart';
import 'package:app/mybutton.dart';
import 'package:app/signup.dart';
import 'package:app/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:app/notification.dart';

void main() {
  runApp(const MyApp());
}

//This functoion is used to show the alert dialog
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

final TextEditingController Emails = TextEditingController();
final TextEditingController Passwords = TextEditingController();
String Emailz = Emails.text;
String Passwordz = Passwords.text;
final NotificationHelper notificationHelper = NotificationHelper();
//This functoion is used to show the notification
void showNotification(String title, String body) {
  notificationHelper.showNotification(
    title,
    body,
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: logoscreen(),
    );
  }
}

class DashBoardScreen extends StatefulWidget {
  @override
  _DashBoardScreenState createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends State<DashBoardScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    _runContinuousFunction();
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
      _runContinuousFunction();
    }
  }

  Timer? _timer;
  void _runContinuousFunction() {
    _timer = Timer.periodic(Duration(seconds: 30), (timer) {
      // Your continuous function logic here
      print("Continuous function is running...");
      gettaskcategory(context);
    });
  }

//This function to signin user
  Future<void> signinuser(BuildContext context) async {
    var response;
    if (Emailz != "" && Passwordz != "") {
      String apiUrl =
          "http://10.5.116.179/task_management_systems_api/validuser.php";

      try {
        response = await http.post(
          Uri.parse(apiUrl),
          body: {
            'Email': Emails.text,
            'Password': Passwords.text,
          },
        );

        var resp = jsonDecode(response.body);
        if (resp["Exists"] == "true") {
          var Id = resp["Id"];
          var Firstname = resp["FirstName"];
          var Lastname = resp["LastName"];
          var Created_At = resp["Created_At"] as String;
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setInt('Id', Id);
          await prefs.setString('Email', Emails.text);
          await prefs.setString('Password', Passwords.text);
          await prefs.setString('FirstName', Firstname);
          await prefs.setString('LastName', Lastname);
          await prefs.setString('Created_At', Created_At);

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DashboardPage(),
            ),
          );
          showTextDialog(context, "Valid User");
          showNotification("Alert", "Someone Logged In Your Account");
        }
        if (resp["Exists"] == "false") {
          showTextDialog(context, "InValid User");
        }
      } catch (e) {
        showTextDialog(context, e.toString());
      }
    }
  }

//This function to get the task category
  Future<void> gettaskcategory(BuildContext context) async {
    List<Task> Taskz = [];
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
          String schedule_date = num["schedule_Date"];
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
          DateTime now = DateTime.now();
          String truth = "2023-11-29" + " " + Time;
          DateTime time = DateTime.parse(truth);
          DateTime schedule = DateTime.parse(schedule_date);

          int hour = 0;
          if (now.hour <= 12) {
            hour = now.hour;
          } else {
            hour = now.hour - 12;
          }
          if (time.hour == hour &&
              time.minute == now.minute &&
              schedule.month == now.month &&
              schedule.year == now.year &&
              schedule.day == now.day) {
            showNotification(task_name, "You Have A Task Today");
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
  }

//This function is used to signup user
  void signupuser(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SignupPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),
                  const Icon(
                    Icons.lock,
                    size: 100,
                  ),
                  const SizedBox(height: 50),
                  Text(
                    'Welcome back, you\'ve been missed!',
                    style: TextStyle(color: Colors.grey[700], fontSize: 16),
                  ),
                  const SizedBox(height: 25),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: TextField(
                      controller: Emails,
                      decoration: InputDecoration(
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade400),
                        ),
                        fillColor: Colors.grey.shade200,
                        filled: true,
                        hintText: 'Email',
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: TextField(
                      obscureText: true,
                      controller: Passwords,
                      decoration: InputDecoration(
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade400),
                        ),
                        fillColor: Colors.grey.shade200,
                        filled: true,
                        hintText: 'Password',
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Forget a Password?',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  mybutton(
                    onTap: () => signinuser(context),
                    buttontext: 'Sign In',
                  ),
                  const SizedBox(height: 50),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Not a member?',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      const SizedBox(width: 4),
                      mybutton(
                        onTap: () => signupuser(context),
                        buttontext: 'Register',
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
