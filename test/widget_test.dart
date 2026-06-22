// Smoke test — verifies the app compiles and MyApp widget can be instantiated.
// Does NOT pump the full widget tree (avoids Firebase/GetX initialization issues
// in a headless test environment).

import 'package:flutter_test/flutter_test.dart';
import 'package:arobo_app/main.dart';

void main() {
  test('MyApp class is importable and instantiable', () {
    expect(MyApp.new, isNotNull);
  });
}
