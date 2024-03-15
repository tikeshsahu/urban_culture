

import 'package:get/get.dart';
import 'package:urban_culture/modules/streaks/streaks_controller.dart';

class StreaksBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => StreaksController(), fenix: true);
  }
}