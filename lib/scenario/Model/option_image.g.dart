// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'option_image.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OptionImage _$OptionImageFromJson(Map<String, dynamic> json) => OptionImage(
      layer: json['layer'] as int,
      imagePath: json['imagePath'] as String,
      enabled: json['enabled'] as bool?,
    );

Map<String, dynamic> _$OptionImageToJson(OptionImage instance) =>
    <String, dynamic>{
      'layer': instance.layer,
      'imagePath': instance.imagePath,
      'enabled': instance.enabled,
    };
