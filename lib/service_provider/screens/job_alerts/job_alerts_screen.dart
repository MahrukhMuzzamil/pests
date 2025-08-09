import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pests247/service_provider/controllers/job_alerts/job_alerts_controller.dart';

class JobAlertsScreen extends StatelessWidget {
  const JobAlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(JobAlertsController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Alerts'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.jobs.isEmpty) {
          return const Center(child: Text('No job alerts nearby.'));
        }
        return ListView.separated(
          itemCount: controller.jobs.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final job = controller.jobs[index];
            return ListTile(
              title: Text(job.title),
              subtitle: Text(job.locationText),
              trailing: Text(
                job.createdAt.toLocal().toIso8601String().split('T').first,
                style: const TextStyle(fontSize: 12),
              ),
            );
          },
        );
      }),
    );
  }
}