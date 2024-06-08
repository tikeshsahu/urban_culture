import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:urban_culture/model/routine.dart';
import 'package:urban_culture/modules/routine/routine_controller.dart';
import 'package:urban_culture/utils/app_utils.dart';
import 'package:urban_culture/utils/storage.dart';

class RoutineScreen extends StatelessWidget {
  const RoutineScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final RoutineController controller = Get.put(RoutineController());
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xffFCF7FA),
      appBar: AppBar(
        title: const Text('Daily Skincare'),
        centerTitle: true,
      ),
      body: SafeArea(
        top: true,
        bottom: true,
        child: SingleChildScrollView(
          child: Obx(
            () => controller.isLoading || controller.isFetchingImage
                ? SizedBox(height: size.height, width: size.width, child: const Center(child: CircularProgressIndicator()))
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: controller.routineData.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> data = controller.routineData[index];
                      RoutineStaticData staticData = AppUtils.staticRoutineData[index];
                      return Column(
                        children: [
                          ListTile(
                            leading: Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                color: const Color(0xffF2E8EB),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                  child: data["isRoutineDone"]
                                      ? const Icon(
                                          Icons.done,
                                          color: Colors.green,
                                        )
                                      : const Icon(
                                          Icons.dangerous_rounded,
                                          color: Colors.amber,
                                        )),
                            ),
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  // staticData.name,
                                  data["routineTitle"] ?? "null hai",
                                  style: const TextStyle(fontWeight: FontWeight.w400),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  data["completedDate"] == "" ? "" : controller.convertTime(data["completedDate"] ?? ""),
                                  style: const TextStyle(color: Color(0xff964F66), fontSize: 14),
                                )
                              ],
                            ),
                            subtitle: Text(
                              // staticData.desc,
                              data["routineDescription"] ?? "null",
                              maxLines: 2,
                              style: const TextStyle(
                                color: Color(0xff964F66),
                              ),
                            ),
                            trailing: data["imagePath"] == ""
                                ? IconButton(
                                    icon: const Icon(Icons.camera_enhance_outlined),
                                    onPressed: () => controller.uploadImageAndSaveRoutine(userId: StorageService.instance.fetch(AppUtils.userId), routineId: data["routineId"]),
                                  )
                                : Container(
                                    height: 50,
                                    width: 50,
                                    decoration: BoxDecoration(
                                      color: const Color(0xffF2E8EB),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: CachedNetworkImage(imageUrl: data["imagePath"], fit: BoxFit.fill, errorWidget: (context, url, error) => const Icon(Icons.error)),
                                    ),
                                  ),
                          ),
                          ElevatedButton(
                            child: const Text("Edit"),
                            onPressed: () {
                              showModalBottomSheet(
                                isScrollControlled: true,
                                context: context,
                                builder: (context) {
                                  return Padding(
                                    padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      // padding: const EdgeInsets.all(AppUtils.normalPadding),
                                      height: MediaQuery.of(context).size.height * 0.5,
                                      child: Form(
                                        key: controller.formKey,
                                        child: Column(
                                          children: [
                                            const Text('Edit Routine', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                            const SizedBox(height: 10 * 2),
                                            // const SizedBox(height: AppUtils.normalPadding * 2),
                                            TextFormField(
                                              controller: controller.titleController,
                                              decoration: InputDecoration(
                                                labelText: 'Title',
                                                border: OutlineInputBorder(
                                                  // borderRadius: BorderRadius.circular(AppUtils.normalRadius),
                                                  borderRadius: BorderRadius.circular(10),
                                                  borderSide: const BorderSide(),
                                                ),
                                              ),
                                              validator: (value) {
                                                if (value == null || value.isEmpty || value == "") {
                                                  return "Please enter title";
                                                }
                                                return null;
                                              },
                                            ),
                                            const SizedBox(height: 15),
                                            TextFormField(
                                              controller: controller.descriptionController,
                                              decoration: InputDecoration(
                                                labelText: 'Description',
                                                border: OutlineInputBorder(
                                                  // borderRadius: BorderRadius.circular(AppUtils.normalRadius),
                                                  borderRadius: BorderRadius.circular(10),
                                                  borderSide: const BorderSide(),
                                                ),
                                              ),
                                              validator: (value) {
                                                if (value == null || value.isEmpty || value == "") {
                                                  return "Please enter description";
                                                }
                                                return null;
                                              },
                                            ),
                                            // const SizedBox(height: AppUtils.normalPadding * 3),
                                            const SizedBox(height: 10 * 3),
                                            ElevatedButton(
                                              onPressed: () {
                                                controller.updateTitleAndDescription(userId: StorageService.instance.fetch(AppUtils.userId), routineId: data["routineId"], title: controller.titleController.text, description: controller.descriptionController.text);
                                                //myTodoController.submitTodo,
                                              },
                                              child: const Text('Submit'),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ).whenComplete(() {
                                controller.titleController.clear();
                                controller.descriptionController.clear();
                              });
                            },
                          )
                        ],
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }
}
