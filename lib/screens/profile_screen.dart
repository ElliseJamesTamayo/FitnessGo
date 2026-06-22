import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../core/network/api_client.dart';
import '../core/storage/api_session_store.dart';
import '../data/local_post_store.dart';
import '../data/local_user_store.dart';
import '../features/fitnesswall/fitnesswall.dart';
import 'create_post_screen.dart';
import 'dashboard_screen.dart';

import '../widgets/profile_photo_avatar.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = '/profile';

  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isLoadingPosts = false;
  List<Map<String, dynamic>> profilePosts = [];

  @override
  void initState() {
    super.initState();
    loadProfilePosts();
  }

  String getTodayText() {
    final now = DateTime.now();

    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${days[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }

  Future<void> loadProfilePosts({bool showErrorMessage = false}) async {
    if (!mounted) return;

    setState(() {
      isLoadingPosts = true;
    });

    try {
      final userId = await ApiSessionStore.getUserId();

      if (userId <= 0) {
        if (!mounted) return;

        setState(() {
          isLoadingPosts = false;
        });

        return;
      }

      final result = await FitnessWallApi.getUserPosts(userId: userId);

      if (!mounted) return;

      if (result['success'] == false) {
        setState(() {
          isLoadingPosts = false;
        });

        if (showErrorMessage) {
          final message = FitnessWallApi.asString(result['message']);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                message.isEmpty ? 'Failed to load your posts.' : message,
              ),
              backgroundColor: Colors.red,
            ),
          );
        }

        return;
      }

      final posts = FitnessWallApi.extractPostList(result);

      setState(() {
        profilePosts = posts;
        isLoadingPosts = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        isLoadingPosts = false;
      });

      if (showErrorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading your posts: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<Map<String, dynamic>> visibleProfilePosts() {
    if (profilePosts.isNotEmpty) {
      return profilePosts;
    }

    return LocalPostStore.profilePosts
        .map((post) => Map<String, dynamic>.from(post))
        .toList();
  }

  Future<void> openCreatePost() async {
    final result = await Navigator.pushNamed(
      context,
      CreatePostScreen.routeName,
    );

    if (result is! Map) {
      return;
    }

    LocalPostStore.add(result);

    if (!mounted) return;

    final localPost = Map<String, dynamic>.from(result);

    setState(() {
      profilePosts.insert(0, localPost);
    });

    await loadProfilePosts(showErrorMessage: false);
  }

  String profileName() {
    final name = LocalUserStore.displayName.trim();

    if (name.isNotEmpty) {
      return name;
    }

    return 'User';
  }

  int readPostId(Map<String, dynamic> post) {
    return FitnessWallApi.asInt(
      post['PostId'] ??
          post['PostID'] ??
          post['postId'] ??
          post['postID'] ??
          post['post_id'] ??
          post['id'],
    );
  }

  String readPostContent(Map<String, dynamic> post) {
    return FitnessWallApi.asString(
      post['PostText'] ??
          post['postText'] ??
          post['post_text'] ??
          post['content'] ??
          post['body'],
    );
  }

  String readPostTime(Map<String, dynamic> post) {
    return FitnessWallApi.readPostTime(post);
  }

  String readPostAudience(Map<String, dynamic> post) {
    final audience = FitnessWallApi.asString(
      post['Audience'] ?? post['audience'],
    ).trim();

    return audience.isEmpty ? 'Public' : audience;
  }

  String readLocalImagePath(Map<String, dynamic> post) {
    return FitnessWallApi.asString(
      post['imagePath'] ?? post['ImagePath'] ?? post['localImagePath'],
    );
  }

  bool hasBackendPostImage(Map<String, dynamic> post) {
    final value = FitnessWallApi.asString(
      post['HasPhoto'] ??
          post['hasPhoto'] ??
          post['has_photo'] ??
          post['PostImage'] ??
          post['postImage'] ??
          post['post_image'] ??
          post['Image'] ??
          post['image'],
    ).trim().toLowerCase();

    return value == '1' ||
        value == 'true' ||
        value == 'yes' ||
        value == 'image' ||
        value == 'photo' ||
        value.isNotEmpty && value != '0' && value != 'false' && value != 'null';
  }

  Widget buildLocalPostImage(Map<String, dynamic> post) {
    final imagePath = readLocalImagePath(post);

    if (imagePath.isEmpty) {
      return const SizedBox.shrink();
    }

    final imageFile = File(imagePath);

    if (!imageFile.existsSync()) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Image.file(imageFile, width: double.infinity, fit: BoxFit.cover),
      ),
    );
  }

  Widget buildBackendPostImage(Map<String, dynamic> post) {
    final postId = readPostId(post);

    if (postId <= 0) {
      return const SizedBox.shrink();
    }

    final version = FitnessWallApi.asString(
      post['Updated_at'] ??
          post['updated_at'] ??
          post['Created_at'] ??
          post['created_at'] ??
          post['time'] ??
          postId,
    ).trim();

    final localFallback = buildLocalPostImage(post);

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: _ProfilePostNetworkImage(
          postId: postId,
          version: version,
          localFallback: localFallback,
        ),
      ),
    );
  }

  Widget buildPostImage(Map<String, dynamic> post) {
    final localImagePath = readLocalImagePath(post);

    if (localImagePath.isNotEmpty) {
      final localImage = buildLocalPostImage(post);

      if (localImage is! SizedBox) {
        return localImage;
      }
    }

    final postId = readPostId(post);

    if (postId <= 0) {
      return const SizedBox.shrink();
    }

    if (!hasBackendPostImage(post)) {
      return const SizedBox.shrink();
    }

    return buildBackendPostImage(post);
  }

  @override
  Widget build(BuildContext context) {
    final posts = visibleProfilePosts();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F1),
      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFF008000),
          onRefresh: () => loadProfilePosts(showErrorMessage: true),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              buildHeader(),
              const SizedBox(height: 16),
              buildComposer(),
              const SizedBox(height: 18),
              buildSectionTitle(posts.length),
              const SizedBox(height: 10),
              if (isLoadingPosts && posts.isEmpty)
                buildLoadingState()
              else if (posts.isEmpty)
                buildEmptyState()
              else
                ...posts.map(buildPostCard),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildHeader() {
    final posts = visibleProfilePosts();

    return Container(
      margin: const EdgeInsets.fromLTRB(22, 12, 22, 0),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF008000),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.14),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(
                    context,
                    DashboardScreen.routeName,
                  );
                },
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                  size: 25,
                ),
              ),
              const Expanded(
                child: Text(
                  'My Profile',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.more_horiz_rounded,
                  color: Colors.white,
                  size: 25,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(5),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const ProfilePhotoAvatar(radius: 32, iconSize: 40),
          ),
          const SizedBox(height: 8),
          Text(
            profileName(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            getTodayText(),
            style: TextStyle(
              color: Colors.white.withOpacity(0.88),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              buildMiniStat('Posts', '${posts.length}'),
              buildMiniDivider(),
              buildMiniStat('Goal', 'Fit'),
              buildMiniDivider(),
              buildMiniStat('Status', 'Active'),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildMiniStat(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.82),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMiniDivider() {
    return Container(
      height: 28,
      width: 1,
      color: Colors.white.withOpacity(0.25),
    );
  }

  Widget buildComposer() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18),
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          const ProfilePhotoAvatar(radius: 20, iconSize: 26),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: openCreatePost,
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 17),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F7F1),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFDCE8D8)),
                ),
                child: const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "What's on your mind?",
                    style: TextStyle(
                      color: Color(0xFF386B38),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.edit_rounded, color: Color(0xFF008000), size: 22),
        ],
      ),
    );
  }

  Widget buildSectionTitle(int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'My Posts',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$count total',
              style: const TextStyle(
                color: Color(0xFF008000),
                fontWeight: FontWeight.w900,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildLoadingState() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18),
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFE1E8DE)),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: Color(0xFF008000)),
      ),
    );
  }

  Widget buildEmptyState() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18),
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFE1E8DE)),
      ),
      child: Column(
        children: const [
          Icon(Icons.post_add_rounded, color: Color(0xFF008000), size: 42),
          SizedBox(height: 10),
          Text(
            'No posts yet',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 5),
          Text(
            'Share your first fitness update.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPostCard(Map<String, dynamic> post) {
    final content = readPostContent(post);
    final audience = readPostAudience(post);
    final isOnlyMe = audience == 'Only Me';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFE1E8DE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.055),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildPostHeader(isOnlyMe, audience, post),
          const SizedBox(height: 14),
          if (content.trim().isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAF6),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                content,
                style: const TextStyle(
                  fontSize: 17,
                  height: 1.4,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          buildPostImage(post),
        ],
      ),
    );
  }

  Widget buildPostHeader(
    bool isOnlyMe,
    String audience,
    Map<String, dynamic> post,
  ) {
    return Row(
      children: [
        const ProfilePhotoAvatar(radius: 27, iconSize: 34),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profileName(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    isOnlyMe ? Icons.lock_rounded : Icons.public_rounded,
                    color: const Color(0xFF008000),
                    size: 15,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    readPostTime(post),
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.more_vert_rounded, color: Colors.black45),
        ),
      ],
    );
  }
}

