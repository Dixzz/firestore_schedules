import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:scheduler/pages/add_event.dart' show AddEventController;

part 'fs_event.g.dart';


class TimestampDatetimeConverter implements JsonConverter<DateTime, Timestamp> {
  const TimestampDatetimeConverter();

  @override
  DateTime fromJson(json) => json.toDate();

  @override
  Timestamp toJson(DateTime date) => Timestamp.fromDate(date);
}

class DurationMillisConverter implements JsonConverter<Duration, int> {
  const DurationMillisConverter();

  @override
  Duration fromJson(json) => Duration(milliseconds: json);

  @override
  int toJson(Duration object) => object.inMilliseconds;
}

@JsonSerializable()
class Event {
  /// doc ref
  @JsonKey(includeFromJson: true, includeToJson: false)
  final String id;

  /// meeting duration, to be showed as 1h or 30m
  /// [AddEventController.duration]
  @DurationMillisConverter()
  final Duration duration;

  /// [AddEventController.meeting]
  @TimestampDatetimeConverter()
  final DateTime meeting;

  final String meetingLink;
  final String clientName;
  final String clientSegmentRefId;
  final String prodMemRefId;
  final String appName;
  final bool virtual;

  @JsonKey(includeFromJson: false, includeToJson: false)
  final bool edit;

  const Event(this.appName, this.meeting, this.duration, this.meetingLink,
      this.clientName, this.clientSegmentRefId, this.prodMemRefId, this.virtual,
      [this.id = "", this.edit = false]);

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);

  /// Connect the generated [_$PersonToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$EventToJson(this);

  Event updateEdit(final bool edit) {
    return Event(appName, meeting, duration, meetingLink, clientName,
        clientSegmentRefId, prodMemRefId, virtual, id, edit);
  }
}
