class AppUser {
  final String name;
  final String surname;
  final String roomNumber;
  final String floor;
  final String email;
  final bool isAdmin;

  const AppUser(this.name, this.surname, this.roomNumber, this.floor, this.email,
      this.isAdmin);

  String getInitials(){
    return name[0] + surname[0];
  }

}

AppUser mockUser = AppUser("Sabina", "Szyszka", "311", "III", "szyszka@bursa.pl", true);