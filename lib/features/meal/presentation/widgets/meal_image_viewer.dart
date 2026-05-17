import 'dart:typed_data';

import 'package:dangdang/core/widgets/common/custom_card.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class MealImageViewer extends StatelessWidget {
  final XFile? image;
  final String? imageUrl;
  final double height;
  final double borderRadius;

  const MealImageViewer({
    super.key,
    this.image,
    this.imageUrl,
    this.height = 300,
    this.borderRadius = 38,
  });

  bool get _hasNetworkImage => imageUrl != null && imageUrl!.isNotEmpty;

  void _showImageDialog(BuildContext context, Widget imageWidget) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.black,
          insetPadding: const EdgeInsets.all(12),
          child: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  minScale: 1,
                  maxScale: 4,
                  child: imageWidget,
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyImage() {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Center(
        child: Icon(Icons.fastfood, size: 64, color: Colors.grey.shade500),
      ),
    );
  }

  Widget _buildNetworkImage(BuildContext context) {
    final previewImage = Image.network(
      imageUrl!,
      height: height,
      width: double.infinity,
      fit: BoxFit.cover,
    );

    final dialogImage = Image.network(imageUrl!, fit: BoxFit.contain);

    return GestureDetector(
      onTap: () => _showImageDialog(context, dialogImage),
      child: previewImage,
    );
  }

  Widget _buildMemoryImage(BuildContext context, Uint8List bytes) {
    final previewImage = Image.memory(
      bytes,
      height: height,
      width: double.infinity,
      fit: BoxFit.cover,
    );

    final dialogImage = Image.memory(bytes, fit: BoxFit.contain);

    return GestureDetector(
      onTap: () => _showImageDialog(context, dialogImage),
      child: previewImage,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      padding: EdgeInsets.zero,
      borderRadius: borderRadius,
      backgroundColor: Colors.grey.shade200,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: image != null
            ? FutureBuilder<Uint8List>(
                future: image!.readAsBytes(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return SizedBox(
                      height: height,
                      width: double.infinity,
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  }

                  return _buildMemoryImage(context, snapshot.data!);
                },
              )
            : _hasNetworkImage
            ? _buildNetworkImage(context)
            : _buildEmptyImage(),
      ),
    );
  }
}
