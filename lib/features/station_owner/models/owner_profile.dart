class OwnerProfile {
  const OwnerProfile({
    required this.fullName,
    required this.phone,
    required this.email,
    required this.establishment,
    required this.city,
    required this.address,
    required this.registrationNumber,
    this.latitude,
    this.longitude,
  });

  final String fullName;
  final String phone;
  final String email;
  final String establishment;
  final String city;
  final String address;
  final String registrationNumber;
  final double? latitude;
  final double? longitude;

  OwnerProfile copyWith({
    String? fullName,
    String? phone,
    String? email,
    String? establishment,
    String? city,
    String? address,
    String? registrationNumber,
    double? latitude,
    double? longitude,
  }) =>
      OwnerProfile(
        fullName: fullName ?? this.fullName,
        phone: phone ?? this.phone,
        email: email ?? this.email,
        establishment: establishment ?? this.establishment,
        city: city ?? this.city,
        address: address ?? this.address,
        registrationNumber: registrationNumber ?? this.registrationNumber,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
      );

  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        'phone': phone,
        'email': email,
        'establishment': establishment,
        'city': city,
        'address': address,
        'registrationNumber': registrationNumber,
        'latitude': latitude,
        'longitude': longitude,
      };

  factory OwnerProfile.fromJson(Map<String, dynamic> json) => OwnerProfile(
        fullName: json['fullName'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        email: json['email'] as String? ?? '',
        establishment: json['establishment'] as String? ?? '',
        city: json['city'] as String? ?? '',
        address: json['address'] as String? ?? '',
        registrationNumber: json['registrationNumber'] as String? ?? '',
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
      );
}
