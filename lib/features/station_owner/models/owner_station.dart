import 'station_charger.dart';

class OwnerStation {
  const OwnerStation({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.active,
    required this.chargers,
    this.imagePath,
  });

  final String id;
  final String name;
  final String address;
  final String phone;
  final bool active;
  final List<StationCharger> chargers;
  final String? imagePath;

  OwnerStation copyWith({
    String? id,
    String? name,
    String? address,
    String? phone,
    bool? active,
    List<StationCharger>? chargers,
    String? imagePath,
  }) =>
      OwnerStation(
        id: id ?? this.id,
        name: name ?? this.name,
        address: address ?? this.address,
        phone: phone ?? this.phone,
        active: active ?? this.active,
        chargers: chargers ?? this.chargers,
        imagePath: imagePath ?? this.imagePath,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'address': address,
        'phone': phone,
        'active': active,
        'chargers': chargers.map((charger) => charger.toJson()).toList(),
        'imagePath': imagePath,
      };

  factory OwnerStation.fromJson(Map<String, dynamic> json) => OwnerStation(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        address: json['address'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        active: json['active'] as bool? ?? true,
        chargers: (json['chargers'] as List<dynamic>? ?? [])
            .whereType<Map<String, dynamic>>()
            .map(StationCharger.fromJson)
            .toList(),
        imagePath: json['imagePath'] as String?,
      );
}
