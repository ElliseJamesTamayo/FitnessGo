class LocalUserStore {
  static String fullName = '';

  static void setFullName(String value) {
    fullName = value.trim();
  }

  static String get displayName {
    if (fullName.isEmpty) return 'User';

    final parts = fullName.trim().split(RegExp(r'\s+'));
    return parts.first;
  }
}
