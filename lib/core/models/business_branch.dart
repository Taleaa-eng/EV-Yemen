import 'business_document.dart';

class BusinessBranch {
  const BusinessBranch({
    required this.id,
    required this.name,
    required this.city,
    required this.address,
    required this.phone,
    required this.commercialRegistrationNumber,
    required this.licenseNumber,
    required this.latitude,
    required this.longitude,
    required this.documentPath,
    required this.documentName,
    required this.imagePath,
    this.documents = const {},
    this.approved = false,
  });

  final String id;
  final String name;
  final String city;
  final String address;
  final String phone;
  final String commercialRegistrationNumber;
  final String licenseNumber;
  final double latitude;
  final double longitude;
  final String documentPath;
  final String documentName;
  final String imagePath;
  final Map<String, BusinessDocument> documents;
  final bool approved;

  BusinessBranch copyWith({bool? approved}) => BusinessBranch(
        id: id,
        name: name,
        city: city,
        address: address,
        phone: phone,
        commercialRegistrationNumber: commercialRegistrationNumber,
        licenseNumber: licenseNumber,
        latitude: latitude,
        longitude: longitude,
        documentPath: documentPath,
        documentName: documentName,
        imagePath: imagePath,
        documents: documents,
        approved: approved ?? this.approved,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'city': city,
        'address': address,
        'phone': phone,
        'commercialRegistrationNumber': commercialRegistrationNumber,
        'licenseNumber': licenseNumber,
        'latitude': latitude,
        'longitude': longitude,
        'documentPath': documentPath,
        'documentName': documentName,
        'imagePath': imagePath,
        'documents':
            documents.map((key, value) => MapEntry(key, value.toJson())),
        'approved': approved,
      };

  factory BusinessBranch.fromJson(Map<String, dynamic> json) => BusinessBranch(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        city: json['city'] as String? ?? '',
        address: json['address'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        commercialRegistrationNumber:
            json['commercialRegistrationNumber'] as String? ?? '',
        licenseNumber: json['licenseNumber'] as String? ?? '',
        latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
        longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
        documentPath: json['documentPath'] as String? ?? '',
        documentName: json['documentName'] as String? ?? '',
        imagePath: json['imagePath'] as String? ?? '',
        documents: (json['documents'] as Map<String, dynamic>? ?? const {}).map(
          (key, value) => MapEntry(
            key,
            BusinessDocument.fromJson(Map<String, dynamic>.from(value as Map)),
          ),
        ),
        approved: json['approved'] as bool? ?? false,
      );
}
