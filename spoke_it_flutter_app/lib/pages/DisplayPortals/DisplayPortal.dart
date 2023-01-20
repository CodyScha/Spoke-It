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
  late MapShapeSource _dataSource;
  late List<Model> _data;
  late List<LineModel> _vectordata;
  late MapZoomPanBehavior _zoomPanBehavior;
  bool pressed = false;

  @override
  void initState() {
    _zoomPanBehavior = MapZoomPanBehavior(
        enableDoubleTapZooming: true, enableMouseWheelZooming: true);
    _dataSource =
        MapShapeSource.asset('assets/siue2.json', shapeDataField: 'name_en');

    // _data = const <Model>[
    //   Model('Brazil', -14.235004, -51.92528),
    //   Model('Germany', 51.16569, 10.451526),
    //   Model('Australia', -25.274398, 133.775136),
    //   Model('India', 20.593684, 78.96288),
    //   Model('Russia', 61.52401, 105.318756),
    //   Model('Granite City', 38.7014, 90.1487),
    //   Model('SIUE Art Display', 38.792283, -89.998616),
    //   Model('Dunham Hall Theatre', 38.793336, -89.998426)
    // ];

    _data = const <Model>[
      Model('SIUE Art Display', 38.792283, -89.998616),
      Model('Dunham Hall Theatre', 38.793336, -89.998426),
      Model('Science East', 38.793988, -89.999159),
      Model('SIUE Student Art Installation', 38.792097, -89.999033),
      Model('SIUE Lovejoy Library', 38.793547, -89.997771),
      Model('SIUE "The Rock"', 38.793189, -89.997956),
      Model('Peck Hall', 38.793463, -89.996867)
    ];

    _vectordata = <LineModel>[
      LineModel(
          MapLatLng(38.793988, -89.999159), MapLatLng(38.792097, -89.999033)),
      LineModel(
          MapLatLng(38.793547, -89.997771), MapLatLng(38.793463, -89.996867))
    ];

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
        padding: const EdgeInsets.all(2.0),
        child: SfMapsTheme(
          data: SfMapsThemeData(
              // shapeHoverColor: Color.fromRGBO(46, 46, 46, 0)
              ),
          child: SfMaps(
            layers: <MapLayer>[
              MapShapeLayer(
                source: _dataSource,
                color: Color.fromRGBO(46, 46, 46, 1),
                zoomPanBehavior: _zoomPanBehavior,
                initialMarkersCount: _data.length,
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
                    latitude: _data[index].latitude,
                    longitude: _data[index].longitude,
                    // iconColor: Colors.red,
                    child: GestureDetector(
                      onTap: () {
                        print("pressed " + _data[index].country);
                      },
                      child: Container(
                        color: Colors.cyan,
                        height: 10,
                        width: 10,
                      ),
                    ),
                  );
                },
                markerTooltipBuilder: (BuildContext context, int index) {
                  return Container(
                    width: 150,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        _data[index].country
                      ),
                    )
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Model {
  const Model(this.country, this.latitude, this.longitude);

  final String country;
  final double latitude;
  final double longitude;
}

class LineModel {
  LineModel(this.from, this.to);

  final MapLatLng from;
  final MapLatLng to;
}
