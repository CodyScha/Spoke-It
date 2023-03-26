import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_maps/maps.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:file_picker/file_picker.dart';

import '../DisplayPortals/DisplayPortal.dart';
import '../Preview/previewPage.dart';
import '../../source/spoke.dart';
import '../../source/portals.dart';

class Output extends StatelessWidget {
  const Output({super.key, required this.portals});
  final List<Portal> portals;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spoke-It', //web name
      theme: ThemeData(
        // This is the theme of your application.

        primarySwatch: Colors.indigo, //title color
        // scaffoldBackgroundColor: Color.fromRGBO(46, 46, 46, 1),
      ),
      home: myOutput(
        portals: portals,
      ), //displayed title
    );
  }
}

class myOutput extends StatefulWidget {
  const myOutput({super.key, required this.portals});

  final List<Portal> portals;
  @override
  State<myOutput> createState() => _myOutputState(portals: portals);
}

class _myOutputState extends State<myOutput> {
  _myOutputState({required this.portals});

  void deletePortal(Portal portal) {
    //serach through list to find portal, then delete it from the list
    String name = portal.name;
    int portalListlen = _portalData.length;
    setState(() {
      _portalData.removeAt(portalIndexPressed);
      _controller.removeMarkerAt(portalIndexPressed);

      portalIndexPressed = -1;
    });

    var temp = List.generate(_controller.markersCount, (i) => i);
    _controller.updateMarkers(temp);
  }

  void hidePortal() {
    setState(() {
      if (_portalData[portalIndexPressed].shown == false) {
      //switch between hidden and shown
      _portalData[portalIndexPressed].shown = true;
    } else {
      _portalData[portalIndexPressed].shown = false;
    }
    });

    var temp = List.generate(1, (i) => portalIndexPressed);
    _controller.updateMarkers(temp);
  }

  void saveFile() async {
    String? path = await FilesystemPicker.openDialog(
      context: context,
      title: 'Saved Profiles',
      fsType: FilesystemType.file,
      rootDirectory: Directory(
          '../..'), //set to be downloads page(where the txt file will save to automatically)
      directory: Directory('profiles'),
      showGoUp: (false),
      allowedExtensions: ['.txt'],
      fileTileSelectMode: FileTileSelectMode.wholeTile,
    );
    //FIX clear file first
    if (path != null) {
      File file = File(path);
      file.writeAsStringSync('');
      int portalListlen = _portalData.length;
      for (int i = 0; i < portalListlen; i++) {
        if (_portalData[i].shown == true) {
          await file.writeAsString(
              "${_portalData[i].name};${_portalData[i].lat};${_portalData[i].long};${_portalData[i].team};${_portalData[i].health};+ \n",
              mode: FileMode.append);
        } else {
          await file.writeAsString(
              "${_portalData[i].name};${_portalData[i].lat};${_portalData[i].long};${_portalData[i].team};${_portalData[i].health}; - \n",
              mode: FileMode.append);
        }
      }
    } else {
      // User canceled the picker
    }
  }

  void saveNewFile(String filename) async {
    String? path;
    /* = await FilesystemPicker.openDialog(
      context: context,
      title: 'Saved Profiles',
      fsType: FilesystemType.file,
      rootDirectory: Directory(
          '../..'), //set to be downloads page(where the txt file will save to automatically)
      directory: Directory('profiles'),
      showGoUp: (false),
      allowedExtensions: ['.txt'],
      fileTileSelectMode: FileTileSelectMode.wholeTile,
    );*/
    path = Directory.current.path;
    File file = File('$path/$filename.txt');
    //FIX clear file first
    file.writeAsStringSync('');
    int portalListlen = _portalData.length;
    for (int i = 0; i < portalListlen; i++) {
      if (_portalData[i].shown == true) {
        await file.writeAsString(
            "${_portalData[i].name};${_portalData[i].lat};${_portalData[i].long};${_portalData[i].team};${_portalData[i].health};+ \n",
            mode: FileMode.append);
      } else {
        await file.writeAsString(
            "${_portalData[i].name};${_portalData[i].lat};${_portalData[i].long};${_portalData[i].team};${_portalData[i].health};- \n",
            mode: FileMode.append);
      }
    }
  }

  String selectPortalInfo() {
    String portalInfo = "";
    if (portalIndexPressed >= 0) {
      portalInfo =
          "\n Coordinates: ${_portalData[portalIndexPressed].lat},${_portalData[portalIndexPressed].long}\n Team: ${_portalData[portalIndexPressed].team}\n Health: ${_portalData[portalIndexPressed].health}\nPoints: 0, loser :( )";
    } else {
      portalInfo = "Please select a portal for more information";
    }
    return portalInfo;
  }

  String selectPortalName() {
    String portalInfo = "";
    if (portalIndexPressed >= 0) {
      portalInfo = '${_portalData[portalIndexPressed].name}';
    } else {
      portalInfo = "";
    }

    return portalInfo;
  }

  final List<Portal> portals;

