import 'package:calendar_journal/models/category.dart';
import 'package:calendar_journal/repositories/repository_category.dart';

class CategoryService {
  late Repository _repository;

  CategoryService() {
    _repository = Repository();
  }

  //Create data
  saveCategory(Category category) async {
    return await _repository.insertData('categories', category.categoryMap());
  }

  //Update data
  updateCategory(Category category) async {
    return await _repository.updateData('categories', category.categoryMap());
  }

  // Read data from table
  readCategories() async {
    return await _repository.readData('categories');
  }

  //Read data from table by Id
  readCategoryById(categoryId) async {
    return await _repository.readDataById('categories', categoryId);
  }

  // Delete data from table
  deleteCategory(categoryId) async{
    return await _repository.deleteData('categories', categoryId);
  }
}
