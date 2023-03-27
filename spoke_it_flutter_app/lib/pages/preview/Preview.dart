import 'dart:io';

import 'package:flutter/material.dart';
import '../load/LoadView.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import '../home/homeView.dart';
import '../../source/portals.dart';

class Preview extends StatelessWidget {
  const Preview({super.key, required this.portals});
  final List<Portal> portals;
  @override
  Widget build(BuildContext context) {
    String dir = Directory.current.toString();
    return MaterialApp(
        title: 'Spoke-It', //web name
        theme: ThemeData(
          // This is the theme of your application.

          primarySwatch: Colors.indigo, //title color
        ),
        home: myPreview(
          portals: portals, //displayed title
        ));
  }
}

class myPreview extends StatefulWidget {
  const myPreview({super.key, required this.portals});

  final List<Portal> portals;

  @override
  State<myPreview> createState() => _myPreview();
}

class _myPreview extends State<myPreview> {
  List<Portal> getPortalList() {
    List<Portal> portalList = widget.portals; //widget.portals is getting from parent stateful widget
    return portalList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //top bar

        title: Text('Preview'),
        centerTitle: true, //centers text
      ),
      body: Row(
        children: [
          Column(
            // Center is a layout widget. It takes a single child and positions it
            // in the middle of the parent.
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                color: Colors.grey[300],
                padding:
                    EdgeInsets.symmetric(vertical: 20.0, horizontal: 120.0),
                //child: Text('Load Data'),
              ),
              Container(
                color: Colors.grey[300],
                padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 92.0),
                child: TextButton(
                    onPressed: () {
                      List<Portal> portal= getPortalList();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                MyHomePage(title: 'Prototype: Spoke-It')),
                      );
                    },
                    child: Text('')),
              ),
              Expanded(
                child: Container(
                  color: Colors.grey[300],
                  padding:
                      EdgeInsets.symmetric(vertical: 20.0, horizontal: 120.0),
                  //child: Text('empty'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
