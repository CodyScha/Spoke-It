import 'dart:math';

import '../model/portals.dart';
import '../model/links.dart';

class Spoke {
  late int numFields;
  late int points;

  //main algorithm function called from output_page
  List<Link> algorithm(List<Portal> portals, bool showCenterLinks) {
    // new algorithm, reset fields
    numFields = 0;

    // state reset in case of subsequent algorithm call
    resetHull(portals);

    // the list of links created by the algorithm
    List<Link> links = [];

    // use only shown portals (non-hidden portals)
    List<Portal> shownPortalList = shownPortals(portals);

    // calculate links in hull
    List jarvisResults = jarvis(shownPortalList);
    links.addAll(jarvisResults[0]);
    numFields += jarvisResults[1].length as int;

    if (showCenterLinks) {
      // connect hull to center
      links.addAll(hullToCenter(shownPortalList));

      // connect internal portals to center
      links.addAll(internalToCenter(shownPortalList));
    } else {
      // if center is part of hull, jarvis added links to it
      // even if showCenterLinks was false. This deletes them
      deleteCenterHullLinks(portals, links);
    }

    // calculate links of portals inside hull
    links.addAll(internalLinks(shownPortalList, jarvisResults[1]));

    // calculates points
    calculatePoints(shownPortalList.length, links.length);
    
    return links;
  }

  // state reset needed for subsequent algorithm calls
  // jarvis will break if some hull values are true before jarvis is called
  void resetHull(List<Portal> portals) {
    for (Portal portal in portals) {
      portal.hull = false;
    }
  }

  // function to delete hull links to center if the center is part of hull
  // and if showCenterLinks is false
  void deleteCenterHullLinks(List<Portal> portals, List<Link> links) {
    // indexes of links to remove
    int i1 = -1;
    int i2 = -1;
    bool firstFound = false;
    bool centerInHull = false;
    for (Portal portal in portals) {
      if (portal.center == true && portal.hull == true) {
        for (Link link in links) {
          if (link.to == portal || link.from == portal) {
            if (!firstFound) {
              i1 = links.indexOf(link);
              firstFound = true;
              centerInHull = true;
            } else {
              i2 = links.indexOf(link);
            }
          }
        }
      }
    }
    // wow this was not fun to debug :)
    // if center in hull, delete hull links attached to center
    if (centerInHull) {
      links.remove(links[i1]);
      links.remove(links[i2 - 1]);
    }
  }

  // returns list of portals that are not hidden since we don't want to include these in the algorithm
  List<Portal> shownPortals(List<Portal> portals) {
    List<Portal> shownPortals = [];

    for (Portal portal in portals) {
      if (portal.shown == true) shownPortals.add(portal);
    }

    return shownPortals;
  }

