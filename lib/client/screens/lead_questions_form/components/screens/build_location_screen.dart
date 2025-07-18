import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pests247/client/models/others/request.dart';

import 'package:pests247/client/controllers/lead_question_form/lead_question_form_controller.dart';
import 'package:pests247/client/widgets/custom_text_field.dart';


import '../widgets/build_page_widget.dart';


Widget buildLocationScreen(LeadsFormController controller) {
  return buildPage(
    title: 'Where do you need the pest control service?',
    child: Column(
      children: [
        buildTextField(
          controller: controller.postalCodeController,
          onChanged: (value) async {
            if (value.isNotEmpty && _isValidPostalCode(value.trim())) {
              controller.isSearching.value = true;
              controller.suggestions.clear();
              controller.errorMessage.value = 'Not Found';

              try {
                List<Map<String, String>> locations = await controller.geocodingService.getCityAndCountry(value.trim(), units: 'degrees');
                controller.suggestions.value = locations;

                if (locations.isNotEmpty) {
                  controller.errorMessage.value = '';
                } else {
                  controller.errorMessage.value = 'No results found for postal code "$value".';
                }
              } catch (e) {
                controller.errorMessage.value = 'Not Found';
              } finally {
                controller.isSearching.value = false;
              }
            } else {
              controller.suggestions.clear();
              controller.errorMessage.value = '';
            }
          }, labelText: 'Enter Postal Code', prefixIcon: Icons.post_add,
        ),
        const SizedBox(height: 16),
        Obx(() {
          if (controller.isSearching.value) {
            return const Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                  child: SizedBox(
                    height: 27,
                    width: 27,
                    child: CircularProgressIndicator(strokeWidth: 6),
                  )),
            );
          }

          if (controller.suggestions.isNotEmpty) {
            return Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.suggestions.length,
                itemBuilder: (context, index) {
                  final suggestion = controller.suggestions[index];
                  String locationInfo;

                  if (suggestion.containsKey('country')) {
                    locationInfo = '${suggestion['city']}, ${suggestion['country']}'; // US
                  } else {
                    locationInfo = '${suggestion['city']}, ${suggestion['state']}'; // Canada
                  }

                  return ListTile(
                    title: Text(locationInfo),
                    subtitle: Text('Postal Code: ${suggestion['postalCode']}'),
                    onTap: () {
                      String selectedLocation = "${suggestion['postalCode']}, ${suggestion['city']}, ${suggestion['state'] ?? suggestion['country']}"; // Updated
                      controller.updateLocation(selectedLocation);

                      controller.postalCodeController.text = selectedLocation;
                      controller.suggestions.clear();
                      controller.errorMessage.value = '';
                    },
                  );
                },
              ),
            );
          } else if (controller.errorMessage.isNotEmpty) {
            return Text(
              controller.errorMessage.value,
              style: const TextStyle(color: Colors.red),
            );
          } else {
            return const SizedBox();
          }
        }),
      ],
    ),
  );
}

bool _isValidPostalCode(String postalCode) {
  final usPostalCodeRegEx = RegExp(r'^\d{5}(-\d{4})?$');
  final canadaPostalCodeRegEx = RegExp(r'^[A-Za-z]\d[A-Za-z] ?\d[A-Za-z]\d$');

  return usPostalCodeRegEx.hasMatch(postalCode) || canadaPostalCodeRegEx.hasMatch(postalCode);
}
