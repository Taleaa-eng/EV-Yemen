import 'dart:io';

import 'package:flutter/material.dart';

import 'station_image_placeholder.dart';

Widget buildStationImage(String? path) {
  if (path == null || path.isEmpty) return stationImagePlaceholder();
  return Image.file(
    File(path),
    fit: BoxFit.cover,
    errorBuilder: (_, __, ___) => stationImagePlaceholder(),
  );
}
