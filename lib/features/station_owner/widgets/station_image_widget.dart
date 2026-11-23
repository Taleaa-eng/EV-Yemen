import 'package:flutter/material.dart';

import 'station_image_stub.dart' if (dart.library.io) 'station_image_io.dart'
    as platform;

Widget buildStationImage(String? path) => platform.buildStationImage(path);
