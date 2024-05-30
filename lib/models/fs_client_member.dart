class ClientMember {
  final String name;
  final bool edit;

  const ClientMember(this.name, [this.edit = false]);

  factory ClientMember.fromJson(dynamic json) {
    return ClientMember(
      json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['name'] = name;
    return map;
  }
  ClientMember toggleEdit([bool? newEdit]) => ClientMember(name, newEdit ?? !edit);

}
