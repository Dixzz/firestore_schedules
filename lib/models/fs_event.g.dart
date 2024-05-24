// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fs_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Event _$EventFromJson(Map<String, dynamic> json) => Event(
      appName: json['appName'] as String,
      created: const TimestampDatetimeConverter()
          .fromJson(json['created'] as Timestamp),
      edit: json['edit'] as bool? ?? false,
    );

Map<String, dynamic> _$EventToJson(Event instance) => <String, dynamic>{
      'appName': instance.appName,
      'created': const TimestampDatetimeConverter().toJson(instance.created),
      'edit': instance.edit,
    };
