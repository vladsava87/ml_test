import 'dart:io';

abstract class IBatchProcessService {
  Stream<Map<String, dynamic>> startBatchProcess(List<File> files);
  void stop();
}
