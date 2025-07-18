import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart'; // Import intl package
import '../../../../../models/credits/credit_history_model.dart';

class CreditHistoryCard extends StatelessWidget {
  final CreditHistoryModel creditHistoryModel;
  const CreditHistoryCard({
    super.key,
    required this.creditHistoryModel,
  });

  @override
  Widget build(BuildContext context) {
    // Format the date to "02 Nov, 2024"
    String formattedDate = creditHistoryModel.date != null
        ? DateFormat('dd MMM, yyyy').format(creditHistoryModel.date!)
        : '';

    return Container(
      height: 70,
      margin: const EdgeInsets.only(bottom: 10),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(.3),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 4,
          horizontal: 10,
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(.3),
                borderRadius: BorderRadius.circular(15),
              ),
              padding: const EdgeInsets.all(5),
              child: const Icon(Icons.money),
            ),
            const SizedBox(width: 10),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    creditHistoryModel.paymentMethod!,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    formattedDate, // Display the formatted date
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "Credits: ${creditHistoryModel.credits.toString()} ",
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w200,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      const Icon(
                        FontAwesomeIcons.minus,
                        size: 20,
                        color: Colors.red,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        "C\$ ${creditHistoryModel.price.toString()}",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
