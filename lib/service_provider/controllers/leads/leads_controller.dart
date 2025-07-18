import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../client/controllers/lead_question_form/geo_coding_service.dart';
import '../../../client/controllers/user/user_controller.dart';
import '../../../client/widgets/custom_snackbar.dart';
import '../../../shared/models/lead_model/lead_model.dart';
import '../../../shared/models/user/user_model.dart';
import '../../models/buyer/buyer_model.dart';

class LeadsController extends GetxController {
  var leads = <LeadModel>[].obs;
  var filteredLeads = <LeadModel>[].obs;
  var isLoading = true.obs;
  var userDetailsMap = <String, UserModel>{}.obs;
  var isSearching = false.obs;
  var suggestions = <Map<String, String>>[].obs;
  var errorMessage = ''.obs;
  var location = ''.obs;
  var selectedDistance = ''.obs;
  var selectedTime = ''.obs;
  var postalCodeController = TextEditingController();
  GeocodingService geocodingService = GeocodingService();
  final List<String> distances = [
    '5 miles',
    '50 miles',
    '100 miles',
    '150 miles',
    '200 miles'
  ];
  final List<String> time = [
    '0.5 hour',
    '1 hour',
    '1.5 hour',
    '2 hour',
    '2.5 hour',
    '3 hour',
  ];

  String apiKey = 'd8ac2514431e41f6b8cd50038c8c63b6';

