import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String appName;
  final DateTime created;
  final bool edit;

  const Event(this.appName, this.created, [this.edit = false]);


  factory Event.fromJson(dynamic json) {
    return Event(
      json['appName'],
      json['created'].toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['appName'] = appName;
    map['created'] = Timestamp.fromDate(created);
    map['edit'] = edit;
    return map;
  }
}
