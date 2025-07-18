class CompanyInfo {
  final String? name;
  final String? logo;
  final String? emailAddress;
  final String? phoneNumber;
  final String? website;
  final String? twitterLink;
  final String? facebookLink;
  final String? location;
  final String? size;
  final String? experience;
  final String? description;
  final List<String>? certifications;
  final String? certificationStatus;
  final String? adminComment; // Optional admin comment on rejection
  final bool isVerified;

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
    );
  }
}
