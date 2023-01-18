import 'dart:io';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_maps/maps.dart';
import '../load/LoadView.dart';
import 'package:filesystem_picker/filesystem_picker.dart';

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
  late MapZoomPanBehavior _zoomPanBehavior;
  bool pressed = false;

  @override
  void initState() {
    _zoomPanBehavior = MapZoomPanBehavior(
        enableDoubleTapZooming: true, enableMouseWheelZooming: true);
    _dataSource =
        MapShapeSource.asset('assets/world.json', shapeDataField: 'name_en');

    _data = const <Model>[
      Model('Brazil', -14.235004, -51.92528),
      Model('Germany', 51.16569, 10.451526),
      Model('Australia', -25.274398, 133.775136),
      Model('India', 20.593684, 78.96288),
      Model('Russia', 61.52401, 105.318756),
      Model('Granite City', 38.7014, 90.1487),
      Model('SIUE Art Display', 38.792283, -89.998616),
      Model('Dunham Hall Theatre', 38.793336, -89.998426)
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
        padding: const EdgeInsets.all(8.0),
        child: SfMaps(
          layers: <MapLayer>[
            MapShapeLayer(
              source: _dataSource,
              zoomPanBehavior: _zoomPanBehavior,
              initialMarkersCount: _data.length,
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
                      color: Colors.red,
                      height: 10,
                      width: 10,
                    ),
                  ),
                );
              },
            ),
          ],
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
