import 'package:get/get.dart';
import 'package:urban_culture/modules/layout/layout_controller.dart';

class LayoutBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LayoutController(), fenix: true);
  }
}