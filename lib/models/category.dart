class Category {
  int? id;
  String? name;
  int? color;


  categoryMap() {
    var mapping = Map<String, dynamic>();
    mapping['id'] = id;
    mapping['name'] = name;
    mapping['color'] = color;
    

    return mapping;
  }
}
