import 'dart:collection';
import 'dart:convert';
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

class StatsScreen extends StatefulWidget {
  const StatsScreen({Key? key}) : super(key: key);

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  CalendarFormat format = CalendarFormat.month;

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final _categoryService = CategoryService();
  final _eventService = EventService();

  final _event = Event();
  List<Event> _selectedEvents = <Event>[];

  Map<DateTime, List<Event>> _events = LinkedHashMap(
    equals: isSameDay,
  );

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

  Color colorCategory(category) {
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
    var events = await _eventService.readEvents();
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
    //print(_eventList.length);
    return _eventList;
  }

  Future<Map<DateTime, List<Event>>> getTask1() async {
    Map<DateTime, List<Event>> mapFetch = {};
    List<Event> events = await getAllEvents();
    for (int i = 0; i < events.length; i++) {
      var date = DateTime.fromMillisecondsSinceEpoch(events[i].datetime!);
      var createDate = DateTime.utc(date.year, date.month, date.day);
      /*print("createDate");
      print(createDate);*/

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
      });

      _selectedEvents = _getEventsFromDay(selectedDay);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppTheme.colors.backgroundColor,
        body: Column(
          children: [
            //Text(createDate),

            Container(
              margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
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
                            ? Color(_categorySelected.color!)
                            : colorCategory(event.category),
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
            /* ..._getEventsFromDay(selectedDay)
              .map((Event event) => cardExercice(event)),*/
            Container(
              margin: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
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
            Expanded(
                child: ListView.builder(
                    itemCount: _selectedEvents.length,
                    itemBuilder: (context, index) {
                      return cardEvent(_selectedEvents[index]);
                    })),
          ],
        ),
        floatingActionButton: SpeedDial(
          icon: Icons.add,
          activeIcon: Icons.close,
          backgroundColor: AppTheme.colors.greenColor,
          spacing: 15,
          spaceBetweenChildren: 10,
          onPress: () => Navigator.of(context)
              .push(MaterialPageRoute(
                  builder: (context) =>
                      EventInput(mode: "", creation: true, event: _event)))
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
        color: _categoryList[index].name! == _categorySelected.name
            ? AppTheme.colors.secondaryColor
            //Color(_categorySelected.color!)
            : Colors.white,
        shape: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: Colors.transparent)),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
                child: Text(_categoryList[index].name!,
                    style: TextStyle(
                      fontSize: 18,
                      color:
                          _categorySelected.name == _categoryList[index].name!
                              ? Colors.white
                              : AppTheme.colors.secondaryColor,
                      fontFamily: 'BalooBhai',
                    )),
              ),
            ]),
      ),
    );
  }

  Widget cardEvent(event) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
          constraints: BoxConstraints(),
          builder: (BuildContext context) {
            return bottomSheet(event);
          },
        );
      },
      child: Card(
          margin: EdgeInsets.fromLTRB(30, 10, 30, 0),
          color: Colors.white,
          shape: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.transparent)),
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: ListTile(
              title: Text(
                event.name,
                overflow: TextOverflow.fade,
                maxLines: 1,
                softWrap: false,
                style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'BalooBhai',
                    color: AppTheme.colors.secondaryColor),
              ),
              trailing: Text(
                datesecondToMinuteHour(event.datetime),
                overflow: TextOverflow.fade,
                maxLines: 1,
                softWrap: false,
                style: TextStyle(
                  fontSize: 15,
                  fontFamily: 'BalooBhai2',
                  color: AppTheme.colors.secondaryColor,
                ),
              ),
              leading: Container(
                alignment: Alignment.center,
                //transformAlignment: transf,
                width: 50.0,
                height: 50.0,
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 235, 235, 235),
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
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.4,
        padding: EdgeInsets.all(30),
        width: MediaQuery.of(context).size.width * 0.85,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.3,
                      child: Text(
                        event.name,
                        overflow: TextOverflow.fade,
                        maxLines: 1,
                        softWrap: false,
                        style: TextStyle(
                            fontSize: 20,
                            fontFamily: 'BalooBhai',
                            color: AppTheme.colors.greenColor),
                      ),
                    ),
                  ]),
                  Row(
                    children: [
                      Text(
                        datesecondToMinuteHour(event.datetime),
                        overflow: TextOverflow.fade,
                        maxLines: 1,
                        softWrap: false,
                        style: TextStyle(
                            fontSize: 15,
                            fontFamily: 'BalooBhai',
                            color: AppTheme.colors.greenColor),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Container(
                      height: 150,
                      padding: const EdgeInsets.all(15),
                      margin: EdgeInsets.symmetric(vertical: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(20),
                        ),
                        border: Border.all(
                          width: 1,
                          color: AppTheme.colors.secondaryColor,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Text(
                        event.description,
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'BalooBhai2',
                          color: AppTheme.colors.secondaryColor,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
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
  var hour = date.hour;
  var minute = date.minute;

  var minuteString = '$minute'.padLeft(2, '0');

  return '$hour h $minuteString';
}