import 'package:spoke_it_flutter_app/model/portals.dart';

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
