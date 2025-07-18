import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';

import '../../../../../client/widgets/custom_button.dart';
import '../../../../../client/widgets/custom_snackbar.dart';
import '../../../../../client/widgets/custom_text_field.dart';
import '../../../../controllers/leads/leads_controller.dart';

class TravelTimeEntryScreen extends StatelessWidget {
  const TravelTimeEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final LeadsController controller = Get.put(LeadsController());

    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Enter the info about your location",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 40),
                  // Text field for postal code input
                  buildTextField(
                    controller: controller.postalCodeController,
                    onChanged: (value) async {
                      if (value.isNotEmpty &&
                          _isValidPostalCode(value.trim())) {
                        controller.isSearching.value = true;
                        controller.suggestions.clear();
                        controller.errorMessage.value = '';

                        try {
                          List<Map<String, String>> locations = await controller
                              .geocodingService
                              .getCityAndCountry(value.trim(),
                                  units: 'degrees');
                          controller.suggestions.value = locations;

                          if (locations.isNotEmpty) {
                            controller.errorMessage.value = '';
                          } else {
                            controller.errorMessage.value =
                                'No results found for postal code "$value".';
                          }
                        } catch (e) {
                          controller.errorMessage.value = e.toString();
                        } finally {
                          controller.isSearching.value = false;
                        }
                      } else {
                        controller.suggestions.clear();
                        controller.errorMessage.value = '';
                      }
                    },
                    labelText: 'Enter Postal Code',
                    prefixIcon: Icons.post_add,
                  ),
                  const SizedBox(height: 25),
                  Obx(
                    () => buildTextField(
                      isReadOnly: true,
                      controller: TextEditingController(
                          text: controller.selectedTime.value),
                      onTap: () =>
                          controller.showTimePicker(context, controller),
                      labelText: "Select travel time",
                      prefixIcon: IconlyBold.location,
                    ),
                  ),
                  const SizedBox(height: 25),
                  Obx(() {
                    if (controller.isSearching.value) {
                      return const Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(
                          child: SizedBox(
                            height: 27,
                            width: 27,
                            child: CircularProgressIndicator(strokeWidth: 6),
                          ),
                        ),
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
                              locationInfo =
                                  '${suggestion['city']}, ${suggestion['country']}';
                            } else {
                              locationInfo =
                                  '${suggestion['city']}, ${suggestion['state']}';
                            }

                            return ListTile(
                              title: Text(locationInfo),
                              subtitle: Text(
                                  'Postal Code: ${suggestion['postalCode']}'),
                              onTap: () {
                                String selectedLocation =
                                    "${suggestion['postalCode']}, ${suggestion['city']}, ${suggestion['state'] ?? suggestion['country']}";
                                controller.updateLocation(selectedLocation);

                                controller.postalCodeController.text =
                                    selectedLocation;
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
                  const SizedBox(height: 24),
                ],
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 100, horizontal: 20),
                child: Obx(
                  () => CustomButton(
                    textStyle:
                        const TextStyle(fontSize: 16, color: Colors.white),
                    height: 45,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    onPressed: () => {
                      if (controller.location.value.isNotEmpty &&
                          controller.selectedTime.value.isNotEmpty)
                        {controller.saveLocation('driveTime')}
                      else
                        {
                          CustomSnackbar.showSnackBar(
                            "Error",
                            "Fill all the details correctly",
                            const Icon(Icons.info, color: Colors.white),
                            Colors.blue,
                            Get.context!,
                          )
                        }
                    },
                    text: 'Add Location',
                    isLoading: controller.isLoading.value,
                    tag: '',
                  ),
                ),
              ),
            ]),
      ),
    );
  }
}

// Helper function to validate postal code
bool _isValidPostalCode(String postalCode) {
  final usPostalCodeRegEx = RegExp(r'^\d{5}(-\d{4})?$');
  final canadaPostalCodeRegEx = RegExp(r'^[A-Za-z]\d[A-Za-z] ?\d[A-Za-z]\d$');

  return usPostalCodeRegEx.hasMatch(postalCode) ||
      canadaPostalCodeRegEx.hasMatch(postalCode);
}
