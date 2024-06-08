



 import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
   final _notificationService = FirebaseMessaging.instance;

   Future<void> init() async {
     await _notificationService.requestPermission();
     final token = await _notificationService.getToken();
     print("Token: $token");
     print("Notification service initialised");

    //  await _notificationService.setForegroundNotificationPresentationOptions(
    //    alert: true,
    //    badge: true,
    //    sound: true,
    //  );

   }
 }

 Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // await Firebase.initializeApp();
  print("Handling a background message: ${message.notification!.title}");
}