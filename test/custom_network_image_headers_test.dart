import 'package:arobo_app/widgets/custom_network_image.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const api = 'https://api.aorbotreks.co.in/api/v1/';
  const token = 'header.payload.signature';

  group('CustomNetworkImage.authHeadersFor', () {
    test('third-party image host (Cloudinary) never receives the token', () {
      expect(
        CustomNetworkImage.authHeadersFor(
          'https://res.cloudinary.com/x/image/upload/w_800/a.jpg',
          token,
          apiBaseUrl: api,
        ),
        isNull,
      );
    });

    test('our own API host gets the Bearer token', () {
      expect(
        CustomNetworkImage.authHeadersFor(
          'https://api.aorbotreks.co.in/storage/documents/logos/1/a.png',
          token,
          apiBaseUrl: api,
        ),
        {'Authorization': 'Bearer $token'},
      );
    });

    test('no token → no header (never the literal "Bearer null")', () {
      for (final t in [null, '']) {
        expect(
          CustomNetworkImage.authHeadersFor(
            'https://api.aorbotreks.co.in/storage/a.png',
            t,
            apiBaseUrl: api,
          ),
          isNull,
        );
      }
    });

    test('lookalike host is not treated as ours', () {
      expect(
        CustomNetworkImage.authHeadersFor(
          'https://api.aorbotreks.co.in.evil.example/a.png',
          token,
          apiBaseUrl: api,
        ),
        isNull,
      );
    });

    test('malformed or relative URL → no header', () {
      for (final u in ['', 'not a url', '/storage/a.png', 'asset:foo']) {
        expect(
          CustomNetworkImage.authHeadersFor(u, token, apiBaseUrl: api),
          isNull,
          reason: u,
        );
      }
    });
  });
}
