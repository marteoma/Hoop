import 'package:solid_bottom_sheet/solid_bottom_sheet.dart';
import 'package:flutter/material.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
           
      bottomSheet: SolidBottomSheet(
        headerBar: Container(
          color: Theme.of(context).primaryColor,
          height: 50,
          child: Center(
            child: Text("Swipe me!"),
          ),
        ),
        body: Container(
          color: Colors.white,
          height: 30,
          child: Center(
            child: Text(
              "Hello! I'm a bottom sheet :D",
              style: Theme.of(context).textTheme.display1,
            ),
          ),
        ),
      ),
    );
  }
}