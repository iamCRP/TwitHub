import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

String formatTimestamp(Timestamp timestep) {
  DateTime dateTime = timestep.toDate();
  return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
}
