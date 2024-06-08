import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
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
  final Rx _titleController = Rx(TextEditingController());
  final Rx _descriptionController = Rx(TextEditingController());
  final Rx _formKey = Rx(GlobalKey<FormState>());
  GlobalKey<FormState> get formKey => _formKey.value;
  TextEditingController get titleController => _titleController.value;
  TextEditingController get descriptionController => _descriptionController.value;
  bool get isLoading => _isLoading.value;
  List get routineData => _routineData;
  bool get isFetchingImage => _isFetchingImage.value;

  @override
  void onInit() {
    fetchDataAndUpdateIfNeeded(StorageService.instance.fetch(AppUtils.userId));
    super.onInit();
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  updateIsLoading(bool value) {
    _isLoading.value = value;
    update();
  }

  updateIsFetchingImage(bool value) {
    _isFetchingImage.value = value;
    update();
  }

  Future<void> fetchDataAndUpdateIfNeeded(String userId) async {
    print("fetchDataAndUpdateIfNeeded");
    updateIsLoading(true);
    try {
      String today = DateTime.now().toString().split(' ')[0];
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;
      List allRoutines = userData['allRoutines'];

      Reference ref = FirebaseStorage.instance.ref().child('images').child(userId);

      // want to check if FirebaseStorage.instance.ref().child('images').child(userId) does not contain DateTime.now().toString().split(' ')[0] then
      // delete the file inside .child(userId)
      if (ref.child(DateTime.now().toString().split(' ')[0]) == null) {
        print("ref delete");
        ref.delete();
      }

      if (userData['lastUpdatedDay'] != today) {
        List updatedRoutines = allRoutines.map((routine) {
          return {
            'routineId': routine['routineId'],
            'routineTitle': 'Routine ${allRoutines.indexOf(routine) + 1}',
            'routineDescription': 'Enter description',
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
      print(e);
      updateIsLoading(false);
      Get.snackbar("Error", "Something went wrong.");
    } finally {
      updateIsLoading(false);
    }
  }

  Future<void> uploadImageAndSaveRoutine({required String userId, required String routineId, String routineTitle = '', String routineDescription = ''}) async {
    try {
      updateIsFetchingImage(true);
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 0);
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
            'routineTitle': routine['routineTitle'],
            'routineDescription': routine['routineDescription'],
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
      print(e);
      updateIsFetchingImage(false);
      Get.snackbar("Error", "Failed to save changes. Please try again.");
    }
  }

  Future updateTitleAndDescription({required String userId, required String routineId, required String title, required String description}) async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    updateIsLoading(true);

    try {
      print("updateTitleAndDescription");
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;
      List<dynamic> allRoutines = userData['allRoutines'];

      List<dynamic> updatedRoutines = allRoutines.map((routine) {
        if (routine['routineId'] == routineId) {
          return {
            'routineId': routine['routineId'],
            'routineTitle': titleController.text,
            'routineDescription': descriptionController.text,
            'completedDate': routine['completedDate'],
            'isRoutineDone': routine['isRoutineDone'],
            'imagePath': routine['imagePath'],
          };
        } else {
          return routine;
        }
      }).toList();

      userSnapshot.reference.update({
        'allRoutines': updatedRoutines,
      });

      _routineData.assignAll(updatedRoutines);
      Get.back();
      onInit();
    } catch (e) {
      print(e);
      Get.snackbar("Error", "Failed to save changes. Please try again.");
    }
  }

  Future<String> uploadImage(File image, String userId, String routineId) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference ref = FirebaseStorage.instance.ref().child('images').child(userId).child(DateTime.now().toString().split(' ')[0]).child(fileName);
      await ref.putFile(image);
      var url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      print(e);
      return '';
    }
  }

  String convertTime(String date) {
    DateTime time = DateTime.parse(date);
    String period = (time.hour < 12) ? 'AM' : 'PM';
    int hour = (time.hour > 12) ? time.hour - 12 : time.hour;
    String minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }
}
