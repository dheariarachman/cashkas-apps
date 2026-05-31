class ServiceModel {
  final int? id;
  final String name;
  final String icon;

  ServiceModel({
    this.id,
    required this.name,
    this.icon = 'category_outlined',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
    };
  }

  factory ServiceModel.fromMap(Map<String, dynamic> map) {
    return ServiceModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      icon: map['icon'] as String? ?? 'category_outlined',
    );
  }
}
