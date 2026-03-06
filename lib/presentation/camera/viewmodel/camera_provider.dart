import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:permission_handler/permission_handler.dart';

enum CameraDetectionMode { none, text, face, barcode, label, object }

class CameraState {
  final CameraController? controller;
  final bool isInitialized;
  final bool hasPermission;
  final CameraDetectionMode currentMode;
  final dynamic detectionResult; // TextBlock list, Face list, etc.
  final bool isProcessing;

  CameraState({
    this.controller,
    this.isInitialized = false,
    this.hasPermission = false,
    this.currentMode = CameraDetectionMode.none,
    this.detectionResult,
    this.isProcessing = false,
  });

  CameraState copyWith({
    CameraController? controller,
    bool? isInitialized,
    bool? hasPermission,
    CameraDetectionMode? currentMode,
    dynamic detectionResult,
    bool clearDetectionResult = false,
    bool? isProcessing,
  }) {
    return CameraState(
      controller: controller ?? this.controller,
      isInitialized: isInitialized ?? this.isInitialized,
      hasPermission: hasPermission ?? this.hasPermission,
      currentMode: currentMode ?? this.currentMode,
      detectionResult: clearDetectionResult
          ? null
          : (detectionResult ?? this.detectionResult),
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }
}

class CameraNotifier extends Notifier<CameraState> {
  final TextRecognizer _textRecognizer = TextRecognizer();
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(enableContours: true, enableLandmarks: true),
  );
  final BarcodeScanner _barcodeScanner = BarcodeScanner();
  final ImageLabeler _imageLabeler = ImageLabeler(
    options: ImageLabelerOptions(confidenceThreshold: 0.6),
  );
  final ObjectDetector _objectDetector = ObjectDetector(
    options: ObjectDetectorOptions(
      mode: DetectionMode.stream,
      classifyObjects: true,
      multipleObjects: true,
    ),
  );

  List<CameraDescription> _cameras = [];
  bool _mounted = true;

  @override
  CameraState build() {
    _mounted = true;

    ref.onDispose(() {
      _mounted = false;
      _textRecognizer.close();
      _faceDetector.close();
      _barcodeScanner.close();
      _imageLabeler.close();
      _objectDetector.close();
      state.controller?.dispose();
    });

    Future.microtask(_initCamera);
    return CameraState();
  }

  Future<void> _initCamera() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        final controller = CameraController(
          _cameras.first,
          ResolutionPreset.medium,
          enableAudio: false,
          imageFormatGroup: Platform.isAndroid
              ? ImageFormatGroup.nv21
              : ImageFormatGroup.bgra8888,
        );

        await controller.initialize();
        if (!_mounted) return;

        state = state.copyWith(
          controller: controller,
          isInitialized: true,
          hasPermission: true,
        );

        controller.startImageStream(_processCameraImage);
      }
    } else {
      if (_mounted) state = state.copyWith(hasPermission: false);
    }
  }

  void setMode(CameraDetectionMode mode) {
    if (state.currentMode == mode) return;
    state = state.copyWith(currentMode: mode, clearDetectionResult: true);
  }

  Future<void> _processCameraImage(CameraImage image) async {
    if (state.isProcessing ||
        state.currentMode == CameraDetectionMode.none ||
        state.controller == null) {
      return;
    }

    final processingMode = state.currentMode;
    state = state.copyWith(isProcessing: true);

    try {
      final inputImage = _inputImageFromCameraImage(image);
      if (inputImage == null) {
        if (_mounted) state = state.copyWith(isProcessing: false);
        return;
      }

      dynamic result;
      switch (processingMode) {
        case CameraDetectionMode.text:
          result = await _textRecognizer.processImage(inputImage);
          break;
        case CameraDetectionMode.face:
          result = await _faceDetector.processImage(inputImage);
          break;
        case CameraDetectionMode.barcode:
          result = await _barcodeScanner.processImage(inputImage);
          break;
        case CameraDetectionMode.label:
          result = await _imageLabeler.processImage(inputImage);
          break;
        case CameraDetectionMode.object:
          result = await _objectDetector.processImage(inputImage);
          break;
        case CameraDetectionMode.none:
          break;
      }

      if (_mounted) {
        if (state.currentMode == processingMode) {
          state = state.copyWith(detectionResult: result, isProcessing: false);
        } else {
          state = state.copyWith(isProcessing: false);
        }
      }
    } catch (e) {
      debugPrint('Error processing camera image: $e');
      if (_mounted) {
        state = state.copyWith(isProcessing: false);
      }
    }
  }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    if (state.controller == null) return null;

    final camera = _cameras.firstWhere(
      (c) => c.lensDirection == state.controller!.description.lensDirection,
    );
    final sensorOrientation = camera.sensorOrientation;

    final rotation =
        InputImageRotationValue.fromRawValue(sensorOrientation) ??
        InputImageRotation.rotation90deg;

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null ||
        (Platform.isAndroid && format != InputImageFormat.nv21) ||
        (Platform.isIOS && format != InputImageFormat.bgra8888)) {
      return null;
    }

    if (image.planes.isEmpty) return null;

    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize = Size(
      image.width.toDouble(),
      image.height.toDouble(),
    );

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: imageSize,
        rotation: rotation,
        format: format,
        bytesPerRow: image.planes[0].bytesPerRow,
      ),
    );
  }
}

final cameraProvider =
    NotifierProvider.autoDispose<CameraNotifier, CameraState>(
      CameraNotifier.new,
    );
