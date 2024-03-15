import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:urban_culture/utils/app_utils.dart';
import 'package:urban_culture/utils/storage.dart';
import 'package:intl/intl.dart';


class RoutineController extends GetxController {
  final RxBool _isLoading = RxBool(false);
  final RxList _routineData = RxList([]);
  final RxBool _isFetchingImage = RxBool(false);
  bool get isLoading => _isLoading.value;
  List get routineData => _routineData;
  bool get isFetchingImage => _isFetchingImage.value;

  @override
  void onInit() {
    fetchDataAndUpdateIfNeeded(StorageService.instance.fetch(AppUtils.userId));
    super.onInit();
  }

  updateIsLoading(bool value) {
    _isLoading.value = value;
    update();
  }

  updateIsFetchingImage(bool value) {
    _isFetchingImage.value = value;
    update();
  }

  String convertTime(String date) {
    DateTime time = DateTime.parse(date);
    String period = (time.hour < 12) ? 'AM' : 'PM';
    int hour = (time.hour > 12) ? time.hour - 12 : time.hour;
    String minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  Future<void> fetchDataAndUpdateIfNeeded(String userId) async {
    updateIsLoading(true);
    try {
      String today = DateTime.now().toString().split(' ')[0];
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;
      List allRoutines = userData['allRoutines'];

      if (userData['lastUpdatedDay'] != today) {
        List updatedRoutines = allRoutines.map((routine) {
          return {
            'routineId': routine['routineId'],
            'completedDate': '',
            'isRoutineDone': false,
            'imagePath': '',
          };
        }).toList();
        _routineData.assignAll(updatedRoutines);
        userSnapshot.reference.update({
          'allRoutines': updatedRoutines,
          'lastUpdatedDay': today,
        });
      } else {
        _routineData.assignAll(allRoutines);
      }
    } catch (e) {
      updateIsLoading(false);
      Get.snackbar("Error", "Something went wrong.");
    } finally {
      updateIsLoading(false);
    }
  }

  Future<void> uploadImageAndSaveRoutine(String userId, String routineId) async {
    try {
      updateIsFetchingImage(true);
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
      if (pickedFile == null) {
        updateIsFetchingImage(false);
        return;
      }

      final imageFile = File(pickedFile.path);
      final imagePath = await uploadImage(imageFile, userId, routineId);

      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;
      List<dynamic> allRoutines = userData['allRoutines'];
      Map<String, dynamic> completedRoutines = userData['completedRoutines'];
      List routineIdsForToday = completedRoutines[DateFormat('yyyy-MM-dd').format(DateTime.now()).toString()] ?? [];
      routineIdsForToday.add(routineId);
      completedRoutines[DateFormat('yyyy-MM-dd').format(DateTime.now()).toString()] = routineIdsForToday;

      List<dynamic> updatedRoutines = allRoutines.map((routine) {
        if (routine['routineId'] == routineId) {
          return {
            'routineId': routine['routineId'],
            'completedDate': DateTime.now().toString(),
            'isRoutineDone': true,
            'imagePath': imagePath,
          };
        } else {
          return routine;
        }
      }).toList();

      userSnapshot.reference.update({
        'completedRoutines': completedRoutines,
        'allRoutines': updatedRoutines,
        'lastUpdatedDay': DateTime.now().toString().split(' ')[0],
      });

      _routineData.assignAll(updatedRoutines);
      updateIsFetchingImage(false);
      onInit();
    } catch (e) {
      updateIsFetchingImage(false);
      Get.snackbar("Error", "Failed to save changes. Please try again.");
    }
  }

  Future<String> uploadImage(File image, String userId, String routineId) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = FirebaseStorage.instance.ref().child('images').child(userId).child(routineId).child(fileName);
      await ref.putFile(image);
      return await ref.getDownloadURL();
    } catch (e) {
      return '';
    }
  }
}
