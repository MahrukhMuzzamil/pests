import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pests247/client/controllers/user/user_controller.dart';
import 'package:pests247/service_provider/controllers/profile/company_info_controller.dart';
import 'package:pests247/client/widgets/custom_snackbar.dart';
import '../../../../../client/widgets/custom_icon_button.dart';
import 'package:pests247/client/widgets/custom_text_field.dart';
import '../widgets/profile_image_card.dart';
import 'dart:io';
import 'dart:ui';
import 'package:url_launcher/url_launcher.dart';

class CompanyInfoScreen extends StatelessWidget {
  const CompanyInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CompanyInfoController companyInfoController =
    Get.put(CompanyInfoController());
    final UserController userController = Get.find();

    var companyInfo = userController.userModel.value?.companyInfo;

    companyInfoController.setCompanyInfo(
      companyInfo?.name ?? '',
      companyInfo?.emailAddress ?? '',
      companyInfo?.phoneNumber ?? '',
      companyInfo?.website ?? '',
      companyInfo?.location ?? '',
      companyInfo?.size ?? '',
      companyInfo?.experience ?? '',
      companyInfo?.description ?? '',
    );

    final TextEditingController gigDescriptionController = TextEditingController(text: companyInfo?.gigDescription ?? '');

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Company Info'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: CustomIconButton(
              onTap: () async {
                if (companyInfoController.detectChanges) {
                  await companyInfoController.updateCompanyInfo();
                } else {
                  CustomSnackbar.showSnackBar(
                    'Info',
                    'No changes detected.',
                    const Icon(Icons.info, color: Colors.blue),
                    Colors.blue,
                    context,
                  );
                }
              },
              icon: Icons.check,
              color: Colors.blue.withOpacity(0.14),
            ),
          )
        ],
      ),
      body: Obx(() {
        return companyInfoController.isLoading.value
            ? const Center(
          child: CircularProgressIndicator(strokeWidth: 6),
        )
            : Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26.0, vertical: 20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Approval Status Card
                if (companyInfo?.status != null)
                  Card(
                    color: companyInfo?.status == 'approved'
                        ? Colors.green.shade100
                        : companyInfo?.status == 'rejected'
                        ? Colors.red.shade100
                        : Colors.yellow.shade100,
                    child: ListTile(
                      leading: Icon(
                        companyInfo?.status == 'approved'
                            ? Icons.check_circle
                            : companyInfo?.status == 'rejected'
                            ? Icons.cancel
                            : Icons.hourglass_empty,
                        color: companyInfo?.status == 'approved'
                            ? Colors.green
                            : companyInfo?.status == 'rejected'
                            ? Colors.red
                            : Colors.orange,
                      ),
                      title: Text(
                        'Status: ${companyInfo?.status?.capitalizeFirst ?? 'Pending'}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: companyInfo?.status == 'rejected'
                          ? Text('Reason: ${companyInfo?.rejectionComment ?? 'No reason provided.'}')
                          : null,
                    ),
                  ),
                const SizedBox(height: 20),
                
                // Fiverr-style business gig card
                BusinessGigCard(
                  businessName: companyInfo?.name ?? '',
                  gigDescription: companyInfo?.gigDescription ?? '',
                  gigImage: companyInfo?.gigImage ?? '',
                  isVerified: companyInfo?.isVerified ?? false,
                ),
                const SizedBox(height: 30),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'This name will be shown to users or leads for identification.',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 10),

                buildTextField(
                  controller: companyInfoController.companyNameController,
                  onChanged: (value) {
                    companyInfoController.companyName.value = value;
                  },
                  labelText: '',
                  prefixIcon: Icons.business,
                ),
                const SizedBox(height: 30),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Your email will be used for contact and notifications.',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 10),

                buildTextField(
                  controller: companyInfoController.emailController,
                  onChanged: (value) {
                    companyInfoController.email.value = value;
                  },
                  labelText: '',
                  prefixIcon: Icons.email,
                ),
                const SizedBox(height: 30),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Your contact number will be used for notifications and communication.',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 10),

                buildTextField(
                  controller: companyInfoController.phoneController,
                  onChanged: (value) {
                    companyInfoController.phoneNumber.value = value;
                  },
                  keyboardType: TextInputType.number,
                  labelText: '',
                  prefixIcon: Icons.phone,
                ),
                const SizedBox(height: 30),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Website URL for your company.',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 10),

                buildTextField(
                  controller: companyInfoController.websiteController,
                  onChanged: (value) {
                    companyInfoController.website.value = value;
                  },
                  labelText: '',
                  prefixIcon: Icons.web,
                ),
                // const SizedBox(height: 30),

                // const Align(
                //   alignment: Alignment.centerLeft,
                //   child: Text(
                //     'Company location or office address.',
                //     style: TextStyle(fontSize: 14, color: Colors.grey),
                //   ),
                // ),
                // const SizedBox(height: 10),

                // Obx(() {
                //   return Column(
                //     children: [
                //       buildTextField(
                //         controller: companyInfoController.locationController,
                //         onChanged: (value) {
                //           companyInfoController.location.value = value;
                //           companyInfoController.searchLocations(value);
                //         },
                //         labelText: '',
                //         prefixIcon: Icons.location_on,
                //       ),
                //       if (companyInfoController.locationSuggestions.isNotEmpty)
                //         ListView.builder(
                //           shrinkWrap: true,
                //           itemCount: companyInfoController.locationSuggestions.length,
                //           itemBuilder: (context, index) {
                //             return Card(
                //               color: Colors.white,
                //               child: ListTile(
                //                 title: Text(companyInfoController.locationSuggestions[index]),
                //                 onTap: () {
                //                   companyInfoController.location.value = companyInfoController.locationSuggestions[index];
                //                   companyInfoController.locationController.text = companyInfoController.locationSuggestions[index];
                //                   companyInfoController.locationSuggestions.clear(); // Clear suggestions after selection
                //                 },
                //               ),
                //             );
                //           },
                //         ),
                //     ],
                //   );
                // }),

                // const SizedBox(height: 30),

                // const Align(
                //   alignment: Alignment.centerLeft,
                //   child: Text(
                //     'Company size in terms of employees or office size.',
                //     style: TextStyle(fontSize: 14, color: Colors.grey),
                //   ),
                // ),
                // const SizedBox(height: 10),
                //
                // buildTextField(
                //   controller: companyInfoController.sizeController,
                //   onChanged: (value) {
                //     companyInfoController.size.value = value;
                //   },
                //   labelText: '',
                //   prefixIcon: Icons.apartment,
                // ),
                // const SizedBox(height: 30),
                //
                // const Align(
                //   alignment: Alignment.centerLeft,
                //   child: Text(
                //     'Company experience or years in the industry.',
                //     style: TextStyle(fontSize: 14, color: Colors.grey),
                //   ),
                // ),
                // const SizedBox(height: 10),
                //
                // buildTextField(
                //   controller: companyInfoController.experienceController,
                //   onChanged: (value) {
                //     companyInfoController.experience.value = value;
                //   },
                //   labelText: '',
                //   prefixIcon: Icons.business_center,
                // ),
                const SizedBox(height: 30),

                // Gig Description
                // const Align(
                //   alignment: Alignment.centerLeft,
                //   child: Text(
                //     'Describe your business gig/listing.',
                //     style: TextStyle(fontSize: 14, color: Colors.grey),
                //   ),
                // ),
                // const SizedBox(height: 10),
                // TextField(
                //   controller: gigDescriptionController,
                //   onChanged: (value) {
                //     companyInfoController.gigDescription.value = value;
                //   },
                //   minLines: 2,
                //   maxLines: 4,
                //   decoration: const InputDecoration(
                //     border: OutlineInputBorder(),
                //     prefixIcon: Icon(Icons.description),
                //     hintText: 'Enter gig description',
                //   ),
                // ),
                const SizedBox(height: 20),

                // Gig Image Upload
                // Row(
                //   children: [
                //     companyInfoController.gigImage.value.isNotEmpty
                //         ? ClipRRect(
                //             borderRadius: BorderRadius.circular(8),
                //             child: Image.network(
                //               companyInfoController.gigImage.value,
                //               width: 60,
                //               height: 60,
                //               fit: BoxFit.cover,
                //             ),
                //           )
                //         : const Icon(Icons.image, size: 60, color: Colors.grey),
                //     const SizedBox(width: 16),
                //     ElevatedButton.icon(
                //       icon: const Icon(Icons.upload_file),
                //       label: const Text('Upload Gig Image'),
                //       onPressed: () async {
                //         await companyInfoController.pickAndUploadGigImage();
                //       },
                //     ),
                //   ],
                // ),

                const SizedBox(height: 40),
                Obx(() {
                  return companyInfoController.isLoading.value
                      ? const Center(
                        child: CircularProgressIndicator(strokeWidth: 6),
                      )
                      : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 26.0, vertical: 20),
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              // Fiverr-style business gig card
                              BusinessGigCard(
                                businessName: companyInfo?.name ?? '',
                                gigDescription: companyInfo?.gigDescription ?? '',
                                gigImage: companyInfo?.gigImage ?? '',
                                isVerified: companyInfo?.isVerified ?? false,
                              ),
                              const SizedBox(height: 30),

                              const Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Brief description of your company.',
                                  style: TextStyle(fontSize: 14, color: Colors.grey),
                                ),
                              ),
                              const SizedBox(height: 10),

                              buildTextField(
                                minLines: 7,
                                controller: companyInfoController.descriptionController,
                                onChanged: (value) {
                                  companyInfoController.description.value = value;
                                },
                                labelText: '',
                                prefixIcon: Icons.description,
                              ),
                              const SizedBox(height: 30),

                              // Certification Upload Section
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Upload your business certifications (PDF, image, etc.)',
                                  style: TextStyle(fontSize: 14, color: Colors.grey[700], fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Obx(() {
                                final certs = companyInfoController.certifications;
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (certs.isNotEmpty)
                                      SizedBox(
                                        height: 120, // Adjust as needed
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          physics: const NeverScrollableScrollPhysics(),
                                          itemCount: certs.length,
                                          itemBuilder: (context, index) {
                                            return ListTile(
                                              leading: const Icon(Icons.file_present, color: Colors.blue),
                                              title: Text('Certification  ${index + 1}', style: const TextStyle(fontSize: 13, color: Colors.blue)),
                                              onTap: () {
                                                launchUrl(Uri.parse(certs[index]));
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                    TextButton.icon(
                                      icon: const Icon(Icons.upload_file),
                                      label: const Text('Upload Certification'),
                                      onPressed: () async {
                                        await companyInfoController.pickAndUploadCertification();
                                      },
                                    ),
                                  ],
                                );
                              }),
                              const SizedBox(height: 50),
                            ],
                          ),
                        ),
                      );
                }),
              ],
            ),
          ),
        );
      }),
    );
  }
}
