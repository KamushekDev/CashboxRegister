import 'dart:core';

import 'package:cashboxregister/Models/ResetNotification.dart';
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
  int inStoreCustomers = 0;
  int allCustomers = 0;

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

  void restart() {
    //todo: reset
    ResetNotification().dispatch(context);
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
            //todo add action
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
          //todo add action
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
