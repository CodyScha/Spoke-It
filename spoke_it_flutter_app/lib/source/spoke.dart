import 'package:spoke_it_flutter_app/source/portals.dart';

class Spoke {
  List<Link> algorithm(List<Portal> portals) {
    //the list of links created by the algorithm
    List<Link> links = [];

    //use only shown portals (non-hidden portals)
    List<Portal> shownPortalList = shownPortals(portals);

    //calculate links in hull
    links.addAll(jarvis(shownPortalList));

    //connect hull to center
    links.addAll(hullToCenter(shownPortalList));

    //connect internal portals to center
    links.addAll(internalToCenter(shownPortalList));

    //calculate links of portals inside hull
    links.addAll(internalLinks(shownPortalList));

    return links;
  }

  List<Portal> shownPortals(List<Portal> portals) {
    List<Portal> shownPortals = [];

    for (Portal portal in portals) {
      if (portal.shown == true) shownPortals.add(portal);
    }

    return shownPortals;
  }

  List<Link> jarvis(List<Portal> portals) {
    List<Link> links = [];
    double val;
    List<Portal> hullList = [];

    // There must be at least 3 points
    if (portals.length < 3) {}

    // Find the leftmost point
    int l = 0;
    for (int i = 1; i < portals.length; i++)
      if (portals[i].lat < portals[l].lat) l = i;

    // Start from leftmost point, keep moving counterclockwise
    // until reach the start point again.  This loop runs O(h)
    // times where h is number of points in result or output.
    int p = l, q;
    do {
      hullList.add(portals[p]);
      portals[p].hull = true;
      // Search for a point 'q' such that orientation(p, q,
      // x) is counterclockwise for all points 'x'. The idea
      // is to keep track of last visited most counterclock-
      // wise point in q. If any point 'i' is more counterclock-
      // wise than q, then update q.
      q = (p + 1) % portals.length;
      for (int i = 0; i < portals.length; i++) {
        // If i is more counterclockwise than current q, then
        // update q
        val = (portals[i].long - portals[p].long) *
                (portals[q].lat - portals[i].lat) -
            (portals[i].lat - portals[p].lat) *
                (portals[q].long - portals[i].long);
        if (val > 0) {
          val = 1;
        } else if (val < 0) {
          val = 2;
        }
        if (val == 2) q = i;
      }

      // Now q is the most counterclockwise with respect to p
      // Set p as q for next iteration, so that q is added to
      // result 'hull'
      p = q;
    } while (p != l); // While we don't come to first point
    for (int i = 0; i < hullList.length; i++) {
      if (i < hullList.length - 1) {
        Link link = new Link(
            from: hullList[i],
            to: hullList[i + 1],
            isCenterLink: false,
            isHullLink: true);
        links.add(link);
      } else {
        Link link = new Link(
            from: hullList[i],
            to: hullList[0],
            isCenterLink: false,
            isHullLink: true);
        links.add(link);
      }
    }
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
    }
    return links;
  }

  List<Link> internalToCenter(List<Portal> portals) {
    List<Link> links = [];

    for (var isCenter in portals) {
      //if portal is the center, find internal portals
      if (isCenter.center == true) {
        for (var portal in portals) {
          //if portal is internal, link to center
          if (portal.hull == false) {
            Link link = new Link(
                from: portal,
                to: isCenter,
                isCenterLink: true,
                isHullLink: false);
            links.add(link);
          }
        }
      }
    }
    return links;
  }

  List<Link> internalLinks(List<Portal> portals) {
    List<Link> links = [];

    return links;
  }
}