  // Retrieve coordinates from a postal code
  Future<Map<String, double>> getCoordinatesFromPostalCode(String postalCode) async {
    String country;
    if (RegExp(r'^\d{5}(-\d{4})?$').hasMatch(postalCode)) {
      country = 'United States';
    } else if (RegExp(r'^[A-Za-z]\d[A-Za-z][ -]?\d[A-Za-z]\d$').hasMatch(postalCode)) {
      country = 'Canada';
    } else {
      throw Exception('Invalid postal code format');
    }

    final url = Uri.parse(
        'https://api.geoapify.com/v1/geocode/search?postcode=$postalCode&country=$country&format=json&apiKey=$apiKey'
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['results'] != null && data['results'].isNotEmpty) {
        final lat = data['results'][0]['lat'];
        final lon = data['results'][0]['lon'];
        return {'lat': lat, 'lon': lon};
      } else {
        throw Exception('No results found for postal code');
      }
    } else {
      throw Exception('Failed to fetch coordinates');
    }
  }


  // Calculate the distance between two sets of lat/lon coordinates in miles
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double milesConversionFactor = 3958.8;
    double toRadians(double degrees) => degrees * pi / 180;
    double deltaLat = toRadians(lat2 - lat1);
    double deltaLon = toRadians(lon2 - lon1);

    double a = sin(deltaLat / 2) * sin(deltaLat / 2) +
        cos(toRadians(lat1)) * cos(toRadians(lat2)) * sin(deltaLon / 2) * sin(deltaLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return milesConversionFactor * c;
  }

  var isSortedByNewest = true.obs; // Track sorting order

  // Add your fetchFilteredLeads function here...

  // Function to toggle sorting
  void toggleSorting() {
    isSortedByNewest.value = !isSortedByNewest.value; // Toggle sorting order
    sortFilteredLeads();
  }

  // Function to sort leads based on the current sorting state
  void sortFilteredLeads() {
    if (isSortedByNewest.value) {
      // Sort by newest first
      filteredLeads.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
    } else {
      // Sort by oldest first
      filteredLeads.sort((a, b) => a.submittedAt.compareTo(b.submittedAt));
    }
  }




  Future<void> fetchFilteredLeads() async {
    isLoading.value = true;
    try {
      final snapshot = await FirebaseFirestore.instance.collection('leads').get();

      if (snapshot.docs.isEmpty) {
        print("No leads found in Firestore.");
        return;
      }

      leads.value = snapshot.docs.map((doc) {
        print("Lead Document: ${doc.data()}");
        return LeadModel.fromMap(doc.data()!);
      }).where((lead) => lead.status != 'maxedOut').toList();

      print("Total leads fetched after filtering 'maxedOut': ${leads.length}");

      UserController userController = Get.find();
      UserModel user = userController.userModel.value!;
      print("Current user ID: ${userController.userModel.value!.uid}");

      leads.value = leads.where((lead) {
        bool isPurchased = lead.buyers.isNotEmpty &&
            lead.buyers.any((buyer) => buyer.userId == userController.userModel.value!.uid);
        print("Lead ${lead.leadId} purchased by user: $isPurchased");
        return !isPurchased;
      }).toList();

      print("Leads after filtering out purchased ones: ${leads.length}");

      if (user.leadLocations == null || user.leadLocations!.isEmpty) {
        filteredLeads.value = leads;
        sortFilteredLeads();
        return;
      }

      filteredLeads.value = [];

      for (var leadLocation in user.leadLocations!) {
        if (leadLocation['postalCode'] == null) continue;

        final leadSettingCoords = await getCoordinatesFromPostalCode(leadLocation['postalCode']);
        print("Lead location coordinates for ${leadLocation['postalCode']}: $leadSettingCoords");

        for (var lead in leads) {
          print("Inspecting lead: ${lead.toMap()}");

          var postalCode = _extractPostalCode(lead.location);
          final leadCoords = await getCoordinatesFromPostalCode(postalCode);
          final distance = calculateDistance(
              leadSettingCoords['lat']!, leadSettingCoords['lon']!,
              leadCoords['lat']!, leadCoords['lon']!
          );

          print("Distance from user location to lead ${lead.leadId}: $distance");

          bool matchesCriteria = false;

          if (leadLocation.containsKey('hours') && leadLocation['driveTime'] != null) {
            String maxTime = leadLocation['driveTime'];
            if (await withinDriveTime(leadSettingCoords, leadCoords, maxTime)) {
              matchesCriteria = true;
              print("Lead ${lead.leadId} matches time criteria.");
            }
          } else {
            double maxMiles = double.parse(leadLocation['miles']);
            if (distance <= maxMiles) {
              matchesCriteria = true;
              print("Lead ${lead.leadId} matches distance criteria.");
            }
          }

          if (matchesCriteria) {
            filteredLeads.add(lead);
            print("Adding lead ${lead.leadId} to filtered leads.");
          } else {
            print("Lead ${lead.leadId} does not match criteria.");
          }
        }
      }

      sortFilteredLeads();
      print("Filtered leads count: ${filteredLeads.length}");

    } catch (e) {
      print("Error filtering leads: $e");
    } finally {
      isLoading.value = false;
    }
  }


  Future<void> fetchAllLeads() async {
    isLoading.value = true;
    try {
      final snapshot = await FirebaseFirestore.instance.collection('leads').get();

      if (snapshot.docs.isEmpty) {
        print("No leads found in Firestore.");
        filteredLeads.clear(); // Clear if no leads found
        return;
      }

      // Map Firestore documents directly to LeadModel and update filteredLeads
      filteredLeads.value = snapshot.docs
          .map((doc) => LeadModel.fromMap(doc.data()!))
          .toList();

      print("Total leads fetched: ${filteredLeads.length}");
    } catch (e) {
      print("Error fetching all leads: $e");
    } finally {
      isLoading.value = false;
    }
  }





  String _extractPostalCode(String location) {
    return location.split(',')[0].trim();
  }

  // Helper function to check if the lead is within a specified drive time
  Future<bool> withinDriveTime(Map<String, double> origin, Map<String, double> destination, String maxDriveTime) async {
    // Construct the URL for the Geoapify API request
    final url = Uri.parse(
        'https://api.geoapify.com/v1/routing?waypoints=${origin['lat']},${origin['lon']}|${destination['lat']},${destination['lon']}&mode=drive&apiKey=$apiKey'
    );

    print("Fetching drive time from Geoapify API...");
    print("Request URL: $url");

    // Send the HTTP GET request
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      // Log the full response for debugging
      print("Response from Geoapify API: $data");

      final durationSeconds = data['features'][0]['properties']['time'];
      final maxTimeHours = int.parse(maxDriveTime.split(' ')[0]);

      // Calculate if within drive time
      bool isWithinDriveTime = (durationSeconds / 3600) <= maxTimeHours;

      // Log the calculated drive time and comparison
      print("Calculated drive time: ${durationSeconds / 60} minutes (max allowed: ${maxTimeHours} hours)");

      return isWithinDriveTime;
    } else {
      print("Error: Received status code ${response.statusCode}");
      throw Exception('Failed to fetch drive time');
    }
  }


  @override
  void onInit() {
    super.onInit();
    fetchFilteredLeads();
  }

  void clearSuggestions() {
    suggestions.clear();
    errorMessage.value = '';
  }

  void updateLocation(String selectedLocation) {
    location.value = selectedLocation;
  }

  Future<void> fetchUserDetailById(String userId) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (snapshot.exists) {
        userDetailsMap[userId] =
            UserModel.fromJson(snapshot.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print("Error fetching user details: $e");
    }
  }

  Future<void> fetchUserDetails() async {
    for (var lead in leads) {
      if (!userDetailsMap.containsKey(lead.userId)) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(lead.userId)
            .get();
        if (userDoc.exists) {
          userDetailsMap[lead.userId] = UserModel.fromJson(userDoc.data()!);
        }
      }
    }
  }

  void filterLeads(String query) {
    if (query.isEmpty) {
      filteredLeads.value = leads;
    } else {
      filteredLeads.value = leads.where((lead) {
        return lead.location.toLowerCase().contains(query.toLowerCase()) ||
            lead.name.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
  }


  Future<void> purchaseLead(LeadModel lead) async {
    final UserController userController = Get.find();
    num currentCredits = userController.userModel.value!.credits;

    if (lead.buyers.any((buyer) => buyer.userId == userController.userModel.value!.uid)) {
      CustomSnackbar.showSnackBar(
        "Info",
        "You have already purchased this lead.",
        const Icon(Icons.info, color: Colors.white),
        Colors.blue,
        Get.context!,
      );
      return;
    }

    if (lead.buyers.length >= 3) {
      await FirebaseFirestore.instance
          .collection('leads')
          .doc(lead.leadId)
          .update({
        'status': 'maxedOut',
      });

      CustomSnackbar.showSnackBar(
        "Info",
        "This lead has reached the maximum number of buyers.",
        const Icon(Icons.info, color: Colors.white),
        Colors.blue,
        Get.context!,
      );
      return;
    }

    if (currentCredits < 5) {
      CustomSnackbar.showSnackBar(
        "Error",
        "Not enough credits!",
        const Icon(Icons.error, color: Colors.white),
        Colors.red,
        Get.context!,
      );
      return;
    }

    currentCredits -= 5;

    final Buyer newBuyer = Buyer(
      userId: userController.userModel.value!.uid,
      status: 'pending',
    );

    lead.buyers.add(newBuyer);

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userController.userModel.value!.uid)
        .update({
      'credits': currentCredits,
      'leads': FieldValue.arrayUnion([lead.leadId]),
    });

    // Also update the lead in Firestore
    await FirebaseFirestore.instance
        .collection('leads')
        .doc(lead.leadId)
        .update({
      'buyers': FieldValue.arrayUnion([newBuyer.toMap()]),
      'status': lead.buyers.length >= 2 ? 'maxedOut' : lead.status,
    });

    // // Update local user model
    // userController.userModel.update((user) {
    //   user?.credits = currentCredits;
    //   if (user?.leads != null) {
    //     user?.leads?.add(lead.leadId);
    //   } else {
    //     user?.leads = [lead.leadId];
    //   }
    // });
    fetchFilteredLeads();
    CustomSnackbar.showSnackBar(
      "Success",
      "Lead contacted! 5 credits deducted.",
      Icon(Icons.check_circle,
          color: Theme.of(Get.context!).colorScheme.primary),
      Colors.green,
      Get.context!,
    );
  }



  String extractNumber(String input) {
    final RegExp numberRegEx = RegExp(r'\d+');
    final match = numberRegEx.firstMatch(input);
    return match != null ? match.group(0) ?? '' : '';
  }

  Future<void> saveLocation(String typeOfLocation) async {
    try {
      isLoading.value = true;
      String location = postalCodeController.text;
      String postalCode = _extractPostalCode(location);
      String city = _extractCity(location);
      String selectedMiles = extractNumber(selectedDistance.value);
      String selectedTimes = extractNumber(selectedTime.value);

      String id = _generateRandomId();
      String value = '';
      if(typeOfLocation == 'miles')
        {
          value = selectedMiles;


        }
      else
        {
          value = "$selectedTimes hours";
        }

      Map<String, dynamic> locationData = {
        'id': id,
        'location': city,
        'postalCode': postalCode,
        typeOfLocation: value,
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({
        'leadLocations': FieldValue.arrayUnion([locationData]),
      });
      UserController userController = Get.find<UserController>();
      LeadsController leadsController = Get.find<LeadsController>();
      await userController.fetchUser();
      leadsController.fetchFilteredLeads();
      update();
      isLoading.value = false;
      postalCodeController.clear();
      selectedDistance.value = '';
      selectedTime.value = '';
      CustomSnackbar.showSnackBar(
        "Success",
        "Location saved successfully!",
        Icon(Icons.check_circle,
            color: Theme.of(Get.context!).colorScheme.primary),
        Colors.green,
        Get.context!,
      );
    } catch (e) {
      CustomSnackbar.showSnackBar(
        "Error",
        "Failed to save location.",
        const Icon(Icons.info, color: Colors.white),
        Colors.blue,
        Get.context!,
      );
    }
  }

  // Function to extract city from location string
  String _extractCity(String location) {
    return location.split(',')[1].trim();
  }

  // Function to generate random ID
  String _generateRandomId() {
    var random = Random();
    const characters = 'abcdefghijklmnopqrstuvwxyz1234567890';
    return List.generate(
        8, (index) => characters[random.nextInt(characters.length)]).join();
  }

  void showDistancePicker(BuildContext context, LeadsController controller,
      List<String> distances) {
    if (Platform.isIOS) {
      showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          return CupertinoActionSheet(
            title: const Text("Select Distance"),
            actions: distances.map((distance) {
              return CupertinoActionSheetAction(
                onPressed: () {
                  controller.selectedDistance.value = distance;
                  Get.back();
                },
                child: Text(distance),
              );
            }).toList(),
            cancelButton: CupertinoActionSheetAction(
              onPressed: () {
                Get.back();
              },
              child: const Text('Cancel'),
            ),
          );
        },
      );
    } else {
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return ListView.builder(
            itemCount: distances.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(distances[index]),
                onTap: () {
                  controller.selectedDistance.value = distances[index];
                  Get.back();
                },
              );
            },
          );
        },
      );
    }
  }



  void showTimePicker(BuildContext context, LeadsController controller) {
    if (Platform.isIOS) {
      showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          return CupertinoActionSheet(
            title: const Text("Select Time"),
            actions: distances.map((distance) {
              return CupertinoActionSheetAction(
                onPressed: () {
                  controller.selectedTime.value = distance;
                  Get.back();
                },
                child: Text(distance),
              );
            }).toList(),
            cancelButton: CupertinoActionSheetAction(
              onPressed: () {
                Get.back();
              },
              child: const Text('Cancel'),
            ),
          );
        },
      );
    } else {
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return ListView.builder(
            itemCount: time.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(time[index]),
                onTap: () {
                  controller.selectedTime.value = time[index];
                  Get.back();
                },
              );
            },
          );
        },
      );
    }
  }
}
