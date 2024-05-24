


class ProductMember {
  final String name;
  final bool edit;

  const ProductMember(this.name, [this.edit = false]);


  factory ProductMember.fromJson(dynamic json) {
    return ProductMember(
      json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['name'] = name;
    map['edit'] = edit;
    return map;
  }
}
