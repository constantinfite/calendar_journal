class Category {
  int? id;
  String? name; 
  String? emoji; 
  int? color;


  categoryMap() {
    var mapping = Map<String, dynamic>();
    mapping['id'] = id;
    mapping['name'] = name;
    mapping['emoji'] = emoji;
    mapping['color'] = color;
    

    return mapping;
  }
}
