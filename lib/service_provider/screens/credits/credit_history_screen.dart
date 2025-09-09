import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CreditHistoryScreen extends StatelessWidget {
  const CreditHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to view credit history.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Credit History')),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('No history available.'));
          }

          final data = snapshot.data!.data() ?? {};
          final List<dynamic> history = (data['creditHistoryList'] as List<dynamic>?) ?? [];
          if (history.isEmpty) {
            return const Center(child: Text('No history available.'));
          }

          history.sort((a, b) {
            final at = a['date'];
            final bt = b['date'];
            final ad = at is Timestamp ? at.toDate() : DateTime.tryParse(at?.toString() ?? '') ?? DateTime(0);
            final bd = bt is Timestamp ? bt.toDate() : DateTime.tryParse(bt?.toString() ?? '') ?? DateTime(0);
            return bd.compareTo(ad);
          });

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: history.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = history[index] as Map<String, dynamic>;
              final int credits = (item['credits'] as num?)?.toInt() ?? 0;
              final String method = (item['paymentMethod']?.toString() ?? '');
              final String desc = (item['description']?.toString() ?? '');
              final Timestamp? ts = item['date'] is Timestamp ? item['date'] as Timestamp? : null;
              final DateTime date = ts?.toDate() ?? DateTime.now();

              final bool isAdd = credits > 0;
              final Color color = isAdd ? Colors.green : Colors.red;

              return ListTile(
                leading: CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(isAdd ? Icons.add : Icons.remove, color: color)),
                title: Text('${isAdd ? '+' : ''}$credits credits', style: TextStyle(color: color, fontWeight: FontWeight.w700)),
                subtitle: Text(desc.isNotEmpty ? '$desc • $method' : method),
                trailing: Text('${date.year}-${date.month.toString().padLeft(2,'0')}-${date.day.toString().padLeft(2,'0')}'),
              );
            },
          );
        },
      ),
    );
  }
}


