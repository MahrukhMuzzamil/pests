class ServiceCategory {
  final String name;
  final String imageURL;
  final bool isActive;

  ServiceCategory(this.name, this.imageURL, {this.isActive = false});
}

// Example categories for HomeServe 247 (only 'Pest Services' active for now)
// To rebrand, change 'Pest Services' to another category and update app assets/names.
final List<ServiceCategory> allCategories = [
  ServiceCategory('Pest Services', 'assets/images/onboard/1.png', isActive: true),
  // ServiceCategory('Cleaning', 'assets/images/onboard/cleaning.png'),
  // ServiceCategory('Roofing', 'assets/images/onboard/roofing.png'),
  // ServiceCategory('Electricians', 'assets/images/onboard/electricians.png'),
  // ServiceCategory('Plumbing', 'assets/images/onboard/plumbing.png'),
  // ServiceCategory('Lawn Care', 'assets/images/onboard/lawncare.png'),
  // ServiceCategory('Painting', 'assets/images/onboard/painting.png'),
  // ServiceCategory('HVAC', 'assets/images/onboard/hvac.png'),
  // ServiceCategory('Carpentry', 'assets/images/onboard/carpentry.png'),
  // ServiceCategory('Moving', 'assets/images/onboard/moving.png'),
  // ServiceCategory('Handyman', 'assets/images/onboard/handyman.png'),
  // ServiceCategory('Security', 'assets/images/onboard/security.png'),
  // ServiceCategory('Appliance Repair', 'assets/images/onboard/appliance.png'),
  // ServiceCategory('Flooring', 'assets/images/onboard/flooring.png'),
  // ServiceCategory('Window Cleaning', 'assets/images/onboard/windowcleaning.png'),
  // ServiceCategory('Pool Services', 'assets/images/onboard/pool.png'),
];
// To activate a category, uncomment its line and set isActive: true if needed.
// For HomeServe 247 rebranding, update the app name and replace assets accordingly.
