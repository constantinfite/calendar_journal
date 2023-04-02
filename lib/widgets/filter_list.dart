import 'dart:convert';
import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'package:calendar_journal/models/category.dart';
import 'package:calendar_journal/services/category_service.dart';
import 'package:chips_choice/chips_choice.dart';
import 'package:calendar_journal/presentation/app_theme.dart';

class FilterList extends StatefulWidget {
  final Function(List<String>) onCategorySelectionChanged;
  final List<String> categories;

  const FilterList(
      {required this.categories, required this.onCategorySelectionChanged});

  @override
  _FilterListState createState() => _FilterListState();
}

class _FilterListState extends State<FilterList> {
  final _categoryService = CategoryService();
  List<Category> _categoryList = <Category>[];
  List<String> _categoryListSelected = <String>[];

  @override
  void initState() {
    super.initState();
    // getAllCategories();
    setState(() {
      _categoryListSelected = widget.categories;
    });
  }

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

  Future<List<C2Choice<String>>> getCategory() async {
    await getAllCategories();
    return C2Choice.listFrom<String, Category>(
        source: _categoryList,
        value: (i, v) => v.name ?? "",
        label: (i, v) => v.name ?? "");
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        color: Theme.of(context).primaryColorDark,
        //height: MediaQuery.of(context).size.height * 0.6,
        padding: EdgeInsets.all(30),
        width: MediaQuery.of(context).size.width * 1,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Row(
              children: [
                Expanded(
                  child: Text(
                    "Set Filters",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 25,
                      fontFamily: 'BalooBhai',
                      color: Theme.of(context).primaryColorLight,
                    ),
                  ),
                )
              ],
            ),
            SizedBox(height: 30),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    "Category",
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'BalooBhai',
                      color: Theme.of(context).primaryColorLight,
                    ),
                  ),
                )
              ],
            ),
            ChipsChoice<String>.multiple(
              value: _categoryListSelected,
              onChanged: (val) {
                setState(() {
                  _categoryListSelected = val;
                  widget.onCategorySelectionChanged(val);
                });
              },
              choiceLoader: getCategory,
              wrapped: true,
              choiceStyle: C2ChipStyle.filled(
                selectedStyle: const C2ChipStyle(
                  backgroundColor: Color.fromARGB(255, 116, 206, 210),
                ),
              ),
            ),
            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
