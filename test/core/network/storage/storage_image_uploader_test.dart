import 'dart:math';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:accounting_software/app/core/foundation/config/app_config.dart';
import 'package:accounting_software/app/core/foundation/image/image_upload.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/core/network/api_client_interface.dart';
import 'package:accounting_software/app/core/network/api_end_points.dart';
import 'package:accounting_software/app/core/network/storage/storage_image_uploader.dart';
import 'package:accounting_software/app/core/network/storage/storage_target.dart';

class _ApiClient extends Fake implements IApiClient {
  AppEndpoint? lastPath;
  dynamic lastData;
  Options? lastOptions;

  @override
  Future<ApiResult<T>> post<T>(
    AppEndpoint path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    JsonFactory<T>? fromJson,
    JsonListFactory<T>? fromJsonList,
    CancelToken? cancelToken,
    bool requiresAuth = true,
  }) async {
    lastPath = path;
    lastData = data;
    lastOptions = options;
    return ApiSuccess<T>(fromJson!({}));
  }
}

void main() {
  test('keeps the existing bucket path, filename pattern and public URL', () async {
    final api = _ApiClient();
    final uploader = StorageImageUploader(
      api,
      clock: () => DateTime.utc(2026, 1, 2),
      random: Random(7),
    );
    final bytes = Uint8List.fromList([0x89, 0x50, 0x4e, 0x47]);
    final image = ImageUpload(
      bytes: bytes,
      fileName: 'logo.png',
      mimeType: 'image/png',
    );

    final result = await uploader.upload(
      target: const StorageTarget(bucket: 'product-images', folder: 'brands'),
      image: image,
    );

    final random = Random(7);
    final expectedPath =
        'brands/${DateTime.utc(2026, 1, 2).microsecondsSinceEpoch}-${random.nextInt(0x7fffffff)}.png';
    expect(
      api.lastPath?.toStringPath(),
      '/storage/v1/object/product-images/$expectedPath',
    );
    expect(api.lastData, bytes);
    expect(api.lastOptions?.headers?['Content-Type'], 'image/png');
    expect(api.lastOptions?.headers?['x-upsert'], 'false');
    result.when(
      success: (url) => expect(
        url,
        '${AppConfig.baseUrl}/storage/v1/object/public/product-images/$expectedPath',
      ),
      failure: (_) => fail('Expected a public URL'),
    );
  });
}
