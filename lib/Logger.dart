import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:core';

import 'package:cashboxregister/Models/FileStorage.dart';
import 'package:event/event.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cashboxregister/MiddleBar.dart';
import 'package:cashboxregister/Models/EventProvider.dart';
import 'package:cashboxregister/Models/LogNotification.dart';
import 'package:cashboxregister/Models/NotificationType.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import 'dart:async';
import 'dart:io';
import 'dart:core';

class Logger extends StatefulWidget {
  final Widget child;

  Logger({this.child, Key key}) : super(key: key);

  @override
  LoggerState createState() => LoggerState(child);
}

class LoggerState extends State<Logger> {
  final Widget child;
  final ScrollController controller = ScrollController();
  final FileStorage storage = FileStorage("Logger");

  EventProvider eventProvider;
  String text = '';

  LoggerState(this.child);

  bool onLog(LogNotification notification) {
    try {
      String message = jsonEncode(notification);
      //print(message);
      setState(() {
        text += message + ',';
      });
      return true;
    } catch (ex) {
      print(ex.toString());
      throw ex;
      return false;
    }
  }

  void saveState(EventArgs args) {
    storage.write(text);
  }

  void resetState(EventArgs args) {
    storage.reset();
    setState(() {
      text = "";
    });
  }

  @override
  void initState() {
    super.initState();
    storage.read().then((value) => {
          setState(() => {text = value})
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

  @override
  Widget build(BuildContext context) {
    var listener = NotificationListener<LogNotification>(
      onNotification: onLog,
      child: Column(children: [
        Expanded(
          child: SingleChildScrollView(
            controller: controller,
            child: SelectableText(text),
          ),
        ),
        child,
      ]),
    );
    if (controller.hasClients)
      controller.animateTo(controller.position.maxScrollExtent,
          duration: Duration(milliseconds: 200), curve: Curves.decelerate);
    return listener;
  }
}