class _ProfilePostNetworkImage extends StatefulWidget {
  final int postId;
  final String version;
  final Widget localFallback;

  const _ProfilePostNetworkImage({
    required this.postId,
    required this.version,
    required this.localFallback,
  });

  @override
  State<_ProfilePostNetworkImage> createState() =>
      _ProfilePostNetworkImageState();
}

class _ProfilePostNetworkImageState extends State<_ProfilePostNetworkImage> {
  static final Map<String, Uint8List> _imageMemoryCache = {};
  static final Map<String, Future<Uint8List?>> _pendingImageLoads = {};

  late Future<Uint8List?> imageFuture;

  @override
  void initState() {
    super.initState();
    imageFuture = getImageFuture();
  }

  @override
  void didUpdateWidget(covariant _ProfilePostNetworkImage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.postId != widget.postId ||
        oldWidget.version != widget.version) {
      imageFuture = getImageFuture();
    }
  }

  String stableVersionValue() {
    final trimmedVersion = widget.version.trim();

    if (trimmedVersion.isNotEmpty) {
      return trimmedVersion;
    }

    return widget.postId.toString();
  }

  String cacheKey() {
    return '${widget.postId}_${stableVersionValue()}';
  }

  Future<Uint8List?> getImageFuture() {
    final key = cacheKey();

    final cachedImage = _imageMemoryCache[key];

    if (cachedImage != null && cachedImage.isNotEmpty) {
      return Future.value(cachedImage);
    }

    return _pendingImageLoads[key] ??=
        loadImage(
          key: key,
          postId: widget.postId,
          versionValue: stableVersionValue(),
        ).whenComplete(() {
          _pendingImageLoads.remove(key);
        });
  }

  Future<Uint8List?> loadImage({
    required String key,
    required int postId,
    required String versionValue,
  }) async {
    final imageUri = Uri.parse(
      '${ApiClient.baseUrl}/posts/$postId/image',
    ).replace(queryParameters: {'v': versionValue});

    try {
      final response = await http
          .get(
            imageUri,
            headers: const {
              'Accept': 'image/jpeg,image/png,image/webp,image/*,*/*',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return null;
      }

      final normalizedImage = normalizeProfilePostImageBytes(
        response.bodyBytes,
      );

      if (normalizedImage != null && normalizedImage.isNotEmpty) {
        _imageMemoryCache[key] = normalizedImage;
      }

      return normalizedImage;
    } catch (_) {
      return null;
    }
  }

  bool hasLocalFallback() {
    return widget.localFallback is! SizedBox;
  }

  Widget loadingView() {
    if (hasLocalFallback()) {
      return widget.localFallback;
    }

    return Container(
      height: 180,
      width: double.infinity,
      alignment: Alignment.center,
      color: const Color(0xFFF1F6EF),
      child: const CircularProgressIndicator(color: Color(0xFF008000)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: imageFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return loadingView();
        }

        final imageBytes = snapshot.data;

        if (imageBytes == null || imageBytes.isEmpty) {
          if (hasLocalFallback()) {
            return widget.localFallback;
          }

          return const SizedBox.shrink();
        }

        return Image.memory(
          imageBytes,
          width: double.infinity,
          fit: BoxFit.cover,
          gaplessPlayback: true,
          cacheWidth: 900,
          errorBuilder: (_, __, ___) {
            if (hasLocalFallback()) {
              return widget.localFallback;
            }

            return const SizedBox.shrink();
          },
        );
      },
    );
  }
}

