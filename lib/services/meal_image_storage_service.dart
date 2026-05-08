import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class MealImageStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadMealImage(XFile image) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';

    final ref = _storage.ref().child('meal_images/$fileName');

    final metadata = SettableMetadata(contentType: 'image/jpeg');

    await ref.putFile(File(image.path), metadata);

    return await ref.getDownloadURL();
  }
}