  late MapZoomPanBehavior _zoomPanBehavior;
  late List<Portal> _portalData;
  late List<LineModel> _linkData;
  late MapShapeLayerController _controller;
  late List<Link> links;
  late MapShapeSource _mapSource;
  late int portalIndexPressed;
  late int linkIndexPressed;
  late bool hasChosenCenter;
  late int chosenCenterIndex;
  late Widget _hiddenPortal;
  late Widget _selectedPortal;
  late Widget _selectedHiddenPortal;
  late Widget _centerPortal;
  late Widget _selectedCenterPortal;

  void initState() {
    _zoomPanBehavior = MapZoomPanBehavior(
        enableDoubleTapZooming: true,
        enableMouseWheelZooming: true,
        enablePinching: true);

    _portalData = portals;

    // _portalData = <MarkerModel>[
    //   MarkerModel('SIUE Art Display', 38.792283, -89.998616, Colors.cyan),
    //   MarkerModel('Dunham Hall Theatre', 38.793336, -89.998426, Colors.cyan),
    //   MarkerModel('Science East', 38.793988, -89.999159, Colors.cyan),
    //   MarkerModel(
    //       'SIUE Student Art Installation', 38.792097, -89.999033, Colors.cyan),
    //   MarkerModel('SIUE Lovejoy Library', 38.793547, -89.997771, Colors.cyan),
    //   MarkerModel('SIUE "The Rock"', 38.793189, -89.997956, Colors.cyan),
    //   MarkerModel('Peck Hall', 38.793463, -89.996867, Colors.cyan)
    // ];

    Spoke alg = new Spoke();
    links = alg.algorithm(portals);

    Link testLink;

    for (int i = 0; i < links.length; ++i) {
      testLink = links[i];
      print('link: $testLink');
    }

    _controller = MapShapeLayerController();
    _mapSource = MapShapeSource.memory(updateJSONTemplate(_portalData));

    hasChosenCenter = false;
    chosenCenterIndex = -1;
    portalIndexPressed = -1;
    linkIndexPressed = -1;

    _centerPortal = Container(
      height: 20,
      width: 20,
      decoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle),
    );

