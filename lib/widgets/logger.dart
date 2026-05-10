import 'package:logger/logger.dart';

final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 0, // Number of method calls to show
    errorMethodCount: 5, // Number of method calls if stacktrace is provided
    lineLength: 120, // Width of each log line
    colors: true,
    printEmojis: true,
    dateTimeFormat: DateTimeFormat.none,
  ),
);
