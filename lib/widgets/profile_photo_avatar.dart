import 'package:flutter/material.dart';

import '../core/network/api_client.dart';
import '../core/storage/api_session_store.dart';

class ProfilePhotoAvatar extends StatefulWidget {
  final int? userId;
  final double radius;
  final double iconSize;
  final Color backgroundColor;
  final Color iconColor;
  final IconData fallbackIcon;

  const ProfilePhotoAvatar({
    super.key,
    this.userId,
    required this.radius,
    this.iconSize = 28,
    this.backgroundColor = const Color(0xFFE8F5E9),
    this.iconColor = const Color(0xFF008000),
    this.fallbackIcon = Icons.person_rounded,
  });

  @override
  State<ProfilePhotoAvatar> createState() => _ProfilePhotoAvatarState();
}

class _ProfilePhotoAvatarState extends State<ProfilePhotoAvatar> {
  late final Future<int> _userIdFuture;
  late final int _cacheBust;

  @override
  void initState() {
    super.initState();
    _cacheBust = DateTime.now().millisecondsSinceEpoch;
    _userIdFuture = widget.userId == null
        ? ApiSessionStore.getUserId()
        : Future<int>.value(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.radius * 2;

    return FutureBuilder<int>(
      future: _userIdFuture,
      builder: (context, snapshot) {
        final userId = snapshot.data ?? 0;

        if (userId <= 0) {
          return _fallback(size);
        }

        final imageUrl =
            '${ApiClient.baseUrl}/profile/$userId/photo?v=$_cacheBust';

        return ClipOval(
          child: SizedBox(
            height: size,
            width: size,
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _fallback(size),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;

                return _fallback(
                  size,
                  child: SizedBox(
                    height: widget.iconSize * 0.65,
                    width: widget.iconSize * 0.65,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF008000),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _fallback(double size, {Widget? child}) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: child ??
            Icon(
              widget.fallbackIcon,
              color: widget.iconColor,
              size: widget.iconSize,
            ),
      ),
    );
  }
}
