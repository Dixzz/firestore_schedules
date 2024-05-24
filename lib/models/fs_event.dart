import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'fs_event.g.dart';

class TimestampDatetimeConverter implements JsonConverter<DateTime, Timestamp> {
  const TimestampDatetimeConverter();

  @override
  DateTime fromJson(json) => json.toDate();

  @override
  Timestamp toJson(DateTime date) => Timestamp.fromDate(date);
}

@JsonSerializable()
class Event {
  final String appName;

  @TimestampDatetimeConverter()
  final DateTime created;
  final bool edit;

  const Event(
      {required this.appName, required this.created, this.edit = false});

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);

  /// Connect the generated [_$PersonToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$EventToJson(this);
}
