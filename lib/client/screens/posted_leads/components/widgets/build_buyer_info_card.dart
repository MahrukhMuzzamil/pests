import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pests247/client/screens/home/components/company_profile_card.dart';
import 'package:pests247/client/widgets/custom_button.dart';
import 'package:pests247/services/notification_services.dart';
import '../../../../../shared/models/lead_model/lead_model.dart';
import '../../../../../shared/models/user/user_model.dart';
import '../../../../controllers/posted_leads/posted_leads_controller.dart';

Widget buildBuyerInfoCard(
    BuildContext context, LeadModel lead, UserModel currentUserModel) {
  final PostedLeadsController postedLeadsController = Get.find();

  return Obx(() {
    List<Widget> buyerCards = [];

    for (var buyer in lead.buyers) {
      postedLeadsController.fetchBuyerUserModel(buyer.userId);

      UserModel? buyerUser = postedLeadsController.buyerUserModels[buyer.userId]?.value;
      if (buyerUser != null) {
        print('Buyer data fetched: ${buyerUser.userName}');

        double avgRating = postedLeadsController
            .calculateAverageRating(buyerUser.reviews ?? []);
        String companyName = buyerUser.companyInfo?.name?.isNotEmpty ?? false
            ? buyerUser.companyInfo!.name!
            : buyerUser.userName;

        // Add the buyer profile card
        buyerCards.add(Container(
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4))
              ]),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  buyerUser.profilePicUrl != null &&
                      buyerUser.profilePicUrl!.isNotEmpty
                      ? CircleAvatar(
                      radius: 30,
                      backgroundImage:
                      NetworkImage(buyerUser.profilePicUrl!))
                      : const CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.blue,
                      child: Icon(Icons.person, color: Colors.white)),
                  const SizedBox(width: 16),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                    child: Text(companyName,
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                        overflow: TextOverflow.ellipsis)),
                                const SizedBox(width: 8),
                                GestureDetector(
                                    onTap: () => _showInfoDialog(Get.context!),
                                    child: Icon(Icons.info_outline,
                                        color: Colors.grey[600])),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Row(children: [
                              buildRatingStars(avgRating),
                              const SizedBox(width: 8),
                              Text(avgRating.toStringAsFixed(1),
                                  style: const TextStyle(
                                      fontSize: 15, fontWeight: FontWeight.bold))
                            ]),
                          ])),
                ],
              ),
              const SizedBox(height: 16),
              CustomButton(
                height: 35,
                textStyle: const TextStyle(fontSize: 15, color: Colors.white),
                backgroundColor: Colors.blue,
                onPressed: () {
                  Get.to(
                          () => CompanyProfileCard(
                          companyInfo: buyerUser.companyInfo,
                          reviews: buyerUser.reviews!,
                          questionAnswerForm: buyerUser.questionAnswerForm!),
                      transition: Transition.cupertino);
                },
                text: 'View Profile',
                isLoading: false,
                tag: 'viewProfile',
              ),
              const SizedBox(height: 10),
              (buyer.status != 'hired' && buyer.status != 'completed')
                  ? CustomButton(
                height: 35,
                textStyle:
                const TextStyle(fontSize: 15, color: Colors.white),
                backgroundColor: Colors.blue,
                onPressed: () {
                  _showRequestQuoteDialog(
                    context,
                    buyer.userId,
                    currentUserModel.userName,
                    postedLeadsController,
                    lead,
                  );
                },
                text: 'Hire Now',
                isLoading: false,
                tag: 'hireNow',
              )
                  : const SizedBox()
            ],
          ),
        ));
      }
    }
    return Column(children: buyerCards);
  });
}



Widget buildRatingStars(double rating) {
  int fullStars = rating.floor();
  bool hasHalfStar = (rating - fullStars) >= 0.5;
  return Row(
    children: List.generate(5, (index) {
      if (index < fullStars) {
        return const Icon(Icons.star, color: Colors.blue, size: 20);
      } else if (index == fullStars && hasHalfStar) {
        return const Icon(Icons.star_half, color: Colors.blue, size: 20);
      } else {
        return const Icon(Icons.star_border, color: Colors.blue, size: 20);
      }
    }),
  );
}

void _showRequestQuoteDialog(
    BuildContext context,
    String buyerId,
    String currentUserName,
    PostedLeadsController postedLeadController,
    LeadModel lead) {
  showDialog(
    context: context,
    builder: (context) {
      return Platform.isIOS
          ? CupertinoAlertDialog(
        title: const Text('Hire Now'),
        content: const Text(
            'A request will be sent to the service provider. They will contact you soon, and the info will also be updated in activity logs.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          CupertinoDialogAction(
            child: const Text('Yes'),
            onPressed: () async {
              Navigator.of(context).pop();
              DocumentSnapshot userDoc = await FirebaseFirestore.instance
                  .collection('users')
                  .doc(buyerId)
                  .get();

              if (userDoc.exists) {
                final userData = userDoc.data() as Map<String, dynamic>;
                String name = userData['companyInfo']?['name'] ?? userData['userName'] ?? currentUserName;
                NotificationsServices.sendLeadRequestQuote(buyerId, context, name);
                postedLeadController.updateLeadHiredPerson(lead, 'hired', buyerId, name);
              }
            },
          ),
        ],
      )
          : AlertDialog(
        title: const Text('Hire Now'),
        content: const Text(
            'A request will be sent to the service provider. They will contact you soon.You can hire only one'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Yes'),
            onPressed: () async {
              Navigator.of(context).pop();
              DocumentSnapshot userDoc = await FirebaseFirestore.instance
                  .collection('users')
                  .doc(buyerId)
                  .get();

              if (userDoc.exists) {
                final userData = userDoc.data() as Map<String, dynamic>;
                String name = userData['companyInfo']?['name'] ?? userData['userName'] ?? currentUserName;
                NotificationsServices.sendLeadRequestQuote(buyerId, context, name);
                postedLeadController.updateLeadHiredPerson(lead, 'hired', buyerId, name);
              }
            },
          ),
        ],
      );
    },
  );
}

void _showInfoDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return Platform.isIOS
          ? CupertinoAlertDialog(
        title: const Text('Info'),
        content: const Text(
            'You can respond to this user by requesting a quote. The user will then contact you either in-app or via other communication methods.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      )
          : AlertDialog(
        title: const Text('Info'),
        content: const Text(
            'You can respond to this user by requesting a quote. The user will then contact you either in-app or via other communication methods.'),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
