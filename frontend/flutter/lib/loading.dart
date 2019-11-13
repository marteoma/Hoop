import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:map/main.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'main.dart';

void main() => runApp(Loading());

class Loading extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hoop!',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        hintColor: Color(0xFFC0F0E8),
        primaryColor: Colors.deepOrangeAccent[400],
        canvasColor: Colors.white,
        fontFamily: "Montserrat",
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text("Hoop!"),
        ),
        body: Center(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 60.0),
              new Text(
                'Cargando..',
                textScaleFactor: 2,
              ),
              SizedBox(height: 100.0),
              HeartbeatProgressIndicator(
                child: Image.asset("assets/ball.png",
                height: 128,
                width: 128,
                
                ),
              ),
              SizedBox(height: 100.0),
              
              FloatingActionButton(
                child: Icon(Icons.replay),
                backgroundColor: Colors.deepOrangeAccent[600],
                
                onPressed: () {
                  asyncLoaderState.currentState.reloadState();
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
