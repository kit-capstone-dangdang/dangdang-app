import 'package:image_picker/image_picker.dart';

class ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  // 1. 카메라 촬영 시 압축 옵션 적용
  Future<XFile?> pickFromCamera() async {
    return await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1024, // 가로 최대 1024 픽셀
      maxHeight: 1024, // 세로 최대 1024 픽셀
      imageQuality: 70, // 화질 70% 로 압축
    );
  }

  // 2. 갤러리 선택 시 압축 옵션 적용
  Future<XFile?> pickFromGallery() async {
    return await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 70,
    );
  }
}
