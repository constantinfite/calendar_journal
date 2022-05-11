import 'package:flutter/material.dart';
import 'package:calendar_journal/models/events.dart';
import 'package:calendar_journal/presentation/app_theme.dart';
import 'package:calendar_journal/services/event_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:calendar_journal/services/category_service.dart';
import 'package:calendar_journal/models/category.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_rounded_date_picker/flutter_rounded_date_picker.dart';

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
  double _score = 3;
  late String _category = "";

  var nowDate = DateTime.now().toUtc();
  TimeOfDay selectedTime = TimeOfDay.now();

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
    getAllCategories();
    fToast = FToast();
    fToast.init(context);

    if (!widget.creation) {
      editValue();
    }
    if (widget.creation && widget.event.datetime != null) {
      nowDate = DateTime.fromMillisecondsSinceEpoch(widget.event.datetime!);
    }
  }

  editValue() async {
    setState(() {
      id = widget.event.id!;
      _eventNameController.text = widget.event.name!;
      _eventDescription.text = widget.event.description!;
      _score = widget.event.score!.toDouble();
      _category = widget.event.category!;
      nowDate = DateTime.fromMillisecondsSinceEpoch(widget.event.datetime!);
      selectedTime = TimeOfDay.fromDateTime(
          DateTime.fromMillisecondsSinceEpoch(widget.event.datetime!));
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
    if (widget.creation) {
      _category = _categoryList[0].name!;
    }
  }

  _showToast(_text) {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Theme.of(context).primaryColorLight,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _text,
            style: TextStyle(
              color: Theme.of(context).scaffoldBackgroundColor,
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

  //Dialog if sure to exit workout
  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
      child: Text("Continue"),
      onPressed: () {
        Navigator.pop(context);
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: widget.creation
          ? Text("Exit event creation")
          : Text("Exit event modification"),
      content: widget.creation
          ? Text("You will lose all the content")
          : Text("You will lose the modify content"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  String formattedDate(nowDate) {
    var month = DateFormat('MMMM').format(DateTime(0, nowDate.month));
    var day = nowDate.day;
    var year = nowDate.year;

    return '$day $month $year';
  }

  String formattedTime(selectedTime) {
    //print(selectedTime);
    //DateTime date = DateFormat.jm().parse(selectedTime.format(context));

    return selectedTime.format(context);
    //return DateFormat("HH:mm").format(date);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
        unselectedWidgetColor: Theme.of(context).primaryColorLight,
        colorScheme: ColorScheme.fromSwatch()
            .copyWith(secondary: Theme.of(context).primaryColorLight));

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 70,
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_rounded,
            ),
            color: Colors.white,
            iconSize: 40,
            onPressed: () => {showAlertDialog(context)}
            // 2
            ),
        backgroundColor: Color.fromARGB(255, 39, 39, 39),
        title: Text(
          !widget.creation ? 'Edit event ' : 'Add event',
          style: TextStyle(
            color: Colors.white,
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
                  if (_formKey.currentState!.validate()) {
                    final _event = Event();
                    _event.name = _eventNameController.text;
                    _event.description = _eventDescription.text;
                    _event.datetime = nowDate.millisecondsSinceEpoch;
                    _event.category = _category;
                    _event.score = _score.toInt();
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
                    _event.datetime = nowDate.millisecondsSinceEpoch;
                    _event.score = _score.toInt();
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
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Date",
                          style: TextStyle(
                            color: Theme.of(context).primaryColorLight,
                            fontSize: 15,
                            fontFamily: 'BalooBhai',
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 5, 20, 0),
                          child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Theme.of(context)
                                        .primaryColorLight, //                   <--- border color
                                    width: 1.5,
                                  ),
                                  color:
                                      Theme.of(context).scaffoldBackgroundColor,
                                  borderRadius: BorderRadius.circular(15)),

                              // dropdown below..
                              child: GestureDetector(
                                onTap: () async {
                                  DateTime? newDate = await showDatePicker(
                                      context: context,
                                      initialDate: nowDate,
                                      firstDate: DateTime(1900),
                                      lastDate: DateTime(2300));
                                  if (newDate == null) {
                                    return;
                                  }
                                  setState(() {
                                    nowDate = DateTime(
                                        newDate.year,
                                        newDate.month,
                                        newDate.day,
                                        selectedTime.hour,
                                        selectedTime.minute);
                                  });
                                },
                                child: Text(
                                  formattedDate(nowDate),
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColorLight,
                                    fontSize: 15,
                                    fontFamily: 'BalooBhai2',
                                  ),
                                ),
                              )),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 5.0),
                          child: Text(
                            "Time",
                            style: TextStyle(
                              color: Theme.of(context).primaryColorLight,
                              fontSize: 15,
                              fontFamily: 'BalooBhai',
                            ),
                          ),
                        ),
                        Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                                border: Border.all(
                                  color: Theme.of(context)
                                      .primaryColorLight, //                   <--- border color
                                  width: 1.5,
                                ),
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
                                borderRadius: BorderRadius.circular(15)),

                            // dropdown below..
                            child: GestureDetector(
                              onTap: () async {
                                final TimeOfDay? timeOfDay =
                                    await showTimePicker(
                                  context: context,
                                  initialTime: selectedTime,
                                );
                                if (timeOfDay != null &&
                                    timeOfDay != selectedTime) {
                                  setState(() {
                                    nowDate = DateTime(
                                        nowDate.year,
                                        nowDate.month,
                                        nowDate.day,
                                        timeOfDay.hour,
                                        timeOfDay.minute);

                                    selectedTime =
                                        TimeOfDay.fromDateTime(nowDate);
                                  });
                                }
                              },
                              child: Text(
                                formattedTime(selectedTime),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Theme.of(context).primaryColorLight,
                                  fontSize: 15,
                                  fontFamily: 'BalooBhai2',
                                ),
                              ),
                            ))
                      ],
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
                      Text(
                        "Title",
                        style: TextStyle(
                          color: Theme.of(context).primaryColorLight,
                          fontSize: 15,
                          fontFamily: 'BalooBhai',
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: TextFormField(
                      textCapitalization: TextCapitalization.sentences,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '';
                        }
                        return null;
                      },
                      style: TextStyle(
                        color: Theme.of(context).primaryColorLight,
                        fontSize: 15,
                        fontFamily: 'BalooBhai2',
                      ),
                      controller: _eventNameController,
                      decoration: InputDecoration(
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                        hintStyle: TextStyle(color: Colors.grey),
                        hintText: 'Enter title',
                        filled: true,
                        fillColor: Theme.of(context).scaffoldBackgroundColor,
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).primaryColorLight,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).primaryColorLight,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(15.0)),
                      ),
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
                      Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: Text(
                          "Category",
                          style: TextStyle(
                            color: Theme.of(context).primaryColorLight,
                            fontSize: 15,
                            fontFamily: 'BalooBhai',
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context)
                              .primaryColorLight, //                   <--- border color
                          width: 1.5,
                        ),
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(15)),

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
                              Text(
                                category.emoji! + "  ",
                                style: TextStyle(
                                  color: Theme.of(context).primaryColorLight,
                                  fontSize: 15,
                                  fontFamily: 'BalooBhai2',
                                ),
                              ),
                              Text(
                                category.name!,
                                style: TextStyle(
                                  color: Theme.of(context).primaryColorLight,
                                  fontSize: 15,
                                  fontFamily: 'BalooBhai2',
                                ),
                              )
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
              ),
              SizedBox(
                height: 20,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        "Comments",
                        style: TextStyle(
                          color: Theme.of(context).primaryColorLight,
                          fontSize: 15,
                          fontFamily: 'BalooBhai',
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: TextFormField(
                      textCapitalization: TextCapitalization.sentences,
                      keyboardType: TextInputType.multiline,
                      minLines: 3,
                      maxLines: null,
                      style: TextStyle(
                        color: Theme.of(context).primaryColorLight,
                        fontSize: 15,
                        fontFamily: 'BalooBhai2',
                      ),
                      controller: _eventDescription,
                      decoration: InputDecoration(
                        hintText: 'Enter description',
                        hintStyle: TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: Theme.of(context).scaffoldBackgroundColor,
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).primaryColorLight,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).primaryColorLight,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(20.0)),
                      ),
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
                      Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: Text(
                          "Score",
                          style: TextStyle(
                            color: Theme.of(context).primaryColorLight,
                            fontSize: 15,
                            fontFamily: 'BalooBhai',
                          ),
                        ),
                      ),
                    ],
                  ),
                  RatingBar.builder(
                    initialRating: _score,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: false,
                    itemCount: 5,
                    itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                    itemBuilder: (context, _) => Icon(
                      Icons.star_rounded,
                      color: AppTheme.colors.greenColor,
                    ),
                    onRatingUpdate: (rating) {
                      setState(() {
                        _score = rating;
                      });
                    },
                  )
                ],
              ),

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
