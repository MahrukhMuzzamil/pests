import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pests247/service_provider/screens/leads/components/screens/travel_time_entry_screen.dart';
import 'distance_entry_screen.dart';

class AddLocationOptionsScreen extends StatelessWidget {
  const AddLocationOptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add a Location'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose an option:',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            _buildLocationCard(
              context,
              title: 'Distance',
              description:
              'Enter a postal code and then choose how far from there as the crow flies.',
              onTap: () => Get.to(() => const DistanceEntryScreen(),transition: Transition.cupertino),
              color: Colors.white,
              icon: Icons.map_outlined,
            ),
            const SizedBox(height: 10),
            _buildLocationCard(
              context,
              title: 'Travel Time',
              description:
              'Enter a postal code and tell us how long you want your maximum drive to be.',
              onTap: () => Get.to(() => const TravelTimeEntryScreen(),transition: Transition.cupertino),
              color: Colors.white,
              icon: Icons.directions_car_outlined,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard(
      BuildContext context, {
        required String title,
        required String description,
        required VoidCallback onTap,
        required Color color,
        required IconData icon,
      }) {
    return Card(
      color: color, // Custom background color for the card
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10), // Rounded corners
      ),
      elevation: 4, // Card elevation for shadow
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          description,
          style: TextStyle(
            color: Colors.black.withOpacity(0.6), // Faded black description
          ),
        ),
        trailing: Icon(icon, color: Theme.of(context).colorScheme.primary),
        onTap: onTap, // Action when card is tapped
      ),
    );
  }
}
