class BusinessDocument {
  const BusinessDocument({
    required this.name,
    required this.path,
    required this.size,
  });

  final String name;
  final String path;
  final int size;

  Map<String, dynamic> toJson() => {
        'name': name,
        'path': path,
        'size': size,
      };

  factory BusinessDocument.fromJson(Map<String, dynamic> json) =>
      BusinessDocument(
        name: json['name'] as String? ?? '',
        path: json['path'] as String? ?? '',
        size: json['size'] as int? ?? 0,
      );
}
