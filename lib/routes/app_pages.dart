import 'package:get/get.dart';
import 'package:urban_culture/modules/auth/auth_binding.dart';
import 'package:urban_culture/modules/auth/auth_screen.dart';
import 'package:urban_culture/modules/layout/layout_binding.dart';
import 'package:urban_culture/modules/layout/layout_screen.dart';
import 'package:urban_culture/modules/routine/routine_binding.dart';
import 'package:urban_culture/modules/routine/routine_screen.dart';
import 'package:urban_culture/modules/streaks/streaks_binding.dart';
import 'package:urban_culture/modules/streaks/streaks_screen.dart';
import 'package:urban_culture/routes/app_routes.dart';

class AppPages {
  static final List<GetPage> pages = [
    GetPage(name: AppRoutes.authRoute, page: () => const AuthScreen(), binding: AuthBinding()),
    GetPage(name: AppRoutes.streaksRoute, page: () => const StreaksScreen(), binding: StreaksBinding()),
    GetPage(name: AppRoutes.routineRoute, page: () => const RoutineScreen(), binding: RoutineBinding()),
    GetPage(name: AppRoutes.layoutRoute, page: () => const LayoutScreen(), bindings: [
      LayoutBinding(),
      RoutineBinding(),
      StreaksBinding(),
    ]),
  ];
}
