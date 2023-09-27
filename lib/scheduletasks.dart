import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:app/main.dart';
import 'package:app/dashboard.dart';
import 'dart:convert';
import 'package:app/main.dart';

//this is the Delete schedule task function
void deleteschedule(BuildContext context, String created_at) async {
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

    String uris =
        "http://10.5.116.179/task_management_systems_api/insertlog.php";
    var res = await http.post(Uri.parse(uris), body: {
      "Log_Title": dps.body.toString(),
      "From_Table": "Schedule_Task",
    });
  }
}

class ScheduleTasks extends StatelessWidget {
  final List<Task> tasks;

  ScheduleTasks({required this.tasks});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scheduled Tasks'),
      ),
      body: TaskList(tasks: tasks),
    );
  }
}

class TaskList extends StatelessWidget {
  final List<Task> tasks;

  TaskList({required this.tasks});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return ListTile(
          title: Text(task.title),
          subtitle: Text(
              'Category: ${task.task_category} | Description: ${task.description} | Date: ${task.Due_Date} at ${task.Time} | Schedule_Date: ${task.schedule_date}| Created at: ${task.created_at}'),
          trailing: PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'delete',
                child: Text('Delete'),
              ),
            ],
            onSelected: (value) {
              if (value == 'delete') {
                // Implement the delete functionality here
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Delete Task'),
                    content: Text(
                        'Are you sure you want to delete this task? This action cannot be undone.'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          deleteschedule(context, task.created_at.toString());
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DashboardPage()),
                          );
                        },
                        child: Text('OK'),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        );
      },
    );
  }
}
