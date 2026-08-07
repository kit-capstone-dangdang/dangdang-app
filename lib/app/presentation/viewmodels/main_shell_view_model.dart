import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainShellViewModel extends ChangeNotifier {
  MainShellViewModel(int initialIndex) : _selectedIndex = initialIndex;

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

final mainShellViewModelProvider = ChangeNotifierProvider.autoDispose
    .family<MainShellViewModel, int>((ref, initialIndex) {
      return MainShellViewModel(initialIndex);
    });
