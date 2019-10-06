import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:todoapp/models/task.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

DateTime SavedDate;

class TaskDialog extends StatefulWidget {

  final Task task;

  TaskDialog({this.task});

  @override
  _TaskDialogState createState() => _TaskDialogState();

}

class _TaskDialogState extends State<TaskDialog> {

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dueDateController = TextEditingController();


  bool _validate1 = false;
  bool _validate2 = false;

  Task _currentTask = Task();

  DateTime selectedDate = DateTime.now();

  TimeOfDay selectedTime = TimeOfDay.now();


  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101),
    );

    final TimeOfDay picked2 = await showTimePicker(
        context: context, initialTime: TimeOfDay.now());

    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });

    if (picked2 != null && picked2 != selectedTime)
      setState(() {
        selectedTime = picked2;
      });
  }


  @override
  void initState() {

    super.initState();

    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    var android = new AndroidInitializationSettings('@mipmap/ic_launcher');
    var iOS = new IOSInitializationSettings();
    var initSetttings = new InitializationSettings(android, iOS);
    flutterLocalNotificationsPlugin.initialize(initSetttings, onSelectNotification: onSelectNotification);


    if (widget.task != null) {
      _currentTask = Task.fromMap(widget.task.toMap());
    }

    _titleController.text = _currentTask.title;
    _descriptionController.text = _currentTask.description;
    _dueDateController.text = _currentTask.dueDate;

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
  void dispose() {
    super.dispose();
    _titleController.clear();
    _descriptionController.clear();
    _dueDateController.clear();

  }

  @override
  Widget build(BuildContext context) {


    SavedDate = new DateTime(selectedDate.year, selectedDate.month, selectedDate.day, selectedTime.hour, selectedTime.minute);


    _currentTask.dueDate = SavedDate.toString();

    return AlertDialog(

      title: Text(widget.task == null ? 'Make Task' : 'Edit Task'),

      content:
      Column(


        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title', errorText: _validate1 ? 'Value Can\'t Be Empty' : null,),
              autofocus: true),

          TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description', errorText: _validate2 ? 'Value Can\'t Be Empty' : null,)),


          RaisedButton(
            onPressed: () => _selectDate(context),

            child: Text("Choose due date \n" + "Set to: " + _currentTask.dueDate),

          ),

        ],
      ),
      actions: <Widget>[
        FlatButton(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        FlatButton(
          child: Text('Save'),
          onPressed: () {

            setState(() {
              _titleController.text.isEmpty ? _validate1 = true : _validate1 = false;
              _descriptionController.text.isEmpty ? _validate2 = true : _validate2 = false;
            });

            if (_titleController.text.isEmpty == false && _descriptionController.text.isEmpty == false  )
              {

                _currentTask.id = _titleController.text.length.toInt() + _currentTask.hashCode ;
                _currentTask.title = _titleController.value.text;
                _currentTask.description = _descriptionController.text;

              Navigator.of(context).pop(_currentTask);

              }
          },
        ),
      ],
    );
  }
}