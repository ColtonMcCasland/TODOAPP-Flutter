import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:todoapp/helpers/task_helper.dart';
import 'package:todoapp/models/task.dart';
import 'package:todoapp/views/task_dialog.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:connectivity/connectivity.dart';
import 'package:flutter_offline/flutter_offline.dart';



class HomePage extends StatefulWidget {

//   state for HomePage
  @override
  _HomePageState createState() => _HomePageState();

}

String status;
ConnectivityResult connectivity;

class _HomePageState extends State<HomePage> {



  final bool connected = connectivity != ConnectivityResult.none;


  // notifications plugin init.
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  // task list init
  List<Task> _taskList = [];

  //taskHelper init
  TaskHelper _helper = TaskHelper();

  // var init
  bool _loading = true;

  // on initialization of HomePageState_
  @override
  void initState() {


    super.initState();



    // flutter notification
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
//    android settings
    var android = new AndroidInitializationSettings('@mipmap/ic_launcher');
//    ios settings
    var iOS = new IOSInitializationSettings();
    // using both settings
    var initSetttings = new InitializationSettings(android, iOS);
    flutterLocalNotificationsPlugin.initialize(initSetttings, onSelectNotification: onSelectNotification);



//    create list of tasks from stored file
    _helper.getAll().then((list) {
      setState(() {
        _taskList = list;
        _loading = false;
      });
    });
  }

//  method for notifications
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

      //    top bar
      appBar: AppBar(title: Text('Todo App \n Tasks: ' + _taskList.length.toString()  ),),

//    floating button calls function
      floatingActionButton:
          FloatingActionButton(child: Icon(Icons.add), onPressed: _addNewTask,),

      //create connection stack and list below main task table body.
      body: Builder(
          builder: (BuildContext context) {
            return OfflineBuilder(
              connectivityBuilder: (BuildContext context,
                  ConnectivityResult connectivity, Widget child) {
                final bool connected = connectivity != ConnectivityResult.none;


                return Stack(
                  fit: StackFit.expand,
                  children: [
                    child,
                    Positioned(
                      left: 0.0,
                      right: 0.0,
                      height: 22.0,
                      top: 0,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        color:
                        connected ? Color(0xFF00EE44) : Color(0xFFEE4400),
                        child: connected
                            ?  Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              "ONLINE",
                              style: TextStyle(color: Colors.white),
                            ),

                          ],
                        )
                            : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              "OFFLINE",
                              style: TextStyle(color: Colors.white),
                            ),
                            SizedBox(
                              width: 8.0,
                            ),
                            SizedBox(
                              width: 12.0,
                              height: 12.0,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.0,
                                valueColor:
                                AlwaysStoppedAnimation<Color>(
                                    Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
              //    create list of tasks
              child: Center(


                child:
                _buildTaskList(),

              ),
            );
          },
        ),
    );
  }

  Widget _buildTaskList() {
//    if no tasks
    if (_taskList.isEmpty) {
      return Center(
//        default message
        child: _loading ? CircularProgressIndicator() : Text("Nothing here!"),

      );
    }
    else {
//      else populate with tasks details
      return ListView.builder(
        padding: const EdgeInsets.only(top: 20.0),

        itemBuilder: _buildTaskItemSlidable,
        itemCount: _taskList.length,

      );
    }
  }

//   build task widget
  Widget _buildTaskItem(BuildContext context, int index) {
    final task = _taskList[index];
    return CheckboxListTile(
      value: task.isDone,
      title: Text("Title: " + task.title),
      subtitle: Text("Description: " + task.description + " \nDue date: " + task.dueDate + "\n" + task.id.toString() ),

      onChanged: (bool isChecked) {
        setState(() {

          task.isDone = isChecked;

//          if task is done, cancel scheduled notification
          if(task.isDone == true)
            {
              cancelNotification( task.id );
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
//        edit option
        IconSlideAction(

          caption: 'Edit',
          color: Colors.blue,
          icon: Icons.edit,
          onTap: () {
//            calls function to add
            _addNewTask(editedTask: _taskList[index], index: index);

          },

        ),
//        remove option
        IconSlideAction(
          caption: 'Remove',
          color: Colors.red,
          icon: Icons.delete,
          onTap: ()
          {

            cancelNotification(task.id);
//             calls function to delete
            _deleteTask(deletedTask: _taskList[index], index: index);
//            cancels scheduled notification

          },
        ),
      ],
    );
  }

//   add task function
  Future _addNewTask({Task editedTask, int index}) async {
    final task = await showDialog<Task>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return TaskDialog(task: editedTask);
      },
    );

    if (task != null) {
//      cancelNotification(task.id);

      var parsedDate = DateTime.parse(task.dueDate);

      setState(() {
        if (index == null)
        {
          scheduleNotification(task.title, task.description, task.id, parsedDate );
          _taskList.add(task);
          _helper.save(task);


        }
        else
          {
//            if task matches already existing task ID, update
          scheduleNotification(task.title, task.description, task.id, parsedDate );
          _taskList[index] = task;
          _helper.update(task);

        }
      });
    }
  }

//   delete task function
  void _deleteTask({Task deletedTask, int index}) {


    setState(()
    {
      _taskList.removeAt(index);
    });

//     cancel scheduled notification
    cancelNotification( deletedTask.id );

// delete task
    _helper.delete(deletedTask.id);

  }

//   function to cancel scheduled Notification
  void cancelNotification(int num) async {
    flutterLocalNotificationsPlugin.cancel(num);
  }


  // function to schedule Notification
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
        payload: title); //
  }



}

