import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  final double radius;
  final String profileImageUrl;
  final String fallbackText;
  final TextStyle? textStyle;
  final VoidCallback? onTap;
  final bool isLoading;
  final Widget? overlayWidget;

  const ProfileAvatar({
    super.key,
    required this.radius,
    required this.profileImageUrl,
    required this.fallbackText,
    this.textStyle,
    this.onTap,
    this.isLoading = false,
    this.overlayWidget,
  });

  @override
  Widget build(BuildContext context) {
    Widget avatar = Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color.fromARGB(255, 237, 238, 241),
          width: 2,
        ),
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: const Color(0xFFE8F0FE),
        backgroundImage: profileImageUrl.isNotEmpty
            ? NetworkImage(profileImageUrl)
            : null,
        child: isLoading
            ? const CircularProgressIndicator()
            : profileImageUrl.isEmpty
            ? Text(fallbackText, style: textStyle)
            : null,
      ),
    );

    if (overlayWidget != null) {
      avatar = Stack(
        clipBehavior: Clip.none,
        children: [
          avatar,
          Positioned(right: -8, bottom: -8, child: overlayWidget!),
        ],
      );
    }

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: avatar);
    }

    return avatar;
  }
}
