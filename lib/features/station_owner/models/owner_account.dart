import '../../../core/models/business_document.dart';
import 'owner_profile.dart';

class OwnerAccount {
  const OwnerAccount({
    required this.id,
    required this.email,
    required this.phone,
    required this.passwordSalt,
    required this.passwordHash,
    required this.profile,
    this.documents = const {},
    this.approved = false,
  });

  final String id;
  final String email;
  final String phone;
  final String passwordSalt;
  final String passwordHash;
  final OwnerProfile profile;
  final Map<String, BusinessDocument> documents;
  final bool approved;

  OwnerAccount copyWith({
    OwnerProfile? profile,
    Map<String, BusinessDocument>? documents,
    bool? approved,
  }) =>
      OwnerAccount(
        id: id,
        email: email,
        phone: phone,
        passwordSalt: passwordSalt,
        passwordHash: passwordHash,
        profile: profile ?? this.profile,
        documents: documents ?? this.documents,
        approved: approved ?? this.approved,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'phone': phone,
        'passwordSalt': passwordSalt,
        'passwordHash': passwordHash,
        'profile': profile.toJson(),
        'documents':
            documents.map((key, value) => MapEntry(key, value.toJson())),
        'approved': approved,
      };

  factory OwnerAccount.fromJson(Map<String, dynamic> json) => OwnerAccount(
        id: json['id'] as String? ?? '',
        email: json['email'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        passwordSalt: json['passwordSalt'] as String? ?? '',
        passwordHash: json['passwordHash'] as String? ?? '',
        profile: OwnerProfile.fromJson(
            json['profile'] as Map<String, dynamic>? ?? const {}),
        documents: (json['documents'] as Map<String, dynamic>? ?? const {}).map(
          (key, value) => MapEntry(
            key,
            BusinessDocument.fromJson(Map<String, dynamic>.from(value as Map)),
          ),
        ),
        approved: json['approved'] as bool? ?? false,
      );
}
