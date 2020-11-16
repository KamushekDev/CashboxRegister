import 'package:event/event.dart';

class EventProvider {
  final saveEvent = Event();
  final resetEvent = Event();
  final hardResetEvent = Event();

  EventProvider() {
    saveEvent.subscribe((args) {
      print('Save event was triggered.');
    });
    hardResetEvent.subscribe((args) {
      print('Hard reset event was triggered.');
    });
    resetEvent.subscribe((args) {
      print('Reset event was triggered.');
    });
  }
}
