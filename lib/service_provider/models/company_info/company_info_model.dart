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
  String? status;
  String? rejectionComment;
  double? averageRating;
  double? latitude;
  double? longitude;
  int premiumPackage;
  final double? distanceFromUser;
  final double? rankScore;
  String? stripeAccountId; // Stripe Connect account ID for payments

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
    this.status,
    this.rejectionComment,
    this.averageRating,
    this.latitude,
    this.longitude,
    this.premiumPackage = 0,
    this.distanceFromUser,
    this.rankScore,
    this.stripeAccountId,
  });

  CompanyInfo copyWith({
  double? distanceFromUser,
  double? rankScore,
  String? stripeAccountId,
}) {
  return CompanyInfo(
    facebookLink: this.facebookLink,
    twitterLink: this.twitterLink,
    name: this.name,
    logo: this.logo,
    emailAddress: this.emailAddress,
    phoneNumber: this.phoneNumber,
    website: this.website,
    location: this.location,
    size: this.size,
    experience: this.experience,
    description: this.description,
    certifications: this.certifications,
    certificationStatus: this.certificationStatus,
    adminComment: this.adminComment,
    isVerified: this.isVerified,
    gigDescription: this.gigDescription,
    gigImage: this.gigImage,
    averageRating: this.averageRating,
    latitude: this.latitude,
    longitude: this.longitude,
    premiumPackage: this.premiumPackage,
    status: this.status,
    rejectionComment: this.rejectionComment,
    distanceFromUser: distanceFromUser ?? this.distanceFromUser,
    rankScore: rankScore ?? this.rankScore,
    stripeAccountId: stripeAccountId ?? this.stripeAccountId,
  );
}


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
      'averageRating': averageRating,
      'latitude': latitude,
      'longitude': longitude,
      'premiumPackage': premiumPackage,
      'status': status,
      'rejectionComment': rejectionComment,
      'stripeAccountId': stripeAccountId,
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
      averageRating: (map['averageRating'] as num?)?.toDouble(),
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      premiumPackage: map['premiumPackage'] ?? 0,
      status: map['status'] as String?,
      rejectionComment: map['rejectionComment'] as String?,
      stripeAccountId: map['stripeAccountId'] as String?,
    );
  }
}
