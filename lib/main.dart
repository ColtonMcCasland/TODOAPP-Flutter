import 'package:flutter/material.dart';
import 'package:todoapp/views/home_page.dart';




void main() {
  runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
      theme: ThemeData(primarySwatch: Colors.cyan)));
}
