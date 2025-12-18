class Account {
  int? id;
  String name;
  String type;
  int icon;
  int color;
  double balance;

  Account({
    this.id,
    required this.name,
    required this.type,
    required this.icon,
    required this.color,
    required this.balance,
  });

  factory Account.fromJson(Map<String, dynamic> json) => Account(
    id: json["id"],
    name: json["name"],
    type: json["type"],
    icon: json["icon"],
    color: json["color"],
    balance: json["balance"].toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "type": type,
    "icon": icon,
    "color": color,
    "balance": balance,
  };
}
