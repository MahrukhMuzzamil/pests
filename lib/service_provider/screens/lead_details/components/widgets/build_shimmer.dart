import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

Widget buildFullShimmerPlaceholder(ThemeData theme) {
  return SingleChildScrollView(
    child: Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildHeaderShimmer(),           
            const SizedBox(height: 20),
            buildSectionShimmer(),          
            const SizedBox(height: 10),
            buildSectionShimmer(),           
            const SizedBox(height: 10),
            buildSectionShimmer(),          
            const SizedBox(height: 30),
            buildSectionShimmer(),           
          ],
        ),
      ),
    ),
  );
}

Widget buildHeaderShimmer() {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(15),
      color: Colors.grey[300],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.grey[300],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                height: 24,
                color: Colors.grey[300],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        buildShimmerInfoRow(Icons.email),
        buildShimmerInfoRow(Icons.phone),
        buildShimmerInfoRow(Icons.date_range),
      ],
    ),
  );
}

Widget buildSectionShimmer() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: List.generate(
      2,
          (index) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Container(
          height: 40,
          width: double.infinity,
          color: Colors.grey[300],
        ),
      ),
    ),
  );
}

Widget buildShimmerInfoRow(IconData icon) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
    child: Row(
      children: [
        Icon(icon, color: Colors.grey[300]),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 20,
            color: Colors.grey[300],
          ),
        ),
      ],
    ),
  );
}
