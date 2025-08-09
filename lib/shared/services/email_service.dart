import 'package:cloud_functions/cloud_functions.dart';

class EmailService {
  static final HttpsCallable _sendJobAlertCallable =
      FirebaseFunctions.instance.httpsCallable('sendJobAlertEmails');

  static Future<void> sendJobAlertEmails({
    required String jobId,
  }) async {
    await _sendJobAlertCallable.call({
      'jobId': jobId,
    });
  }
}