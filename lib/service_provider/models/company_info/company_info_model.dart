class CompanyInfo {
  String? name;
  String? logo;
  String? emailAddress;
  String? phoneNumber;
  String? website;
  String? twitterLink;
  String? facebookLink;
  String? location;
  String? size;
  String? experience;
  String? description;
  List<String>? certifications;
  String? certificationStatus;
  String? adminComment; // Optional admin comment on rejection
  bool isVerified;
  String? gigDescription; // Description for the business gig/listing
  String? gigImage; // Image for the gig/listing

  CompanyInfo({
    this.facebookLink,this.twitterLink,
    this.name,
    this.logo,
    this.emailAddress,
    this.phoneNumber,
    this.website,
    this.location,
    this.size,
    this.experience,
    this.description,
    this.certifications,
    this.certificationStatus,
    this.adminComment,
    this.isVerified = false,
    this.gigDescription,
    this.gigImage,
  });

  // Convert CompanyInfo object to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'logo': logo,
      'emailAddress': emailAddress,
      'phoneNumber': phoneNumber,
      'website': website,
      'facebookLink': facebookLink,
      'twitterLink': twitterLink,
      'location': location,
      'size': size,
      'experience': experience,
      'description': description,
      'certifications': certifications,
      'certificationStatus': certificationStatus,
      'adminComment': adminComment,
      'isVerified': isVerified,
      'gigDescription': gigDescription,
      'gigImage': gigImage,
    };
  }

  // Create a CompanyInfo object from Firestore data
  factory CompanyInfo.fromMap(Map<String, dynamic> map) {
    return CompanyInfo(
      name: map['name'] as String?,
      logo: map['logo'] as String?,
      emailAddress: map['emailAddress'] as String?,
      phoneNumber: map['phoneNumber'] as String?,
      website: map['website'] as String?,
      facebookLink: map['facebookLink'] as String?,
      twitterLink: map['twitterLink'] as String?,
      location: map['location'] as String?,
      size: map['size'] as String?,
      experience: map['experience'] as String?,
      description: map['description'] as String?,
      certifications: (map['certifications'] as List?)?.map((e) => e as String).toList(),
      certificationStatus: map['certificationStatus'] as String?,
      adminComment: map['adminComment'] as String?,
      isVerified: map['isVerified'] ?? false,
      gigDescription: map['gigDescription'] as String?,
      gigImage: map['gigImage'] as String?,
    );
  }
}
