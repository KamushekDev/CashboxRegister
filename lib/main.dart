import 'dart:async';
import 'dart:io';
import 'dart:core';

import 'package:event/event.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cashboxregister/MiddleBar.dart';
import 'file:///C:/Users/Kamushek/Source/Repos/CashboxRegister/cashboxregister/lib/Logger.dart';
import 'package:cashboxregister/Models/EventProvider.dart';
import 'package:cashboxregister/Models/StateEvent.dart';
import 'package:cashboxregister/Models/StateEventType.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import 'Cashbox.dart';

String title = "Кассовик для Падерно";

void main() {
  runApp(
    MaterialApp(
      title: title,
      home: Provider<EventProvider>(
        create: (_) => EventProvider(),
        child: CashboxRegister(),
      ),
    ),
  );
}

class CashboxRegister extends StatefulWidget {
  CashboxRegister({Key key}) : super(key: key);

  final int numberOfCashboxes = 5;

  @override
  _CashboxRegisterState createState() =>
      _CashboxRegisterState(numberOfCashboxes);
}

class _CashboxRegisterState extends State<CashboxRegister> {
  final int numberOfCashboxes;

  int currentKey = 1;
  EventProvider eventProvider;

  _CashboxRegisterState(this.numberOfCashboxes);

  void resetKey(StateEvent args) {
    eventProvider.stateEvent.unsubscribe(resetKey);
    if (args.type == StateEventType.Reset)
      setState(() {
        currentKey++;
      });
  }

  @override
  Widget build(BuildContext context) {
    if (eventProvider == null) {
      setState(() {
        eventProvider = Provider.of<EventProvider>(context);
      });
      eventProvider.stateEvent.subscribe(resetKey);
    }

    var cashboxes = List<Cashbox>();
    for (int i = 1; i <= numberOfCashboxes; i++) {
      cashboxes.add(Cashbox(i));
    }

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Logger(
        key: ValueKey<int>(currentKey),
        child: Column(
          children: [
            MiddleBar(),
            Row(
              children: cashboxes,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            ),
          ],
        ),
      ),
    );
  }
}
