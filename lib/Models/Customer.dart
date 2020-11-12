class Customer {
  Customer(this.number, this.entryTime, {this.servingTime, DateTime exitTime})
      : this.exitTime = exitTime ?? DateTime.now();

  Customer.fromOld(Customer old, this.exitTime, this.servingTime)
      : entryTime = old.entryTime,
        number = old.number;

  Duration get waitTime => exitTime.difference(entryTime);

  final DateTime exitTime;
  final Duration servingTime;
  final DateTime entryTime;
  final int number;
}
