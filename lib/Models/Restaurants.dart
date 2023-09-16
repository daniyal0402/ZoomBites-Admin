class Restaurant {
  final String key;
  final String location;
  final List<Map<String, dynamic>> menu;
  final String name;
  final String number;
  final String id;

  Restaurant({
    required this.key,
    required this.location,
    required this.menu,
    required this.name,
    required this.number,
    required this.id,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'id': id,
      'number': number,
      'location': location,
      'menu': menu,
      'key': key,
    };
  }
}
