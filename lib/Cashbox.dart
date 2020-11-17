import 'dart:collection';
import 'dart:convert';

import 'package:cashboxregister/Models/EventProvider.dart';
import 'package:cashboxregister/Models/FileStorage.dart';
import 'package:event/event.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:core';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:cashboxregister/Models/LogNotification.dart';
import 'package:cashboxregister/Models/Customer.dart';
import 'package:cashboxregister/Models/NotificationType.dart';
import 'package:provider/provider.dart';

class CashboxState extends State<Cashbox> {
  bool enabled = false;
  Widget alert;
  int currentCustomersNumber = 1;
  DateTime lastServe;
  int elapsedSeconds = 0;
  int elapsedSecondsStart = 0;
  Timer timer;

  final int number;
  final Stopwatch stopwatch = Stopwatch();
  final Queue<Customer> customers = Queue();
  final FileStorage storage;

  void parseAndSetState(String value) {
    if (value != "") {
      var values = value.split(";");
      setState(() {
        enabled = values[0].toLowerCase().contains("true");
        currentCustomersNumber = int.parse(values[1]);
        lastServe = DateTime.tryParse(values[2])?.toLocal();
        elapsedSeconds = elapsedSecondsStart = int.parse(values[3]);
        var isTimerEnabled = values[4].toLowerCase().contains("true");
        if (isTimerEnabled) startTimer();
        for (int i = 5; i < values.length; i++) {
          var json = jsonDecode(values[i]);
          customers.add(Customer.fromJson(json));
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    storage.read().then(parseAndSetState);
  }

  void saveState(EventArgs args) {
    var result =
        "$enabled;$currentCustomersNumber;${lastServe?.toUtc().toString()};$elapsedSeconds;${timer?.isActive ?? false}";

    var list = customers.toList();

    try {
      list.forEach((element) {
        result += ";${jsonEncode(element)}";
      });
    } catch (ex) {
      print(ex.toString());
      throw ex;
    }
    storage.write(result);
  }

  void resetState(EventArgs args) {
    storage.reset();
    setState(() {
      enabled = false;
      currentCustomersNumber = 1;
      lastServe = null;
      elapsedSeconds = 0;
      elapsedSecondsStart = 0;
      customers.clear();
      if (timer?.isActive == true) stopTimer();
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
    stopTimer();
    Provider.of<EventProvider>(context, listen: false)
        .saveEvent
        .unsubscribe(saveState);

    Provider.of<EventProvider>(context, listen: false)
        .hardResetEvent
        .unsubscribe(resetState);
    super.deactivate();
  }

  CashboxState(this.number) : storage = FileStorage("Cashbox$number") {
    alert = AlertDialog(
      title: Text("Касса не работает"),
      content: Text('Включить кассу $number'),
      actions: [
        TextButton(
          child: Text('Да'),
          onPressed: () {
            Navigator.of(context).pop(true);
          },
        ),
        TextButton(
          child: Text('Нет'),
          onPressed: () {
            Navigator.of(context).pop(false);
          },
        ),
      ],
      elevation: 24,
    );
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), onTick);
    stopwatch.reset();
    stopwatch.start();
  }

  void stopTimer() {
    timer?.cancel();
    stopwatch.stop();
    stopwatch.reset();
    timer = null;
    elapsedSeconds = 0;
    elapsedSecondsStart = 0;
  }

  void resetTimer() {
    stopTimer();
    startTimer();
  }

  void onTick(Timer timer) {
    setState(() {
      elapsedSeconds = elapsedSecondsStart +
          (stopwatch.elapsedMilliseconds / 1000).truncate();
    });
  }

  Future<void> toggleCashbox() async {
    if (enabled && customers.isNotEmpty) {
      var alert = AlertDialog(
        title: Text("Касса не пуста"),
        content: Text('Отметить покупателей на $number кассе ушедшими?'),
        actions: [
          TextButton(
            child: Text('Да'),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
          TextButton(
            child: Text('Нет'),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
        ],
        elevation: 24,
      );

      var result = await showDialog(
        context: context,
        child: alert,
        barrierDismissible: false,
      );
      if (!result) return;

      while (customers.isNotEmpty) {
        popCustomer();
      }
    }

    setState(() {
      enabled = !enabled;
    });
    LogNotification(NotificationType.cashboxAvailability,
            cashboxNumber: number, cashboxBecomesActive: enabled)
        .dispatch(context);
  }

  Future<bool> shouldOperate() async {
    if (!enabled) {
      var result = await showDialog(
        context: context,
        child: alert,
        barrierDismissible: false,
      );

      if (!result) return false;
      toggleCashbox();
    }
    return true;
  }

  Future<void> addCustomer() async {
    if (!await shouldOperate()) return;

    setState(() {
      var entryDate = DateTime.now();
      if (customers.isEmpty) {
        lastServe = entryDate;
        startTimer();
      }
      customers.add(Customer(currentCustomersNumber, entryDate));
      currentCustomersNumber++;
    });
  }

  Future<void> removeCustomer() async {
    if (!await shouldOperate()) return;

    if (customers.isEmpty) {
      var zeroAlert = AlertDialog(
        title: Text("Отрицательное число покупателей"),
        content: Text("Операция на $number кассе будет проигнорована"),
      );
      await showDialog(
        context: context,
        child: zeroAlert,
        barrierDismissible: true,
      );
      return;
    }
    popCustomer();
  }

  void popCustomer() {
    setState(() {
      var customer = customers.first;
      customers.removeFirst();
      var exitTime = DateTime.now();
      var servingTime = exitTime.difference(lastServe);

      lastServe = exitTime;

      var completeCustomer = Customer.fromOld(customer, exitTime, servingTime);

      LogNotification(NotificationType.cashboxCustomer,
              cashboxNumber: number, customer: completeCustomer)
          .dispatch(context);

      if (customers.isNotEmpty)
        resetTimer();
      else
        stopTimer();
    });
  }

  void silentlyRemoveCustomer() {
    setState(() {
      if (customers.isNotEmpty) customers.removeLast();
    });
  }

  @override
  Widget build(BuildContext context) {
    final double size = 50;

    return Column(
      children: [
        Text(
          '$elapsedSeconds',
          style: Theme.of(context).textTheme.headline6,
        ),
        Card(
          shape: CircleBorder(),
          child: Material(
            shape: CircleBorder(),
            color: enabled ? Colors.teal : Colors.black12,
            child: InkWell(
              customBorder: CircleBorder(),
              splashColor: Colors.blue.withAlpha(30),
              onTap: toggleCashbox,
              child: Container(
                child: Center(
                  child: Text(customers.length.toString(),
                      style: Theme.of(context).textTheme.headline3),
                ),
                width: size,
                height: size,
                decoration: BoxDecoration(shape: BoxShape.circle),
              ),
            ),
          ),
        ),
        Text('$currentCustomersNumber'),
        IconButton(
          padding: EdgeInsets.symmetric(vertical: 5),
          iconSize: size,
          icon: Icon(Icons.add_circle_outline, color: Colors.green),
          onPressed: addCustomer,
        ),
        GestureDetector(
          onLongPress: silentlyRemoveCustomer,
          child: IconButton(
            padding: EdgeInsets.zero,
            iconSize: size,
            icon: Icon(Icons.remove_circle_outline, color: Colors.red),
            onPressed: removeCustomer,
          ),
        )
      ],
    );
  }
}

class Cashbox extends StatefulWidget {
  final int number;

  Cashbox(this.number, {Key key}) : super(key: key);

  @override
  CashboxState createState() => CashboxState(number);
}
