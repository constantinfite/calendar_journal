import 'package:flutter/material.dart';
import 'package:calendar_journal/presentation/app_theme.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:calendar_journal/services/category_service.dart';
import 'package:calendar_journal/models/category.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class CategoryInput extends StatefulWidget {
  const CategoryInput(
      {Key? key, required this.creation, required this.category})
      : super(key: key);
  final bool creation;
  final Category category;
  @override
  State<CategoryInput> createState() => _CategoryInputState();
}

class _CategoryInputState extends State<CategoryInput> {
  int id = 0;
  final _categoryNameController = TextEditingController();
  final _categoryEmojiController = TextEditingController();
  Color _color = Colors.blue;

  late FToast fToast;
  final _formKey = GlobalKey<FormState>();

  List<Category> _categoryList = <Category>[];
  final _categoryService = CategoryService();

  @override
  void initState() {
    super.initState();

    fToast = FToast();
    fToast.init(context);

    if (!widget.creation) {
      editValue();
    }
  }

  editValue() async {
    setState(() {
      id = widget.category.id!;
      _categoryNameController.text = widget.category.name!;
      _categoryEmojiController.text = widget.category.emoji!;
      _color = Color(widget.category.color!);
    });
  }

  _showToast(_text) {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: AppTheme.colors.secondaryColor,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontFamily: 'BalooBhai2',
            ),
          ),
        ],
      ),
    );
    // Custom Toast Position
    fToast.showToast(
        child: toast,
        toastDuration: Duration(seconds: 2),
        positionedToastBuilder: (context, child) {
          return Stack(alignment: Alignment.centerRight, children: <Widget>[
            Positioned.fill(
                top: MediaQuery.of(context).size.height * 0.75, child: child)
          ]);
        });
  }

  /*choiceAction(String choice) async {
    if (choice == "delete") {
      await _eventService.deleteEvent(id);
      Navigator.pop(context);
      _showToast("Event delete");
    }
  }*/

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
        unselectedWidgetColor: AppTheme.colors.secondaryColor,
        colorScheme: ColorScheme.fromSwatch()
            .copyWith(secondary: AppTheme.colors.secondaryColor));

    return Scaffold(
      backgroundColor: AppTheme.colors.backgroundColor,
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 100,
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_rounded,
            ),
            color: AppTheme.colors.secondaryColor,
            iconSize: 40,
            onPressed: () => Navigator.pop(context)
            // 2
            ),
        backgroundColor: Colors.transparent,
        title: Text(
          widget.creation ? "Create category" : "Modify category",
          style: TextStyle(
            color: AppTheme.colors.secondaryColor,
            fontSize: 30,
            fontFamily: 'BalooBhai',
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
              icon: const Icon(Icons.check),
              color: AppTheme.colors.primaryColor,
              iconSize: 50,
              onPressed: () async {
                // creation of exercice
                if (widget.creation) {
                  if (_categoryNameController.text != null) {
                    final _category = Category();
                    _category.name = _categoryNameController.text;
                    _category.emoji = _categoryEmojiController.text;
                    _category.color = _color.value;
                    print(_category.emoji);
                    await _categoryService.saveCategory(_category);

                    _showToast("Event created");
                    Navigator.pop(context);
                  } else {
                    fToast.removeQueuedCustomToasts();
                    _showToast("Empty value");
                  }
                }
                // modification of category
                else {
                  if (_formKey.currentState!.validate()) {
                    final _category = Category();
                    _category.name = _categoryNameController.text;
                    _category.emoji = _categoryEmojiController.text;
                    _category.color = _color.value;
                    _category.id = id;
                    await _categoryService.updateCategory(_category);
                    Navigator.pop(context);
                    _showToast("Category modified");
                  } else {
                    _showToast("Empty value");
                  }
                }
              }
              // 2
              ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Form(
              key: _formKey,
              child: Column(children: <Widget>[
                TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '';
                    }
                    return null;
                  },
                  style: TextStyle(
                    color: AppTheme.colors.secondaryColor,
                    fontSize: 20,
                    fontFamily: 'BalooBhai',
                  ),
                  controller: _categoryNameController,
                  decoration: InputDecoration(
                    hintText: 'Enter title',
                    filled: true,
                    fillColor: Colors.white,
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.transparent,
                          width: 0.0,
                        ),
                        borderRadius: BorderRadius.circular(20.0)),
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '';
                    }
                    return null;
                  },
                  style: TextStyle(
                    color: AppTheme.colors.secondaryColor,
                    fontSize: 20,
                    fontFamily: 'BalooBhai',
                  ),
                  controller: _categoryEmojiController,
                  decoration: InputDecoration(
                    hintText: 'Choici emoji',
                    filled: true,
                    fillColor: Colors.white,
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.transparent,
                          width: 0.0,
                        ),
                        borderRadius: BorderRadius.circular(20.0)),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Card(
                  color: Colors.white,
                  child: Column(children: [
                    GestureDetector(
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text(
                                  'Pick a color!',
                                  style: TextStyle(
                                    color: AppTheme.colors.secondaryColor,
                                    fontSize: 20,
                                    fontFamily: 'BalooBhai',
                                  ),
                                ),
                                content: SingleChildScrollView(
                                  child: BlockPicker(
                                    pickerColor: _color, //default color
                                    onColorChanged: (Color color) {
                                      //on color picked
                                      setState(() {
                                        _color = color;
                                      });
                                    },
                                  ),
                                ),
                                actions: <Widget>[
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      elevation: 2,
                                      primary: AppTheme.colors.secondaryColor,
                                      textStyle: TextStyle(
                                          fontFamily: "BalooBhai",
                                          fontSize: 30),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          side: BorderSide(
                                              color: Colors.transparent)),
                                    ),
                                    child: Text(
                                      'Save',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontFamily: 'BalooBhai',
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pop(); //dismiss the color picker
                                    },
                                  ),
                                ],
                              );
                            });
                      },
                      child: ListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Select color",
                              style: TextStyle(
                                color: AppTheme.colors.secondaryColor,
                                fontSize: 20,
                                fontFamily: 'BalooBhai',
                              ),
                            ),
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle, color: _color),
                            )
                          ],
                        ),
                      ),
                    ),
                    /* SizedBox(
                      height: 150,
                      child: ListTile(
                          title: BlockPicker(
                        pickerColor: Colors.red, //default color
                        onColorChanged: (Color color) {
                          //on color picked
                          setState(() {
                            _color = color;
                          });
                        },
                      )),
                    ),*/
                  ]),
                  shape: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: Colors.transparent)),
                  elevation: 2,
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
