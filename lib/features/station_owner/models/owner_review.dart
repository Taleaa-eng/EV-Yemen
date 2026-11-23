class OwnerReview {
  const OwnerReview({
    required this.id,
    required this.stationId,
    required this.customerName,
    required this.title,
    required this.comment,
    required this.rating,
    required this.createdAt,
  });

  final String id;
  final String stationId;
  final String customerName;
  final String title;
  final String comment;
  final int rating;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'stationId': stationId,
        'customerName': customerName,
        'title': title,
        'comment': comment,
        'rating': rating,
        'createdAt': createdAt.toIso8601String(),
      };

  factory OwnerReview.fromJson(Map<String, dynamic> json) => OwnerReview(
        id: json['id'] as String? ?? '',
        stationId: json['stationId'] as String? ?? '',
        customerName: json['customerName'] as String? ?? '',
        title: json['title'] as String? ?? '',
        comment: json['comment'] as String? ?? '',
        rating: json['rating'] as int? ?? 0,
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0),
      );
}
