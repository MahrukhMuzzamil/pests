import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../../client/models/others/gig.dart';

class AddEditGigScreen extends StatefulWidget {
  final Gig? gig;
  const AddEditGigScreen({super.key, this.gig});

  @override
  State<AddEditGigScreen> createState() => _AddEditGigScreenState();
}

class _AddEditGigScreenState extends State<AddEditGigScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  File? _imageFile;
  String? _imageUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.gig?.title ?? '');
    _descriptionController = TextEditingController(text: widget.gig?.description ?? '');
    _priceController = TextEditingController(text: widget.gig?.price.toString() ?? '');
    _imageUrl = widget.gig?.imageUrl;
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage(File image) async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final ref = FirebaseStorage.instance.ref().child('gig_images').child('$userId-${DateTime.now().toIso8601String()}');
      await ref.putFile(image);
      return await ref.getDownloadURL();
    } catch (e) {
      Get.snackbar('Error', 'Failed to upload image: $e');
      return null;
    }
  }

  Future<void> _saveGig() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() { _isLoading = true; });

    String? imageUrl = _imageUrl;
    if (_imageFile != null) {
      imageUrl = await _uploadImage(_imageFile!);
      if (imageUrl == null) {
        setState(() { _isLoading = false; });
        return;
      }
    }

    if (imageUrl == null || imageUrl.isEmpty) {
      Get.snackbar('Error', 'Please upload an image for the gig.');
      setState(() { _isLoading = false; });
      return;
    }

    final userId = FirebaseAuth.instance.currentUser!.uid;
    final gigData = {
      'title': _titleController.text,
      'description': _descriptionController.text,
      'price': double.tryParse(_priceController.text) ?? 0.0,
      'imageUrl': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
    };

    try {
      final gigCollection = FirebaseFirestore.instance.collection('users').doc(userId).collection('gigs');
      if (widget.gig != null) {
        await gigCollection.doc(widget.gig!.id).update(gigData);
      } else {
        await gigCollection.add(gigData);
      }
      Get.back();
    } catch (e) {
      Get.snackbar('Error', 'Failed to save gig: $e');
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.gig == null ? 'Add Gig' : 'Edit Gig'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) => value!.isEmpty ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (value) => value!.isEmpty ? 'Please enter a description' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) => value!.isEmpty || (double.tryParse(value) == null)
                    ? 'Please enter a valid price'
                    : null,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _imageFile != null
                      ? Image.file(_imageFile!, width: 100, height: 100, fit: BoxFit.cover)
                      : (_imageUrl != null && _imageUrl!.isNotEmpty
                          ? Image.network(_imageUrl!, width: 100, height: 100, fit: BoxFit.cover)
                          : const Icon(Icons.image, size: 100, color: Colors.grey)),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.image),
                    label: const Text('Pick Image'),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveGig,
                    child: const Text('Save Gig'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
} 