    _selectedCenterPortal = Container(
      height: 20,
      width: 20,
      decoration: BoxDecoration(
          color: Colors.green,
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

    _selectedHiddenPortal = Container(
      height: 20,
      width: 20,
      decoration: BoxDecoration(
          color: Colors.grey[700],
          shape: BoxShape.circle,
          border: Border.all(
              color: Color.fromARGB(255, 117, 209, 255),
              width: 4,
              style: BorderStyle.solid,
              strokeAlign: BorderSide.strokeAlignOutside)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //top bar
        title: Text('Strategy Output'),
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
                        EdgeInsets.symmetric(vertical: 15.0, horizontal: 140.0),
                    //child: Text('Load Data'),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Stack(
                      children: <Widget>[
                        Container(
                          child: TextButton(
                            onPressed: () {
                              if (portalIndexPressed != -1) {
                                setState(() {
                                  for (var p in _portalData) {
                                    if (p.center) {
                                      p.center = false;
                                      print(
                                          "${p.name} is no longer the center portal");
                                    }
                                  }
                                  // Update the new center.
                                  _portalData[portalIndexPressed].center = true;
                                  hasChosenCenter = true;
                                  chosenCenterIndex = portalIndexPressed;

                                  // Update the markers
                                  _controller.updateMarkers(List.generate(
                                      _controller.markersCount, (i) => i));
                                });
                              }

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
                            onPressed: (portalIndexPressed != -1 && !_portalData[portalIndexPressed].center) ? () {
                              hidePortal();
                              print('pressed da Hide button'); //remove
                            } : null ,
                            style: (portalIndexPressed == -1)
                                  ? TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 0.0, horizontal: 52.0),
                                      foregroundColor: Colors.white,
                                      textStyle: const TextStyle(fontSize: 30),
                                      backgroundColor:
                                          Color.fromARGB(255, 99, 96, 102))
                                  : TextButton.styleFrom(
                                      padding: _portalData[portalIndexPressed].shown
                                          ? const EdgeInsets.symmetric(
                                              vertical: 0.0, horizontal: 52.0)
                                          : const EdgeInsets.symmetric(
                                              vertical: 0.0, horizontal: 34.0),
                                      foregroundColor: Colors.white,
                                      textStyle: const TextStyle(fontSize: 30),
                                      backgroundColor: const Color.fromARGB(
                                          255, 99, 96, 102)),
                            child: (portalIndexPressed == -1)
                                  ? Text("Hide")
                                  : Text(_portalData[portalIndexPressed].shown
                                      ? "Hide"
                                      : "Include"),
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
                            // We only want the delete button to be active if a link is pressed, or if a non-center portal is pressed.
                            onPressed: (linkIndexPressed != -1 ||
                                    (portalIndexPressed != -1 &&
                                        !_portalData[portalIndexPressed].center))
                                ? () {
                                    print('pressed da Delete button'); //remove
                                    if (portalIndexPressed != -1) {
                                      Portal portalSelected =
                                          _portalData[portalIndexPressed];
                                      deletePortal(portalSelected);
                                    } else if (linkIndexPressed != -1) {
                                      setState(() {
                                        links.removeAt(linkIndexPressed);
                                        linkIndexPressed = -1;
                                      });
                                    }
                                  }
                                : null,
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
                              print('pressed da Save button'); //remove

                              saveFile();
                            },
                            child: Text("Save"), //generate
                            style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                    vertical: 0.0, horizontal: 52.0),
                                foregroundColor: Colors.white,
                                textStyle: const TextStyle(fontSize: 30),
                                backgroundColor:
                                    Color.fromARGB(255, 18, 153, 6)),
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    color: Colors.grey[300],
                    padding:
                        EdgeInsets.symmetric(vertical: 15.0, horizontal: 140.0),
                    //child: Text('Load Data'),
                  ),
                  Container(
                    color: Color.fromARGB(255, 187, 186, 186),
                    constraints:
                        BoxConstraints.expand(width: 180.0, height: 40.0),
                    child: Text(
                      selectPortalName(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ), //FIX get first line to be name bolded
                  ),
                  Container(
                    color: Color.fromARGB(255, 187, 186, 186),
                    constraints:
                        BoxConstraints.expand(width: 180.0, height: 200.0),
                    child: Text(
                        selectPortalInfo()), //FIX get first line to be name bolded
                  ),
                  Container(
                    color: Colors.grey[300],
                    padding:
                        EdgeInsets.symmetric(vertical: 15.0, horizontal: 140.0),
                    //child: Text('Load Data'),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Stack(
                      children: <Widget>[
                        Container(
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        Preview(portals: _portalData)),
                              );
                              print('pressed da Go Back button');
                            },
                            child: Text("Go Back"), //generate
                            style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                    vertical: 0.0, horizontal: 32.0),
                                foregroundColor: Colors.white,
                                textStyle: const TextStyle(fontSize: 30),
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
          Container(
            width: MediaQuery.of(context).size.width - 220,
            color: Color.fromRGBO(46, 46, 46, 1),
            child: Padding(
              padding: const EdgeInsets.all(1.0),
              child: SfMapsTheme(
                data: SfMapsThemeData(
                    // shapeHoverColor: Color.fromRGBO(46, 46, 46, 1),
                    // shapeHoverStrokeColor: Colors.pink,
                    // shapeHoverStrokeWidth: 5,
                    layerColor: Color.fromRGBO(46, 46, 46, 1),
                    layerStrokeWidth: 0),
                child: SfMaps(layers: <MapLayer>[
                  MapShapeLayer(
                    source: _mapSource,
                    zoomPanBehavior: _zoomPanBehavior,
                    initialMarkersCount: _portalData.length,
                    sublayers: [
                      MapLineLayer(
                        lines:
                            List<MapLine>.generate(links.length, (int index) {
                          return MapLine(
                            from: MapLatLng(
                                links[index].from.lat, links[index].from.long),
                            to: MapLatLng(
                                links[index].to.lat, links[index].to.long),
                            color: (index == linkIndexPressed)
                                ? Color.fromARGB(255, 117, 209, 255)
                                : Colors.white,
                            width: 5,
                            onTap: () {
                              setState(() {
                                // User has selected a link.

                                // Save link index
                                linkIndexPressed = index;
                                // Overwrite the portal index
                                portalIndexPressed = -1;
                                // This should also update the markers.
                                _controller.updateMarkers(List.generate(
                                    _controller.markersCount, (i) => i));
                              });
                              print(
                                  "User pressed the ${links[index].to.name} - ${links[index].from.name}");
                            },
                          );
                        }).toSet(),
                      )
                    ],
                    markerBuilder: (BuildContext context, int index) {
                      if (_portalData[index].center &&
                          index == portalIndexPressed) {
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
                                      portalIndexPressed = index;

                                      // Update the link index
                                      linkIndexPressed = -1;
                                      // Update the markers
                                      _controller.updateMarkers(List.generate(
                                          _controller.markersCount, (i) => i));
                                    });
                                  },
                                  child: _selectedCenterPortal,
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
                      } else if (_portalData[index].center) {
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
                                      portalIndexPressed = index;

                                      // Update the link index
                                      linkIndexPressed = -1;
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
                      } else if (!_portalData[index].shown &&
                          index == portalIndexPressed) {
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
                                        portalIndexPressed = index;

                                        // Update the link index
                                        linkIndexPressed = -1;
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
                                        portalIndexPressed = index;

                                        // Update the link index
                                        linkIndexPressed = -1;

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
                      } else if (index == portalIndexPressed) {
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
                                      portalIndexPressed = index;

                                      // Update the link index
                                      linkIndexPressed = -1;
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
                                      portalIndexPressed = index;

                                      // Update the link index
                                      linkIndexPressed = -1;

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

class MarkerModel {
  MarkerModel(this.name, this.latitude, this.longitude, this.color);

  final String name;
  final double latitude;
  final double longitude;
  Color color;
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
  // print('testingtesting');
  // print('this is a test $assetFileStr');
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
