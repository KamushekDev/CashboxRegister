class Customer {
  Customer(this.number, this.entryTime, {this.servingTime, DateTime exitTime})
      : this.exitTime = exitTime ?? DateTime.now();

  Customer.fromOld(Customer old, this.exitTime, this.servingTime)
      : entryTime = old.entryTime,
        number = old.number;

  Customer.fromJson(Map<String, dynamic> json)
      : exitTime = DateTime.tryParse(json["exitTime"])?.toLocal(),
        servingTime = json["servingTime"] != null
            ? Duration(milliseconds: json["servingTime"])
            : null,
        entryTime = DateTime.tryParse(json["entryTime"])?.toLocal(),
        number = json["number"];

  Map<String, dynamic> toJson() => {
        'exitTime': exitTime?.toUtc().toString(),
        'servingTime': servingTime?.inMilliseconds,
        'entryTime': entryTime?.toUtc().toString(),
        'number': number,
      };

  Duration get waitTime => exitTime.difference(entryTime);

  final DateTime exitTime;
  final Duration servingTime;
  final DateTime entryTime;
  final int number;
}
