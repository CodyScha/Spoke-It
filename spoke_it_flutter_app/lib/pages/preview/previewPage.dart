import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:spoke_it_flutter_app/pages/Output/OutputScreen.dart';
import 'package:syncfusion_flutter_maps/maps.dart';
import 'package:syncfusion_flutter_core/theme.dart';

import '../../source/portals.dart';
import '../DisplayPortals/DisplayPortal.dart';

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
          //file: File('$dir/Saved/SIUE_Gardens.txt')), //displayed title
          portals: portals,
        ));
  }
}

class myPreview extends StatefulWidget {
  const myPreview({super.key, required this.portals});

  final List<Portal> portals;
  //final File file;

  @override
  State<myPreview> createState() => _myPreview();
}

class _myPreview extends State<myPreview> {
  List<Portal> getPortalList() {
    List<Portal> portalList =
        widget.portals; //widget.portals is getting from parent stateful widget
    return portalList;
  }

  late String test;
  late String test2;
  late MapZoomPanBehavior _zoomPanBehavior;
  late List<MarkerModel> _portalData;
  late List<LineModel> _linkData;
  late MapShapeLayerController _controller;

  void initState() {
    test = 'Center'; // ! Delete l8r
    test2 = 'Generate';

    _zoomPanBehavior = MapZoomPanBehavior(
        enableDoubleTapZooming: true, enableMouseWheelZooming: true);

    _portalData = <MarkerModel>[
      MarkerModel('SIUE Art Display', 38.792283, -89.998616, Colors.cyan),
      MarkerModel('Dunham Hall Theatre', 38.793336, -89.998426, Colors.cyan),
      MarkerModel('Science East', 38.793988, -89.999159, Colors.cyan),
      MarkerModel(
          'SIUE Student Art Installation', 38.792097, -89.999033, Colors.cyan),
      MarkerModel('SIUE Lovejoy Library', 38.793547, -89.997771, Colors.cyan),
      MarkerModel('SIUE "The Rock"', 38.793189, -89.997956, Colors.cyan),
      MarkerModel('Peck Hall', 38.793463, -89.996867, Colors.cyan)
    ];

    _linkData = <LineModel>[
      LineModel(
          MapLatLng(38.793988, -89.999159), MapLatLng(38.792097, -89.999033)),
      LineModel(
          MapLatLng(38.793547, -89.997771), MapLatLng(38.793463, -89.996867))
    ];

    _controller = MapShapeLayerController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //top bar
        title: Text('Preview Portals'),
        centerTitle: true, //centers text
      ),
      body: Row(
        children: [
          SizedBox(
            width: 220,
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  border: Border(
                      right: BorderSide(color: (Colors.grey[400])!, width: 1))),
              child: Column(
                // Center is a layout widget. It takes a single child and positions it
                // in the middle of the parent.
                // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                // crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  // Container(
                  //   color: Color.fromARGB(255, 7, 175, 7),
                  //   padding:
                  //       EdgeInsets.symmetric(vertical: 20.0, horizontal: 120.0),
                  //   //child: Text('Load Data'),
                  // ),
                  // Container(
                  //   color: Color.fromARGB(255, 173, 16, 16),
                  //   padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 92.0),
                  //   child: TextButton(
                  //       onPressed: () {
                  //         Navigator.push(
                  //           context,
                  //           MaterialPageRoute(
                  //               builder: (context) =>
                  //                   MyHomePage(title: 'Prototype: Spoke-It')),
                  //         );
                  //       },
                  //       child: Text('')),
                  // ),
                  Container(
                    color: Colors.grey[300],
                    padding:
                        EdgeInsets.symmetric(vertical: 20.0, horizontal: 140.0),
                    //child: Text('Load Data'),
                  ),
                  Text(
                    'Select a center portal',
                    textScaleFactor: 1.4,
                    textAlign: TextAlign.center,
                  ),
                  Container(
                    color: Colors.grey[300],
                    padding:
                        EdgeInsets.symmetric(vertical: 25.0, horizontal: 140.0),
                    //child: Text('Load Data'),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Stack(
                      children: <Widget>[
                        Container(
                          child: TextButton(
                            onPressed: () {
                              print('pressed da $test button');
                            },
                            child: Text(test), //Center
                            style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                    vertical: 0.0, horizontal: 37.0),
                                foregroundColor: Colors.white,
                                textStyle: const TextStyle(fontSize: 35),
                                backgroundColor: Colors.indigo),
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    color: Colors.grey[300],
                    padding:
                        EdgeInsets.symmetric(vertical: 25.0, horizontal: 140.0),
                    //child: Text('Load Data'),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Stack(
                      children: <Widget>[
                        Container(
                          child: TextButton(
                            onPressed: () {
                              print('pressed da $test2 button');
                              List<Portal> portals = getPortalList();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        Output(portals: portals)),
                              );
                            },
                            child: Text(test2), //generate
                            style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                    vertical: 0.0, horizontal: 15.0),
                                foregroundColor: Colors.white,
                                textStyle: const TextStyle(fontSize: 35),
                                backgroundColor: Colors.indigo),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(1.0),
            child: SfMaps(layers: <MapLayer>[
              MapShapeLayer(
                source: MapShapeSource.asset('assets/siue2.json',
                    shapeDataField: 'name_en'),
                initialMarkersCount: _portalData.length,
                sublayers: [
                  MapLineLayer(
                    lines:
                        List<MapLine>.generate(_linkData.length, (int index) {
                      return MapLine(
                        from: _linkData[index].from,
                        to: _linkData[index].to,
                        color: Colors.white,
                        width: 5,
                      );
                    }).toSet(),
                  )
                ],
                markerBuilder: (BuildContext context, int index) {
                  return MapMarker(
                      latitude: _portalData[index].latitude,
                      longitude: _portalData[index].longitude,
                      child: Container(
                        height: 25,
                        width: 25,
                        color: Colors.red,
                      ));
                },
                controller: _controller,
                markerTooltipBuilder: (BuildContext context, index) {
                  return Container(
                    width: 150,
                    child: Text(_portalData[index].name),
                  );
                },
              )
            ]),
          ),
        ],
      ),
    );
  }
}

