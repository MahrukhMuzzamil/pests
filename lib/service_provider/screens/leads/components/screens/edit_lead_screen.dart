import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // Import this for Cupertino dialog
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pests247/client/widgets/custom_snackbar.dart';
import 'package:pests247/service_provider/controllers/leads/leads_controller.dart';
import '../../../../../client/controllers/user/user_controller.dart';
import 'lead_locations_screen.dart';

class EditLeadScreen extends StatelessWidget {
  const EditLeadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserController>();
    final leadController = Get.find<LeadsController>();
    final userLocations = userController.userModel.value?.leadLocations ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Lead'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Your Locations:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Get.to(() => const AddLocationOptionsScreen(),transition: Transition.cupertino);
                  },
                  child: const Text('+ Add a Location'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: userLocations.isNotEmpty
                  ? ListView.builder(
                itemCount: userLocations.length,
                itemBuilder: (context, index) {
                  final location = userLocations[index];
                  final miles = location['miles'];
                  final driveTime = location['driveTime'];
                  final city = location['location'] ?? 'Unknown city';
                  final locationId = location['id'];

                  // Choose what to display: Miles or Drive Time
                  String distanceInfo;
                  if (miles != null) {
                    distanceInfo = '$miles miles';
                  } else if (driveTime != null) {
                    distanceInfo = '$driveTime';
                  } else {
                    distanceInfo = 'Distance not available';
                  }

                  // Dismissible for swipe-to-delete
                  return Dismissible(
                    key: Key(locationId ?? index.toString()),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.redAccent,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                    confirmDismiss: (direction) async {
                      return await _showDeleteConfirmationDialog(context);
                    },
                    onDismissed: (direction) async {
                      await deleteLocationFromFirestore(
                          userController,leadController, locationId);
                      CustomSnackbar.showSnackBar(
                          'Location Deleted',
                          'Location deleted successfully',
                          const Icon(Icons.delete),
                          Colors.redAccent.withOpacity(.3),
                          context);
                    },
                    child: Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 5.0),
                      elevation: 2,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 10.0),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 30,
                              color: Colors.blueAccent,
                            ),
                            const SizedBox(width: 16),
                            // Text Row
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87),
                                  children: [
                                    const TextSpan(
                                      text: ' Within ',
                                    ),
                                    TextSpan(
                                      text: distanceInfo,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    if (distanceInfo.contains('hours'))
                                      const TextSpan(
                                        text: ' drive',
                                      ),
                                    const TextSpan(
                                      text: ' of ',
                                    ),
                                    TextSpan(
                                      text: city,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              )
                  : const Center(
                child: Text(
                  'No location set',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _showDeleteConfirmationDialog(BuildContext context) {
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      // iOS specific dialog
      return showCupertinoDialog<bool>(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: const Text('Confirm Deletion'),
            content: const Text('Are you sure you want to delete this location?'),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              CupertinoDialogAction(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Delete'),
              ),
            ],
          );
        },
      );
    } else {
      // Android specific dialog
      return showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Confirm Deletion'),
            content: const Text('Are you sure you want to delete this location?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Delete'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> deleteLocationFromFirestore(
      UserController userController, LeadsController leadController, String locationId) async {
    try {
      final userId = userController.userModel.value?.uid;
      if (userId == null) {
        print('User ID is null');
        return;
      }

      // Log user ID and location ID for debugging
      print('User ID: $userId, Location ID: $locationId');

      // Fetch current leadLocations before deletion for logging
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      print('Current leadLocations: ${userDoc.data()?['leadLocations']}');

      // Fetch the location to delete
      var locationToDelete = (userDoc.data()?['leadLocations'] as List).firstWhere(
            (location) => location['id'] == locationId,
        orElse: () => null,
      );

      if (locationToDelete == null) {
        print('Location not found for deletion.');
        return;
      }

      // Delete location by ID
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'leadLocations': FieldValue.arrayRemove([locationToDelete])
      });

      // Fetch updated leadLocations for confirmation
      final updatedUserDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      print('Updated leadLocations: ${updatedUserDoc.data()?['leadLocations']}');

      // Update local user model in GetX
      userController.userModel.update((user) {
        user?.leadLocations?.removeWhere((loc) => loc['id'] == locationId);
      });

      // Fetch leads to update UI
      await leadController.fetchFilteredLeads();

      print('Location successfully deleted.');
    } catch (e) {
      print('Error deleting location: $e');
      if (e is FirebaseException) {
        print('Firebase Error: ${e.message}');
      }
    }
  }


}
