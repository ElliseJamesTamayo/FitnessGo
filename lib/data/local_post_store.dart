class LocalPostStore {
  static final List<Map<String, String>> _posts = [];

  static void add(Map data) {
    final content = (data['content'] ?? '').toString().trim();
    final audience = (data['audience'] ?? 'Public').toString();

    if (content.isEmpty) {
      return;
    }

    _posts.insert(0, {
      'name': 'User',
      'time': 'Just now',
      'content': content,
      'audience': audience,
    });
  }

  static List<Map<String, String>> get publicPosts {
    return _posts.where((post) => post['audience'] == 'Public').toList();
  }

  static List<Map<String, String>> get profilePosts {
    return List.unmodifiable(_posts);
  }

  static int get profilePostCount {
    return _posts.length;
  }
}


