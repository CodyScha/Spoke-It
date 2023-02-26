import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:spoke_it_flutter_app/pages/Output/OutputScreen.dart';
import 'package:syncfusion_flutter_maps/maps.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import '../../source/portals.dart';

import '../../source/portals.dart';
import '../DisplayPortals/DisplayPortal.dart';

class Preview extends StatelessWidget {
  const Preview({super.key, required this.portals});

  final List<Portal> portals;

  @override
  Widget build(BuildContext context) {
    String dir = Directory.current.toString();
    return MaterialApp(
        //web name
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
  State<myPreview> createState() => _myPreview(portals: portals);
}

class _myPreview extends State<myPreview> {
  _myPreview({required this.portals});

  final List<Portal> portals;

  List<Portal> getPortalList() {
    List<Portal> portalList =
        widget.portals; //widget.portals is getting from parent stateful widget
    return portalList;
  }

  late MapZoomPanBehavior _zoomPanBehavior;
  //late List<MarkerModel> _portalData;
  late List<Portal> _portalData;
  late MapShapeLayerController _controller;
  late MapShapeSource _mapSource;
  late int indexPressed;
  late bool hasChosenCenter;
  late int chosenCenterIndex;
  late Widget _hiddenPortal;
  late Widget _selectedPortal;
  late Widget _centerPortal;
  late Widget _centerSelectedPortal;
  late Widget _hiddenSelectedPortal;

  void initState() {
    _zoomPanBehavior = MapZoomPanBehavior(
        enableDoubleTapZooming: true,
        enableMouseWheelZooming: true,
        enablePinching: true);

    _portalData = portals;

    _controller = MapShapeLayerController();
    _mapSource = MapShapeSource.memory(updateJSONTemplate(_portalData));

    hasChosenCenter = false;
    chosenCenterIndex = -1;
    indexPressed = -1;

    _centerPortal = Container(
      height: 20,
      width: 20,
      decoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle),
    );

    _selectedPortal = Container(
      height: 20,
      width: 20,
      decoration: BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
          border: Border.all(
              color: Color.fromARGB(255, 117, 209, 255),
              width: 4,
              style: BorderStyle.solid,
              strokeAlign: BorderSide.strokeAlignOutside)),
    );

    _hiddenPortal = Container(
      height: 20,
      width: 20,
      decoration:
          BoxDecoration(color: Colors.grey[700], shape: BoxShape.circle),
    );
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
                  Container(
                    color: Colors.grey[300],
                    padding:
                        EdgeInsets.symmetric(vertical: 20.0, horizontal: 140.0),
                    //child: Text('Load Data'),
                  ),
                  const Text(
                    'Select a center portal',
                    textScaleFactor: 1.4,
                    textAlign: TextAlign.center,
                  ),
                  Container(
                    color: Colors.grey[300],
                    padding:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 140.0),
                    //child: Text('Load Data'),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Stack(
                      children: <Widget>[
                        Container(
                          child: TextButton(
                            onPressed: () {
                              // User has pressed the Center button
                              print('User pressed the Center button.');
                              print(indexPressed);

                              // Find the previous center and mark it false.
                              setState(() {
                                for (var p in _portalData) {
                                  if (p.center) {
                                    p.center = false;
                                    print(
                                        "${p.name} is no longer the center portal");
                                  }
                                }

                                // Update the new center.
                                _portalData[indexPressed].center = true;
                                hasChosenCenter = true;
                                chosenCenterIndex = indexPressed;

                                // Update the markers
                                _controller.updateMarkers(List.generate(
                                    _controller.markersCount, (i) => i));
                              });

                              for (var p in _portalData) {
                                if (p.center) {
                                  print("${p.name} is the new center portal");
                                }
                              }
                            },
                            child: Text("Center"), //Center
                            style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                    vertical: 0.0, horizontal: 39.0),
                                foregroundColor: Colors.white,
                                textStyle: const TextStyle(fontSize: 30),
                                backgroundColor: Colors.indigo),
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    color: Colors.grey[300],
                    padding:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 140.0),
                    //child: Text('Load Data'),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Stack(
                      children: <Widget>[
                        Container(
                          child: TextButton(
                              onPressed: (
                                  //create a function that when a portal is clicked it will update a Portal variable,
                                  //the hide function will find that portal in the list and update its +/-
                                  ) {
                                print('User pressed the Hide Button');

                                // Use the index pressed to change that portal's state to hidden.
                                setState(() {
                                  _portalData[indexPressed].shown = false;
                                  print(
                                      "Portal $indexPressed: ${_portalData[indexPressed].name} is now hidden.");

                                  // Update the markers
                                  _controller.updateMarkers(List.generate(
                                      _controller.markersCount, (i) => i));

                                  // Update the indexPressed
                                  indexPressed = -1;
                                });
                              },
                              child: (indexPressed == -1)
                                  ? Text("Hide")
                                  : Text(_portalData[indexPressed].shown
                                      ? "Hide"
                                      : "Include"),
                              style: (indexPressed == -1)
                                  ? TextButton.styleFrom(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 0.0, horizontal: 52.0),
                                      foregroundColor: Colors.white,
                                      textStyle: const TextStyle(fontSize: 30),
                                      backgroundColor:
                                          Color.fromARGB(255, 99, 96, 102))
                                  : TextButton.styleFrom(
                                      padding: _portalData[indexPressed].shown
                                          ? EdgeInsets.symmetric(
                                              vertical: 0.0, horizontal: 52.0)
                                          : EdgeInsets.symmetric(
                                              vertical: 0.0, horizontal: 34.0),
                                      foregroundColor: Colors.white,
                                      textStyle: const TextStyle(fontSize: 30),
                                      backgroundColor:
                                          Color.fromARGB(255, 99, 96, 102))),
                        )
                      ],
                    ),
                  ),
                  Container(
                    color: Colors.grey[300],
                    padding:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 140.0),
                    //child: Text('Load Data'),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Stack(
                      children: <Widget>[
                        Container(
                          child: TextButton(
                            onPressed: () {
                              print('User pressed the Delete button');

                              // First, we remove the selected index from the List.
                              setState(() {
                                _portalData.removeAt(indexPressed);

                                // Check if this portal was chosen to be a center portal. If so, update the state to reflect that we no longer have a center portal.
                                hasChosenCenter = false;
                                chosenCenterIndex = -1;
                              });

                              // Then, we need to remove the marker from the Map Widget
                              _controller.removeMarkerAt(indexPressed);

                              // Also, update the indexPressed. Without this, the rebuild will show the next portal being pressed without actually being pressed by the user.
                              setState(() {
                                indexPressed = -1;
                              });

                              // Lastly, update the marker list and tell the Widget to rebuild.
                              _controller.updateMarkers(List.generate(
                                  _controller.markersCount, (i) => i));
                            },
                            child: Text("Delete"), //delete
                            style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                    vertical: 0.0, horizontal: 40.0),
                                foregroundColor: Colors.white,
                                textStyle: const TextStyle(fontSize: 30),
                                backgroundColor:
                                    Color.fromARGB(255, 163, 6, 6)),
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
                            onPressed: hasChosenCenter
                                ? () {
                                    print(
                                        'User has pressed the Generate Button');
                                    List<Portal> portals = getPortalList();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              Output(portals: portals)),
                                    );
                                  }
                                : null,
                            child: Text("Generate"), //generate
                            style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                    vertical: 0.0, horizontal: 15.0),
                                foregroundColor: Colors.white,
                                textStyle: const TextStyle(fontSize: 35),
                                backgroundColor: hasChosenCenter
                                    ? Colors.indigo
                                    : Colors.grey[500]),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width - 220,
            color: Color.fromRGBO(46, 46, 46, 1),
            child: Padding(
              padding: const EdgeInsets.all(1.0),
              child: SfMapsTheme(
                data: SfMapsThemeData(
                    shapeHoverColor: Color.fromRGBO(46, 46, 46, 1),
                    layerColor: Color.fromRGBO(46, 46, 46, 1),
                    layerStrokeWidth: 0),
                child: SfMaps(layers: <MapLayer>[
                  MapShapeLayer(
                    source: _mapSource,
                    zoomPanBehavior: _zoomPanBehavior,
                    initialMarkersCount: _portalData.length,
                    markerBuilder: (BuildContext context, int index) {
                      if (index == chosenCenterIndex) {
                        return MapMarker(
                            latitude: _portalData[index].lat,
                            longitude: _portalData[index].long,
                            child:
                                Stack(alignment: Alignment.center, children: [
                              MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  onTap: () {
                                    print(
                                        'Pressed the $index: ${_portalData[index].name} Portal.');
                                    setState(() {
                                      indexPressed = index;

                                      // Update the markers
                                      _controller.updateMarkers(List.generate(
                                          _controller.markersCount, (i) => i));
                                    });
                                  },
                                  child: _centerPortal,
                                ),
                              ),
                              IgnorePointer(
                                child: SizedBox(
                                  width: 125,
                                  child: Padding(
                                      padding: const EdgeInsets.only(top: 45),
                                      child: Text(
                                        _portalData[index].name,
                                        // softWrap: true,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 11),
                                      )),
                                ),
                              )
                            ]));
                      } else if (!_portalData[index].shown) {
                        return MapMarker(
                            latitude: _portalData[index].lat,
                            longitude: _portalData[index].long,
                            child:
                                Stack(alignment: Alignment.center, children: [
                              MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  onTap: () {
                                    print(
                                        'Pressed the $index: ${_portalData[index].name} Portal.');
                                    setState(() {
                                      indexPressed = index;

                                      // Update the markers
                                      _controller.updateMarkers(List.generate(
                                          _controller.markersCount, (i) => i));
                                    });
                                  },
                                  child: _hiddenPortal,
                                ),
                              ),
                              IgnorePointer(
                                child: SizedBox(
                                  width: 125,
                                  child: Padding(
                                      padding: const EdgeInsets.only(top: 45),
                                      child: Text(
                                        _portalData[index].name,
                                        // softWrap: true,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 11),
                                      )),
                                ),
                              )
                            ]));
                      } else if (index == indexPressed) {
                        return MapMarker(
                            latitude: _portalData[index].lat,
                            longitude: _portalData[index].long,
                            child:
                                Stack(alignment: Alignment.center, children: [
                              MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  onTap: () {
                                    print(
                                        'Pressed the $index: ${_portalData[index].name} Portal.');
                                    setState(() {
                                      indexPressed = index;

                                      // Update the markers
                                      _controller.updateMarkers(List.generate(
                                          _controller.markersCount, (i) => i));
                                    });
                                  },
                                  child: _selectedPortal,
                                ),
                              ),
                              IgnorePointer(
                                child: SizedBox(
                                  width: 125,
                                  child: Padding(
                                      padding: const EdgeInsets.only(top: 45),
                                      child: Text(
                                        _portalData[index].name,
                                        // softWrap: true,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 11),
                                      )),
                                ),
                              )
                            ]));
                      } else {
                        return MapMarker(
                            latitude: _portalData[index].lat,
                            longitude: _portalData[index].long,
                            child:
                                Stack(alignment: Alignment.center, children: [
                              MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  onTap: () {
                                    print(
                                        'Pressed the $index: ${_portalData[index].name} Portal.');
                                    setState(() {
                                      indexPressed = index;

                                      // Update the markers
                                      _controller.updateMarkers(List.generate(
                                          _controller.markersCount, (i) => i));
                                    });
                                  },
                                  child: Container(
                                    height: 20,
                                    width: 20,
                                    decoration: BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle),
                                  ),
                                ),
                              ),
                              IgnorePointer(
                                child: SizedBox(
                                  width: 125,
                                  child: Padding(
                                      padding: const EdgeInsets.only(top: 45),
                                      child: Text(
                                        _portalData[index].name,
                                        // softWrap: true,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 11),
                                      )),
                                ),
                              )
                            ]));
                      }
                    },
                    controller: _controller,
                  )
                ]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Uint8List updateJSONTemplate(List<Portal> markers) {
  double buffer = 0.0001;
  String aggregiousTabs = '\t\t\t\t\t\t\t';

  List<int> coordLatLines = [14, 18, 22, 26, 30];
  List<int> coordLongLines = [13, 17, 21, 25, 29];

  // * First, need to get the JSON from the assets folder
  var assetFileStr = File('assets/siue2.json').readAsStringSync();
  // var assetFileStr = '';
  // rootBundle.loadString('assets/siue2.json');

  // * Save a copy of the file in a new dir
  if (!Directory('map').existsSync()) {
    var mapdir = Directory('map').create();
  }
  File newFile = File('map/map.json');
  print('testingtesting');
  print('this is a test $assetFileStr');
  newFile.writeAsStringSync(assetFileStr);

  // * Now, we need to change the coords in the new file
  List<String> newFileLines = newFile.readAsLinesSync();
  // print(newFileLines.length);

  // * First, find the extremes for latitude and longitude.
  double maxLat = -91.0;
  double minLat = 91.0;
  double maxLong = -181.0;
  double minLong = 181.0;

  // * Iterate through the markers to find the extremes
  for (var m in markers) {
    // * Latitude
    maxLat = max(m.lat, maxLat);
    minLat = min(m.lat, minLat);

    // * Longitude
    maxLong = max(m.long, maxLong);
    minLong = min(m.long, minLong);
  }

  // * Print the results
  print('maxLat: $maxLat');
  print('minLat: $minLat');
  print('maxLong: $maxLong');
  print('minLong: $minLong');

  // * Now, change the newFile lines to the max and mins
  String minLatStr = aggregiousTabs + (minLat - buffer).toString();
  String maxLatStr = aggregiousTabs + (maxLat + buffer).toString();
  String minLongStr = '$aggregiousTabs${minLong - buffer},';
  String maxLongStr = '$aggregiousTabs${maxLong + buffer},';

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
