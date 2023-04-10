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
