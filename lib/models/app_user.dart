class AppUser {
  final String name;
  final String surname;
  final String roomNumber;
  final String floor;
  final String email;
  final bool notifyDuties;
  final bool notifyLaundry;
  final UserRole role;

  const AppUser({
    required this.name,
    required this.surname,
    required this.roomNumber,
    required this.floor,
    required this.email,
    required this.notifyDuties,
    required this.notifyLaundry,
    required this.role,
  });

  factory AppUser.fromMap(Map<String, dynamic> data, String email) {
    return AppUser(
      name: data[UserFields.name] as String,
      surname: data[UserFields.surname] as String,
      roomNumber: data[UserFields.roomNumber] as String,
      floor: data[UserFields.floor] as String,
      email: email,
      role: UserRole.values.asNameMap()[data[UserFields.role]] ?? UserRole.resident,
      notifyLaundry: data[UserFields.notifyLaundry] as bool,
      notifyDuties: data[UserFields.notifyDuties] as bool,
    );
  }

  bool get isAdmin => role == UserRole.admin;

  String getInitials() {
    return name[0] + surname[0];
  }
}

abstract final class UserFields {
  static const name = "name";
  static const surname = "surname";
  static const email = "email";
  static const floor = "floor";
  static const roomNumber = "roomNumber";
  static const role = "role";
  static const notifyDuties = "notifyDuties";
  static const notifyLaundry = "notifyLaundry";
}

enum UserRole { admin, resident }
