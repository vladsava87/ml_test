import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:isolate';
import 'package:ml_test/domain/enums/e_batch_item_status.dart';
import 'package:ml_test/domain/enums/e_face_detector_profie.dart';
import 'package:ml_test/domain/enums/e_image_type.dart';
import 'package:ml_test/infrastructure/services/image_ml_service.dart';
import 'package:ml_test/infrastructure/services/image_process_service.dart';
import 'package:ml_test/infrastructure/services/process_documents_service.dart';
import 'package:ml_test/infrastructure/services/text_ml_service.dart';
import 'package:ml_test/domain/enums/e_batch_item_step.dart';
import 'package:flutter/services.dart';
import 'package:ml_test/domain/interfaces/services/i_batch_process_service.dart';
import 'package:get/get.dart';
import 'package:ml_test/domain/interfaces/services/i_pdf_service.dart';
import 'package:ml_test/infrastructure/services/pdf_service.dart';

class BatchProcessService implements IBatchProcessService {
  static void _batchIsolateEntry(Map<String, dynamic> params) async {
    final RootIsolateToken token = params['token'];
    final SendPort sendPort = params['sendPort'];
    final List<String> paths = params['paths'];
    BackgroundIsolateBinaryMessenger.ensureInitialized(token);

    Get.put<IPdfService>(PdfService());

    final controlPort = ReceivePort();
    sendPort.send({'type': 'controlPort', 'port': controlPort.sendPort});

    bool isStopped = false;
    controlPort.listen((message) {
      if (message == 'stop') {
        isStopped = true;
      }
    });

    final textMl = TextMlService();
    final imageMl = ImageMlService();
    final processService = ProcessDocumentsService();
    final imageProcess = ImageProcessService();

    for (int i = 0; i < paths.length; i++) {
      if (isStopped) {
        sendPort.send({'type': 'stopped'});
        controlPort.close();
        return;
      }

      final path = paths[i];
      final file = File(path);

      sendPort.send({
        'type': 'status',
        'index': i,
        'status': EBatchItemStatus.processing,
      });

      try {
        sendPort.send({
          'type': 'step',
          'index': i,
          'step': EBatchItemStep.normalizingImage.name,
        });
        final normalizedFile = await imageProcess.normalizeImage(file);
        final processingFile = normalizedFile ?? file;

        if (isStopped) {
          sendPort.send({'type': 'stopped'});
          controlPort.close();
          return;
        }

        sendPort.send({
          'type': 'step',
          'index': i,
          'step': EBatchItemStep.analyzingImage.name,
        });
        final faces = await imageMl.detectFacesFromFile(
          processingFile,
          EFaceDetectorProfie.accurate,
        );

        if (isStopped) {
          sendPort.send({'type': 'stopped'});
          controlPort.close();
          return;
        }

        EImageType detectedType = EImageType.unknown;
        String? resultPath;
        String? extractedText;

        if (faces.isNotEmpty) {
          detectedType = EImageType.person;
          sendPort.send({
            'type': 'step',
            'index': i,
            'step': EBatchItemStep.applyingBwFilter.name,
          });
          resultPath = await imageProcess.applyFaceBw(
            file: processingFile,
            faces: faces,
          );
        } else {
          sendPort.send({
            'type': 'step',
            'index': i,
            'step': EBatchItemStep.recognizingText.name,
          });
          final recognized = await textMl.recognizeTextFromFile(processingFile);
          extractedText = recognized.text.trim();

          if (isStopped) {
            sendPort.send({'type': 'stopped'});
            controlPort.close();
            return;
          }

          final hasDocText =
              extractedText.length >= 30 || recognized.blocks.length >= 2;

          if (hasDocText) {
            detectedType = EImageType.document;
            sendPort.send({
              'type': 'step',
              'index': i,
              'step': EBatchItemStep.calculatingBounds.name,
            });

            List<Offset>? textBounds;
            if (recognized.blocks.isNotEmpty) {
              double maxWidth = 0;
              final List<Map<String, dynamic>> blockData = [];
              for (final block in recognized.blocks) {
                if (block.cornerPoints.isEmpty) continue;
                int minX = block.cornerPoints[0].x,
                    maxX = block.cornerPoints[0].x;
                for (final p in block.cornerPoints) {
                  if (p.x < minX) minX = p.x;
                  if (p.x > maxX) maxX = p.x;
                }
                final double width = (maxX - minX).toDouble();
                if (width > maxWidth) maxWidth = width;
                blockData.add({'points': block.cornerPoints, 'width': width});
              }

              final List<Point<int>> allPoints = [];
              for (final data in blockData) {
                if (data['width'] > maxWidth * 0.15) {
                  allPoints.addAll(data['points'] as List<Point<int>>);
                }
              }

              if (allPoints.length < 4) {
                for (final block in recognized.blocks) {
                  allPoints.addAll(block.cornerPoints);
                }
              }

              if (allPoints.length >= 4) {
                int minX = 10000000, maxX = -1, minY = 10000000, maxY = -1;
                for (final point in allPoints) {
                  if (point.x < minX) minX = point.x;
                  if (point.x > maxX) maxX = point.x;
                  if (point.y < minY) minY = point.y;
                  if (point.y > maxY) maxY = point.y;
                }

                if (minX <= maxX && minY <= maxY) {
                  final double centroidX = (minX + maxX) / 2.0;
                  final double centroidY = (minY + maxY) / 2.0;
                  const double paddingScale = 1.12;

                  Offset expandPoint(int px, int py) {
                    return Offset(
                      (centroidX + (px - centroidX) * paddingScale),
                      (centroidY + (py - centroidY) * paddingScale),
                    );
                  }

                  textBounds = [
                    expandPoint(minX, minY), // TL
                    expandPoint(maxX, minY), // TR
                    expandPoint(maxX, maxY), // BR
                    expandPoint(minX, maxY), // BL
                  ];
                }
              }
            }

            sendPort.send({
              'type': 'step',
              'index': i,
              'step': EBatchItemStep.processingDocument.name,
            });
            resultPath = await processService.processDocument(
              processingFile.path,
              points: textBounds,
            );
          }
        }

        if (isStopped) {
          sendPort.send({'type': 'stopped'});
          controlPort.close();
          return;
        }

        sendPort.send({
          'type': 'step',
          'index': i,
          'step': EBatchItemStep.savingResult.name,
        });
        sendPort.send({
          'type': 'result',
          'index': i,
          'detectedType': detectedType,
          'resultPath': resultPath,
          'extractedText': extractedText,
        });
      } catch (e) {
        if (isStopped) {
          sendPort.send({'type': 'stopped'});
          controlPort.close();
          return;
        }
        sendPort.send({
          'type': 'status',
          'index': i,
          'status': EBatchItemStatus.error,
          'error': e.toString(),
        });
      }
    }

    sendPort.send({'type': 'complete'});
    controlPort.close();
  }

