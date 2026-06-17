import 'package:flutter/material.dart';

class CreatePostScreen extends StatefulWidget {
  static const routeName = '/create-post';

  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController postController = TextEditingController();

  String audience = 'Public';
  bool photoSelected = false;

  @override
  void dispose() {
    postController.dispose();
    super.dispose();
  }

  void submitPost() {
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

    Navigator.pop(context, {
      'content': postText,
      'audience': audience,
      'hasPhoto': photoSelected,
    });
  }

  IconData get audienceIcon {
    return audience == 'Only Me'
        ? Icons.lock_rounded
        : Icons.public_rounded;
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
            onPressed: submitPost,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF008000),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                horizontal: 23,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: const Text(
              'Post',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 15,
              ),
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
        border: Border.all(
          color: const Color(0xFFE2EBDD),
        ),
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
        const CircleAvatar(
          radius: 27,
          backgroundColor: Color(0xFFE8F5E9),
          child: Icon(
            Icons.person_rounded,
            color: Color(0xFF008000),
            size: 35,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'User',
                style: TextStyle(
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      itemBuilder: (context) {
        return const [
          PopupMenuItem(
            value: 'Public',
            child: Row(
              children: [
                Icon(
                  Icons.public_rounded,
                  color: Color(0xFF008000),
                  size: 20,
                ),
                SizedBox(width: 10),
                Text(
                  'Public',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'Only Me',
            child: Row(
              children: [
                Icon(
                  Icons.lock_rounded,
                  color: Color(0xFF008000),
                  size: 20,
                ),
                SizedBox(width: 10),
                Text(
                  'Only Me',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
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
          border: Border.all(
            color: const Color(0xFFB9E5B9),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              audienceIcon,
              color: const Color(0xFF008000),
              size: 16,
            ),
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
        border: Border.all(
          color: const Color(0xFFE2EBDD),
        ),
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
            onTap: () {
              setState(() {
                photoSelected = !photoSelected;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
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
        border: Border.all(
          color: const Color(0xFFB9E5B9),
        ),
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
            child: Icon(
              audienceIcon,
              color: const Color(0xFF008000),
              size: 20,
            ),
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


