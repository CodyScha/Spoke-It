import 'package:spoke_it_flutter_app/source/portals.dart';

class Spoke {
  List<Link> algorithm(List<Portal> portals) {
    List<Link> links = [];

    //calculate links in hull
    links.addAll(jarvis(portals));

    //connect hull to center
    links.addAll(hullToCenter(portals));

    //calculate links of portals inside hull
    links.addAll(internalLinks(portals));

    return links;
  }

  List<Link> jarvis(List<Portal> portals) {
    List<Link> links = [];

    return links;
  }

  List<Link> hullToCenter(List<Portal> portals) {
    List<Link> links = [];

    for (var isCenter in portals) {
      //if portal is the center, find hull portals
      if (isCenter.center == true) {
        for (var portal in portals) {
          //if portal is hull, link to center
          if (portal.hull == true) {
            Link link = new Link(
                from: portal,
                to: isCenter,
                isCenterLink: true,
                isHullLink: false);
            links.add(link);
          }
        }
      }
      break;
    }
    return links;
  }

  List<Link> internalLinks(List<Portal> portals) {
    List<Link> links = [];

    return links;
  }
}
