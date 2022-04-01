import 'package:calendar_journal/src/app.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:calendar_journal/models/events.dart';
import 'package:calendar_journal/presentation/app_theme.dart';
import 'package:calendar_journal/services/event_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:calendar_journal/presentation/icons.dart';
import 'package:calendar_journal/services/category_service.dart';
import 'package:calendar_journal/models/category.dart';

class EventInput extends StatefulWidget {
  const EventInput({
    Key? key,
    required this.creation,
    required this.event,
  }) : super(key: key);
  //final int id;

  final bool creation;
  final Event event;
  @override
  State<EventInput> createState() => _EventInputState();
}

class _EventInputState extends State<EventInput> {
  int id = 0;
  final _eventNameController = TextEditingController();
  final _eventDescription = TextEditingController();
  int _score = 0;
  String _category = "One";
  var nowDate = DateTime.now().toUtc();

  late FToast fToast;
  final listNumber = List<String>.generate(21, (i) => "$i");
  final _formKey = GlobalKey<FormState>();

  final _event = Event();
  final _eventService = EventService();

  List<Category> _categoryList = <Category>[];
  final _categoryService = CategoryService();

  List<String> nameList = <String>[];

  @override
  void initState() {
    super.initState();
    getAllCategories();
    fToast = FToast();
    fToast.init(context);

    if (!widget.creation) {
      editValue();
    }
  }

  editValue() async {
    setState(() {
      id = widget.event.id!;
      _eventNameController.text = widget.event.name!;
      _eventDescription.text = widget.event.description!;
      _score = widget.event.score!;
      _category = widget.event.category!;
      //nowDate = DateTime.fromMillisecondsSinceEpoch(time, isUtc: true);widget.event.datetime!;
      print(_category);
    });
  }

  getAllCategories() async {
    _categoryList = <Category>[];
    var categories = await _categoryService.readCategories();
    categories.forEach((category) {
      setState(() {
        var categoryModel = Category();
        categoryModel.name = category['name'];
        categoryModel.id = category['id'];
        categoryModel.color = category['color'];
        categoryModel.emoji = category['emoji'];
        _categoryList.add(categoryModel);
        //nameList.add(category['emoji'] + " " + category['name']);
      });
    });
    _category = _categoryList[0].name!;
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

  choiceAction(String choice) async {
    if (choice == "delete") {
      await _eventService.deleteEvent(id);
      Navigator.pop(context);
      _showToast("Event delete");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
        unselectedWidgetColor: AppTheme.colors.secondaryColor,
        colorScheme: ColorScheme.fromSwatch()
            .copyWith(secondary: AppTheme.colors.secondaryColor));

    return Scaffold(
      backgroundColor: Colors.white,
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
          !widget.creation ? 'Edit event ' : 'Add event',
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
              color: AppTheme.colors.greenColor,
              iconSize: 50,
              onPressed: () async {
                // creation of exercice
                if (widget.creation) {
                  if (_eventNameController.text != null) {
                    final _event = Event();
                    _event.name = _eventNameController.text;
                    _event.description = _eventDescription.text;
                    _event.datetime = nowDate.millisecondsSinceEpoch;
                    _event.category = _category;
                    _event.score = _score;
                    await _eventService.saveEvent(_event);
                    _showToast("Event created");
                    Navigator.pop(context);
                  } else {
                    fToast.removeQueuedCustomToasts();
                    _showToast("Empty value");
                  }
                }
                // modification of exercice
                else {
                  if (_formKey.currentState!.validate()
                      //&& _preparationTime != 0
                      ) {
                    final _event = Event();
                    _event.id = id;
                    _event.name = _eventNameController.text;
                    _event.description = _eventDescription.text;
                    _event.datetime = widget.event.datetime;
                    _event.category = _category;
                    await _eventService.updateEvent(_event);
                    Navigator.pop(context);

                    print(_event.category);

                    _showToast("Event modified");
                  } else {
                    _showToast("Empty value");
                  }
                }
              }
              // 2
              ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Form(
            key: _formKey,
            child: Column(children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 20,
                      ),
                      Text(
                        "Title",
                        style: TextStyle(
                          color: AppTheme.colors.secondaryColor,
                          fontSize: 15,
                          fontFamily: 'BalooBhai',
                        ),
                      ),
                    ],
                  ),
                  TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '';
                      }
                      return null;
                    },
                    style: TextStyle(
                      color: AppTheme.colors.secondaryColor,
                      fontSize: 15,
                      fontFamily: 'BalooBhai2',
                    ),
                    controller: _eventNameController,
                    decoration: InputDecoration(
                      hintStyle: TextStyle(color: Colors.grey),
                      hintText: 'Enter title',
                      filled: true,
                      fillColor: Colors.white,
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: AppTheme.colors.secondaryColor,
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: AppTheme.colors.secondaryColor,
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(20.0)),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 15,
                      ),
                      Text(
                        "Comments",
                        style: TextStyle(
                          color: AppTheme.colors.secondaryColor,
                          fontSize: 15,
                          fontFamily: 'BalooBhai',
                        ),
                      ),
                    ],
                  ),
                  TextFormField(
                    keyboardType: TextInputType.multiline,
                    minLines: 3,
                    maxLines: null,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '';
                      }
                      return null;
                    },
                    style: TextStyle(
                      color: AppTheme.colors.secondaryColor,
                      fontSize: 15,
                      fontFamily: 'BalooBhai2',
                    ),
                    controller: _eventDescription,
                    decoration: InputDecoration(
                      hintText: 'Enter description',
                      hintStyle: TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white,
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: AppTheme.colors.secondaryColor,
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: AppTheme.colors.secondaryColor,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(20.0)),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 15,
                      ),
                      Text(
                        "Category",
                        style: TextStyle(
                          color: AppTheme.colors.secondaryColor,
                          fontSize: 15,
                          fontFamily: 'BalooBhai',
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: AppTheme.colors
                              .secondaryColor, //                   <--- border color
                          width: 2.0,
                        ),
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10)),

                    // dropdown below..
                    child: DropdownButton<String>(
                      value: _category,
                      onChanged: (String? value) {
                        setState(() {
                          _category = value!;
                        });
                      },
                      items: _categoryList
                          .map<DropdownMenuItem<String>>((Category category) {
                        return DropdownMenuItem<String>(
                          value: category.name,
                          child: Row(
                            children: [
                              Text(category.emoji! + "  "),
                              Text(category.name!)
                            ],
                          ),
                        );
                      }).toList(),

                      // add extra sugar..
                      icon: Icon(Icons.arrow_drop_down),
                      iconSize: 42,
                      underline: SizedBox(),
                    ),
                  ),
                ],
              )
              /*DropdownButtonFormField(
                value: _category,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue, width: 2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  border: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: AppTheme.colors.cyanColor, width: 2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                dropdownColor: Colors.white,
                items: nameList.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                hint: Text('Category'),
                onChanged: (String? value) {
                  setState(() {
                    _category = value!;
                  });
                },
              ),*/
            ]),
          ),
        ),
      ),
    );
  }
}
