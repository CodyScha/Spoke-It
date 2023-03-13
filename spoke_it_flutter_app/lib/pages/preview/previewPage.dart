import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:spoke_it_flutter_app/pages/Output/OutputScreen.dart';
import 'package:syncfusion_flutter_maps/maps.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import '../../source/portals.dart';

import '../../source/portals.dart';
import '../../source/spoke.dart';
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

  void deletePortal(Portal portal) {
    //serach through list to find portal, then delete it from the list
    String name = portal.name;
    int portalListlen = _portalData.length;
    setState(() {
      _portalData.removeAt(_index);
    });

    _controller.removeMarkerAt(_index);
    var temp = List.generate(_controller.markersCount, (i) => i);
    _controller.updateMarkers(temp);
  }

  void hidePortal() {
    //serach through list to find portal, then delete it from the list

    //found portal to hide
    if (_portalData[_index].shown == false) {
      //switch between hidden and shown
      _portalData[_index].shown = true;
    } else {
      _portalData[_index].shown = false;
    }

    var temp = List.generate(1, (i) => _index);
    _controller.updateMarkers(temp);
  }

  final List<Portal> portals;

  late MapZoomPanBehavior _zoomPanBehavior;
  //late List<MarkerModel> _portalData;
  late List<Portal> _portalData;
  late int _index;
  late List<LineModel> _linkData;
  late MapShapeLayerController _controller;
  late MapShapeSource _mapSource;
  late int indexPressed;
  late bool hasChosenCenter;
  late int chosenCenterIndex;
  late Widget _hiddenPortal;
  late Widget _selectedPortal;
  late Widget _selectedHiddenPortal;
  late Widget _centerPortal;

  void initState() {
    _zoomPanBehavior = MapZoomPanBehavior(
        enableDoubleTapZooming: true,
        enableMouseWheelZooming: true,
        enablePinching: true);

    _portalData = portals;

    _linkData = <LineModel>[
      LineModel(
          MapLatLng(38.793988, -89.999159), MapLatLng(38.792097, -89.999033)),
      LineModel(
          MapLatLng(38.793547, -89.997771), MapLatLng(38.793463, -89.996867))
    ];

    _controller = MapShapeLayerController();
    _mapSource = MapShapeSource.memory(updateJSONTemplate(_portalData));

    hasChosenCenter = false;
    chosenCenterIndex = -1;
    indexPressed = -1;
    for (int i = 0; i < _portalData.length; i++) {
      if (_portalData[i].center) {
        hasChosenCenter = true;
        chosenCenterIndex = i;
        break;
      }
    }

    _centerPortal = Container(
      height: 20,
      width: 20,
      decoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle),
    );

    _hiddenPortal = Container(
      height: 20,
      width: 20,
      decoration: BoxDecoration(
          color: Color.fromARGB(255, 221, 150, 186), shape: BoxShape.circle),
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
              strokeAlign: StrokeAlign.outside)),
    );

    _selectedHiddenPortal = Container(
      height: 20,
      width: 20,
      decoration: BoxDecoration(
          color: Color.fromARGB(255, 221, 150, 186),
          shape: BoxShape.circle,
          border: Border.all(
              color: Color.fromARGB(255, 117, 209, 255),
              width: 4,
              style: BorderStyle.solid,
              strokeAlign: StrokeAlign.outside)),
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
                              hidePortal();
                              print('User pressed the Hide Button');
                            },
                            child: Text("Hide"),
                            style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                    vertical: 0.0, horizontal: 52.0),
                                foregroundColor: Colors.white,
                                textStyle: const TextStyle(fontSize: 30),
                                backgroundColor:
                                    Color.fromARGB(255, 99, 96, 102)),
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

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              Output(portals: _portalData)),
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
                      // Marker is the currently selected one.
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
                                            _controller.markersCount,
                                            (i) => i));
                                      });
                                    },
                                    child: _centerPortal),
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
                      } else if (!_portalData[index].shown &&
                          index == indexPressed) {
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
                                            _controller.markersCount,
                                            (i) => i));
                                      });
                                    },
                                    child: _selectedHiddenPortal),
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
                                        _index = index;

                                        // Update the markers
                                        _controller.updateMarkers(List.generate(
                                            _controller.markersCount,
                                            (i) => i));
                                      });
                                    },
                                    child: _hiddenPortal),
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
                      }
                      // Marker is not currently selected
                      else if (_portalData[index].center) {
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
                                      _index = index;
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
