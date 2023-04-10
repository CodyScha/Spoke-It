// ignore_for_file: file_names

import 'dart:io';

import 'package:flutter/material.dart';
import '../home/homeView.dart';
import '../Preview/PreviewPage.dart';
import 'package:file_picker/file_picker.dart';
import '../../model/portals.dart';

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
      home: const LoadSelection(), //displayed title
    );
  }
}

class LoadSelection extends StatefulWidget {
  const LoadSelection({super.key});

  @override
  State<LoadSelection> createState() => _LoadSelection();
}

class _LoadSelection extends State<LoadSelection> {

  @override
  Widget build(BuildContext context) {
    void processLines(List<String> lines) {
      List<Portal> portals = [];

      for (var line in lines) {
        List<String> ports = line.split(";");
        Portal portal = Portal(
            name: ports[0],
            lat: double.parse(ports[1]),
            long: double.parse(ports[2]),
            team: ports[3],
            health: int.parse(ports[4]),
            shown: true,
            center:false);

        if (ports[5] == "+") {
          portal.shown = true;
        } else {
          portal.shown = false;
        }
        portals.add(portal);
      }

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MyPreview(portals: portals)),
      );
    }

    void pickFile() async {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt'],
      );

      if (result != null) {
        File file = File(result.files.first.path.toString());
        //use file
        file.readAsLines().then(processLines);
      } else {
        // User canceled the picker
      }
    }

    return Scaffold(
      appBar: AppBar(
        //top bar
        title: const Text('Load'),
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
                    const EdgeInsets.symmetric(vertical: 20.0, horizontal: 120.0),
                //child: Text('Load Data'),
              ),
              Container(
                color: Colors.grey[300],
                padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 92.0),
                child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const MyHomePage(title: 'Load')),
                      );
                    },
                    child: const Text('Home')),
              ),
              Container(
                color: Colors.grey[300],
                padding:
                    const EdgeInsets.symmetric(vertical: 20.0, horizontal: 120.0),
                //child: Text('Inport Data'),
              ),
              Container(
                color: Colors.grey[300],
                padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 73.0),
                child: TextButton(
                    onPressed: () {
                      pickFile();
                    },
                    child: const Text('Import Data')),
              ),
              Expanded(
                child: Container(
                  color: Colors.grey[300],
                  padding:
                      const EdgeInsets.symmetric(vertical: 20.0, horizontal: 120.0),
                  //child: Text('empty'),
                ),
              ),
            ],
          ),
          Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 40.0, horizontal: 150.0),
              ),
            ],
          ),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 70.0),
              ),
              Container(
                color: Colors.grey[300],
                padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 71.0),
                child: TextButton(
                    onPressed: () {
                      /*Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Preview()),
                      );*/
                    },
                    child: const Text('option 1')),
              ),
              Container(
                color: Colors.grey[300],
                padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 70.0),
                child: TextButton(onPressed: () {}, child: const Text('option 2')),
              ),
              Container(
                color: Colors.grey[300],
                padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 70.0),
                child: TextButton(onPressed: () {}, child: const Text('option 3')),
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
