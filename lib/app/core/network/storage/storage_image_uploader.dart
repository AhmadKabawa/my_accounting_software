import 'dart:math';

import 'package:dio/dio.dart';
import 'package:accounting_software/app/core/foundation/config/app_config.dart';
import 'package:accounting_software/app/core/foundation/image/image_upload.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/core/network/api_client_interface.dart';
import 'package:accounting_software/app/core/network/api_end_points.dart';
import 'package:accounting_software/app/core/network/storage/storage_target.dart';

/// Uploads raw image bytes to Supabase Storage through the shared API client.
class StorageImageUploader {
  StorageImageUploader(
    this._apiClient, {
    DateTime Function()? clock,
    Random? random,
  }) : _clock = clock ?? DateTime.now,
       _random = random ?? Random();

  final IApiClient _apiClient;
  final DateTime Function() _clock;
  final Random _random;

  Future<ApiResult<String>> upload({
    required StorageTarget target,
    required ImageUpload image,
  }) {
    final stamp = _clock().microsecondsSinceEpoch;
    final extension = _fileExtension(image);
    final path =
        '${target.folder}/$stamp-${_random.nextInt(0x7fffffff)}.$extension';

    return _apiClient.post<String>(
      AppEndpoint('/storage/v1/object/${target.bucket}/$path'),
      data: image.bytes,
      options: Options(
        headers: {
          'Content-Type': image.normalizedMimeType,
          'x-upsert': 'false',
        },
      ),
      fromJson: (_) =>
          '${AppConfig.baseUrl}/storage/v1/object/public/${target.bucket}/$path',
    );
  }

  String _fileExtension(ImageUpload image) =>
      switch (image.normalizedMimeType) {
        'image/jpeg' => 'jpg',
        'image/png' => 'png',
        'image/webp' => 'webp',
        _ => 'img',
      };
}
