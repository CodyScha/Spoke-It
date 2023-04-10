// ignore_for_file: file_names, no_logic_in_create_state, must_call_super

import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_maps/maps.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:intl/intl.dart';

import 'preview_page.dart';
import '../calc/spoke.dart';
import '../model/portals.dart';
import '../model/links.dart';

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

// ignore: camel_case_types
class myOutput extends StatefulWidget {
  const myOutput({super.key, required this.portals});

  final List<Portal> portals;
  @override
  State<myOutput> createState() => _myOutputState(portals: portals);
}

// ignore: camel_case_types
class _myOutputState extends State<myOutput> {
  _myOutputState({required this.portals});

  void deletePortal(Portal portal) {
    //serach through list to find portal, then delete it from the list
    setState(() {
      _portalData.removeAt(portalIndexPressed);
      _controller.removeMarkerAt(portalIndexPressed);

      portalIndexPressed = -1;
    });

    var temp = List.generate(_controller.markersCount, (i) => i);
    _controller.updateMarkers(temp);

    // * Reset the Link lists
    linksNoSpokes = alg.algorithm(_portalData, false);
    linksWithSpokes = alg.algorithm(_portalData, true);

    // * Update the displayed links
    linksDisplayed = (toggleCenterLinks) ? linksWithSpokes : linksNoSpokes;

    // * Update the points
    points = alg.points;
  }

