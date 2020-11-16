import 'dart:core';

import 'package:cashboxregister/Models/FileStorage.dart';
import 'package:flutter/material.dart';
import 'package:cashboxregister/Models/EventProvider.dart';
import 'package:cashboxregister/Models/LogNotification.dart';
import 'package:cashboxregister/Models/NotificationType.dart';

import 'package:event/event.dart';
import 'package:provider/provider.dart';

class MiddleBar extends StatefulWidget {
  MiddleBar({Key key}) : super(key: key);

  @override
  MiddleBarState createState() => MiddleBarState();
}

class MiddleBarState extends State<MiddleBar> {
  final FileStorage storage = FileStorage("MiddleBar");

  int inStoreCustomers = 0;
  int allCustomers = 0;

  void parseAndSetState(String value) {
    if (value == "") {
      setState(() {
        inStoreCustomers = 0;
        allCustomers = 0;
      });
    } else {
      var values = value.split(";");
      setState(() {
        inStoreCustomers = int.tryParse(values[0]) ?? 0;
        allCustomers = int.tryParse(values[1]) ?? 0;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    storage.read().then(parseAndSetState);
  }

  void saveState(EventArgs args) {
    storage.write("$inStoreCustomers;$allCustomers");
  }

  void resetState(EventArgs args) {
    storage.reset();
    setState(() {
      inStoreCustomers = 0;
      allCustomers = 0;
    });
  }

  void addCustomer() {
    LogNotification(NotificationType.shopCustomer, customerEntered: true)
        .dispatch(context);
    setState(() {
      inStoreCustomers++;
      allCustomers++;
    });
  }

  void removeCustomer() {
    LogNotification(NotificationType.shopCustomer, customerEntered: false)
        .dispatch(context);
    setState(() {
      inStoreCustomers--;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    Provider.of<EventProvider>(context, listen: false)
        .saveEvent
        .subscribe(saveState);
    Provider.of<EventProvider>(context, listen: false)
        .hardResetEvent
        .subscribe(resetState);
  }

  @override
  void deactivate() {
    super.deactivate();
    Provider.of<EventProvider>(context, listen: false)
        .saveEvent
        .unsubscribe(saveState);

    Provider.of<EventProvider>(context, listen: false)
        .hardResetEvent
        .unsubscribe(resetState);
  }

  void hardReset() {
    Provider.of<EventProvider>(context, listen: false)
        .hardResetEvent
        .broadcast();
  }

  void restart() {
    Provider.of<EventProvider>(context, listen: false).resetEvent.broadcast();
  }

  void save() {
    Provider.of<EventProvider>(context, listen: false).saveEvent.broadcast();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: GestureDetector(
            onLongPress: hardReset,
            child: Material(
              shape: CircleBorder(),
              clipBehavior: Clip.antiAlias,
              color: Colors.black26,
              child: IconButton(
                  icon: Icon(
                    Icons.autorenew_outlined,
                    color: Colors.red,
                  ),
                  onPressed: restart),
            ),
          ),
        ),
        Material(
          shape: CircleBorder(),
          clipBehavior: Clip.antiAlias,
          color: Colors.blue,
          child: IconButton(
              icon: Icon(
                Icons.save_outlined,
                color: Colors.black38,
              ),
              onPressed: save),
        ),
        Expanded(
          child: ButtonBar(
            alignment: MainAxisAlignment.end,
            buttonPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            layoutBehavior: ButtonBarLayoutBehavior.constrained,
            children: [
              Text('All: $allCustomers, in store: $inStoreCustomers'),
              Material(
                shape: CircleBorder(),
                clipBehavior: Clip.antiAlias,
                color: Colors.red,
                child: IconButton(
                    icon: Icon(
                      Icons.remove_circle_outline,
                      color: Colors.white54,
                    ),
                    onPressed: removeCustomer),
              ),
              Material(
                shape: CircleBorder(),
                clipBehavior: Clip.antiAlias,
                color: Colors.green,
                child: IconButton(
                    icon: Icon(
                      Icons.add_circle_outline,
                      color: Colors.white54,
                    ),
                    onPressed: addCustomer),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
