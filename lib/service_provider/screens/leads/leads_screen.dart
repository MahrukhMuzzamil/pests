import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pests247/client/controllers/user/user_controller.dart';
import 'package:pests247/client/widgets/custom_button.dart';
import 'package:pests247/service_provider/controllers/leads/purchased_leads_controller.dart';
import '../../../services/notification_services.dart';
import '../../../shared/controllers/app/app_controller.dart';
import '../../controllers/leads/leads_controller.dart';
import 'components/screens/edit_lead_screen.dart';
import 'components/widgets/build_lead_card.dart';

class LeadsScreen extends StatefulWidget {
  const LeadsScreen({super.key});

  @override
  State<LeadsScreen> createState() => _LeadsScreenState();
}

class _LeadsScreenState extends State<LeadsScreen> {
  bool isLoggedIn = false;
  final leadsController = Get.put(LeadsController());
  final purchaseLeadController = Get.put(PurchasedLeadsController());
  final userController = Get.put(UserController());

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    NotificationsServices.requestNotificationPermission();
    userController.fetchUser();
  }

  void _checkLoginStatus() async {
    bool status = await AppController.checkLoginStatus();
    setState(() {
      isLoggedIn = status;
    });

    if (isLoggedIn) {
      purchaseLeadController.fetchPurchasedLeads();
      leadsController.fetchFilteredLeads();
    }
    else{
      leadsController.fetchAllLeads();
    }
  }

  @override
  Widget build(BuildContext context) {
    UserController userController = Get.put(UserController());

    return Scaffold(
      appBar: AppBar(
        title: Obx(() => userController.userModel.value == null
            ? const SizedBox()
            : Text(
          'Hi, ${userController.userModel.value?.userName ?? ''}',
          style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18),
        )),
        elevation: 0,
        leadingWidth: 80,
        leading: GestureDetector(
          child: const CircleAvatar(
            child: Icon(CupertinoIcons.person, size: 33),
          ),
        ),
      ),
      body: Column(
        children: [
          // Row for Filter and Edit buttons with text
          Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Filter Button
                GestureDetector(
                  onTap: () {
                    leadsController.toggleSorting();
                  },
                  child: Obx(() {
                    return Row(
                      children: [
                        const SizedBox(width: 5),
                        const Icon(
                          Icons.filter_list,
                          color: Colors.blue,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          leadsController.isSortedByNewest.value
                              ? 'Newest'
                              : 'Oldest',
                          style:
                          const TextStyle(fontSize: 16, color: Colors.blue),
                        ),
                      ],
                    );
                  }),
                ),
                // Edit Button
                userController.userModel.value == null
                    ? const SizedBox()
                    : Row(
                  children: [
                    SizedBox(
                      height: 40,
                      width: 105,
                      child: CustomButton(
                        borderRadius: 10,
                        icon: Icons.edit,
                        iconSize: 20,
                        textStyle: const TextStyle(
                            fontSize: 14, color: Colors.white),
                        text: 'Edit',
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(.9),
                        onPressed: () {
                          if (isLoggedIn) {
                            Get.to(() => const EditLeadScreen(),
                                transition: Transition.cupertino);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                Text('Please login to edit leads.'),
                              ),
                            );
                          }
                        },
                        isLoading: false,
                        tag: '',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (leadsController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (leadsController.filteredLeads.isEmpty) {
                return const Center(child: Text('No leads available.'));
              }

              return RefreshIndicator(
                onRefresh: leadsController.fetchFilteredLeads,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: leadsController.filteredLeads.length,
                  itemBuilder: (context, index) {
                    final lead = leadsController.filteredLeads[index];
                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.scale(
                              scale: 0.98 + 0.02 * value,
                              child: Transform.translate(
                                offset: Offset(0, (1 - value) * 10),
                                child: child,
                              )),
                        );
                      },
                      child: LeadCard(
                        lead: lead,
                        isLoggedIn: isLoggedIn,
                        isShown: false,
                        status: '',
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
