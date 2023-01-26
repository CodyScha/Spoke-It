import 'dart:io';

import 'package:flutter/material.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import '../home/homeView.dart';
import '../Preview/Preview.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';

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
      home: LoadSelection(), //displayed title
    );
  }
}

class LoadSelection extends StatefulWidget {
  @override
  State<LoadSelection> createState() => _LoadSelection();
}

class _LoadSelection extends State<LoadSelection> {
  /*
    String? path = await FilesystemPicker.openDialog(
      context: context,
      fsType: FilesystemType.file,
      rootDirectory: Directory.current,
      allowedExtensions: ['.txt'],
      fileTileSelectMode: FileTileSelectMode.wholeTile,
    );
   */

  @override
  Widget build(BuildContext context) {
    void pickFile() async {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt'],
      );

      if (result != null) {
        File file = File(result.files.first.path.toString());
        //use file
        //myPreview(File)
        // ignore: use_build_context_synchronously
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => myPreview(file: file)),
        );
      } else {
        // User canceled the picker
      }
    }

    return Scaffold(
      appBar: AppBar(
        //top bar
        title: Text('Prototype - Load'),
        centerTitle: true, //centers text
      ),

      /*drawer: Drawer(
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
                // Update the state of the app.
                // ...
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Import Data'),
              onTap: () {
                // Update the state of the app.
                // ...

                pickFile();
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 40.0, horizontal: 70.0),
            ),
            Container(
              color: Colors.grey[300],
              padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 70.0),
              child: TextButton(onPressed: () {}, child: Text('option 1')),
            ),
            Container(
              color: Colors.grey[300],
              padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 70.0),
              child: TextButton(onPressed: () {}, child: Text('option 2')),
            ),
            Container(
              color: Colors.grey[300],
              padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 70.0),
              child: TextButton(onPressed: () {}, child: Text('option 3')),
            ),
          ],
        ),
      ),*/
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                MyHomePage(title: 'Prototype: Load')),
                      );
                    },
                    child: Text('Home')),
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
                  //child: Text('empty'),
                ),
              ),
            ],
          ),
          Column(
            children: [
              Container(
                padding:
                    EdgeInsets.symmetric(vertical: 40.0, horizontal: 150.0),
              ),
            ],
          ),
          Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 40.0, horizontal: 70.0),
              ),
              Container(
                color: Colors.grey[300],
                padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 71.0),
                child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Preview()),
                      );
                    },
                    child: Text('option 1')),
              ),
              Container(
                color: Colors.grey[300],
                padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 70.0),
                child: TextButton(onPressed: () {}, child: Text('option 2')),
              ),
              Container(
                color: Colors.grey[300],
                padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 70.0),
                child: TextButton(onPressed: () {}, child: Text('option 3')),
              ),
            ],
          )
        ],
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      //adjusts location //https://api.flutter.dev/flutter/material/FloatingActionButtonLocation-class.html
    );
  }
}
