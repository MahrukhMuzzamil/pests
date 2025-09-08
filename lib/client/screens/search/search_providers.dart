import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pests247/service_provider/models/company_info/company_info_model.dart';

class SearchProvidersScreen extends StatefulWidget {
  const SearchProvidersScreen({super.key});

  @override
  State<SearchProvidersScreen> createState() => _SearchProvidersScreenState();
}

class _SearchProvidersScreenState extends State<SearchProvidersScreen> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search providers or services',
            border: InputBorder.none,
          ),
          textInputAction: TextInputAction.search,
          onChanged: (v) => setState(() => _query = v.trim()),
        ),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.clear),
            onPressed: () {
              _controller.clear();
              setState(() => _query = '');
            },
          )
        ],
      ),
      body: _query.isEmpty
          ? const Center(child: Text('Type to search'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where('accountType', isEqualTo: 'serviceProvider')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data?.docs ?? [];
                final filtered = docs.where((d) {
                  final data = d.data() as Map<String, dynamic>;
                  final ci = data['companyInfo'];
                  if (ci == null) return false;
                  final info = CompanyInfo.fromMap(ci);
                  final text = ((info.name ?? '') + ' ' + (info.gigDescription ?? '')).toLowerCase();
                  return text.contains(_query.toLowerCase());
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text('No results'));
                }

                return ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const Divider(height: 0),
                  itemBuilder: (context, index) {
                    final data = filtered[index].data() as Map<String, dynamic>;
                    final info = CompanyInfo.fromMap(data['companyInfo']);
                    return ListTile(
                      leading: const Icon(Icons.business),
                      title: Text(info.name ?? ''),
                      subtitle: Text(info.gigDescription ?? ''),
                      onTap: () => Get.back(),
                    );
                  },
                );
              },
            ),
    );
  }
}


