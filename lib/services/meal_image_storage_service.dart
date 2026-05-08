import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class MealImageStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadMealImage(XFile image) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';

    final ref = _storage.ref().child('meal_images/$fileName');

    final metadata = SettableMetadata(
      contentType: image.mimeType ?? 'image/jpeg',
    );

    final bytes = await image.readAsBytes();

    await ref.putData(bytes, metadata);

    return await ref.getDownloadURL();
  }
}
