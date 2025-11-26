import 'package:intl/intl.dart';

String formatDateByddMMYYYY(DateTime dateTime) {
  return DateFormat("dd-MM-yyyy").format(dateTime);
}

String formatDateByddMMYYYYHHmm(DateTime dateTime) {
  return DateFormat("dd-MM-yyyy HH:mm").format(dateTime);
}

String formatDateByddMMYYYYnHHmm(DateTime dateTime) {
  return DateFormat("dd-MM-yyyy\nHH:mm").format(dateTime);
}
