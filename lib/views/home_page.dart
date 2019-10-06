import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:todoapp/helpers/task_helper.dart';
import 'package:todoapp/models/task.dart';
import 'package:todoapp/views/task_dialog.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';



class HomePage extends StatefulWidget {

  @override
  _HomePageState createState() => _HomePageState();

}


class _HomePageState extends State<HomePage> {

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  List<Task> _taskList = [];

  TaskHelper _helper = TaskHelper();

  bool _loading = true;

  @override
  void initState() {
    super.initState();

    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    var android = new AndroidInitializationSettings('@mipmap/ic_launcher');
    var iOS = new IOSInitializationSettings();
    var initSetttings = new InitializationSettings(android, iOS);
    flutterLocalNotificationsPlugin.initialize(initSetttings, onSelectNotification: onSelectNotification);

    _helper.getAll().then((list) {
      setState(() {
        _taskList = list;
        _loading = false;
      });
    });
  }

  Future onSelectNotification(String payload) {
    debugPrint("payload : $payload");
    showDialog(
      context: context,
      builder: (_) => new AlertDialog(
        title: new Text('Notification'),
        content: new Text('$payload'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: Text('Todo App \n Tasks: ' + _taskList.length.toString() ),),
      floatingActionButton:
          FloatingActionButton(child: Icon(Icons.add), onPressed: _addNewTask,),
      body: _buildTaskList(),
    );
  }

  Widget _buildTaskList() {
    if (_taskList.isEmpty) {
      return Center(
        child: _loading ? CircularProgressIndicator() : Text("Nothing here!"),
      );
    } else {
      return ListView.builder(
        itemBuilder: _buildTaskItemSlidable,
        itemCount: _taskList.length,
      );
    }
  }

  Widget _buildTaskItem(BuildContext context, int index) {
    final task = _taskList[index];
    var parsedDate = DateTime.parse(task.dueDate);
    return CheckboxListTile(
      value: task.isDone,
      title: Text("Title: " + task.title),
      subtitle: Text("Description: " + task.description + " \nDue date: " + task.dueDate + "\n" ),

      onChanged: (bool isChecked) {
        setState(() {

          task.isDone = isChecked;
          print(task.isDone);
          if(task.isDone == true)
            {
              print("cancel!");
              cancelNotification( task.id );
            }
          else
            {
              scheduleNotification(task.title, task.description, task.id, parsedDate);
            }
        });

        _helper.update(task);
      },
    );

  }

  Widget _buildTaskItemSlidable(BuildContext context, int index) {
    final task = _taskList[index];
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,

      child: _buildTaskItem(context, index),
      actions: <Widget>[
        IconSlideAction(
          caption: 'Edit',
          color: Colors.blue,
          icon: Icons.edit,
          onTap: () {
            var parsedDate = DateTime.parse(_taskList[index].dueDate);

            cancelNotification(_taskList[index].id);
            scheduleNotification(_taskList[index].title, _taskList[index].description, task.id, parsedDate);

            _addNewTask(editedTask: _taskList[index], index: index);
          },

        ),
        IconSlideAction(
          caption: 'Remove',
          color: Colors.red,
          icon: Icons.delete,
          onTap: () {

            _deleteTask(deletedTask: _taskList[index], index: index);
            cancelNotification(task.id);

          },
        ),
      ],
    );
  }

  Future _addNewTask({Task editedTask, int index}) async {
    final task = await showDialog<Task>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return TaskDialog(task: editedTask);
      },
    );

    if (task != null) {

      var parsedDate = DateTime.parse(task.dueDate);

      setState(() {
        if (index == null)
        {
          _taskList.add(task);
          _helper.save(task);

          scheduleNotification(task.title, task.description, task.id, parsedDate );
        }
        else
          {
          _taskList[index] = task;
          _helper.update(task);

          cancelNotification(task.id);
          scheduleNotification(task.title, task.description, task.id, parsedDate );
        }
      });
    }
  }

  void _deleteTask({Task deletedTask, int index}) {

    setState(() {
      _taskList.removeAt(index);
    });

    cancelNotification( deletedTask.id );


    _helper.delete(deletedTask.id);

    Flushbar(
      title: "Undo last delete",
      message: "Task \"${deletedTask.title}\" Removed.",
      margin: EdgeInsets.all(8),
      borderRadius: 8,
      duration: Duration(seconds: 3),
      mainButton: FlatButton(
        child: Text(
          "Undo",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        onPressed: () {
          var parsedDate = DateTime.parse(deletedTask.dueDate);
          setState(() {
            _taskList.insert(index, deletedTask);
            _helper.update(deletedTask);

            scheduleNotification(deletedTask.title, deletedTask.description, deletedTask.id, parsedDate);
          });
        },
      ),
    )..show(context);
  }

  void cancelNotification(int num) async {
    flutterLocalNotificationsPlugin.cancel(num);
  }

  void scheduleNotification(String title, String desc, int num, DateTime SavedDate) async {

    var scheduledNotificationDateTime = SavedDate;

    var androidPlatformChannelSpecifics =
    new AndroidNotificationDetails('your other channel id',
        'your other channel name', 'your other channel description',priority: Priority.High,importance: Importance.Max);
    var iOSPlatformChannelSpecifics =
    new IOSNotificationDetails();
    NotificationDetails platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.schedule(
        num,
        title,
        desc,
        scheduledNotificationDateTime,
        platformChannelSpecifics,
        payload: 'TodoApp Notification');
  }


}