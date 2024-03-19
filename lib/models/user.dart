// ignore_for_file: non_constant_identifier_names

class User {
  int? id;
  int? id_user;
  String? name;
  String? email;

  User({this.id, this.id_user, this.name, this.email});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_user': id_user,
      'name': name,
      'email': email,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      id_user: map['id_user'],
      name: map['name'],
      email: map['email'],
    );
  }
}
