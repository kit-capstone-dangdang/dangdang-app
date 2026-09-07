import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainShellModel extends ChangeNotifier {
  MainShellModel(int initialIndex) : _selectedIndex = initialIndex;

  int _selectedIndex;

  int get selectedIndex => _selectedIndex;

  void selectIndex(int index) {
    if (_selectedIndex == index) {
      return;
    }

    _selectedIndex = index;
    notifyListeners();
  }
}

final mainShellProvider = ChangeNotifierProvider.autoDispose
    .family<MainShellModel, int>((ref, initialIndex) {
      return MainShellModel(initialIndex);
    });