  // returns tuple with list of links of the convex hull and list of portals in the convex hull
  List jarvis(List<Portal> portals) {
    List<Link> links = [];
    double val;
    List<Portal> hullList = [];

    // There must be at least 3 points
    if (portals.length < 3) {}

    // Find the leftmost point
    int l = 0;
    for (int i = 1; i < portals.length; i++) {
      if (portals[i].lat < portals[l].lat) l = i;
    }

    // Start from leftmost point, keep moving counterclockwise
    // until reach the start point again.  This loop runs O(h)
    // times where h is number of points in result or output.
    int p = l, q;
    do {
      if (portals[p].hull == true) break;

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
        Link link = Link(
            from: hullList[i],
            to: hullList[i + 1],
            isCenterLink: false,
            isHullLink: true);
        links.add(link);
      } else {
        Link link = Link(
            from: hullList[i],
            to: hullList[0],
            isCenterLink: false,
            isHullLink: true);
        links.add(link);
      }
    }
    return [links, hullList];
  }

  // links hull portals to the center portal
  // makes wedges
  List<Link> hullToCenter(List<Portal> portals) {
    List<Link> links = [];

    for (var isCenter in portals) {
      // if portal is the center, find hull portals
      if (isCenter.center == true) {
        for (var portal in portals) {
          // if portal is hull, link to center
          if (portal.hull == true) {
            Link link = Link(
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

  // links internal portals to the center portal
  List<Link> internalToCenter(List<Portal> portals) {
    List<Link> links = [];

    for (var isCenter in portals) {
      // if portal is the center, find internal portals
      if (isCenter.center == true) {
        for (var portal in portals) {
          // if portal is internal, link to center
          if (portal.hull == false) {
            Link link = Link(
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

  // master function for creating links within wedges
  // loops for all wedges and calls recursive function maxWedge
  List<Link> internalLinks(List<Portal> portals, List<Portal> hullPortals) {
    List<Link> links = [];
    List<Portal> wedgePortals = [];

    // for all wedges in G, call maxWedge(list of portals in wedge, hull point 1, hull point 2)
    for (int i = 0; i < hullPortals.length - 1; ++i) {
      // find the portals in the wedge, including the center and two "hull points"
      List<Portal> wedgePortals =
          portalsInWedge(portals, hullPortals[i], hullPortals[i + 1]);
      links.addAll(maxWedge(wedgePortals, hullPortals[i], hullPortals[i + 1]));
    }

    // Previous loop doesn't find links in the wedge between last hull portal and first hull portal
    // So do it one more time between these two
    wedgePortals = portalsInWedge(
        portals, hullPortals[hullPortals.length - 1], hullPortals[0]);
    links.addAll(maxWedge(
        wedgePortals, hullPortals[hullPortals.length - 1], hullPortals[0]));

    return links;
  }

  // recursively make all links within each wedge
  List<Link> maxWedge(
      List<Portal> wedgePortals, Portal wedgeOne, Portal wedgeTwo) {
    List<Link> links = [];
    // checking if there are portals within the wedge (base case is empty wedge)
    if (wedgePortals.length != 3) {
      // find farthest portal (P) from center in the wedge
      Portal furthest =
          findClosestToWedgePortals(wedgePortals, wedgeOne, wedgeTwo);
      // link to wedge 1 and wedge 2
      Link linkToWedgeOne = Link(
          from: furthest, to: wedgeOne, isCenterLink: false, isHullLink: false);
      Link linkToWedgeTwo = Link(
          from: furthest, to: wedgeTwo, isCenterLink: false, isHullLink: false);
      links.add(linkToWedgeOne);
      links.add(linkToWedgeTwo);

      // when these two links are created, 3 new subfields are created
      numFields += 3;

      // Recurse on the left wedge
      // links.addAll(maxWedge(left wedge portals, wedgeOne, P))
      List<Portal> leftWedgePortals =
          portalsInWedge(wedgePortals, wedgeOne, furthest);
      links.addAll(maxWedge(leftWedgePortals, wedgeOne, furthest));

      // Recurse on the right wedge
      // links.addAll(maxWedge(right wedge portals, P, wedgeTwo))
      List<Portal> rightWedgePortals =
          portalsInWedge(wedgePortals, furthest, wedgeTwo);
      links.addAll(maxWedge(rightWedgePortals, furthest, wedgeTwo));
    }

    return links;
  }

  // find the furthest portal in a wedge from the center portal
  Portal findClosestToWedgePortals(
      List<Portal> portals, Portal wedgeOne, Portal wedgeTwo) {
    Portal furthest;
    double distance = double.maxFinite;
    double xDifOne, yDifOne, xDifTwo, yDifTwo;

    // initialize non-nullable furthest (will be overridden)
    furthest = portals[0];

    // find closest to wedge portals (sum result of distance equation)
    for (Portal portal in portals) {
      // make sure portal is not one of the wedge portals,
      // since we want the portal to be inside the wedge
      if (portal != wedgeOne && portal != wedgeTwo) {
        xDifOne = wedgeOne.lat - portal.lat;
        yDifOne = wedgeOne.long - portal.long;
        xDifTwo = wedgeTwo.lat - portal.lat;
        yDifTwo = wedgeTwo.long - portal.long;
        if (sqrt(pow(xDifOne, 2) + pow(yDifOne, 2)) +
                sqrt(pow(xDifTwo, 2) + pow(yDifTwo, 2)) <
            distance) {
          distance = sqrt(pow(xDifOne, 2) + pow(yDifOne, 2)) +
              sqrt(pow(xDifTwo, 2) + pow(yDifTwo, 2));
          furthest = portal;
        }
      }
    }

    return furthest;
  }

  // finds and returns all portals in a wedge, including the "hull portals" and the center
  List<Portal> portalsInWedge(
      List<Portal> portals, Portal wedgeOne, Portal wedgeTwo) {
    List<Portal> portalsInWedge = [];
    // initialize center, will be overridden
    Portal center = portals[1];

    // find center portal
    for (Portal portal in portals) {
      if (portal.center == true) center = portal;
    }
    portalsInWedge.add(center);
    portalsInWedge.add(wedgeOne);
    portalsInWedge.add(wedgeTwo);

    for (Portal portal in portals) {
      // center, wedgeOne, and wedgeTwo are already added to the list, so lets not add them twice
      if (portal != center && portal != wedgeOne && portal != wedgeTwo) {
        // a temp list to pass to determineInWedge() that will include the portal in question
        List<Portal> temp = [center, wedgeOne, wedgeTwo];
        temp.add(portal);
        // if portal is in the wedge, add it to portalsInWedge
        if (determineInWedge(temp, wedgeOne, wedgeTwo)) {
          portalsInWedge.add(portal);
        }
      }
    }

    return portalsInWedge;
  }

  // determines if a specific portal is in wedge
  // takes in a list of 4 portals, 3 being the center and two wedge portals
  // the fourth portal is the portal we are testing
  bool determineInWedge(
      List<Portal> portals, Portal wedgeOne, Portal wedgeTwo) {
    List<Portal> temp = [];

    // create copy of portals list so our real portals don't get edited by jarvis march
    for (Portal portal in portals) {
      Portal tempPortal = portal;
      // need to set this back to false or jarvis will break
      tempPortal.hull = false;
      temp.add(tempPortal);
    }

    // portals in new hull created
    List<Portal> hull = jarvis(temp)[1];

    // if the convex hull has three portals, the portal might be inside the wedge
    // if the convex hull has four portals, the portal is outside the wedge
    if (hull.length != 3) return false;

    // if any of the three portals in the hull are not the center or two wedge portals,
    // the portal is outside of the wedge
    for (Portal portal in hull) {
      if (!portal.center && portal != wedgeOne && portal != wedgeTwo) {
        return false;
      }
    }

    return true;
  }

  // calculates max points (without mods)
  // and updates points variable
  void calculatePoints(int portalCount, int linkCount) {
    // * Reset the points
    points = 0;

    int portalPoints = 675, // for getting portal
        resPoints = 125, // deploying a resonator
        eightResPoints = 250, // deploying the last resonator
        modPoints = 125, // deploying a mod
        linkPoints = 313, // creating a link
        fieldPoints = 1250; // creating a field

    // calculate Portal Points
    points += (portalCount * portalPoints) +
        (portalCount * resPoints * 8) +
        (portalCount * eightResPoints) +
        (portalCount * 2 * modPoints);
    // calculate Link Points
    points += (linkPoints * linkCount);
    // calculate Field Points
    points += (fieldPoints * numFields);
  }

  // updates how many fields exist using adjacency matrix and DFS
  // this runtime is pretty awful O(n^3)
  // so only call this method after deleting a link, not when running alg
  void recalcPoints(List<Portal> portals, List<Link> links) {
    List<Portal> shownPortalList = shownPortals(portals);
    var adjacency = List.generate(
        shownPortalList.length,
        (i) => List.generate(shownPortalList.length,
            (j) => 0), // creates the adjacency list to store where the links are
        growable: false);
    List.generate(
        shownPortalList.length, // dummy 2d list for adjacency
        (i) => List.generate(shownPortalList.length, (j) => 0),
        growable: false);
    List.generate(
        shownPortalList.length, // dummy 2d list for adjacency
        (i) => List.generate(shownPortalList.length, (j) => 0),
        growable: false);
    int trace = 0;
    // calculate new fields with this solution:
    // https://www.geeksforgeeks.org/number-of-triangles-in-a-undirected-graph/#

    // Step One: set adjacency
    for (int i = 0; i < shownPortalList.length; i++) {
      for (int j = 0; j < shownPortalList.length; j++) {
        for (int k = 0; k < links.length; k++) {
          if ((shownPortalList[i] == links[k].from &&
                  shownPortalList[j] == links[k].to) ||
              (shownPortalList[i] == links[k].to &&
                  shownPortalList[j] == links[k].from)) {
            adjacency[i][j] = 1;
            adjacency[i][i] = 0;
          }
        }
      }
    }
    // Step Four: get the trace of tempAdjacencyTwoa and divide it by six to get the field count

    for (int i = 0; i < shownPortalList.length; i++) {
      for (int j = 0; j < shownPortalList.length; j++) {
        if (adjacency[i][j] == 1) {
          for (int k = 0; k < shownPortalList.length; k++) {
            if (adjacency[j][k] == 1 && adjacency[k][i] == 1) {
              trace += 1;
            }
          }
        }
      }
    }
    trace = trace ~/ 6;
    numFields = trace;
    // Step Five: recalculate points
    calculatePoints(shownPortalList.length, links.length);
  }
}

// wow that sure was a lot of math!
