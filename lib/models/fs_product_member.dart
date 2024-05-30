import 'package:scheduler/helpers/logger.dart';

class Member {
  final String name;
  final String id;
  final bool admin;
  final bool edit;

  const Member(this.name, this.admin, this.id, [this.edit = false]);

  factory Member.fromJson(dynamic json) {
    logit("wew $json");
    return Member(
      json['name'],
      json['admin'],
      json['id'],
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['name'] = name;
    map['edit'] = edit;
    map['admin'] = admin;
    map['id'] = id;
    return map;
  }

  Member toggleEdit([bool? newEdit]) =>
      Member(name, admin, id, newEdit ?? !edit);
}
