// logging_util.dart

import 'dart:io';

import 'package:intl/intl.dart';
import 'package:logging/logging.dart';

class LoggingUtil {
  static final log = Logger('Main');

  static Future<void> initializeLogging() async {
    final now = DateTime.now();
    final fileName =
        '../log/logfile${DateFormat('ddMMyyyy.HH.mm.ss.000000000').format(now)}.txt';
    try {
      final file = File(fileName)..createSync(recursive: true);
      final fileSink = file.openWrite(mode: FileMode.writeOnlyAppend);

      Logger.root.level = Level.ALL;
      Logger.root.onRecord.listen((record) {
        fileSink
            .writeln('${record.level.name}: ${record.time}: ${record.message}');
      });

      // Ensure the fileSink is closed properly when the app is terminated
      // Uncomment if you have a way to call this at app close
      fileSink.close();
    } catch (e) {
      log.severe('Error opening file: $e');
    }
  }
}
