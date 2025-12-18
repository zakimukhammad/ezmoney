class Category {
  int? id;
  String name;
  String type; // 'income' or 'expense'
  int icon;
  int color;

  Category({
    this.id,
    required this.name,
    required this.type,
    required this.icon,
    required this.color,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json["id"],
    name: json["name"],
    type: json["type"],
    icon: json["icon"],
    color: json["color"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "type": type,
    "icon": icon,
    "color": color,
  };
}
