import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:flutter/material.dart';
import '../load/LoadView.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';
import '../Preview/previewPage.dart';
import '../../source/portals.dart';
import 'dart:typed_data';

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
  @override
  Widget build(BuildContext context) {
    void processLines(List<String> lines) {
      List<Portal> portals = [];

      for (var line in lines) {
        List<String> ports = line.split(";");
        Portal portal = new Portal(
            name: ports[0],
            lat: double.parse(ports[1]),
            long: double.parse(ports[2]),
            team: ports[3],
            health: int.parse(ports[4]),
            shown: true);
        /*
        if (ports[5]=="+"){
          portal.shown = true;
        }else{
          portal.shown = false;
        }*/
        portals.add(portal);
      }

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => myPreview(portals: portals)),
      );
    }

    void pickFile() async {
      // print(Directory.current);
      Directory projectDir = Directory.current;

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt'],
      );

      // print(Directory.current);

      if (result != null) {
        File file = File(result.files.first.path.toString());
        file.readAsLines().then(processLines); //?
      } else {
        // User canceled the picker
      }

      Directory.current = projectDir;
      // print(Directory.current);
    }

    loadFile() async {
      String? path = await FilesystemPicker.openDialog(
        context: context,
        title: 'Saved Profiles',
        fsType: FilesystemType.file,
        rootDirectory: Directory(
            '../..'), //set to be downloads page(where the txt file will save to automatically)
        directory: Directory('profiles'),
        showGoUp: (false),
        allowedExtensions: ['.txt'],
        fileTileSelectMode: FileTileSelectMode.wholeTile,
      );

      if (path != null) {
        File file = File(path);
        file.readAsLines().then(processLines);
      } else {
        // User canceled the picker
      }
    }

    return Scaffold(
      appBar: AppBar(
        //top bar
        title: Text(widget.title),
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
                padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 74.0),
                child: TextButton(
                    onPressed: () {
                      loadFile();
                    },
                    child: Text('Load Profile')),
              ),
              Container(
                color: Colors.grey[300],
                padding:
                    EdgeInsets.symmetric(vertical: 20.0, horizontal: 120.0),
                //child: Text('Inport Data'),
              ),
              Container(
                color: Colors.grey[300],
                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 73.0),
                child: TextButton(
                    onPressed: () {
                      pickFile();
                    },
                    child: Text('Import Data')),
              ),
              Expanded(
                child: Container(
                  color: Colors.grey[300],
                  padding:
                      EdgeInsets.symmetric(vertical: 20.0, horizontal: 120.0),
                ),
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.only(left: 200.0),
                child: Text(
                  'Spoke-It',
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  textScaleFactor: 8.0,
                  style: TextStyle(
                      color: Colors.indigo[400],
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),

      //adjusts location //https://api.flutter.dev/flutter/material/FloatingActionButtonLocation-class.html
    );
  }
}
