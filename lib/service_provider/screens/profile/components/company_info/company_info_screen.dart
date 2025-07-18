import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pests247/client/controllers/user/user_controller.dart';
import 'package:pests247/client/widgets/custom_text_field.dart';
import '../../../../controllers/profile/company_info_controller.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Company Info',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
        ),
        actions: [
          Obx(() {
            return Container(
              height: 40,
              margin: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(.2),
                  borderRadius: const BorderRadius.all(Radius.circular(25))),
              child: TextButton(
                onPressed: companyInfoController.detectChanges
                    ? () {
                  companyInfoController.updateCompanyInfo();
                }
                    : null,
                child: Text(
                  'Save',
                  style: TextStyle(
                    color: companyInfoController.detectChanges
                        ? Colors.blue
                        : Colors.grey,
                    fontSize: 16,
                  ),
                ),
              ),
            );
          }),
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
                Center(
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.blue.withOpacity(.8),
                    child: (companyInfo?.logo == null || companyInfo!.logo!.isEmpty)
                        ? const Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.white,
                    )
                        : ClipOval(
                      child: Image.network(
                        companyInfo.logo!,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
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
                  final certs = companyInfo?.certifications ?? [];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (certs.isNotEmpty)
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: certs.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              leading: Icon(Icons.file_present, color: Colors.blue),
                              title: Text(certs[index], style: TextStyle(fontSize: 13, color: Colors.blue)),
                              trailing: IconButton(
                                icon: Icon(Icons.open_in_new),
                                onPressed: () {
                                  // TODO: Open file URL
                                },
                              ),
                            );
                          },
                        ),
                      TextButton.icon(
                        icon: Icon(Icons.upload_file),
                        label: Text('Upload Certification'),
                        onPressed: () {
                          // TODO: Implement file picker and upload logic
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
    );
  }
}
