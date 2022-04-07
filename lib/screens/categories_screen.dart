import 'package:calendar_journal/main.dart';
import 'package:flutter/material.dart';
import 'package:calendar_journal/models/category.dart';
import 'package:calendar_journal/screens/home_screen.dart';
import 'package:calendar_journal/services/category_service.dart';
import 'package:calendar_journal/screens/input_category.dart';
import 'package:calendar_journal/presentation/app_theme.dart';

class CategoriesScreen extends StatefulWidget {
  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final _categoryNameController = TextEditingController();
  final _categoryDescriptionController = TextEditingController();

  var _category = Category();
  var category;
  final _categoryService = CategoryService();

  List<Category> _categoryList = <Category>[];

  final _editCategoryNameController = TextEditingController();
  final _editCategoryDescriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getAllCategories();
  }

  final GlobalKey<ScaffoldState> _globalKey = GlobalKey<ScaffoldState>();

  getAllCategories() async {
    _categoryList = <Category>[];
    var categories = await _categoryService.readCategories();
    categories.forEach((category) {
      setState(() {
        var categoryModel = Category();
        categoryModel.name = category['name'];
        categoryModel.emoji = category['emoji'];
        categoryModel.id = category['id'];
        categoryModel.color = category['color'];
        _categoryList.add(categoryModel);
      });
    });
  }

  _editCategory(BuildContext context, categoryId) async {
    category = await _categoryService.readCategoryById(categoryId);

    setState(() {
      _category.id = category[0]['id'];
      _category.name = category[0]['name'] ?? 'No name';
      _category.emoji = category[0]['emoji'] ?? 'No emoji';
      _category.color = category[0]['color'] ?? 0;
    });

    Navigator.of(context)
        .push(MaterialPageRoute(
            builder: (context) => CategoryInput(
                  creation: false,
                  category: _category,
                )))
        .then((_) {
      getAllCategories();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _globalKey,
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => HomeScreen()))),
        toolbarHeight: 100,
        elevation: 0,
        backgroundColor: Color.fromARGB(255, 39, 39, 39),
        title: Text(
          "Categories",
          style: TextStyle(
            color: Colors.white,
            fontSize: 35,
            fontFamily: 'BalooBhai',
          ),
        ),
        centerTitle: true,
        actionsIconTheme: IconThemeData(
          color: AppTheme.colors.secondaryColor,
          size: 36,
        ),
      ),
      body: GridView.count(
        // Create a grid with 2 columns. If you change the scrollDirection to
        // horizontal, this produces 2 rows.
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        padding: const EdgeInsets.all(20),
        // Generate 100 widgets that display their index in the List.
        children: List.generate(_categoryList.length, (index) {
          return GestureDetector(
            onTap: () => {_editCategory(context, _categoryList[index].id)},
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Color(_categoryList[index].color ?? 000000),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    _categoryList[index].emoji!,
                    style: TextStyle(
                      color: AppTheme.colors.secondaryColor,
                      fontSize: 50,
                      fontFamily: 'BalooBhai',
                    ),
                  ),
                  Text(
                    _categoryList[index].name!,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontFamily: 'BalooBhai',
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
      /*ListView.builder(
          itemCount: _categoryList.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: EdgeInsets.only(top: 8.0, left: 16.0, right: 16.0),
              child: Card(
                elevation: 2.0,
                child: ListTile(
                  leading: Text(
                    _categoryList[index].emoji!,
                    overflow: TextOverflow.fade,
                    maxLines: 1,
                    softWrap: false,
                    style: TextStyle(
                      fontSize: 25,
                      fontFamily: 'BalooBhai2',
                      color: AppTheme.colors.secondaryColor,
                    ),
                  ),
                  title: Text(
                    (_categoryList[index].name!),
                    overflow: TextOverflow.fade,
                    maxLines: 1,
                    softWrap: true,
                    style: TextStyle(
                        fontSize: 20,
                        fontFamily: 'BalooBhai',
                        color: AppTheme.colors.secondaryColor),
                  ),
                  trailing: SizedBox(
                    width: 100,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(
                            icon: Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              _deleteFormDialog(
                                  context, _categoryList[index].id);
                            }),
                        IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              _editCategory(context, _categoryList[index].id);
                            })
                      ],
                    ),
                  ),
                  /**/
                ),
              ),
            );
          }),
          */
      floatingActionButton: FloatingActionButton(
          foregroundColor: Theme.of(context).primaryColorDark,
          onPressed: () => Navigator.of(context)
                  .push(MaterialPageRoute(
                      builder: (context) => CategoryInput(
                            category: _category,
                            creation: true,
                          )))
                  .then((_) {
                getAllCategories();
              }),
          child: Icon(Icons.add),
          backgroundColor: AppTheme.colors.greenColor),
    );
  }
}
