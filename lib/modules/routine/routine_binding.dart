

import 'package:get/get.dart';
import 'package:urban_culture/modules/routine/routine_controller.dart';

class RoutineBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => RoutineController(), fenix: true);
  }
}