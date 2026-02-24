import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ml_test/infrastructure/services/process_documents_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel(
    'com.vladsava.ml_test/document_processing',
  );
  final List<MethodCall> log = <MethodCall>[];

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          log.add(methodCall);
          if (methodCall.method == 'processDocument') {
            return '/path/to/processed.pdf';
          }
          return null;
        });
    log.clear();
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test(
    'processDocument calls platform channel with correct arguments',
    () async {
      final service = ProcessDocumentsService();
      final result = await service.processDocument('/path/to/image.jpg');

      expect(result, '/path/to/processed.pdf');
      expect(log, hasLength(1));
      expect(log.first.method, 'processDocument');
      expect(log.first.arguments, {'imagePath': '/path/to/image.jpg'});
    },
  );
}
