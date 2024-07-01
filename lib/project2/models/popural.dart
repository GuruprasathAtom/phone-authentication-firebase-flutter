class Popuralmodel {
  String name;
  String iconPath;
  String level;
  String duration;
  String calorie;
  bool bosIsSelected;

  Popuralmodel({
    required this.name,
    required this.iconPath,
    required this.level,
    required this.duration,
    required this.calorie,
    required this.bosIsSelected,
  });

  static List<Popuralmodel> getPopuralDiets() {
    List<Popuralmodel> popural = [];

    popural.add(Popuralmodel(
      name: 'Blueberry pancake',
      iconPath: 'assets/icons/blueberry-pancake.svg',
      level: 'Easy',
      duration: '20 mins',
      calorie: '230kCal',
      bosIsSelected: true,
    ));

    popural.add(Popuralmodel(
      name: 'Salmon Nigiri',
      iconPath: 'assets/icons/salmon-nigiri.svg',
      level: 'Easy',
      duration: '20 mins',
      calorie: '130kCal',
      bosIsSelected: false,
    ));
    return popural;
  }
}
