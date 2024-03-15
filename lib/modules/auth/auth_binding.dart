import 'package:get/get.dart';
import 'package:urban_culture/modules/auth/auth_controller.dart';


class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AuthController(), fenix: true);
  }
}