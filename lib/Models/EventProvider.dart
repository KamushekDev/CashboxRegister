import 'package:event/event.dart';
import 'package:cashboxregister/Models/StateEvent.dart';

class EventProvider {
  final stateEvent = Event<StateEvent>();

  EventProvider() {
    stateEvent.subscribe((args) {
      print('Event: ${args.type}');
    });
  }
}
