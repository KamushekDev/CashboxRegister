import 'dart:async';
import 'dart:io';
import 'dart:core';

import 'package:cashboxregister/Logger.dart';
import 'package:cashboxregister/Models/ResetNotification.dart';
import 'package:event/event.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cashboxregister/MiddleBar.dart';
import 'package:cashboxregister/Models/EventProvider.dart';
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

  _CashboxRegisterState(this.numberOfCashboxes);

  bool onReset(Notification notification) {
    print("reset event");
    setState(() {
      currentKey++;
    });
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: NotificationListener<ResetNotification>(
        onNotification: onReset,
        child: Logger(
          key: ValueKey<int>(currentKey),
          child: Column(
            children: [
              MiddleBar(),
              Row(
                children: Iterable.generate(numberOfCashboxes)
                    .map((i) => Cashbox(i + 1))
                    .cast<Cashbox>()
                    .toList(),
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
