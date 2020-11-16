import 'package:event/event.dart';

class EventProvider {
  final saveEvent = Event();

  EventProvider() {
    saveEvent.subscribe((args) {
      print('Save event was triggered.');
    });
  }
}
