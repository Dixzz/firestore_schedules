// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fs_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Event _$EventFromJson(Map<String, dynamic> json) => Event(
      json['appName'] as String,
      const TimestampDatetimeConverter().fromJson(json['meeting'] as Timestamp),
      const DurationMillisConverter().fromJson(json['duration'] as int),
      json['meetingLink'] as String,
      json['clientName'] as String,
      json['clientSegmentRefId'] as String,
      json['prodMemRefId'] as String,
      json['virtual'] as bool,
      json['id'] as String? ?? "",
    );

Map<String, dynamic> _$EventToJson(Event instance) => <String, dynamic>{
      'duration': const DurationMillisConverter().toJson(instance.duration),
      'meeting': const TimestampDatetimeConverter().toJson(instance.meeting),
      'meetingLink': instance.meetingLink,
      'clientName': instance.clientName,
      'clientSegmentRefId': instance.clientSegmentRefId,
      'prodMemRefId': instance.prodMemRefId,
      'appName': instance.appName,
      'virtual': instance.virtual,
    };
