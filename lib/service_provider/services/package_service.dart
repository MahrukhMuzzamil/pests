import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pests247/shared/models/package/package.dart';

class PackageService {
  final CollectionReference _packageCollection =
      FirebaseFirestore.instance.collection('creditsPackages');

  Stream<List<Package>> getPackagesStream() {
    return _packageCollection.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Package.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList());
  }
} 