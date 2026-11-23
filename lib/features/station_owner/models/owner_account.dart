import 'owner_profile.dart';

class OwnerAccount {
  const OwnerAccount({
    required this.id,
    required this.email,
    required this.phone,
    required this.passwordSalt,
    required this.passwordHash,
    required this.profile,
  });

  final String id;
  final String email;
  final String phone;
  final String passwordSalt;
  final String passwordHash;
  final OwnerProfile profile;

  OwnerAccount copyWith({OwnerProfile? profile}) => OwnerAccount(
        id: id,
        email: email,
        phone: phone,
        passwordSalt: passwordSalt,
        passwordHash: passwordHash,
        profile: profile ?? this.profile,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'phone': phone,
        'passwordSalt': passwordSalt,
        'passwordHash': passwordHash,
        'profile': profile.toJson(),
      };

  factory OwnerAccount.fromJson(Map<String, dynamic> json) => OwnerAccount(
        id: json['id'] as String? ?? '',
        email: json['email'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        passwordSalt: json['passwordSalt'] as String? ?? '',
        passwordHash: json['passwordHash'] as String? ?? '',
        profile: OwnerProfile.fromJson(
            json['profile'] as Map<String, dynamic>? ?? const {}),
      );
}
