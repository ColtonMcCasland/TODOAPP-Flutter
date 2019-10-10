import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:todoapp/models/task.dart';

DateTime SavedDate;

// task widget
class TaskDialog extends StatefulWidget {

//   task init
  final Task task;

//  edit task in context
  TaskDialog({this.task});

  @override
  _TaskDialogState createState() => _TaskDialogState();

}

// class to interact with task
class _TaskDialogState extends State<TaskDialog> {

//  title controller
  final _titleController = TextEditingController();
//  description controller
  final _descriptionController = TextEditingController();
//  due date controller
  final _dueDateController = TextEditingController();

// vars to check for emptie fields.
  bool _validate1 = false;
  bool _validate2 = false;

// task initialization
  Task _currentTask = Task();

//   dateTime set to now()
  DateTime selectedDate = DateTime.now();
//   TimeofDay set to now()
  TimeOfDay selectedTime = TimeOfDay.now();


//  select date Popup menu
  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101),
    );

//    time popup after DateTime
    final TimeOfDay picked2 = await showTimePicker(
        context: context, initialTime: TimeOfDay.now());

//    checks that fields arn't empty
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

    if (widget.task != null)
    {
      _currentTask = Task.fromMap(widget.task.toMap());
    }

//    Connect Task text controllers to fields.
    _titleController.text = _currentTask.title;
    _descriptionController.text = _currentTask.description;
    _dueDateController.text = _currentTask.dueDate;

  }

//  clear fields on function call
  @override
  void dispose() {
    super.dispose();
    _titleController.clear();
    _descriptionController.clear();
    _dueDateController.clear();

  }

  @override
  Widget build(BuildContext context) {

// savedDate var to contain selected due date information.
    SavedDate = new DateTime(selectedDate.year, selectedDate.month, selectedDate.day, selectedTime.hour, selectedTime.minute);

// returns that to the task.dueDate field in db.
    _currentTask.dueDate = SavedDate.toString();

    // different titles for different context.
    return AlertDialog(

//       titles
      title: Text(widget.task == null ? 'Make Task' : 'Edit Task'),

      content:
      Column(


        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
//          title for task
          TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title', errorText: _validate1 ? 'Value Can\'t Be Empty' : null,),
              autofocus: true),
//          description for task
          TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description', errorText: _validate2 ? 'Value Can\'t Be Empty' : null,)),

//          Duedate for task
          RaisedButton(
            onPressed: () => _selectDate(context),

            child: Text("Choose due date \n" + "Set to: " + _currentTask.dueDate),

          ),
        ],
      ),
//       cancel button
      actions: <Widget>[
        FlatButton(
          child: Text('Cancel'),
          onPressed: () {
//             exit context
            Navigator.of(context).pop();
          },
        ),
//         save button
        FlatButton(
          child: Text('Save'),
          onPressed: () {
//        check for empty fields, stop save, and notify user to fill respective fields.
            setState(() {
              _titleController.text.isEmpty ? _validate1 = true : _validate1 = false;
              _descriptionController.text.isEmpty ? _validate2 = true : _validate2 = false;
            });

//             if correct form, save task
            if (_titleController.text.isEmpty == false && _descriptionController.text.isEmpty == false  )
              {
//
                _currentTask.id =  _currentTask.hashCode;
                _currentTask.title = _titleController.value.text;
                _currentTask.description = _descriptionController.text;

//                exit context
              Navigator.of(context).pop(_currentTask);

              }
          },
        ),
      ],
    );
  }
}