Uint8List? normalizeProfilePostImageBytes(Uint8List bytes) {
  if (bytes.isEmpty) {
    return null;
  }

  if (isRealProfilePostImage(bytes)) {
    return bytes;
  }

  var text = utf8.decode(bytes, allowMalformed: true).trim();

  if (text.isEmpty) {
    return null;
  }

  if (text.startsWith('data:image') && text.contains(',')) {
    text = text.split(',').last.trim();
  }

  if ((text.startsWith('"') && text.endsWith('"')) ||
      (text.startsWith("'") && text.endsWith("'"))) {
    text = text.substring(1, text.length - 1).trim();
  }

  if (text.startsWith("b'") && text.endsWith("'")) {
    text = text.substring(2, text.length - 1).trim();
  }

  final cleaned = text.replaceAll(RegExp(r'\s+'), '');

  try {
    final decoded = base64Decode(base64.normalize(cleaned));

    if (isRealProfilePostImage(decoded)) {
      return Uint8List.fromList(decoded);
    }
  } catch (_) {
    return null;
  }

  return null;
}

bool isRealProfilePostImage(List<int> data) {
  if (data.length < 4) {
    return false;
  }

  final isJpeg =
      data.length >= 3 && data[0] == 0xFF && data[1] == 0xD8 && data[2] == 0xFF;

  final isPng =
      data.length >= 8 &&
      data[0] == 0x89 &&
      data[1] == 0x50 &&
      data[2] == 0x4E &&
      data[3] == 0x47 &&
      data[4] == 0x0D &&
      data[5] == 0x0A &&
      data[6] == 0x1A &&
      data[7] == 0x0A;

  final isGif =
      data.length >= 6 &&
      data[0] == 0x47 &&
      data[1] == 0x49 &&
      data[2] == 0x46 &&
      data[3] == 0x38 &&
      (data[4] == 0x37 || data[4] == 0x39) &&
      data[5] == 0x61;

  final isWebp =
      data.length >= 12 &&
      data[0] == 0x52 &&
      data[1] == 0x49 &&
      data[2] == 0x46 &&
      data[3] == 0x46 &&
      data[8] == 0x57 &&
      data[9] == 0x45 &&
      data[10] == 0x42 &&
      data[11] == 0x50;

  return isJpeg || isPng || isGif || isWebp;
}
