import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'option_image.g.dart';

@JsonSerializable()
class OptionImage {
  int layer;
  String imagePath;
  bool? enabled = false;

  OptionImage({required this.layer, required this.imagePath, this.enabled});

  factory OptionImage.fromJson(Map<String, dynamic> json) =>
      _$OptionImageFromJson(json);

  Map<String, dynamic> toJson() => _$OptionImageToJson(this);
}
