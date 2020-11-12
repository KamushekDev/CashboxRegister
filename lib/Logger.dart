import 'dart:async';
import 'dart:io';
import 'dart:core';

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

  EventProvider eventProvider;
  String text = '';

  LoggerState(this.child);

  bool onLog(LogNotification notification) {
    String message = notification.toString();
    print(message);
    setState(() {
      text += message + '\n';
    });
    return true;
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
          duration: Duration(milliseconds: 400), curve: Curves.decelerate);
    return listener;
  }
}
