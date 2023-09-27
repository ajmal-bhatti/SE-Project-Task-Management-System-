import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:app/main.dart';

class DeleteUserPage extends StatefulWidget {
  @override
  _DeleteUserPageState createState() => _DeleteUserPageState();
}

class _DeleteUserPageState extends State<DeleteUserPage> {
  TextEditingController _userIdController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Delete User'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _userIdController,
              decoration: InputDecoration(labelText: 'User Email'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // Call your API or backend service to delete the user
                deleteUser();
              },
              child: Text('Delete User'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> deleteUser() async {
    String username = _userIdController.text;
    var res;
    print('Username: $username');
    final String apiUrl = "http://10.5.116.179/practice_api/deleterecord.php";
    if (username != "") {
      try {
        final response = await http.delete(
          Uri.parse('$apiUrl?Email=$username'),
        );
        if (response.statusCode == 204) {
          print("User Deleted Successfully");
        } else {
          print("User Deleted Failed");
        }
      } catch (e) {
        print(res.body);
        print(e);
      }
    } else {
      print("Please fill all field");
    }
  }
}
