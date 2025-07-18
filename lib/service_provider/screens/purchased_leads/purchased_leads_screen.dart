import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pests247/service_provider/controllers/leads/purchased_leads_controller.dart';
import '../lead_details/lead_details_screen.dart';
import '../leads/components/widgets/build_lead_card.dart';

class PurchasedLeadsScreen extends StatelessWidget {
  const PurchasedLeadsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final PurchasedLeadsController leadsController = Get.put(PurchasedLeadsController());

    Color getColorForStatus(String status) {
      switch (status) {
        case 'completed':
          return Colors.green;
        case 'pending':
          return Colors.grey;
        case 'hired':
          return Colors.indigo;
        default: // all
          return Colors.indigo;
      }
    }

    String getStatusWithCount(String status) {
      int count = 0;

      if (status == 'all') {
        count = leadsController.filteredLeads.length; // Total leads
      } else {
        count = leadsController.filteredLeads.where((lead) {
          final currentUserId = FirebaseAuth.instance.currentUser!.uid;
          final buyer = lead.buyers.firstWhere(
                (buyer) => buyer.userId == currentUserId,
            orElse: null,
          );
          return buyer.status == status;
        }).length;
      }
      return '$status ($count)';
    }

    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            // Row for Filter and Status Dropdown button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                            size: 25,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            leadsController.isSortedByNewest.value
                                ? 'Newest'
                                : 'Oldest',
                            style: const TextStyle(
                                fontSize: 17, color: Colors.blue),
                          ),
                        ],
                      );
                    }),
                  ),
                  // Status Dropdown
                  Obx(() {
                    final currentColor = getColorForStatus(leadsController.selectedStatus.value);
                    return Container(
                      height: 45,
                      padding: const EdgeInsets.symmetric(horizontal: 1),
                      decoration: BoxDecoration(
                        color: currentColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DropdownButton<String>(
                        underline: const SizedBox(),
                        icon: const Icon(Icons.arrow_drop_down,
                            color: Colors.white),
                        dropdownColor: Colors.white,
                        value: leadsController.selectedStatus.value,
                        items: <String>[
                          'all',
                          'pending',
                          'hired',
                          'completed'
                        ].map<DropdownMenuItem<String>>((String value) {
                          Icon icon;
                          Color color = getColorForStatus(value);

                          switch (value) {
                            case 'completed':
                              icon = const Icon(Icons.check_circle, color: Colors.white,size: 19,);
                              break;
                            case 'pending':
                              icon = const Icon(Icons.circle, color: Colors.red,size: 19,);
                              break;
                            case 'hired':
                              icon = const Icon(Icons.check, color: Colors.white,size: 19,);
                              break;
                            default: // all
                              icon = const Icon(Icons.list, color: Colors.white,size: 19,);
                              break;
                          }

                          return DropdownMenuItem<String>(
                            value: value,
                            child: Container(
                              color: color,
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
                              child: Row(
                                children: [
                                  icon,
                                  const SizedBox(width: 10),
                                  // Display the status with count
                                  Text(getStatusWithCount(value).toUpperCase(), style: const TextStyle(fontSize: 14,color: Colors.white)),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            leadsController.selectedStatus.value = newValue;
                            leadsController.filterLeadsByStatus(newValue);
                          }
                        },
                      ),
                    );
                  })
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
                  onRefresh: leadsController.fetchPurchasedLeads,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: leadsController.filteredLeads.length,
                    itemBuilder: (context, index) {
                      final lead = leadsController.filteredLeads[index];
                      final currentUserId = FirebaseAuth.instance.currentUser!.uid;
                      final buyer = lead.buyers.firstWhere(
                            (buyer) => buyer.userId == currentUserId,
                        orElse:  null,
                      );
                      final status = buyer.status;
                      return GestureDetector(
                        onTap: () => Get.to(
                              () => LeadDetailScreen(leadId: lead.leadId,status: status,),
                          transition: Transition.cupertino,
                        ),
                        child: LeadCard(
                          lead: lead,
                          status: status,
                          isShown: true, isLoggedIn: true,
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
