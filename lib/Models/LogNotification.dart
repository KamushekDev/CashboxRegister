import 'dart:convert';
import 'dart:core';
import 'package:flutter/material.dart';

import 'Customer.dart';
import 'NotificationType.dart';

class LogNotification extends Notification {
  final NotificationType type;
  int cashboxNumber;
  bool cashboxBecomesActive;
  bool customerEntered;

  Customer customer;

  DateTime time;

  @override
  String toString() {
    switch (type) {
      case NotificationType.cashboxAvailability:
        return '[$time] Cashbox $cashboxNumber becomes ${cashboxBecomesActive ? 'active' : 'inactive'}';
        break;
      case NotificationType.cashboxCustomer:
        return '[$time] Customer ${customer.number} leaved $cashboxNumber cashbox. Entry time: ${customer.entryTime}. Wait time: ${customer.waitTime}. Serving time: ${customer.servingTime}';
        break;
      case NotificationType.shopCustomer:
        return '[$time] Customer ${customerEntered ? 'entered' : 'left'} the shop.';
        break;
    }
    //todo specify the exception type & message
    throw Exception("argument exception");
  }

  Map<String, dynamic> toJson() => {
        'type': type.toString(),
        'cashboxNumber': cashboxNumber,
        'cashboxBecomesActive': cashboxBecomesActive,
        'customerEntered': customerEntered,
        'customer': jsonEncode(customer),
        'time': time.toString(),
      };

  LogNotification(
    this.type, {
    time,
    this.cashboxNumber,
    this.cashboxBecomesActive,
    this.customerEntered,
    this.customer,
  }) : this.time = time ?? DateTime.now();
}
