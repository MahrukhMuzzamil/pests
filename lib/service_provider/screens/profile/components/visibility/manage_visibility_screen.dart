import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pests247/services/stripe_service.dart';

class ManageVisibilityScreen extends StatelessWidget {
  const ManageVisibilityScreen({super.key});

  Future<void> _activatePackage(BuildContext context, Map<String, dynamic> pkg) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final int tier = (pkg['tier'] as num?)?.toInt() ?? 0;
    final int durationDays = (pkg['durationDays'] as num?)?.toInt() ?? 30;
    final String name = (pkg['name']?.toString() ?? '');
    final DateTime expiry = DateTime.now().add(Duration(days: durationDays));

    print('Activating package: $name, tier: $tier, duration: $durationDays');

    final userRef = FirebaseFirestore.instance.collection('users').doc(uid);

    await FirebaseFirestore.instance.runTransaction((txn) async {
      final snap = await txn.get(userRef);
      if (!snap.exists) return;
      final data = snap.data() as Map<String, dynamic>;
      final Map<String, dynamic> newCompanyInfo = Map<String, dynamic>.from(data['companyInfo'] ?? {});
      newCompanyInfo['premiumPackage'] = tier;

      print('Setting premiumPackage to: $tier for user: $uid');

      txn.update(userRef, {
        'companyInfo': newCompanyInfo,
        'visibilityPackage': pkg['id'],
        'visibilityPackageName': name,
        'visibilityPackageExpiry': Timestamp.fromDate(expiry),
      });
    });

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Activated $name (expires ${expiry.toLocal().toString().split(' ')[0]})')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Visibility Packages')),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser?.uid).snapshots(),
        builder: (context, userSnap) {
          final String? activeId = (userSnap.data?.data() ?? {})['visibilityPackage'] as String?;
          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('visibilityPackages')
                .orderBy('tier', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('No visibility packages available.', style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    const Text('Ask admin to add packages under "Visibility Packages" in dashboard.', textAlign: TextAlign.center),
                  ],
                ),
              ),
            );
          }
              final docs = snapshot.data!.docs;
              return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final pkg = docs[index].data();
              final String id = docs[index].id;
              final String name = pkg['name']?.toString() ?? '';
              final int tier = (pkg['tier'] as num?)?.toInt() ?? 0;
              final int duration = (pkg['durationDays'] as num?)?.toInt() ?? 30;
              final double price = (pkg['price'] as num?)?.toDouble() ?? 0.0;
              final String description = pkg['description']?.toString() ?? '';

              // Pick icon/color by name first (gold/silver/platinum), fallback to tier
              final lname = name.toLowerCase();
              IconData icon;
              Color color;
              if (lname.contains('gold')) {
                icon = Icons.emoji_events; // trophy
                color = const Color(0xFFFFD700); // Gold color
              } else if (lname.contains('silver')) {
                icon = Icons.military_tech; // medal
                color = const Color(0xFFC0C0C0); // Silver color
              } else if (lname.contains('platinum')) {
                icon = Icons.workspace_premium; // premium/crown-like
                color = const Color(0xFF1E88E5); // Blue color
              } else {
                switch (tier) {
                  case 3:
                    icon = Icons.emoji_events;
                    color = const Color(0xFFFFA000);
                    break;
                  case 2:
                    icon = Icons.military_tech;
                    color = const Color(0xFF90A4AE);
                    break;
                  default:
                    icon = Icons.workspace_premium;
                    color = const Color(0xFF1E88E5);
                }
              }

              final bool isActive = activeId == id;

              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Row(
                    children: [
                      CircleAvatar(backgroundColor: color.withOpacity(0.12), child: Icon(icon, color: color)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(child: Text('$name (Tier $tier)', style: const TextStyle(fontWeight: FontWeight.w700))),
                                if (isActive)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.green.shade200)),
                                    child: const Text('Active', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w700)),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Wrap(spacing: 8, runSpacing: 6, children: [
                              _chip('Top placement'),
                              _chip('Premium badge'),
                              _chip('Duration: $duration days'),
                            ]),
                            if (description.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(description, style: const TextStyle(color: Colors.black54, fontSize: 12)),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('\$${price.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          isActive
                              ? OutlinedButton(onPressed: null, child: const Text('Active'))
                              : ElevatedButton(
                                  onPressed: () async {
                                    final ok = await StripeService.instance.payForVisibilityPackage(
                                      context: context,
                                      price: price,
                                      description: 'Visibility package: $name',
                                    );
                                    if (ok) {
                                      await _activatePackage(context, {...pkg, 'id': id});
                                    }
                                  },
                                  child: const Text('Activate'),
                                ),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          );
            },
          );
        },
      ),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12)),
    );
  }
}


