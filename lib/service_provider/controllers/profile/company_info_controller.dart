import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pests247/client/widgets/custom_snackbar.dart';
import 'package:http/http.dart' as http;
import '../../../client/controllers/user/user_controller.dart';
import '../../../data/keys.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

class CompanyInfoController extends GetxController {
  var companyName = ''.obs;
  var email = ''.obs;
  var phoneNumber = ''.obs;
  var website = ''.obs;
  var location = ''.obs;
  var size = ''.obs;
  var experience = ''.obs;
  var description = ''.obs;
  var isLoading = false.obs;
  var isChanged = false.obs;
  var locationSuggestions = <String>[].obs;
  var gigDescription = ''.obs;
  var gigImage = ''.obs;
  var certifications = <String>[].obs;


  late TextEditingController companyNameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController websiteController;
  late TextEditingController locationController;
  late TextEditingController sizeController;
  late TextEditingController experienceController;
  late TextEditingController descriptionController;

  @override
  void onInit() {
    super.onInit();
    companyNameController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    websiteController = TextEditingController();
    locationController = TextEditingController();
    sizeController = TextEditingController();
    experienceController = TextEditingController();
    descriptionController = TextEditingController();
  }

  void setCompanyInfo(String name, String email, String phone, String website,
      String location, String size, String experience, String description, {
      String gigDesc = '', String gigImg = '', List<String>? certs}) {
    companyNameController.text = name;
    emailController.text = email;
    phoneController.text = phone;
    websiteController.text = website;
    locationController.text = location;
    sizeController.text = size;
    experienceController.text = experience;
    descriptionController.text = description;
    gigDescription.value = gigDesc;
    gigImage.value = gigImg;
    certifications.value = certs ?? [];

    companyName.value = name;
    this.email.value = email;
    phoneNumber.value = phone;
    this.website.value = website;
    this.location.value = location;
    this.size.value = size;
    this.experience.value = experience;
    this.description.value = description;

    isChanged.value = false;
  }

  bool get detectChanges {
    UserController userController = Get.find();

    var companyInfo = userController.userModel.value?.companyInfo;

    return companyName.value != (companyInfo?.name ?? '') ||
        email.value != (companyInfo?.emailAddress ?? '') ||
        phoneNumber.value != (companyInfo?.phoneNumber ?? '') ||
        website.value != (companyInfo?.website ?? '') ||
        location.value != (companyInfo?.location ?? '') ||
        size.value != (companyInfo?.size ?? '') ||
        experience.value != (companyInfo?.experience ?? '') ||
        description.value != (companyInfo?.description ?? '') ||
        gigDescription.value != (companyInfo?.gigDescription ?? '') ||
        gigImage.value != (companyInfo?.gigImage ?? '') ||
        !listEquals(certifications, companyInfo?.certifications ?? []);
  }



  final String geoapifyApiUrl = 'https://api.geoapify.com/v1/geocode/search';

  // Function to search locations using Geoapify API
  Future<void> searchLocations(String query) async {
    if (query.isEmpty) {
      locationSuggestions.clear();
      return;
    }

    const boundingBox = 'min_lon=-140.0&min_lat=24.396308&max_lon=-66.93457&max_lat=49.384358';

    final url = Uri.parse(
        '$geoapifyApiUrl?text=$query&apiKey=${Keys.geoApifyKey}&$boundingBox'
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final List<String> suggestions = [];
        for (var result in data['features']) {
          suggestions.add(result['properties']['formatted']);
        }

        locationSuggestions.assignAll(suggestions);
      } else {
        throw Exception('Failed to load location suggestions');
      }
    } catch (e) {
      print('Error fetching location data: $e');
    }
  }

  // For gig image upload
  Future<void> pickAndUploadGigImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.image);
      if (result != null && result.files.single.path != null) {
        final file = result.files.single;
        final filePath = file.path!;
        final fileBytes = await File(filePath).readAsBytes();
        final ref = FirebaseStorage.instance.ref().child('gig_images/${file.name}');
        await ref.putData(fileBytes);
        final url = await ref.getDownloadURL();
        gigImage.value = url;
      }
    } catch (e) {
      print('Error uploading gig image: $e');
      CustomSnackbar.showSnackBar(
        'Error',
        'Failed to upload gig image. Please try again.',
        const Icon(Icons.error, color: Colors.red),
        Colors.red,
        Get.context!,
      );
    }
  }

  // For certification upload (allow images and pdf)
  Future<void> pickAndUploadCertification() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );
      if (result != null && result.files.single.path != null) {
        final file = result.files.single;
        final filePath = file.path!;
        final fileBytes = await File(filePath).readAsBytes();
        final ref = FirebaseStorage.instance.ref().child('certifications/${file.name}');
        await ref.putData(fileBytes);
        final url = await ref.getDownloadURL();
        certifications.value = [...certifications, url];
      }
    } catch (e) {
      print('Error uploading certification: $e');
      CustomSnackbar.showSnackBar(
        'Error',
        'Failed to upload certification. Please try again.',
        const Icon(Icons.error, color: Colors.red),
        Colors.red,
        Get.context!,
      );
    }
  }

  Future<void> updateCompanyInfo() async {
    // Restrict to one gig per business (enforced by only allowing one companyInfo per user)
    if (!detectChanges) {
      CustomSnackbar.showSnackBar(
        'No Changes',
        'No changes were made to the company profile.',
        const Icon(Icons.warning, color: Colors.orange),
        Colors.orange,
        Get.context!,
      );
      return;
    }
    isLoading.value = true;
    try {
      UserController userController = Get.find();
      String userId = userController.userModel.value!.uid;
      Map<String, dynamic> companyInfo = {
        'name': companyName.value,
        'emailAddress': email.value,
        'phoneNumber': phoneNumber.value,
        'website': website.value,
        'location': location.value,
        'size': size.value,
        'experience': experience.value,
        'description': description.value,
        'logo': '',
        'gigDescription': gigDescription.value,
        'gigImage': gigImage.value,
        'certifications': certifications,
        'status': 'pending', // Set status to pending on update
        'rejectionComment': null, // Clear rejection comment on update
      };
      DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(userId);
      await userRef.update({
        'companyInfo': companyInfo,
      });
      await userController.fetchUser();
      setCompanyInfo(
        companyName.value,
        email.value,
        phoneNumber.value,
        website.value,
        location.value,
        size.value,
        experience.value,
        description.value,
        gigDesc: gigDescription.value,
        gigImg: gigImage.value,
        certs: certifications,
      );
      isLoading.value = false;
      CustomSnackbar.showSnackBar(
        'Success',
        'Company profile updated successfully.',
        const Icon(Icons.check, color: Colors.green),
        Colors.green,
        Get.context!,
      );
    } catch (e) {
      isLoading.value = false;
      CustomSnackbar.showSnackBar(
        'Error',
        'Failed to update company profile. Please try again.',
        const Icon(Icons.error, color: Colors.red),
        Colors.red,
        Get.context!,
      );
    }
  }

  @override
  void onClose() {
    companyNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    websiteController.dispose();
    locationController.dispose();
    sizeController.dispose();
    experienceController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}
