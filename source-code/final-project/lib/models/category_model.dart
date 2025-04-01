import 'package:isar/isar.dart';

part 'category_model.g.dart';

@Collection()
class CategoryModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String name;

  String? iconName;
  String? colorCode;

  CategoryModel({
    this.id = Isar.autoIncrement,
    required this.name,
    this.iconName,
    this.colorCode,
  });

  CategoryModel.create(Map<String, dynamic> json) {
    name = json['name'];
    iconName = json['iconName'];
    colorCode = json['colorCode'];
  }
}
