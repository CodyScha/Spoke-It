import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:spoke_it_flutter_app/pages/Output/OutputScreen.dart';
import 'package:spoke_it_flutter_app/pages/home/homeView.dart';
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

  String selectPortalInfo() {
    String portalInfo = "";
    if (indexPressed >= 0) {
      portalInfo =
          "\n Coordinates: ${_portalData[indexPressed].lat},${_portalData[indexPressed].long}\n Team: ${_portalData[indexPressed].team}\n Health: ${_portalData[indexPressed].health}\n";
    } else {
      portalInfo = "Please select a portal for more information";
    }
    return portalInfo;
  }

  String selectPortalName() {
    String portalInfo = "";
    if (indexPressed >= 0) {
      portalInfo = '${_portalData[indexPressed].name}';
    } else {
      portalInfo = "";
    }

    return portalInfo;
  }

  void areYouSure() async {
    String fname;
    var result = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Are you sure?\nUnsaved changes will be lost.\n',
          ),
          //'You are about to exit to the homepage, any new changes will not be saved.\n Would you like to continue?\n'),
          actions: <Widget>[
            TextButton(
              style: const ButtonStyle(
                backgroundColor: MaterialStatePropertyAll<Color>(
                    Color.fromARGB(255, 163, 6, 6)),
              ),
              child: Text(
                'CANCEL',
                style:
                    const TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            /*TextButton(
              style: const ButtonStyle(
                backgroundColor: MaterialStatePropertyAll<Color>(
                    Color.fromARGB(255, 18, 153, 6)),
              ),
              child: Text(
                'SAVE',
                style:
                    const TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
              ),
              onPressed: () {
                nameNewFile();
              },
            ),*/
            TextButton(
              style: const ButtonStyle(
                backgroundColor: MaterialStatePropertyAll<Color>(
                    Color.fromARGB(255, 101, 85, 186)),
              ),
              child: Text(
                'CONTINUE',
                //selectionColor:  Color.fromARGB(255, 0, 0, 0),),
                style:
                    const TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomeView()),
                );
              },
            ),
          ],
        );
      },
    );
  }

  TextEditingController _textFieldController = TextEditingController();

  void nameNewFile() {
    String value = '';
    String fname;
    var result = showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Save under this name:'),
          content: TextField(
            controller: _textFieldController,
            decoration: InputDecoration(hintText: "Name your file:"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('CANCEL'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text('OK'),
              onPressed: () {
                // setState(() {
                fname = _textFieldController.text;
                if (!fname.endsWith('.txt')) {
                  fname = fname + ".txt";
                  Navigator.pop(context);
                }

                if (saveNewFile(fname) != null) {
                  print("file was saved");
                  showDialog(
                    context: context,
                    builder: (context2) => AlertDialog(
                      title: Center(child: const Text('File saved!')),
                      backgroundColor: Colors.green,
                      actions: <Widget>[
                        TextButton(
                          child: const Align(
                            alignment: Alignment.center,
                            child: Text('OK'),
                          ),
                          onPressed: () {
                            Navigator.pop(context2);
                          },
                        ),
                      ],
                    ),
                  );
                } else {
                  showDialog(
                    context: context,
                    builder: (context3) => AlertDialog(
                      title: Center(
                          child:
                              const Text('File not saved, please try again')),
                      backgroundColor: Colors.red,
                      actions: <Widget>[
                        TextButton(
                          child: const Align(
                            alignment: Alignment.center,
                            child: Text('OK'),
                          ),
                          onPressed: () {
                            Navigator.pop(context3);
                          },
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
    // result = _textFieldController.text;
    // print(result);
    // return saveNewFile(result);
  }

  Future<File> saveNewFile(
    String filename,
  ) async {
    bool saved = false;
    String path;
    // String? path = await FilesystemPicker.openDialog(
    //   context: context,
    //   title: 'Saved Profiles',
    //   fsType: FilesystemType.file,
    //   rootDirectory: Directory(
    //       '../..'), //set to be downloads page(where the txt file will save to automatically)
    //   directory: Directory('profiles'),
    //   showGoUp: (false),
    //   allowedExtensions: ['.txt'],
    //   fileTileSelectMode: FileTileSelectMode.wholeTile,
    // );
    // path = Directory.current.path;
    path = Directory("profiles").path;
    print(path);
    File file = File('$path/$filename');
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
    return file;
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
  late int _index = -1;

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

    _centerSelectedPortal = Container(
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

    _hiddenSelectedPortal = Container(
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
                        EdgeInsets.symmetric(vertical: 7.0, horizontal: 140.0),
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
                        EdgeInsets.symmetric(vertical: 7.0, horizontal: 140.0),
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
                                    vertical: 0.0, horizontal: 22.0),
                                foregroundColor: Colors.white,
                                textStyle: const TextStyle(fontSize: 30),
                                backgroundColor: hasChosenCenter
                                    ? Color.fromARGB(255, 184, 80, 20)
                                    : Colors.grey[500]),
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
                              // User has pressed the Center button
                              print('User pressed the Center button.');
                              print(indexPressed);

                              // Find the previous center and mark it false.
                              if (indexPressed != -1) {
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
                                  // If the portal was hidden, then it should be shown again.
                                  _portalData[indexPressed].shown = true;
                                  hasChosenCenter = true;
                                  chosenCenterIndex = indexPressed;

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
                              onPressed: (
                                  //create a function that when a portal is clicked it will update a Portal variable,
                                  //the hide function will find that portal in the list and update its +/-
                                  ) {
                                print('User pressed the Hide/Include Button');

                                // Use the index pressed to change that portal's state to hidden.
                                setState(() {
                                  // Portal is to be hidden
                                  if (_portalData[indexPressed].shown) {
                                    // Need to make sure if the portal was the center to maintain state.
                                    if (_portalData[indexPressed].center) {
                                      _portalData[indexPressed].center = false;
                                      hasChosenCenter = false;
                                      chosenCenterIndex = -1;
                                    }
                                    _portalData[indexPressed].shown = false;

                                    print(
                                        "Portal $indexPressed: ${_portalData[indexPressed].name} is now hidden.");
                                  }
                                  // Portal is to be re-included
                                  else {
                                    _portalData[indexPressed].shown = true;

                                    print(
                                        "Portal $indexPressed: ${_portalData[indexPressed].name} is now included.");
                                  }

                                  // Update the markers
                                  _controller.updateMarkers(List.generate(
                                      _controller.markersCount, (i) => i));

                                  // Update the indexPressed
                                  // indexPressed = -1;
                                });
                              },
                              style: (indexPressed == -1)
                                  ? TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 0.0, horizontal: 52.0),
                                      foregroundColor: Colors.white,
                                      textStyle: const TextStyle(fontSize: 30),
                                      backgroundColor:
                                          Color.fromARGB(255, 99, 96, 102))
                                  : TextButton.styleFrom(
                                      padding: _portalData[indexPressed].shown
                                          ? const EdgeInsets.symmetric(
                                              vertical: 0.0, horizontal: 52.0)
                                          : const EdgeInsets.symmetric(
                                              vertical: 0.0, horizontal: 34.0),
                                      foregroundColor: Colors.white,
                                      textStyle: const TextStyle(fontSize: 30),
                                      backgroundColor: const Color.fromARGB(
                                          255, 99, 96, 102)),
                              child: (indexPressed == -1)
                                  ? Text("Hide")
                                  : Text(_portalData[indexPressed].shown
                                      ? "Hide"
                                      : "Include")),
                        )
                      ],
                    ),
                  ),
                  Container(
                    color: Colors.grey[300],
                    padding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 140.0),
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

                              setState(() {
                                // Check if this portal was chosen to be a center portal. If so, update the state to reflect that we no longer have a center portal.
                                if (_portalData[indexPressed].center) {
                                  hasChosenCenter = false;
                                  chosenCenterIndex = -1;
                                }

                                // Remove the portal from the Portal List object.
                                _portalData.removeAt(indexPressed);
                                // Then, we need to remove the marker from the Map Widget
                                _controller.removeMarkerAt(indexPressed);

                                // Also, update the indexPressed. Without this, the rebuild will show the next portal being pressed without actually being pressed by the user.
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

                              nameNewFile();
                              // print(nameNewFile());
                              // Future<String> filename = nameNewFile();
                              // print("right before if statement");
                              // print(filename);
                              // print("right after filenmae before if statement");
                              // // if (filename is Future<String>) {
                              // //   print("in if statement" + filename);
                              // saveNewFile(filename);
                              // }
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
                        BoxConstraints.expand(width: 180.0, height: 150.0),
                    child: Text(
                        selectPortalInfo()), //FIX get first line to be name bolded
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
                              //nameNewFile();
                              /*Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => HomeView()),
                              );
                              */
                              print('pressed da Go Back button');
                              areYouSure();
                            },
                            child: Text("Go Home"), //generate
                            style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                    vertical: 0.0, horizontal: 19.0),
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
                      if (index == indexPressed) {
                        // Marker is the center and selected
                        if (_portalData[index].center) {
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
                                    child: _centerSelectedPortal,
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
                                              color: Colors.white,
                                              fontSize: 11),
                                        )),
                                  ),
                                )
                              ]));
                        }
                        // Marker is hidden and selected
                        else if (!_portalData[index].shown) {
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
                                    child: _hiddenSelectedPortal,
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
                                              color: Colors.white,
                                              fontSize: 11),
                                        )),
                                  ),
                                )
                              ]));
                        }
                        // Regular marker and selected
                        else {
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
                                              color: Colors.white,
                                              fontSize: 11),
                                        )),
                                  ),
                                )
                              ]));
                        }
                      }
                      // Marker is not currently selected
                      else {
                        // Marker is the center
                        if (_portalData[index].center) {
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
                                              color: Colors.white,
                                              fontSize: 11),
                                        )),
                                  ),
                                )
                              ]));
                        }
                        // Marker is hidden
                        else if (!_portalData[index].shown) {
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
                                              color: Colors.white,
                                              fontSize: 11),
                                        )),
                                  ),
                                )
                              ]));
                        }
                        // Regular marker
                        else {
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
                                              color: Colors.white,
                                              fontSize: 11),
                                        )),
                                  ),
                                )
                              ]));
                        }
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

Uint8List updateJSONTemplate(List<Portal> portals) {
  double buffer = 0;
  String aggregiousTabs = '\t\t\t\t\t\t\t';

  // * First, need to get the JSON from the assets folder
  var assetFileStr = File('assets/siue2.json').readAsStringSync();

  // * Save a copy of the file in a new dir
  if (!Directory('map').existsSync()) {
    var mapdir = Directory('map').create();
  }
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
  for (var m in portals) {
    // * Latitude
    maxLat = max(m.lat, maxLat);
    minLat = min(m.lat, minLat);

    // * Longitude
    maxLong = max(m.long, maxLong);
    minLong = min(m.long, minLong);
  }

  // * Calculate the buffer to add to the view area. 20% of the width
  buffer = (maxLat - minLat) / 5;

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

  // * Write the lines to the new file.
  String combineLines = '';
  for (var l in newFileLines) {
    combineLines += '$l\n';
  }
  newFile.writeAsStringSync(combineLines);

  // * Then convert to bytes to load to program
  Uint8List mapFileBytes = (newFile).readAsBytesSync();

  return mapFileBytes;
}
