import 'package:calendar_journal/models/category.dart';
import 'package:flutter/material.dart';
import 'package:calendar_journal/screens/calendar.dart';
import 'package:calendar_journal/screens/home_screen.dart';
import 'package:calendar_journal/screens/categories_screen.dart';
import 'package:calendar_journal/services/category_service.dart';

class DrawerNavigaton extends StatefulWidget {
  @override
  _DrawerNavigatonState createState() => _DrawerNavigatonState();
}

class _DrawerNavigatonState extends State<DrawerNavigaton> {
  final List<Category> _categoryList = <Category>[];

  final CategoryService _categoryService = CategoryService();

  @override
  initState() {
    super.initState();
    getAllCategories();
  }

  getAllCategories() async {
    var categories = await _categoryService.readCategories();

    categories.forEach((category) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Drawer(
        child: ListView(
          children: <Widget>[
            ListTile(
                leading: Icon(Icons.home),
                title: Text('Home'),
                onTap: () => Navigator.pop(context)
                //Navigator.of(context).push(MaterialPageRoute(builder: (context) => HomeScreen())),
                ),
            ListTile(
              leading: Icon(Icons.view_list),
              title: Text('Categories'),
              onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => CategoriesScreen())),
            ),
            Divider(),
            Column(),
          ],
        ),
      ),
    );
  }
}
