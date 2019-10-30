import 'package:intl/intl.dart';

abstract class SoapSerializer<T> {
  String serialize(T value);
}

class SoapDateTimeSerializer extends SoapSerializer<DateTime> {
  final String format;
  SoapDateTimeSerializer(this.format);

  @override
  String serialize(DateTime value) {
    return DateFormat(format).format(value);
  }
}

class SoapIntSerializer extends SoapSerializer<int> {
  @override
  String serialize(int value) {
    return value.toString();
  }
}

class SoapDoubleSerializer extends SoapSerializer<double> {
  final int decimalPlaces;
  SoapDoubleSerializer({this.decimalPlaces = 2});

  @override
  String serialize(double value) {
    return value.toStringAsFixed(decimalPlaces);
  }
}
