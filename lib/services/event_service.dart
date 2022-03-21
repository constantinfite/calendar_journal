import 'package:calendar_journal/models/events.dart';
import 'package:calendar_journal/repositories/repository_event.dart';

class EventService {
  late Repository _repository;

  EventService() {
    _repository = Repository();
  }

  //Create data
  saveEvent(Event event) async {
    return await _repository.insertData('events', event.eventMap());
  }

  //Update data
  updateEvent(Event event) async {
    return await _repository.updateData('events', event.eventMap());
  }

  // Read data from table
  readEvents() async {
    return await _repository.readData('events');
  }

  //Read data from table by Id
  readEventById(eventId) async {
    return await _repository.readDataById('events', eventId);
  }

  // Delete data from table
  deleteEvent(eventId) async {
    return await _repository.deleteData('events', eventId);
  }
}
