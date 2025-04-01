import 'package:isar/isar.dart';

part 'password_model.g.dart';

@Collection()
class PasswordModel {
  Id id = Isar.autoIncrement;

  late String title;
  late String username;
  late String password;
  late String url;

  @Index()
  late String category;

  @Index()
  late DateTime createdAt;

  DateTime? updatedAt;

  String? notes;

  PasswordModel({
    this.id = Isar.autoIncrement,
    required this.title,
    required this.username,
    required this.password,
    required this.url,
    required this.category,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  PasswordModel.create(Map<String, dynamic> json) {
    title = json['title'];
    username = json['username'];
    password = json['password'];
    url = json['url'];
    category = json['category'];
    notes = json['notes'];
    createdAt = DateTime.now();
    updatedAt =
        json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null;
  }
}
