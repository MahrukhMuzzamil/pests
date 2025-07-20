import 'package:flutter/material.dart';

class ProfileImageCard extends StatelessWidget {
  final double? size;
  final String? image;

  const ProfileImageCard({this.image, this.size, super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size ?? 90,
      width: size ?? 90,
      child: image != null && image!.isNotEmpty
          ? ClipOval(
        child: Image.network(
          image!,
          width: size ?? 90,
          height: size ?? 90,
          fit: BoxFit.cover,
        ),
      )
          : CircleAvatar(
        radius: (size ?? 90) / 2,
        child: Icon(
          Icons.person,
          size: (size ?? 90) / 2,
        ),
      ),
    );
  }
}

class BusinessGigCard extends StatelessWidget {
  final String businessName;
  final String? gigDescription;
  final String? gigImage;
  final bool isVerified;

  const BusinessGigCard({
    required this.businessName,
    this.gigDescription,
    this.gigImage,
    this.isVerified = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                gigImage != null && gigImage!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          gigImage!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const CircleAvatar(radius: 30, child: Icon(Icons.business)),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    businessName,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                if (isVerified)
                  const Icon(Icons.verified, color: Colors.blue, size: 28),
              ],
            ),
            const SizedBox(height: 12),
            if (gigDescription != null && gigDescription!.isNotEmpty)
              Text(
                gigDescription!,
                style: const TextStyle(fontSize: 15, color: Colors.black87),
              ),
          ],
        ),
      ),
    );
  }
}
