import 'package:diaspora_connect/app/api/response_cache.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes/fake_image_cache.dart';

void main() {
  test(
    'clear forgets saved responses and images, keeps other settings',
    () async {
      SharedPreferences.setMockInitialValues({'app_locale': 'ne'});
      final prefs = await SharedPreferences.getInstance();
      final images = FakeImageCache();
      final cache = ResponseCache(prefs, images);

      await cache.write('en:https://api/issues', {'id': 1});
      expect(cache.read('en:https://api/issues'), {'id': 1});

      await cache.clear();

      expect(cache.read('en:https://api/issues'), isNull);
      expect(images.emptied, isTrue);
      // The language survives sign-out.
      expect(prefs.getString('app_locale'), 'ne');
    },
  );
}
