import 'package:flutter/material.dart';

class ClientProfileImageCard extends StatelessWidget {
  final double? size;
  final String? image;

  const ClientProfileImageCard({this.image, this.size, super.key});

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
