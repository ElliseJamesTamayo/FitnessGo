class AdminCredentials {
  static const String username = 'fitnessgo_admin';
  static const String password = 'Admin123';

  static bool isValid({
    required String enteredUsername,
    required String enteredPassword,
  }) {
    return enteredUsername.trim() == username &&
        enteredPassword == password;
  }
}