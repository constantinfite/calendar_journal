import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'package:calendar_journal/screens/input_event_screen.dart';
import 'package:calendar_journal/src/app.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:calendar_journal/models/events.dart';
import 'package:calendar_journal/services/event_service.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:calendar_journal/presentation/app_theme.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:calendar_journal/services/category_service.dart';
import 'package:calendar_journal/models/category.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart'
    hide ModalBottomSheetRoute;
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:permission_handler/permission_handler.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat format = CalendarFormat.twoWeeks;

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final _categoryService = CategoryService();
  final _eventService = EventService();

  var _event = Event();
  var event;
  List<Event> _selectedEvents = <Event>[];

  Map<DateTime, List<Event>> _events = LinkedHashMap(
    equals: isSameDay,
  );

  int id = 0;
  String _value = "";

  List<Category> _categoryList = <Category>[];
  late var _categorySelected = Category();

  List<Event> _getEventsFromDay(DateTime date) {
    if (_categorySelected.name == "All") {
      return _events[date] ?? [];
    } else {
      return (_events[date]
              ?.where((i) => i.category == _categorySelected.name)
              .toList()) ??
          [];
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;

    getAllCategories();

    getTask1().then((val) => setState(() {
          _events = val;

          var _correctDate = DateTime.utc(
              _selectedDay!.year, _selectedDay!.month, _selectedDay!.day);

          _selectedEvents = _getEventsFromDay(_correctDate);
          if (_categorySelected.name != "All") {
            _selectedEvents = _selectedEvents
                .where((i) => i.category == _categorySelected.name)
                .toList();
          }
        }));
  }

  @override
  void dispose() {
    super.dispose();
  }

  Color colorCategoryDotScore(score) {
    if (score == 5) {
      return Color.fromARGB(255, 87, 227, 44);
    }
    if (score == 4) {
      return Color.fromARGB(255, 183, 221, 41);
    }
    if (score == 3) {
      return Color.fromARGB(255, 255, 226, 52);
    }
    if (score == 2) {
      return Color.fromARGB(255, 255, 165, 52);
    } else {
      return Color.fromARGB(255, 255, 69, 69);
    }
    /*for (var cat in _categoryList) {
      if (cat.name == category) {
        color = Color(cat.color!);
      }
    }*/
  }

  Color colorCategoryDotCategory(category) {
    Color color = Colors.blue;
    for (var cat in _categoryList) {
      if (cat.name == category) {
        color = Color(cat.color!);
      }
    }
    return color;
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

  Future<List<Event>> getAllEvents() async {
    var events = await _eventService.readEvents("");
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

  Future<Map<DateTime, List<Event>>> getTask1() async {
    Map<DateTime, List<Event>> mapFetch = {};
    List<Event> events = await getAllEvents();
    for (int i = 0; i < events.length; i++) {
      var date = DateTime.fromMillisecondsSinceEpoch(events[i].datetime!);
      var createDate = DateTime.utc(date.year, date.month, date.day);

      var original = mapFetch[createDate];

      if (original == null) {
        mapFetch[createDate] = [events[i]];
      } else {
        mapFetch[createDate] = List.from(original)..addAll([events[i]]);
      }
    }
    return mapFetch;
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;

        _event.datetime = _focusedDay.millisecondsSinceEpoch;
      });

      _selectedEvents = _getEventsFromDay(selectedDay);
    }
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
      getTask1().then((val) => setState(() {
            _events = val;

            var _correctDate = DateTime.utc(
                _selectedDay!.year, _selectedDay!.month, _selectedDay!.day);

            _selectedEvents = _getEventsFromDay(_correctDate);
            if (_categorySelected.name != "All") {
              _selectedEvents = _selectedEvents
                  .where((i) => i.category == _categorySelected.name)
                  .toList();
            }
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
                        getTask1().then((val) => setState(() {
                              _events = val;

                              var _correctDate = DateTime.utc(
                                  _selectedDay!.year,
                                  _selectedDay!.month,
                                  _selectedDay!.day);

                              _selectedEvents = _getEventsFromDay(_correctDate);
                              if (_categorySelected.name != "All") {
                                _selectedEvents = _selectedEvents
                                    .where((i) =>
                                        i.category == _categorySelected.name)
                                    .toList();
                              }
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
                          getTask1().then((val) => setState(() {
                                _events = val;

                                var _correctDate = DateTime.utc(
                                    _selectedDay!.year,
                                    _selectedDay!.month,
                                    _selectedDay!.day);

                                _selectedEvents =
                                    _getEventsFromDay(_correctDate);
                                if (_categorySelected.name != "All") {
                                  _selectedEvents = _selectedEvents
                                      .where((i) =>
                                          i.category == _categorySelected.name)
                                      .toList();
                                }
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
        getTask1().then((val) => setState(() {
              _events = val;

              var _correctDate = DateTime.utc(
                  _selectedDay!.year, _selectedDay!.month, _selectedDay!.day);

              _selectedEvents = _getEventsFromDay(_correctDate);
              if (_categorySelected.name != "All") {
                _selectedEvents = _selectedEvents
                    .where((i) => i.category == _categorySelected.name)
                    .toList();
              }
            }));
        Navigator.pop(context);
      });
    }
  }

  showAlertDialog(
    BuildContext context,
  ) {}

  Color colorCategory(index) {
    if (Theme.of(context).brightness == Brightness.dark) {
      if (_categoryList[index].name! == _categorySelected.name) {
        return AppTheme.colors.greenColor;
      } else {
        return Theme.of(context).primaryColorDark;
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

  exportDB() async {
    var status = await Permission.manageExternalStorage.status;
    if (!status.isGranted) {
      await Permission.manageExternalStorage.request();
    }
    var status1 = await Permission.storage.status;
    if (!status1.isGranted) {
      await Permission.storage.request();
    }
    try {
      File ourDBFile = File(
          '/data/user/0/com.constantin.calendar_journal/app_flutter/db_eventlist_sqflite');
      Directory? folderPathForDBFile =
          Directory('/storage/emulated/0/Android/CategoryList/');
      await folderPathForDBFile.create();
      await ourDBFile.copy('/storage/emulated/0/Android/CategoryList/event.db');
      print("ok");
    } catch (e) {
      print(e);
    }
  }

  loadDb() async {
    try {
      var status = await Permission.manageExternalStorage.status;
      if (!status.isGranted) {
        await Permission.manageExternalStorage.request();
      }
      var status1 = await Permission.storage.status;
      if (!status1.isGranted) {
        await Permission.storage.request();
      }
      File savedDBFile =
          File('/storage/emulated/0/Android/CategoryList/calendar.db');
      await savedDBFile.copy(
          '/data/user/0/com.constantin.calendar_journal/app_flutter/calendar.db');
      print('ok');
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // backgroundColor: AppTheme.colors.backgroundColor,
        body: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(
            children: [
              //Text(createDate),
              Container(
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                child: Row(children: [
                  Expanded(
                    child: Container(
                      height: 50.0,
                      color: Colors.transparent,
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _categoryList.length,
                          itemBuilder: (context, index) {
                            return buildCategory(index: index);
                          }),
                    ),
                  ),
                ]),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 20),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: TableCalendar(
                  focusedDay: _selectedDay!,
                  firstDay: DateTime(1990),
                  lastDay: DateTime(2050),
                  calendarFormat: format,
                  onFormatChanged: (CalendarFormat _format) {
                    setState(() {
                      format = _format;
                    });
                  },
                  calendarBuilders: CalendarBuilders(
                    singleMarkerBuilder: (context, date, event) {
                      (event as Event);
                      return Container(
                        height: 8.0,
                        width: 8.0,
                        margin: const EdgeInsets.all(0.5),
                        decoration: BoxDecoration(
                          // provide your own condition here
                          color: event.category! == _categorySelected.name
                              ? colorCategoryDotCategory(event.category)
                              : colorCategoryDotCategory(event.category),
                          shape: BoxShape.circle,
                        ),
                      );
                    },
                    dowBuilder: (context, day) {
                      /*if (day.weekday == DateTime.sunday) {
                        final text = DateFormat.E().format(day);

                        return Center(
                          child: Text(
                            text,
                            style: TextStyle(color: Colors.red),
                          ),
                        );
                      }*/
                    },
                  ),
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  daysOfWeekVisible: true,
                  onPageChanged: (focusedDay) {
                    focusedDay = focusedDay;
                  },

                  //Day Changed
                  onDaySelected: _onDaySelected,
                  selectedDayPredicate: (DateTime date) {
                    return isSameDay(_selectedDay, date);
                  },

                  eventLoader: (day) {
                    return _getEventsFromDay(day);
                  },
                  //To style the Calendar
                  calendarStyle: CalendarStyle(
                    isTodayHighlighted: true,
                    selectedDecoration: BoxDecoration(
                      color: AppTheme.colors.greenColor,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    selectedTextStyle:
                        TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
                    todayDecoration: BoxDecoration(
                      color: Color.fromARGB(255, 212, 212, 212),
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    todayTextStyle: TextStyle(color: Colors.white),
                    defaultDecoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    weekendDecoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  headerStyle: HeaderStyle(
                    formatButtonVisible: true,
                    titleCentered: true,
                    formatButtonShowsNext: false,
                    formatButtonDecoration: BoxDecoration(
                      color: AppTheme.colors.greenColor,
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    formatButtonTextStyle: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              Expanded(
                  child: ListView.builder(
                      itemCount: _selectedEvents.length,
                      itemBuilder: (context, index) {
                        return Slidable(
                            startActionPane: ActionPane(
                              motion: const StretchMotion(),
                              children: [
                                SlidableAction(
                                  onPressed: (context) => onEditEvent(
                                      context, _selectedEvents[index].id!),
                                  label: 'Edit',
                                  backgroundColor: AppTheme.colors.greenColor,
                                ),
                              ],
                            ),
                            endActionPane: ActionPane(
                              motion: const StretchMotion(),
                              children: [
                                SlidableAction(
                                  onPressed: (context) => onDeleteEvent(
                                      context, _selectedEvents[index].id!),
                                  label: 'Delete',
                                  // backgroundColor: Colors.red,
                                )
                              ],
                            ),
                            child: cardEvent(_selectedEvents[index]));
                      })),

              // ElevatedButton(onPressed: loadDb, child: const Text("exportDB"))
            ],
          ),
        ),
        floatingActionButton: SpeedDial(
          icon: Icons.add,
          activeIcon: Icons.close,
          foregroundColor: Theme.of(context).primaryColorDark,
          backgroundColor: AppTheme.colors.greenColor,
          spacing: 15,
          spaceBetweenChildren: 10,
          onPress: () => Navigator.of(context)
              .push(MaterialPageRoute(
                  builder: (context) => EventInput(
                        creation: true,
                        event: _event,
                      )))
              .then((_) {
            getTask1().then((val) => setState(() {
                  _events = val;

                  var _correctDate = DateTime.utc(_selectedDay!.year,
                      _selectedDay!.month, _selectedDay!.day);

                  _selectedEvents = _getEventsFromDay(_correctDate);
                  if (_categorySelected.name != "All") {
                    _selectedEvents = _selectedEvents
                        .where((i) => i.category == _categorySelected.name)
                        .toList();
                  }
                }));
          }),
        ));
  }

  Widget buildCategory({required index}) {
    return GestureDetector(
      onTap: () async {
        HapticFeedback.mediumImpact();

        setState(() {
          _categorySelected = _categoryList[index];

          var _correctDate = DateTime.utc(
              _selectedDay!.year, _selectedDay!.month, _selectedDay!.day);

          _selectedEvents = _getEventsFromDay(_correctDate);

          if (_categorySelected.name != "All") {
            _selectedEvents = _selectedEvents
                .where((i) => i.category == _categorySelected.name)
                .toList();
          }
        });
      },
      child: Card(
        color: colorCategory(index),
        //Theme.of(context).scaffoldBackgroundColor
        shape: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: Colors.transparent)),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
                child: Row(
                  children: [
                    Text(_categoryList[index].emoji ?? '♾️',
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
      ),
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
          margin: EdgeInsets.fromLTRB(0, 7, 0, 7),
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
