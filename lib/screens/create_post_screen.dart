import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../core/storage/api_session_store.dart';
import '../data/local_user_store.dart';
import '../features/createpost/data/createpost_api.dart';
import '../widgets/profile_photo_avatar.dart';

class CreatePostScreen extends StatefulWidget {
  static const routeName = '/create-post';

  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController postController = TextEditingController();
  final ImagePicker imagePicker = ImagePicker();

  String audience = 'Public';
  bool photoSelected = false;
  bool isPosting = false;
  XFile? selectedPhoto;

  @override
  void dispose() {
    postController.dispose();
    super.dispose();
  }

  Future<void> pickPhoto() async {
    final image = await imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 45,
    );

    if (image == null) return;

    setState(() {
      selectedPhoto = image;
      photoSelected = true;
    });
  }

  Future<void> submitPost() async {
    final postText = postController.text.trim();

    if (postText.isEmpty && !photoSelected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Write something or add a photo first.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final userId = await ApiSessionStore.getUserId();

    if (userId == null || userId <= 0) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User not found. Please login again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isPosting = true;
    });

    try {
      final result = await CreatePostApi.createPost(
        userId: userId,
        postText: postText,
        audience: audience,
      );

      if (!mounted) return;

      if (result['success'] == false) {
        setState(() {
          isPosting = false;
        });

        final message = CreatePostApi.asString(result['message']);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message.isEmpty ? 'Failed to create post.' : message),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final postId = CreatePostApi.asInt(
        result['PostId'] ?? result['postId'] ?? result['post_id'],
      );

      if (selectedPhoto != null && postId > 0) {
        final imageResult = await CreatePostApi.uploadPostImage(
          postId: postId,
          imagePath: selectedPhoto!.path,
        );

        if (!mounted) return;

        if (imageResult['success'] == false) {
          setState(() {
            isPosting = false;
          });

          final message = CreatePostApi.asString(imageResult['message']);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                message.isEmpty
                    ? 'Post saved, but image upload failed.'
                    : message,
              ),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }
      }

      Navigator.pop(context, {
        'content': postText,
        'PostText': postText,
        'audience': audience,
        'Audience': audience,
        'hasPhoto': photoSelected.toString(),
        'HasPhoto': photoSelected ? 1 : 0,
        'imagePath': selectedPhoto?.path ?? '',
        'name': LocalUserStore.displayName.isEmpty
            ? 'User'
            : LocalUserStore.displayName,
        'Fullname': LocalUserStore.displayName.isEmpty
            ? 'User'
            : LocalUserStore.displayName,
        'UserId': userId,
        'userId': userId,
        'PostId': postId,
        'postId': postId,
        'time': 'Just now',
        'refresh': 'true',
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        isPosting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating post: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  IconData get audienceIcon {
    return audience == 'Only Me' ? Icons.lock_rounded : Icons.public_rounded;
  }

  String get audienceHint {
    return audience == 'Only Me'
        ? 'Only you can see this post.'
        : 'This will appear on the Fitness Wall.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F1),
      body: SafeArea(
        child: Column(
          children: [
            buildTopBar(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
                children: [
                  buildComposerCard(),
                  const SizedBox(height: 14),
                  buildAddPhotoCard(),
                  const SizedBox(height: 14),
                  buildGuideCard(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 10, 18, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: Color(0xFF008000),
              size: 29,
            ),
          ),
          const Expanded(
            child: Text(
              'Create Post',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: isPosting ? null : submitPost,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF008000),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 23, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: Text(
              isPosting ? 'Posting...' : 'Post',
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildComposerCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE2EBDD)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.055),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          buildUserRow(),
          const SizedBox(height: 14),
          buildTextComposer(),
        ],
      ),
    );
  }

  Widget buildUserRow() {
    return Row(
      children: [
        const ProfilePhotoAvatar(radius: 27, iconSize: 35),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                LocalUserStore.displayName.isEmpty
                    ? 'User'
                    : LocalUserStore.displayName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 7),
              buildAudienceSelector(),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildAudienceSelector() {
    return PopupMenuButton<String>(
      initialValue: audience,
      onSelected: (value) {
        setState(() {
          audience = value;
        });
      },
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      itemBuilder: (context) {
        return const [
          PopupMenuItem(
            value: 'Public',
            child: Row(
              children: [
                Icon(Icons.public_rounded, color: Color(0xFF008000), size: 20),
                SizedBox(width: 10),
                Text('Public', style: TextStyle(fontWeight: FontWeight.w800)),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'Only Me',
            child: Row(
              children: [
                Icon(Icons.lock_rounded, color: Color(0xFF008000), size: 20),
                SizedBox(width: 10),
                Text('Only Me', style: TextStyle(fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ];
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFB9E5B9)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(audienceIcon, color: const Color(0xFF008000), size: 16),
            const SizedBox(width: 6),
            Text(
              audience,
              style: const TextStyle(
                color: Color(0xFF008000),
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF008000),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextComposer() {
    return TextField(
      controller: postController,
      minLines: 7,
      maxLines: 10,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
      style: const TextStyle(
        fontSize: 18,
        height: 1.35,
        color: Colors.black87,
        fontWeight: FontWeight.w600,
      ),
      decoration: const InputDecoration(
        hintText: "What's on your mind?",
        hintStyle: TextStyle(
          color: Colors.black38,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
        border: InputBorder.none,
      ),
    );
  }

  Widget buildAddPhotoCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 13, 14, 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2EBDD)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Add to your post',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: pickPhoto,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: photoSelected
                    ? const Color(0xFF008000)
                    : const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                children: [
                  Icon(
                    photoSelected
                        ? Icons.check_circle_rounded
                        : Icons.image_rounded,
                    color: photoSelected
                        ? Colors.white
                        : const Color(0xFF008000),
                    size: 20,
                  ),
                  const SizedBox(width: 7),
                  Text(
                    photoSelected ? 'Added' : 'Photo',
                    style: TextStyle(
                      color: photoSelected
                          ? Colors.white
                          : const Color(0xFF008000),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildGuideCard() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFB9E5B9)),
      ),
      child: Row(
        children: [
          Container(
            height: 36,
            width: 36,
            decoration: const BoxDecoration(
              color: Color(0xFFE8F5E9),
              shape: BoxShape.circle,
            ),
            child: Icon(audienceIcon, color: const Color(0xFF008000), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              audienceHint,
              style: const TextStyle(
                fontSize: 14,
                height: 1.35,
                color: Colors.black54,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
