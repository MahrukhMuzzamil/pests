import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pests247/shared/models/job/job_post.dart';

class JobBoardService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> createJob(JobPost job) async {
    await _firestore.collection('jobs').doc(job.id).set(job.toMap());
  }

  static Future<List<JobPost>> fetchJobsNearby({
    required double latitude,
    required double longitude,
    required double maxMiles,
  }) async {
    // Basic fetch; client filters by distance. For scalable geoqueries, add geohashes.
    final snapshot = await _firestore
        .collection('jobs')
        .orderBy('createdAt', descending: true)
        .limit(200)
        .get();

    return snapshot.docs
        .map((d) => JobPost.fromMap(d.data()))
        .toList();
  }
}


