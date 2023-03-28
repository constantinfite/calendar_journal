import 'dart:convert';
import 'package:calendar_journal/screens/input_event_screen.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'package:calendar_journal/models/events.dart';
import 'package:calendar_journal/services/event_service.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:calendar_journal/presentation/app_theme.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:calendar_journal/services/category_service.dart';
import 'package:calendar_journal/models/category.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:chips_choice/chips_choice.dart';
import '../widgets/filter_list.dart';

class ListEventScreen extends StatefulWidget {
  const ListEventScreen({Key? key}) : super(key: key);

  @override
  State<ListEventScreen> createState() => _ListEventScreenState();
}

class _ListEventScreenState extends State<ListEventScreen> {
  CalendarFormat format = CalendarFormat.month;

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final _categoryService = CategoryService();
  final _eventService = EventService();

  var _event = Event();
  var event;

  List<Event> _events = <Event>[];

  int id = 0;
  TextEditingController textController = TextEditingController();

  List<Category> _categoryList = <Category>[];
  List<String> _categoryListSelected = <String>[];
  late var _categorySelected = Category();

  Future<List<C2Choice<String>>> getCategory() async {
    return C2Choice.listFrom<String, Category>(
        source: _categoryList,
        value: (i, v) => v.name ?? "",
        label: (i, v) => v.name ?? "");
  }

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    getAllCategories();
    getAllEvents("").then((val) => setState(() {
          _events = val;
        }));
  }

  @override
  void dispose() {
    super.dispose();
  }

  String emojiCategory(category) {
    String emoji = "";

    for (var cat in _categoryList) {
      if (cat.name == category) {
        emoji = cat.emoji!;
      }
    }
    return emoji;
  }

  getAllCategories() async {
    _categoryList = <Category>[];
    var categories = await _categoryService.readCategories();
    var categoryModel = Category();
    categoryModel.name = "All";
    categoryModel.id = 0;
    categoryModel.color = AppTheme.colors.secondaryColor.value;
    _categoryList.add(categoryModel);
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
    _categorySelected = _categoryList[0];
  }

  Future<List<Event>> getAllEvents(String value) async {
    var events = await _eventService.readEvents(value);
    List<Event> _eventList = <Event>[];
    events.forEach((event) {
      setState(() {
        var eventModel = Event();
        eventModel.id = event['id'];
        eventModel.name = event['name'];
        eventModel.description = event['description'];
        eventModel.category = event['category'];
        eventModel.score = event['score'];
        eventModel.datetime = event['datetime'];
        _eventList.add(eventModel);
      });
    });
    return _eventList;
  }

  onEditEvent(context, int id) async {
    event = await _eventService.readEventById(id);

    setState(() {
      _event.id = event[0]['id'];
      _event.name = event[0]['name'] ?? 'No name';
      _event.description = event[0]['description'] ?? 'No description';
      _event.score = event[0]['score'] ?? 0;
      _event.category = event[0]['category'];
      _event.datetime = event[0]['datetime'];
    });
    Navigator.of(context)
        .push(MaterialPageRoute(
            builder: (context) => EventInput(creation: false, event: _event)))
        .then((_) {
      getAllEvents("").then((val) => setState(() {
            _events = val;

            var _correctDate = DateTime.utc(
                _selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
          }));
      Navigator.pop(context);
    });
  }

  onDeleteEvent(context, int id) {
    Future.delayed(
        const Duration(seconds: 0),
        () => showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: Text("Are you sure to delete the event"),
                  actions: [
                    TextButton(
                      child: Text("Cancel"),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    TextButton(
                      child: Text("Continue"),
                      onPressed: () async {
                        Navigator.pop(context);
                        await _eventService.deleteEvent(id);
                        getAllEvents("").then((val) => setState(() {
                              _events = val;

                              var _correctDate = DateTime.utc(
                                  _selectedDay!.year,
                                  _selectedDay!.month,
                                  _selectedDay!.day);
                            }));
                      },
                    ),
                  ],
                )));
  }

  choiceAction(context, int id, choice) async {
    if (choice == "delete") {
      Future.delayed(
          const Duration(seconds: 0),
          () => showDialog(
              context: context,
              builder: (context) => AlertDialog(
                    title: Text("Are you sure to delete the event"),
                    actions: [
                      TextButton(
                        child: Text("Cancel"),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      TextButton(
                        child: Text("Continue"),
                        onPressed: () async {
                          Navigator.pop(context);
                          await _eventService.deleteEvent(id);
                          Navigator.pop(context);
                          getAllEvents("").then((val) => setState(() {
                                _events = val;

                                var _correctDate = DateTime.utc(
                                    _selectedDay!.year,
                                    _selectedDay!.month,
                                    _selectedDay!.day);
                              }));
                        },
                      ),
                    ],
                  )));
      //await _eventService.deleteEvent(id);
      //Navigator.pop(context);

      //_showToast("Exercice delete");
    } else {
      event = await _eventService.readEventById(id);

      setState(() {
        _event.id = event[0]['id'];
        _event.name = event[0]['name'] ?? 'No name';
        _event.description = event[0]['description'] ?? 'No description';
        _event.score = event[0]['score'] ?? 0;
        _event.category = event[0]['category'];
        _event.datetime = event[0]['datetime'];
      });
      Navigator.of(context)
          .push(MaterialPageRoute(
              builder: (context) => EventInput(creation: false, event: _event)))
          .then((_) {
        getAllEvents("").then((val) => setState(() {
              _events = val;

              var _correctDate = DateTime.utc(
                  _selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
            }));
        Navigator.pop(context);
      });
    }
  }

  Color colorCategory(index) {
    if (Theme.of(context).brightness == Brightness.dark) {
      if (_categoryList[index].name! == _categorySelected.name) {
        return Colors.white;
      } else {
        return Color.fromARGB(255, 39, 39, 39);
      }
    } else {
      if (_categoryList[index].name! == _categorySelected.name) {
        return Color.fromARGB(255, 39, 39, 39);
      } else {
        return Colors.white;
      }
    }
  }

  Color colorTextCategory(index) {
    if (Theme.of(context).brightness == Brightness.light) {
      if (_categoryList[index].name! == _categorySelected.name) {
        return Color.fromARGB(255, 39, 39, 39);
      } else {
        return Colors.white;
      }
    } else {
      if (_categoryList[index].name! == _categorySelected.name) {
        return Colors.white;
      } else {
        return Color.fromARGB(255, 39, 39, 39);
      }
    }
  }

  void updateList(String value) {
    getAllEvents(value).then((val) => setState(() {
          _events = val;
        }));
  }

  updateFilter(val) {
    print(val);
    setState(() => _categoryListSelected = val);
    // getAllEvents('').then((val) => setState(() {
    //       _events = val;
    //     }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: AppTheme.colors.backgroundColor,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) => updateList(value),
                    style:
                        TextStyle(color: Theme.of(context).primaryColorLight),
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: Theme.of(context).primaryColorDark,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.0),
                            borderSide: BorderSide.none),
                        hintText: "Find events",
                        prefixIcon: Icon(Icons.search),
                        prefixIconColor: Theme.of(context).primaryColor),
                  ),
                ),
                SizedBox(
                  width: 15,
                ),
                Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      color: Theme.of(context).primaryColorDark,
                      borderRadius: BorderRadius.circular(16)),
                  child: IconButton(
                      icon: Icon(Icons.filter_alt, color: Colors.white),
                      onPressed: () => {
                            showMaterialModalBottomSheet(
                              backgroundColor: Colors.transparent,
                              barrierColor: Color.fromARGB(152, 0, 0, 0),
                              context: context,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(20))),
                              builder: (BuildContext context) {
                                return FilterList();
                              },
                            )
                          }),
                )
              ],
            ),
            Container(margin: EdgeInsets.fromLTRB(0, 20, 0, 20)),

            //Text(createDate),
            Expanded(
                child: ListView.builder(
                    itemCount: _events.length,
                    itemBuilder: (context, index) {
                      return Slidable(
                          startActionPane: ActionPane(
                            motion: const StretchMotion(),
                            children: [
                              SlidableAction(
                                onPressed: (context) =>
                                    onEditEvent(context, _events[index].id!),
                                label: 'Edit',
                                backgroundColor: AppTheme.colors.greenColor,
                              ),
                            ],
                          ),
                          endActionPane: ActionPane(
                            motion: const StretchMotion(),
                            children: [
                              SlidableAction(
                                onPressed: (context) =>
                                    onDeleteEvent(context, _events[index].id!),
                                label: 'Delete',
                                // backgroundColor: Colors.red,
                              )
                            ],
                          ),
                          child: cardEvent(_events[index]));
                    })),
          ],
        ),
      ),
    );
  }

  Widget buildCategory({required index}) {
    return GestureDetector(
      onTap: () async {
        HapticFeedback.mediumImpact();

        setState(() {
          _categorySelected = _categoryList[index];

          if (_categorySelected.name != "All") {
            _events = _events
                .where((i) => i.category == _categorySelected.name)
                .toList();
          }
        });
      },
      child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
              child: Column(
                children: [
                  Container(
                    // width: 100.0,
                    // height: 100.0,
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(15.0),
                    decoration: BoxDecoration(
                      color: colorCategory(index),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: Color(_categoryList[index].color ??
                            000000), //                   <--- border color
                        width: 2.0,
                      ),
                    ),
                    child: Text(
                      _categoryList[index].emoji ?? '',
                      style: TextStyle(
                        color: AppTheme.colors.secondaryColor,
                        fontSize: 40,
                        fontFamily: 'BalooBhai2',
                      ),
                    ),
                  ),
                  Text(
                      _categoryList[index].name!.length > 15
                          ? '${_categoryList[index].name!.substring(0, 15)}...'
                          : _categoryList[index].name!,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      softWrap: false,
                      style: TextStyle(
                        fontSize: 18,
                        color: colorTextCategory(index),
                        fontFamily: 'BalooBhai',
                      )),
                ],
              ),
            ),
          ]),
    );
  }

  Widget cardEvent(event) {
    return GestureDetector(
      onTap: () {
        showMaterialModalBottomSheet(
          backgroundColor: Colors.transparent,
          barrierColor: Color.fromARGB(152, 0, 0, 0),
          context: context,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
          builder: (BuildContext context) {
            return bottomSheet(event);
          },
        );
      },
      child: Card(
          margin: EdgeInsets.fromLTRB(0, 0, 0, 15),
          color: Theme.of(context).primaryColorDark,
          shape: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: Colors.transparent)),
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: ListTile(
              title: Text(
                event.name,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                softWrap: false,
                style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'BalooBhai',
                    color: Theme.of(context).primaryColorLight),
              ),
              trailing: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    event.score.toString(),
                    style: TextStyle(
                      fontSize: 25,
                      fontFamily: 'BalooBhai2',
                      color: Theme.of(context).primaryColorLight,
                    ),
                  ),
                  Icon(
                    Icons.star_rounded,
                    color: AppTheme.colors.greenColor,
                  ),
                ],
              ),
              subtitle: Text(
                datesecondToMinuteHour(event.datetime),
                overflow: TextOverflow.fade,
                maxLines: 1,
                softWrap: false,
                style: TextStyle(
                  fontSize: 15,
                  fontFamily: 'BalooBhai2',
                  color: Theme.of(context).primaryColorLight,
                ),
              ),
              leading: Container(
                alignment: Alignment.center,
                //transformAlignment: transf,
                width: 50.0,
                height: 50.0,
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Color.fromARGB(255, 113, 113, 113)
                      : Color.fromARGB(255, 230, 230, 230),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  emojiCategory(event.category),
                  overflow: TextOverflow.fade,
                  maxLines: 1,
                  softWrap: false,
                  style: TextStyle(
                    fontSize: 25,
                    fontFamily: 'BalooBhai2',
                    color: AppTheme.colors.secondaryColor,
                  ),
                ),
              ),
            ),
          )),
    );
  }

  // Widget filterList() {
  //   return SingleChildScrollView(
  //     child: Container(
  //       color: Theme.of(context).primaryColorDark,
  //       //height: MediaQuery.of(context).size.height * 0.6,
  //       padding: EdgeInsets.all(30),
  //       width: MediaQuery.of(context).size.width * 1,
  //       child: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         mainAxisAlignment: MainAxisAlignment.start,
  //         children: <Widget>[
  //           Row(
  //             children: [
  //               Expanded(
  //                 child: Text(
  //                   "Set Filters",
  //                   textAlign: TextAlign.center,
  //                   style: TextStyle(
  //                     fontSize: 25,
  //                     fontFamily: 'BalooBhai',
  //                     color: Theme.of(context).primaryColorLight,
  //                   ),
  //                 ),
  //               )
  //             ],
  //           ),
  //           SizedBox(height: 30),
  //           Row(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Expanded(
  //                 child: Text(
  //                   "Category",
  //                   style: TextStyle(
  //                     fontSize: 20,
  //                     fontFamily: 'BalooBhai',
  //                     color: Theme.of(context).primaryColorLight,
  //                   ),
  //                 ),
  //               )
  //             ],
  //           ),
  //           ChipsChoice<String>.multiple(
  //               value: _categoryListSelected,
  //               onChanged: (val) => setState(() => _categoryListSelected = val),
  //               choiceLoader: getCategory,
  //               wrapped: true,
  //               choiceStyle: C2ChipStyle.filled(
  //                 selectedStyle: const C2ChipStyle(
  //                   backgroundColor: Color.fromARGB(255, 116, 206, 210),
  //                 ),
  //               )),
  //           SizedBox(height: 50),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget bottomSheet(event) {
    return SingleChildScrollView(
      child: Container(
        color: Theme.of(context).primaryColorDark,
        //height: MediaQuery.of(context).size.height * 0.6,
        padding: EdgeInsets.all(30),
        width: MediaQuery.of(context).size.width * 1,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  datesecondToMinuteHour(event.datetime),
                  overflow: TextOverflow.fade,
                  maxLines: 1,
                  softWrap: false,
                  style: TextStyle(
                      fontSize: 15,
                      fontFamily: 'BalooBhai2',
                      color: AppTheme.colors.greenColor),
                ),
              ],
            ),
            Row(
              //mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  emojiCategory(event.category),
                  overflow: TextOverflow.fade,
                  maxLines: 1,
                  softWrap: false,
                  style: TextStyle(
                    fontSize: 30,
                    fontFamily: 'BalooBhai2',
                    color: AppTheme.colors.secondaryColor,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    event.name,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    softWrap: false,
                    style: TextStyle(
                        fontSize: 20,
                        fontFamily: 'BalooBhai',
                        color: AppTheme.colors.greenColor),
                  ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.only(top: 10),
                    //margin: EdgeInsets.symmetric(vertical: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(20),
                      ),
                      border: Border.all(
                        width: 0,
                        color: Colors.transparent,
                        //style: BorderStyle.solid,
                      ),
                    ),
                    child: Text(
                      event.description,
                      style: TextStyle(
                        fontSize: 15,
                        fontFamily: 'BalooBhai2',
                        color: Theme.of(context).primaryColorLight,
                      ),
                    ),
                  ),
                )
              ],
            ),
            SizedBox(height: 50)
          ],
        ),
      ),
    );
  }
}

String decodeJsonToText(event) {
  var serie = jsonDecode(event);
  String text = "";
  for (var i = 0; i < serie.length; i++) {
    if (i < serie.length - 1) {
      text = text + serie[i].toString() + "-";
    } else {
      text = text + serie[i].toString();
    }
  }
  return text;
}

String formatDuration(int totalSeconds) {
  final duration = Duration(seconds: totalSeconds);
  final minutes = duration.inMinutes;
  final seconds = totalSeconds % 60;

  final minutesString = '$minutes'.padLeft(1, '0');
  final secondsString = '$seconds'.padLeft(2, '0');
  return '$minutesString m $secondsString s';
}

String datesecondToMinuteHour(int dateSecond) {
  var date = DateTime.fromMillisecondsSinceEpoch(dateSecond).toLocal();
  var month = DateFormat('MMMM').format(DateTime(0, date.month));
  var day = date.day;
  var hour = date.hour;
  var minute = date.minute;

  var minuteString = '$minute'.padLeft(2, '0');

  return '$day $month, $hour:$minuteString';
}
