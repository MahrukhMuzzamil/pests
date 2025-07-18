import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pests247/client/screens/reviews/reviews_screen.dart';
import 'package:pests247/shared/models/lead_model/lead_model.dart';

class ReviewRequestCard extends StatelessWidget {
  final String  serviceProviderId;
  final String leadId;
  final LeadModel lead;
  const ReviewRequestCard({
    super.key, required this.serviceProviderId, required this.leadId, required this.lead,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'reviewButton',
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          child: GestureDetector(
            onTap: () {
              Get.to(() => ClientReviewScreen(leadId: leadId, serviceProviderId: serviceProviderId, lead: lead,),transition: Transition.cupertino);
            },
            child: Container(
              height: 55,
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.green.shade300,
                    Colors.blue.shade500
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.shade200,
                    offset: const Offset(0, 4),
                    blurRadius: 10.0,
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.add_circle, color: Colors.white, size: 23),
                  SizedBox(width: 15),
                  Text(
                    'Submit a Review',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Spacer(),
                  Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}