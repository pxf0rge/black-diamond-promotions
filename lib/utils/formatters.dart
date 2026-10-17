import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static String _symbol = '\$';

  static void setCurrencySymbol(String symbol) {
    _symbol = symbol;
  }

  static NumberFormat get _currency => NumberFormat.currency(symbol: _symbol);
  static final DateFormat _time = DateFormat('h:mm a');
  static final DateFormat _date = DateFormat('MMM d, yyyy');
  static final DateFormat _dateTime = DateFormat('MMM d, yyyy • h:mm a');

  static String currency(double amount) {
    if (amount == 0) return 'FREE';
    return _currency.format(amount);
  }

  static String time(DateTime dateTime) => _time.format(dateTime);
  static String date(DateTime dateTime) => _date.format(dateTime);
  static String dateTime(DateTime dateTime) => _dateTime.format(dateTime);
}
