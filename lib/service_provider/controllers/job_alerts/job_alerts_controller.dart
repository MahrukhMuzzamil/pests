import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:pests247/shared/models/job/job_model.dart';
import 'package:pests247/shared/utils/distance_utils.dart';

import '../../../client/controllers/user/user_controller.dart';

class JobAlertsController extends GetxController {
  final RxList<JobModel> jobs = <JobModel>[].obs;
  final RxBool isLoading = false.obs;

  Future<void> fetchNearbyJobs({double miles = 100}) async {
    isLoading.value = true;
    try {
      final userController = Get.find<UserController>();
      final user = userController.userModel.value;
      if (user == null || user.latitude == null || user.longitude == null) {
        jobs.clear();
        return;
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('jobs')
          .where('status', isEqualTo: 'open')
          .orderBy('createdAt', descending: true)
          .limit(200)
          .get();

      final List<JobModel> allJobs = snapshot.docs
          .map((doc) => JobModel.fromMap(doc.data()))
          .toList();

      final List<JobModel> nearby = allJobs.where((job) {
        return isWithinMilesRadius(
          sourceLat: user.latitude!,
          sourceLon: user.longitude!,
          targetLat: job.latitude,
          targetLon: job.longitude,
          maxMiles: miles,
        );
      }).toList();

      jobs.assignAll(nearby);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchNearbyJobs();
  }
}