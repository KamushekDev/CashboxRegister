import 'package:event/event.dart';
import 'package:cashboxregister/Models/StateEventType.dart';

class StateEvent extends EventArgs {
  final StateEventType type;

  StateEvent(this.type);
}
