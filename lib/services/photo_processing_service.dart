import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:pandora_snap/domain/models/dog_model.dart';
import 'package:pandora_snap/domain/models/user_model.dart' as model;
import 'package:pandora_snap/domain/repositories/photo_repository.dart';
import 'package:pandora_snap/services/edge_impulse_service.dart';

enum PhotoUploadResult {
  success,
  error,
  serverOffline,
}

class PhotoProcessingService {
  final EdgeImpulseService _edgeImpulseService;
  final PhotoRepository _photoRepository;

  PhotoProcessingService({
    required EdgeImpulseService edgeImpulseService,
    required PhotoRepository photoRepository,
  })  : _edgeImpulseService = edgeImpulseService,
        _photoRepository = photoRepository;

  Future<PhotoUploadResult> processAndUpload({
    required String imagePath,
    required Dog selectedDog,
    required model.User user,
    required Rect boundingBox,
    required Size imageRenderSize,
  }) async {
    File? croppedFile;
    try {
      final originalFile = File(imagePath);
      final imageBytes = await originalFile.readAsBytes();
      final originalImage = img.decodeImage(imageBytes)!;

      final originalWidth = originalImage.width;
      final originalHeight = originalImage.height;
      int cropWidth, cropHeight, offsetX, offsetY;
      if (originalWidth / originalHeight > 3 / 4) {
        cropHeight = originalHeight;
        cropWidth = (originalHeight * 3) ~/ 4;
        offsetX = (originalWidth - cropWidth) ~/ 2;
        offsetY = 0;
      } else {
        cropWidth = originalWidth;
        cropHeight = (originalWidth * 4) ~/ 3;
        offsetX = 0;
        offsetY = (originalHeight - cropHeight) ~/ 2;
      }

      final croppedImage = img.copyCrop(originalImage, x: offsetX, y: offsetY, width: cropWidth, height: cropHeight);
      croppedFile = File('${originalFile.parent.path}/cropped_${originalFile.uri.pathSegments.last}');
      await croppedFile.writeAsBytes(img.encodeJpg(croppedImage));

      final scaleX = croppedImage.width / imageRenderSize.width;
      final scaleY = croppedImage.height / imageRenderSize.height;

      final normalizedBBox = Rect.fromLTRB(
        min(boundingBox.left, boundingBox.right) * scaleX,
        min(boundingBox.top, boundingBox.bottom) * scaleY,
        max(boundingBox.left, boundingBox.right) * scaleX,
        max(boundingBox.top, boundingBox.bottom) * scaleY,
      );

      final dogLabel = selectedDog.name.toLowerCase();

      final status = await _edgeImpulseService.uploadImage(
        imageFile: croppedFile,
        label: dogLabel,
        boundingBox: normalizedBBox,
      );

      await _photoRepository.uploadPhoto(croppedFile, selectedDog, user);

      if (status == UploadStatus.success) {
        return PhotoUploadResult.success;
      } else {
        return PhotoUploadResult.serverOffline;
      }
    } catch (e) {
      debugPrint('Ocorreu um erro no processamento: $e');
      return PhotoUploadResult.error;
    } finally {
      await croppedFile?.delete();
    }
  }
}