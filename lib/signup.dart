import 'dart:convert';
import 'package:app/main.dart';
import 'package:app/taskcategory.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:app/notification.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Signup Page',
      home: SignupPage(),
    );
  }
}

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

final NotificationHelper notificationHelper = NotificationHelper();
void showNotification(String title, String body) {
  notificationHelper.showNotification(
    title,
    body,
  );
}

class _SignupPageState extends State<SignupPage> {
  TextEditingController Email = TextEditingController();
  TextEditingController Password = TextEditingController();
  TextEditingController First_Name = TextEditingController();
  TextEditingController Last_Name = TextEditingController();
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

//This function is used to signup the user
  Future<void> _handleSignup() async {
    var res;
    if (Email.text != "" &&
        Password.text != "" &&
        First_Name.text != "" &&
        Last_Name.text != "") {
      try {
        String uri =
            "http://10.5.116.179/task_management_systems_api/insertuser.php";
        res = await http.post(Uri.parse(uri), body: {
          "Email": Email.text,
          "Password": Password.text,
          "First_Name": First_Name.text,
          "Last_Name": Last_Name.text,
        });
        var resp = jsonDecode(res.body);
        if (resp["success"] == "true" && resp["Exist"] == "false") {
          showTextDialog(context, "User Registered Successfully");
          showNotification(
              "Account Created Successfully using Emial", Email.text);
          Email.text = "";
          Password.text = "";
          First_Name.text = "";
          Last_Name.text = "";
        }
        if (resp["Exist"] == "true" && resp["success"] == "false") {
          showTextDialog(context, "Email Already Exists");
        }
      } catch (e) {
        showTextDialog(context, e.toString());
      }
    } else {
      showTextDialog(context, "Please fill all the fields");
      String uris =
          "http://10.5.116.179/task_management_systems_api/insertlog.php";
      var res = await http.post(Uri.parse(uris), body: {
        "Log_Title": resp.body.toString(),
        "From_Table": "Users",
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Signup Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: First_Name,
              decoration: InputDecoration(labelText: 'First Name'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: Last_Name,
              decoration: InputDecoration(labelText: 'Last Name'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: Email,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: Password,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: _handleSignup,
              child: Text('Sign Up',
                  style: TextStyle(
                    fontSize: 16,
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
