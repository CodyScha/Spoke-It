// ignore_for_file: file_names

import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_maps/maps.dart';
import '../../source/portals.dart';
import 'package:syncfusion_flutter_core/theme.dart';

class Display extends StatelessWidget {
  const Display({super.key, required this.portals});
  final List<Portal> portals;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spoke-It', //web name
      theme: ThemeData(
        // This is the theme of your application.

        primarySwatch: Colors.red, //title color
        // scaffoldBackgroundColor: Color.fromRGBO(46, 46, 46, 1),
      ),
      home: MyDisplay(
        portals: portals,
      ), //displayed title
    );
  }
}

class MyDisplay extends StatefulWidget {
  const MyDisplay({super.key, required this.portals});

  final List<Portal> portals;
  @override
  State<MyDisplay> createState() => _MyDisplayState();
}

class _MyDisplayState extends State<MyDisplay> {
  late MapShapeSource _mapSource;
  late List<MarkerModel> _portalData;
  late List<LineModel> _vectordata;
  late MapZoomPanBehavior _zoomPanBehavior;
  late MapShapeLayerController _controller;
  bool pressed = false;

  @override
  void initState() {
    _zoomPanBehavior = MapZoomPanBehavior(
        enableDoubleTapZooming: true, enableMouseWheelZooming: true);

    // _mapSource = MapShapeSource.asset('assets/siue2.json', shapeDataField: 'name_en');
    // _mapSource = MapShapeSource.memory(getJSON(_markerData));

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

    // _markerData = <MarkerModel>[
    //   MarkerModel('Good Samaritan House Mural', 38.700395, -90.152362, Colors.cyan),
    //   MarkerModel('Abstract Metal Art', 38.701165,-90.152455, Colors.cyan),
    //   // MarkerModel('SIUE "The Rock"', 38.793189, -89.997956, Colors.cyan),
    //   MarkerModel('Community Care Center', 38.700642, -90.153146, Colors.cyan)
    // ];

    _mapSource = MapShapeSource.memory(updateJSONTemplate(_portalData));

    // updateJSONTemplate(_portalData).then((response) {
    // _mapSource = MapShapeSource.memory(response);
    // });

    _vectordata = <LineModel>[
      LineModel(
          const MapLatLng(38.793988, -89.999159), const MapLatLng(38.792097, -89.999033)),
      LineModel(
          const MapLatLng(38.793547, -89.997771), const MapLatLng(38.793463, -89.996867))
    ];

    _controller = MapShapeLayerController();

    updateJSONTemplate(_portalData);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Portal testing"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(0.0),
        child: SfMapsTheme(
          data: SfMapsThemeData(
              // shapeHoverColor: Color.fromRGBO(46, 46, 46, 0)
              ),
          child: SfMaps(
            layers: <MapLayer>[
              MapShapeLayer(
                source: _mapSource,
                // source: MapShapeSource.memory(
                //   getJSON(_markerData),
                // ),
                color: const Color.fromRGBO(46, 46, 46, 1),
                zoomPanBehavior: _zoomPanBehavior,
                initialMarkersCount: _portalData.length,
                sublayers: [
                  MapLineLayer(
                    lines:
                        List<MapLine>.generate(_vectordata.length, (int index) {
                      return MapLine(
                        from: _vectordata[index].from,
                        to: _vectordata[index].to,
                        color: Colors.white,
                        width: 5,
                      );
                    }).toSet(),
                  ),
                ],
                markerBuilder: (BuildContext context, int index) {
                  return MapMarker(
                    latitude: _portalData[index].latitude,
                    longitude: _portalData[index].longitude,
                    // iconColor: Colors.red,
                    child: GestureDetector(
                      onLongPress: () {
                        // Set of code that will allow the user to delete a portal from the view.
                        // As far as I can tell, this is the order that actions need to happen to avoid errors.
                        setState(() {
                          _portalData.removeAt(index);
                        });

                        _controller.removeMarkerAt(index);

                        var temp =
                            List.generate(_controller.markersCount, (i) => i);

                        _controller.updateMarkers(temp);
                      },
                      onTap: () {

                        setState(() {
                          _portalData[index].color = Colors.blueGrey;
                        });

                        var temp = List.generate(1, (i) => index);
                        _controller.updateMarkers(temp);
                      },
                      child: Container(
                        height: 25,
                        width: 25,
                        decoration: BoxDecoration(
                          color: _portalData[index].color,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  );
                },
                controller: _controller, //Needed to update markers
                markerTooltipBuilder: (BuildContext context, int index) {
                  return SizedBox(
                      width: 150,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(_portalData[index].name),
                      ));
                },
              ),
            ],
          ),
        ),
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

  // * First, need to get the JSON from the assets folder
  var assetFileStr = File(
          '/Users/codyschaefer/Documents/SIUE/2023 Spring/CS499/Spoke-It/spoke_it_flutter_app/assets/siue2.json')
      .readAsStringSync();
  // var assetFileStr = '';
  // rootBundle.loadString('assets/siue2.json');

  // * Save a copy of the file in a new dir
  if (!Directory('map').existsSync()) {
    Directory('map').create();
  }
  File newFile = File('map/map.json');
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
    maxLat = max(m.latitude, maxLat);
    minLat = min(m.latitude, minLat);

    // * Longitude
    maxLong = max(m.longitude, maxLong);
    minLong = min(m.longitude, minLong);
  }

  // * Print the results
  // print('maxLat: $maxLat');
  // print('minLat: $minLat');
  // print('maxLong: $maxLong');
  // print('minLong: $minLong');

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
