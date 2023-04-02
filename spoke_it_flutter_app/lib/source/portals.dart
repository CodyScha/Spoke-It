import 'dart:io';

import 'package:flutter/material.dart';
import '../pages/load/LoadView.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';
import '../pages/Preview/Preview.dart';
import 'dart:typed_data';

class Portal {
  String name;
  double lat;
  double long;
  String team;
  int health;
  bool shown;
  bool hull = false;
  bool center = false;

  Portal(
      {required this.name,
      required this.lat,
      required this.long,
      required this.team,
      required this.health,
      required this.shown,
      required this.center});
}

class Link {
  Portal to;
  Portal from;
  bool isCenterLink;
  bool isHullLink;

  Link(
      {required this.to,
      required this.from,
      required this.isCenterLink,
      required this.isHullLink});
}

class Field {
  Portal portalOne;
  Portal portalTwo;
  Portal portalThree;

  Field(
    {required this.portalOne,
    required this.portalTwo,
    required this.portalThree});
}
