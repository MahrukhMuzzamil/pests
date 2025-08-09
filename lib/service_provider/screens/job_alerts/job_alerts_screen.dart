import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pests247/service_provider/controllers/job_alerts_controller.dart';
import 'package:pests247/shared/models/job/job_post.dart';

class JobAlertsScreen extends StatefulWidget {
  final double providerLatitude;
  final double providerLongitude;
  final double radiusMiles;

  const JobAlertsScreen({
    super.key,
    required this.providerLatitude,
    required this.providerLongitude,
    this.radiusMiles = 100,
  });

  @override
  State<JobAlertsScreen> createState() => _JobAlertsScreenState();
}

class _JobAlertsScreenState extends State<JobAlertsScreen> {
  late final JobAlertsController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<JobAlertsController>()
        ? Get.find<JobAlertsController>()
        : Get.put(JobAlertsController());
    controller.fetchNearbyJobs(
      latitude: widget.providerLatitude,
      longitude: widget.providerLongitude,
      radiusMiles: widget.radiusMiles,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Job Alerts')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (widget.providerLatitude == 0 || widget.providerLongitude == 0) {
          return const Center(child: Text('Add your business location to see nearby jobs.'));
        }
        if (controller.jobs.isEmpty) {
          return const Center(child: Text('No nearby jobs'));
        }
        return RefreshIndicator(
          onRefresh: () async {
            await controller.fetchNearbyJobs(
              latitude: widget.providerLatitude,
              longitude: widget.providerLongitude,
              radiusMiles: widget.radiusMiles,
            );
          },
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: controller.jobs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final job = controller.jobs[index];
              return _JobTile(job: job);
            },
          ),
        );
      }),
    );
  }
}

class _JobTile extends StatelessWidget {
  final JobPost job;
  const _JobTile({required this.job});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              job.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            if ((job.city ?? '').isNotEmpty || (job.state ?? '').isNotEmpty)
              Text('${job.city ?? ''}${(job.city ?? '').isNotEmpty && (job.state ?? '').isNotEmpty ? ', ' : ''}${job.state ?? ''} ${job.postalCode}'),
            const SizedBox(height: 8),
            if (job.description.isNotEmpty)
              Text(job.description, maxLines: 3, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              children: [
                ...job.services.map((s) => Chip(label: Text(s))),
                ...job.pests.take(3).map((p) => Chip(label: Text(p))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


