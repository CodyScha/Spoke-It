import 'dart:io';

import 'package:flutter/material.dart';
import '../load/LoadView.dart';
import 'package:filesystem_picker/filesystem_picker.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    
    return MaterialApp(
      title: 'Home', //web name
      theme: ThemeData(
        // This is the theme of your application.

        primarySwatch: Colors.indigo, //title color
      ),
      home: MyHomePage(title: 'Prototype: Spoke-It'), //displayed title
    );
  }
}

///////////////////////////
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  void pickFile() async { 
    FilesystemPicker.openDialog(
      context: context,
      fsType: FilesystemType.file,
      rootDirectory: Directory('C:'), //set to be downloads page(where the txt file will save to automatically)
      allowedExtensions: ['.txt'],
      fileTileSelectMode: FileTileSelectMode.wholeTile,
    );
    //FilePickerResult? result = await FilePicker.platform.pickFiles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //top bar
        title: Text(widget.title),
        centerTitle: true, //centers text
      ),

      drawer: Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          //padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.indigo,
              ),
              child: Text('Menu'),
            ),
            ListTile(
              title: const Text('Load Data'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoadSelection()),
                );
              },
            ),
            ListTile(
              title: const Text('Import Data'),
              onTap: () {
                // Update the state of the app.
                // ...
                pickFile();
                //Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      /*body: Row(
        children: [
          Column(
            // Center is a layout widget. It takes a single child and positions it
            // in the middle of the parent.
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                color: Colors.grey[300],
                padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
                //child: Text('Load Data'),
              ),
              ElevatedButton(onPressed: () {}, child: Text('Load Data')),
              Container(
                color: Colors.grey[300],
                padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
                //child: Text('Inport Data'),
              ),
              ElevatedButton(onPressed: () {}, child: Text('Inport Data')),
              Expanded(
                child: Container(
                  color: Colors.grey[300],
                  padding:
                      EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
                  //child: Text('empty'),
                ),
              ),
            ],
          ),
        ],
      ),
      */
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.blue[900], //main color
        hoverColor: Colors.green[700], //changes to color when hovered over
        //elevation: 12 position in zaxis , further from page
        child: const Icon(Icons.add),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      //adjusts location //https://api.flutter.dev/flutter/material/FloatingActionButtonLocation-class.html
    );
  }

  
  
}
