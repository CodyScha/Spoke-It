import 'dart:io';

import 'package:flutter/material.dart';
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
      home: LoadSelection(), //displayed title
    );
  }
}

class LoadSelection extends StatefulWidget {
  @override
  State<LoadSelection> createState() => _LoadSelection();
}

class _LoadSelection extends State<LoadSelection> {
  void pickFile() async {
    FilesystemPicker.openDialog(
      context: context,
      fsType: FilesystemType.file,
      rootDirectory: Directory(
          'C:'), //set to be downloads page(where the txt file will save to automatically)
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
        title: Text('Prototype - Load'),
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
      ),
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
