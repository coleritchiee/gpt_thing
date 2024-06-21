import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';

class UserFile {
  String name;
  File? file; // TODO: make this NOT null
  IconData icon;
  late Color color;

  UserFile({required this.name, this.file, required this.icon}) {
    color = Colors.primaries[Random().nextInt(Colors.primaries.length)];
  }
}