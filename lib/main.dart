import 'dart:core';

import 'package:cashboxregister/Logger.dart';
import 'package:event/event.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cashboxregister/MiddleBar.dart';
import 'package:cashboxregister/Models/EventProvider.dart';
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

  void onReset(EventArgs args) {
    setState(() {
      currentKey++;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    Provider.of<EventProvider>(context, listen: false)
        .resetEvent
        .subscribe(onReset);
  }

  @override
  void deactivate() {
    super.deactivate();
    Provider.of<EventProvider>(context, listen: false)
        .resetEvent
        .unsubscribe(onReset);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Logger(
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
    );
  }
}