class MarkerModel {
  MarkerModel(this.name, this.latitude, this.longitude, this.color);

  final String name;
  final double latitude;
  final double longitude;
  Color color;
}

class LineModel {
  LineModel(this.from, this.to);

  final MapLatLng from;
  final MapLatLng to;
}

Uint8List updateJSONTemplate(List<MarkerModel> markers) {
  double buffer = 0.00005;
  String aggregiousTabs = '\t\t\t\t\t\t\t';

  List<int> coordLatLines = [14, 18, 22, 26, 30];
  List<int> coordLongLines = [13, 17, 21, 25, 29];

  // * First, need to get the JSON from the assets folder
  var assetFileStr = File('assets/siue2.json').readAsStringSync();

  // * Save a copy of the file in a new dir
  Directory('map').create();
  File newFile = File('map/map.json');
  newFile.writeAsStringSync(assetFileStr);

  // * Now, we need to change the coords in the new file
  List<String> newFileLines = newFile.readAsLinesSync();

  // * First, find the extremes for latitude and longitude.
  double maxLat = -91.0;
  double minLat = 91.0;
  double maxLong = -181.0;
  double minLong = 181.0;

  // * Iterate through the markers to find the extremes
  for (var m in markers) {
    // * Latitude
    maxLat = max(m.latitude, maxLat);
    minLat = min(m.latitude, minLat);

    // * Longitude
    maxLong = max(m.longitude, maxLong);
    minLong = min(m.longitude, minLong);
  }

  // * Print the results
  print('maxLat: $maxLat');
  print('minLat: $minLat');
  print('maxLong: $maxLong');
  print('minLong: $minLong');

  // * Now, change the newFile lines to the max and mins
  String minLatStr = aggregiousTabs + (minLat - buffer).toString();
  String maxLatStr = aggregiousTabs + (maxLat + buffer).toString();
  String minLongStr = aggregiousTabs + (minLong - buffer).toString() + ',';
  String maxLongStr = aggregiousTabs + (maxLong + buffer).toString() + ',';

  newFileLines[12] = minLongStr;
  newFileLines[13] = minLatStr;

  newFileLines[16] = maxLongStr;
  newFileLines[17] = minLatStr;

  newFileLines[20] = maxLongStr;
  newFileLines[21] = maxLatStr;

  newFileLines[24] = minLongStr;
  newFileLines[25] = maxLatStr;

  newFileLines[28] = minLongStr;
  newFileLines[29] = minLatStr;
  // * Wasn't that exciting, I love programming 😀

  // newFileLines[16] = '\t\t\t\t\t\t\t-89.850000000,';
  String combineLines = '';
  for (var l in newFileLines) {
    combineLines += '$l\n';
  }
  newFile.writeAsStringSync(combineLines);

  // * Then convert to bytes to load to program
  Uint8List mapFileBytes = (newFile).readAsBytesSync();

  return mapFileBytes;
}
