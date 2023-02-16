import 'package:spoke_it_flutter_app/source/portals.dart';

class spoke {
  List<Link> algorithm(List<Portal> portals) {
    List<Link> links = [];

    //calculate links in hull
    links += jarvis(portals);

    //connect hull to center
    links += hullToCenter(portals);

    //calculate links of portals inside hull
    links += internalLinks(portals);

    return links;
  }

  List<Link> jarvis(List<Portal> portals) {
    List<Link> links = [];

    return links;
  }

  List<Link> hullToCenter(List<Portal> portals) {
    List<Link> links = [];

    return links;
  }

  List<Link> internalLinks(List<Portal> portals) {
    List<Link> links = [];

    return links;
  }
}
