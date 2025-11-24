import 'package:flutter_test/flutter_test.dart';
import 'package:madres_digitales_flutter_new/config/app_config.dart';
import 'package:madres_digitales_flutter_new/core/utils/url_utils.dart';

void main() {
  group('UrlUtils', () {
    test('buildFullUrl returns absolute when input is absolute', () {
      const url = 'https://example.com/video.mp4';
      final result = UrlUtils.buildFullUrl(url);
      expect(result, url);
    });

    test('buildFullUrl builds from relative path /uploads', () {
      const rel = '/uploads/video.mp4';
      final result = UrlUtils.buildFullUrl(rel);
      expect(result, contains('/uploads/video.mp4'));
      expect(result.startsWith(AppConfig.apiBaseUrl.replaceFirst(RegExp(r'/api$'), '')), true);
    });

    test('buildFullUrl builds from relative without leading slash', () {
      const rel = 'uploads/image.jpg';
      final result = UrlUtils.buildFullUrl(rel);
      expect(result, contains('/uploads/image.jpg'));
      expect(result.startsWith(AppConfig.apiBaseUrl.replaceFirst(RegExp(r'/api$'), '')), true);
    });
  });
}