import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EggController extends GetxController {
  var tapCount = 0.obs;

  void touchEgg() async {
    tapCount++;
    await _saveTapCount();
  }

  void reset() async {
    await _resetTapCount();
    tapCount.value = 0;
  }

  @override
  void onInit() {
    super.onInit();
    _loadTapCount();
  }

  Future<void> _saveTapCount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('tapCount', tapCount.value);
  }

  Future<void> _loadTapCount() async {
    final prefs = await SharedPreferences.getInstance();
    tapCount.value = prefs.getInt('tapCount') ?? 0;
  }

  Future<void> _resetTapCount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('tapCount', 0);
  }
}