  Isolate? _currentIsolate;
  ReceivePort? _currentReceivePort;
  SendPort? _currentControlPort;
  Timer? _stopTimeout;

  StreamController<Map<String, dynamic>>? _streamController;

  @override
  Stream<Map<String, dynamic>> startBatchProcess(List<File> files) {
    _streamController = StreamController<Map<String, dynamic>>();
    _currentReceivePort = ReceivePort();

    final paths = files.map((f) => f.path).toList();
    final token = RootIsolateToken.instance!;

    Isolate.spawn(_batchIsolateEntry, {
      'token': token,
      'sendPort': _currentReceivePort!.sendPort,
      'paths': paths,
    }).then((isolate) {
      _currentIsolate = isolate;
      _currentReceivePort?.listen((message) {
        if (message['type'] == 'controlPort') {
          _currentControlPort = message['port'];
        } else if (message['type'] == 'complete') {
          _streamController?.add(message);
          _cleanup();
        } else if (message['type'] == 'stopped') {
          _cleanup();
        } else {
          _streamController?.add(message);
        }
      });
    });

    return _streamController!.stream;
  }

  @override
  void stop() {
    if (_currentControlPort == null) {
      _cleanup();
      return;
    }

    _currentControlPort?.send('stop');

    _stopTimeout?.cancel();
    _stopTimeout = Timer(const Duration(seconds: 5), () {
      _cleanup();
    });
  }

  void _cleanup() {
    _stopTimeout?.cancel();
    _stopTimeout = null;

    _currentReceivePort?.close();
    _streamController?.close();

    _currentIsolate?.kill(priority: Isolate.beforeNextEvent);

    _currentReceivePort = null;
    _currentIsolate = null;
    _currentControlPort = null;
    _streamController = null;
  }
}
