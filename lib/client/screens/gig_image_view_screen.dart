import 'package:flutter/material.dart';

class GigImageViewScreen extends StatelessWidget {
  final String imageUrl;

  const GigImageViewScreen({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: InteractiveViewer(
          child: Image.network(
            imageUrl,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const CircularProgressIndicator();
            },
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.broken_image, size: 100, color: Colors.grey);
            },
          ),
        ),
      ),
    );
  }
}