class OwnerNotificationSettings {
  const OwnerNotificationSettings({
    this.reviews = true,
    this.station = true,
    this.account = true,
  });

  final bool reviews;
  final bool station;
  final bool account;

  Map<String, dynamic> toJson() => {
        'reviews': reviews,
        'station': station,
        'account': account,
      };

  factory OwnerNotificationSettings.fromJson(Map<String, dynamic> json) =>
      OwnerNotificationSettings(
        reviews: json['reviews'] as bool? ?? true,
        station: json['station'] as bool? ?? true,
        account: json['account'] as bool? ?? true,
      );
}
