class AppUser {
  final String name;
  final String surname;
  final String roomNumber;
  final String floor;
  final String email;
  final bool isAdmin;
  final bool notifyDuties;
  final bool notifyLaundry;

  const AppUser({
    required this.name,
    required this.surname,
    required this.roomNumber,
    required this.floor,
    required this.email,
    required this.isAdmin,
    required this.notifyDuties,
    required this.notifyLaundry,
  });

  factory AppUser.fromMap(Map<String, dynamic> data, String email) {
    return AppUser(
      name: data["name"] as String,
      surname: data["surname"] as String,
      roomNumber: data["roomNumber"] as String,
      floor: data["floor"] as String,
      email: email,
      isAdmin: data["role"] as String == "admin",
      notifyLaundry: data["notifyLaundry"] as bool,
      notifyDuties: data["notifyDuties"] as bool,
    );
  }

  String getInitials() {
    return name[0] + surname[0];
  }
}

AppUser mockUser = AppUser(
  name: "Sabina",
  surname: "Szyszka",
  roomNumber: "311",
  floor: "III",
  email: "szyszk@bursa.pl",
  isAdmin: true,
  notifyDuties: true,
  notifyLaundry: true,
);
