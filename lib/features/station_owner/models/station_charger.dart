class StationCharger {
  const StationCharger({
    required this.id,
    required this.connector,
    required this.powerKw,
    required this.tariff,
    required this.available,
  });

  final String id;
  final String connector;
  final String powerKw;
  final String tariff;
  final bool available;

  StationCharger copyWith({
    String? id,
    String? connector,
    String? powerKw,
    String? tariff,
    bool? available,
  }) =>
      StationCharger(
        id: id ?? this.id,
        connector: connector ?? this.connector,
        powerKw: powerKw ?? this.powerKw,
        tariff: tariff ?? this.tariff,
        available: available ?? this.available,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'connector': connector,
        'powerKw': powerKw,
        'tariff': tariff,
        'available': available,
      };

  factory StationCharger.fromJson(Map<String, dynamic> json) => StationCharger(
        id: json['id'] as String? ?? '',
        connector: json['connector'] as String? ?? '',
        powerKw: json['powerKw'] as String? ?? '',
        tariff: json['tariff'] as String? ?? '',
        available: json['available'] as bool? ?? true,
      );
}

List<StationCharger> sampleChargers(int count) {
  const ids = ['BAY-01', 'BAY-02', 'BAY-03', 'BAY-04'];
  const connectors = ['CCS2 Fast', 'CHAdeMO', 'Type 2', 'GB/T'];
  const powers = ['120', '50', '22', '60'];
  const tariffs = ['180', '150', '140', '180'];
  return List.generate(
    count,
    (index) => StationCharger(
      id: ids[index % ids.length],
      connector: connectors[index % connectors.length],
      powerKw: powers[index % powers.length],
      tariff: tariffs[index % tariffs.length],
      available: index != 2,
    ),
  );
}
