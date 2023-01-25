import 'dart:io';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_maps/maps.dart';
import '../load/LoadView.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:syncfusion_flutter_core/theme.dart';

class Display extends StatelessWidget {
  const Display({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spoke-It', //web name
      theme: ThemeData(
        // This is the theme of your application.

        primarySwatch: Colors.red, //title color
      ),
      home: myDisplay(title: 'Prototype: Spoke-It'), //displayed title
    );
  }
}

class myDisplay extends StatefulWidget {
  const myDisplay({super.key, required this.title});

  final String title;

  @override
  State<myDisplay> createState() => _myDisplayState();
}

class _myDisplayState extends State<myDisplay> {
  late MapShapeSource _mapSource;
  late List<MarkerModel> _markerData;
  late List<LineModel> _vectordata;
  late MapZoomPanBehavior _zoomPanBehavior;
  late MapShapeLayerController _controller;
  bool pressed = false;

  @override
  void initState() {
    _zoomPanBehavior = MapZoomPanBehavior(
        enableDoubleTapZooming: true, enableMouseWheelZooming: true);
    _mapSource =
        MapShapeSource.asset('assets/siue2.json', shapeDataField: 'name_en');

    _markerData = <MarkerModel>[
      MarkerModel('SIUE Art Display', 38.792283, -89.998616, Colors.cyan),
      MarkerModel('Dunham Hall Theatre', 38.793336, -89.998426, Colors.cyan),
      MarkerModel('Science East', 38.793988, -89.999159, Colors.cyan),
      MarkerModel(
          'SIUE Student Art Installation', 38.792097, -89.999033, Colors.cyan),
      MarkerModel('SIUE Lovejoy Library', 38.793547, -89.997771, Colors.cyan),
      MarkerModel('SIUE "The Rock"', 38.793189, -89.997956, Colors.cyan),
      MarkerModel('Peck Hall', 38.793463, -89.996867, Colors.cyan)
    ];

    _vectordata = <LineModel>[
      LineModel(
          MapLatLng(38.793988, -89.999159), MapLatLng(38.792097, -89.999033)),
      LineModel(
          MapLatLng(38.793547, -89.997771), MapLatLng(38.793463, -89.996867))
    ];

    _controller = MapShapeLayerController();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Portal testing"),
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
                color: Color.fromRGBO(46, 46, 46, 1),
                zoomPanBehavior: _zoomPanBehavior,
                initialMarkersCount: _markerData.length,
                sublayers: [
                  MapLineLayer(
                    lines:
                        List<MapLine>.generate(_vectordata.length, (int index) {
                      return MapLine(
                        from: _vectordata[index].from,
                        to: _vectordata[index].to,
                        color: Colors.white,
                        width: 3,
                      );
                    }).toSet(),
                  ),
                ],
                markerBuilder: (BuildContext context, int index) {
                  return MapMarker(
                    latitude: _markerData[index].latitude,
                    longitude: _markerData[index].longitude,
                    // iconColor: Colors.red,
                    child: GestureDetector(
                      onLongPress: () {
                        // Set of code that will allow the user to delete a portal from the view.
                        // As far as I can tell, this is the order that actions need to happen to avoid errors.

                        print("deleted " + _markerData[index].name);
                        // print(index);
                        // print(_data);
                        setState(() {
                          _markerData.removeAt(index);
                        });

                        _controller.removeMarkerAt(index);

                        var temp =
                            List.generate(_controller.markersCount, (i) => i);

                        _controller.updateMarkers(temp);
                      },
                      onTap: () {
                        print("hid " + _markerData[index].name);

                        setState(() {
                          _markerData[index].color = Colors.blueGrey;
                          // _vectordata.removeAt(0);
                        });

                        var temp = List.generate(1, (i) => index);
                        _controller.updateMarkers(temp);
                      },
                      child: Container(
                        color: _markerData[index].color,
                        height: 10,
                        width: 10,
                      ),
                    ),
                  );
                },
                controller: _controller, //Needed to update markers
                markerTooltipBuilder: (BuildContext context, int index) {
                  return Container(
                      width: 150,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(_markerData[index].name),
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
