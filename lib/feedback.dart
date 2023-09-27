import 'package:flutter/material.dart';
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
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Feedback App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FeedbackScreen(),
    );
  }
}

final TextEditingController _feedbackController = TextEditingController();

class FeedbackScreen extends StatefulWidget {
  @override
  _FeedbackScreenState createState() => _FeedbackScreenState();
}

//This functoion is used to submit the feedback
void _submitFeedback(BuildContext context) async {
  var res;
  var resp;
  if (_feedbackController.text != "") {
    try {
      String uri =
          "http://10.5.116.179/task_management_systems_api/insertfeedback.php";
      res = await http.post(Uri.parse(uri), body: {
        "feedback": _feedbackController.text,
      });
      resp = jsonDecode(res.body);
      if (resp['success'] == "true") {
        showTextDialog(context, "Feedback Submitted Successfully");
      }
      if (resp['success'] == "false") {
        showTextDialog(context, "Feedback Submission Failed");
      }
    } catch (e) {
      print(e);
      print(resp.body);
    }
  } else {
    showTextDialog(context, "Please enter your feedback");
  }
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Feedback Form'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _feedbackController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Enter your feedback',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                _submitFeedback(context);
              },
              child: Text('Submit Feedback'),
            ),
          ],
        ),
      ),
    );
  }
}