  void hidePortal() {
    setState(() {
      if (_portalData[portalIndexPressed].shown == false) {
        //switch between hidden and shown
        _portalData[portalIndexPressed].shown = true;
      } else {
        _portalData[portalIndexPressed].shown = false;
      }

      // * Reset the Link lists
      linksNoSpokes = alg.algorithm(_portalData, false);
      linksWithSpokes = alg.algorithm(_portalData, true);

      // * Update the displayed links
      linksDisplayed = (toggleCenterLinks) ? linksWithSpokes : linksNoSpokes;

      // * Update the points
      points = alg.points;
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
              "${_portalData[i].name};${_portalData[i].lat};${_portalData[i].long};${_portalData[i].team};${_portalData[i].health};- \n",
              mode: FileMode.append);
        }
      }
    } else {
      // User canceled the picker
    }
  }

  final TextEditingController _textFieldController = TextEditingController();

  void nameNewFile() async {
    String fname;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Save under this name:'),
          content: TextField(
            controller: _textFieldController,
            decoration: const InputDecoration(hintText: "Name your file:"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('CANCEL'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                // setState(() {
                fname = _textFieldController.text;
                if (!fname.endsWith('.txt')) {
                  fname = "$fname.txt";
                  Navigator.pop(context);
                }

                // ignore: unnecessary_null_comparison
                if (saveNewFile(fname) != null) {
                  showDialog(
                    context: context,
                    builder: (context2) => AlertDialog(
                      title: const Center(child: Text('File saved!')),
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
                      title: const Center(
                          child: Text('File not saved, please try again')),
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
  }

  Future<File> saveNewFile(
    String filename,
  ) async {
    String path;
    path = Directory("profiles").path;
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

  String selectPortalInfo() {
    String portalInfo = "";
    if (portalIndexPressed >= 0) {
      portalInfo =
          "\n Coordinates: ${_portalData[portalIndexPressed].lat},${_portalData[portalIndexPressed].long}\n Team: ${_portalData[portalIndexPressed].team}\n Health: ${_portalData[portalIndexPressed].health}";
    } else {
      portalInfo = "Please select a portal for more information";
    }
    return portalInfo;
  }

  String selectPortalName() {
    String portalInfo = "";
    if (portalIndexPressed >= 0) {
      portalInfo = _portalData[portalIndexPressed].name;
    } else {
      portalInfo = "";
    }

    return portalInfo;
  }

  final List<Portal> portals;

  late MapZoomPanBehavior _zoomPanBehavior;
  late List<Portal> _portalData;
  late MapShapeLayerController _controller;
  late List<Link> linksDisplayed;
  late List<Link> linksWithSpokes;
  late List<Link> linksNoSpokes;
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
  late int points;
  Spoke alg = Spoke();

  bool toggleCenterLinks = true;
  NumberFormat formatter = NumberFormat.decimalPattern();

  @override
  void initState() {
    _zoomPanBehavior = MapZoomPanBehavior(
        enableDoubleTapZooming: true,
        enableMouseWheelZooming: true,
        enablePinching: true);

    _portalData = portals;

    linksNoSpokes = alg.algorithm(_portalData, false);
    linksWithSpokes =
        linksDisplayed = alg.algorithm(_portalData, toggleCenterLinks);
    linksDisplayed = linksWithSpokes;

    points = alg.points;

    _controller = MapShapeLayerController();
    _mapSource = MapShapeSource.memory(updateJSONTemplate(_portalData));

    hasChosenCenter = false;
    chosenCenterIndex = -1;
    portalIndexPressed = -1;
    linkIndexPressed = -1;

    _centerPortal = Container(
      height: 20,
      width: 20,
      decoration:
          const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
    );

    _selectedCenterPortal = Container(
      height: 20,
      width: 20,
      decoration: BoxDecoration(
          color: Colors.green,
          shape: BoxShape.circle,
          border: Border.all(
              color: const Color.fromARGB(255, 117, 209, 255),
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
              color: const Color.fromARGB(255, 117, 209, 255),
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
              color: const Color.fromARGB(255, 117, 209, 255),
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
        title: const Text('Strategy Output'),
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
                children: <Widget>[
                  Container(
                    color: Colors.grey[300],
                    padding: const EdgeInsets.symmetric(
                        vertical: 15.0, horizontal: 140.0),
                    //child: Text('Load Data'),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Stack(
                      children: <Widget>[
                        TextButton(
                          onPressed: (portalIndexPressed == -1)
                              ? null
                              : () {
                                  if (portalIndexPressed != -1) {
                                    setState(() {
                                      for (var p in _portalData) {
                                        if (p.center) {
                                          p.center = false;
                                        }
                                      }
                                      // * Update the new center.
                                      _portalData[portalIndexPressed].center =
                                          true;
                                      _portalData[portalIndexPressed].shown =
                                          true;
                                      hasChosenCenter = true;
                                      chosenCenterIndex = portalIndexPressed;

                                      // * Update the markers
                                      _controller.updateMarkers(List.generate(
                                          _controller.markersCount, (i) => i));
                                    });
                                    // * Reset the Link lists
                                    linksNoSpokes =
                                        alg.algorithm(_portalData, false);
                                    linksWithSpokes =
                                        alg.algorithm(_portalData, true);

                                    // * Update the displayed links
                                    linksDisplayed = (toggleCenterLinks)
                                        ? linksWithSpokes
                                        : linksNoSpokes;

                                    // * Update the points
                                    points = alg.points;
                                  }
                                }, //Center
                          style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 0.0, horizontal: 39.0),
                              foregroundColor: Colors.white,
                              textStyle: const TextStyle(fontSize: 30),
                              backgroundColor: Colors.indigo),
                          child: const Text("Center"),
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
                        TextButton(
                          onPressed: (portalIndexPressed != -1 &&
                                  !_portalData[portalIndexPressed].center)
                              ? () {
                                  hidePortal();
                                  //remove
                                }
                              : null,
                          style: (portalIndexPressed == -1)
                              ? TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 0.0, horizontal: 52.0),
                                  foregroundColor: Colors.white,
                                  textStyle: const TextStyle(fontSize: 30),
                                  backgroundColor:
                                      const Color.fromARGB(255, 99, 96, 102))
                              : TextButton.styleFrom(
                                  padding: _portalData[portalIndexPressed].shown
                                      ? const EdgeInsets.symmetric(
                                          vertical: 0.0, horizontal: 52.0)
                                      : const EdgeInsets.symmetric(
                                          vertical: 0.0, horizontal: 34.0),
                                  foregroundColor: Colors.white,
                                  textStyle: const TextStyle(fontSize: 30),
                                  backgroundColor:
                                      const Color.fromARGB(255, 99, 96, 102)),
                          child: (portalIndexPressed == -1)
                              ? const Text("Hide")
                              : Text(_portalData[portalIndexPressed].shown
                                  ? "Hide"
                                  : "Include"),
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
                        TextButton(
                          // * We only want the delete button to be active if a link is pressed, or if a non-center portal is pressed.
                          onPressed: (linkIndexPressed != -1 ||
                                  (portalIndexPressed != -1 &&
                                      !_portalData[portalIndexPressed].center))
                              ? () {
                                  // * Delete a portal
                                  if (portalIndexPressed != -1) {
                                    Portal portalSelected =
                                        _portalData[portalIndexPressed];
                                    deletePortal(portalSelected);
                                  }
                                  // * Delete a link
                                  else if (linkIndexPressed != -1) {
                                    setState(() {
                                      // * Remove the link from both Link lists
                                      // * First, take a copy of the link that was pressed by the user.
                                      Link tempLink =
                                          linksDisplayed[linkIndexPressed];

                                      // * Now, iterate through both Link lists to find the one to remove
                                      int withSpokesIndex = -1;
                                      int noSpokesIndex = -1;
                                      for (int i = 0;
                                          i < linksWithSpokes.length;
                                          i++) {
                                        if ((tempLink.to ==
                                                    linksWithSpokes[i].to &&
                                                tempLink.from ==
                                                    linksWithSpokes[i].from) ||
                                            (tempLink.from ==
                                                    linksWithSpokes[i].to &&
                                                tempLink.to ==
                                                    linksWithSpokes[i].from)) {
                                          withSpokesIndex = i;
                                          break;
                                        }
                                      }

                                      for (int i = 0;
                                          i < linksNoSpokes.length;
                                          i++) {
                                        if ((tempLink.to ==
                                                    linksNoSpokes[i].to &&
                                                tempLink.from ==
                                                    linksNoSpokes[i].from) ||
                                            (tempLink.from ==
                                                    linksNoSpokes[i].to &&
                                                tempLink.to ==
                                                    linksNoSpokes[i].from)) {
                                          noSpokesIndex = i;
                                          break;
                                        }
                                      }

                                      linksWithSpokes.removeAt(withSpokesIndex);

                                      // * If you try to delete a spoke link, this will always be out of bounds. Just don't remove a link from this one if that is the case
                                      if (noSpokesIndex != -1) {
                                        linksNoSpokes.removeAt(noSpokesIndex);
                                      }

                                      // * Calc the new score based on the Links list with spokes
                                      alg.recalcPoints(
                                          _portalData, linksWithSpokes);

                                      // * Update the points
                                      points = alg.points;

                                      // * Update the display according to toggleCenterLinks
                                      linksDisplayed = (toggleCenterLinks)
                                          ? linksWithSpokes
                                          : linksNoSpokes;

                                      // * Reset the link pressed state.
                                      linkIndexPressed = -1;
                                    });
                                  }
                                }
                              : null, //delete
                          style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 0.0, horizontal: 40.0),
                              foregroundColor: Colors.white,
                              textStyle: const TextStyle(fontSize: 30),
                              backgroundColor:
                                  const Color.fromARGB(255, 163, 6, 6)),
                          child: const Text("Delete"),
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
                        TextButton(
                          onPressed: () {
                            //remove

                            nameNewFile();
                          }, //generate
                          style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 0.0, horizontal: 52.0),
                              foregroundColor: Colors.white,
                              textStyle: const TextStyle(fontSize: 30),
                              backgroundColor:
                                  const Color.fromARGB(255, 18, 153, 6)),
                          child: const Text("Save"),
                        )
                      ],
                    ),
                  ),
                  Container(
                    color: Colors.grey[300],
                    padding: const EdgeInsets.symmetric(
                        vertical: 15.0, horizontal: 140.0),
                    //child: Text('Load Data'),
                  ),
                  Container(
                    color: const Color.fromARGB(255, 187, 186, 186),
                    constraints:
                        const BoxConstraints.expand(width: 180.0, height: 40.0),
                    child: Text(
                      selectPortalName(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ), //FIX get first line to be name bolded
                  ),
                  Container(
                    color: const Color.fromARGB(255, 187, 186, 186),
                    constraints: const BoxConstraints.expand(
                        width: 180.0, height: 200.0),
                    child: Text(
                        selectPortalInfo()), //FIX get first line to be name bolded
                  ),
                  Container(
                    color: Colors.grey[300],
                    padding: const EdgeInsets.symmetric(
                        vertical: 15.0, horizontal: 140.0),
                    //child: Text('Load Data'),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Stack(
                      children: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      Preview(portals: _portalData)),
                            );
                          }, //generate
                          style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 0.0, horizontal: 32.0),
                              foregroundColor: Colors.white,
                              textStyle: const TextStyle(fontSize: 30),
                              backgroundColor: Colors.indigo),
                          child: const Text("Go Back"),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Stack(children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width - 220,
              color: const Color.fromRGBO(46, 46, 46, 1),
              child: Padding(
                padding: const EdgeInsets.all(1.0),
                child: SfMapsTheme(
                  data: SfMapsThemeData(
                      // shapeHoverColor: Color.fromRGBO(46, 46, 46, 1),
                      // shapeHoverStrokeColor: Colors.pink,
                      // shapeHoverStrokeWidth: 5,
                      layerColor: const Color.fromRGBO(46, 46, 46, 1),
                      layerStrokeWidth: 0),
                  child: SfMaps(layers: <MapLayer>[
                    MapShapeLayer(
                      source: _mapSource,
                      zoomPanBehavior: _zoomPanBehavior,
                      initialMarkersCount: _portalData.length,
                      sublayers: [
                        MapLineLayer(
                          lines: List<MapLine>.generate(linksDisplayed.length,
                              (int index) {
                            return MapLine(
                              from: MapLatLng(linksDisplayed[index].from.lat,
                                  linksDisplayed[index].from.long),
                              to: MapLatLng(linksDisplayed[index].to.lat,
                                  linksDisplayed[index].to.long),
                              color: (index == linkIndexPressed)
                                  ? const Color.fromARGB(255, 117, 209, 255)
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
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 11),
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
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 11),
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
                                        setState(() {
                                          portalIndexPressed = index;

                                          // Update the link index
                                          linkIndexPressed = -1;
                                          // Update the markers
                                          _controller.updateMarkers(
                                              List.generate(
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
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 11),
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
                                        setState(() {
                                          portalIndexPressed = index;

                                          // Update the link index
                                          linkIndexPressed = -1;

                                          // Update the markers
                                          _controller.updateMarkers(
                                              List.generate(
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
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 11),
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
                                          // ignore: prefer_const_constructors
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 11),
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
                                    child: Container(
                                      height: 20,
                                      width: 20,
                                      // ignore: prefer_const_constructors
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
                                          // ignore: prefer_const_constructors
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 11),
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
            // * Button to toggle the center links
            Padding(
              padding: const EdgeInsets.only(top: 8.5),
              child: Tooltip(
                message: "Toggle center links",
                child: ElevatedButton(
                  onPressed: () {
                    // * Update the state of the center links toggle
                    setState(() {
                      // * Toggle the center links variable
                      toggleCenterLinks = !toggleCenterLinks;

                      // * Update the links
                      linksDisplayed =
                          (toggleCenterLinks) ? linksWithSpokes : linksNoSpokes;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(14.0),
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.grey[800]),
                  child: Icon(
                      (toggleCenterLinks)
                          ? Icons.remove_red_eye
                          : Icons.remove_red_eye_outlined,
                      color: Colors.grey),
                ),
              ),
            ),
            Container(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(left: 9.0, bottom: 9.0),
                child: Container(
                  decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      color: Colors.white),
                  alignment: Alignment.center,
                  // color: Colors.white,
                  // width: 150,
                  height: 42,
                  // ignore: prefer_const_constructors
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: RichText(
                      text: TextSpan(
                          style: const TextStyle(
                              color: Colors.black, fontSize: 17),
                          children: <TextSpan>[
                            const TextSpan(text: "Total Points: "),
                            TextSpan(
                                text: formatter.format(points),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green))
                          ]),
                    ),
                  ),
                ),
              ),
            )
          ]),
        ],
      ),
    );
  }
}

Uint8List updateJSONTemplate(List<Portal> portals) {
  double buffer = 0;
  String aggregiousTabs = '\t\t\t\t\t\t\t';

  // * First, need to get the JSON from the assets folder
  var assetFileStr = File('assets/siue.json').readAsStringSync();

  // * Save a copy of the file in a new dir
  if (!Directory('map').existsSync()) {}
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
