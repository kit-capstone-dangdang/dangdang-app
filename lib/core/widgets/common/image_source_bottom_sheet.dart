import 'package:flutter/material.dart';

class ImageSourceBottomSheet extends StatelessWidget {
  final Future<void> Function() onCameraTap;
  final Future<void> Function() onGalleryTap;

  const ImageSourceBottomSheet({
    super.key,
    required this.onCameraTap,
    required this.onGalleryTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: onCameraTap,
            icon: const Icon(Icons.camera_alt, color: Colors.white, size: 24),
            label: const Text(
              '카메라로 촬영하기',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              minimumSize: const Size(double.infinity, 60),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 5,
            ),
          ),
          const SizedBox(height: 15),
          ElevatedButton.icon(
            onPressed: onGalleryTap,
            icon: Icon(
              Icons.image_outlined,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: 24,
            ),
            label: Text(
              '갤러리에서 선택하기',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 16,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest,
              minimumSize: const Size(double.infinity, 60),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 0,
            ),
          ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }
}
