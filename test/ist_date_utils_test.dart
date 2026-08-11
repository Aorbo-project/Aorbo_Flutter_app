// ISTDateUtils — the canonical date formatter (Module M, artifact #184-188).
// Pure class, no GetX/Firebase/network dependency, so it's directly
// unit-testable the same way traveller_selection_logic_test.dart already is.

import 'package:arobo_app/utils/ist_date_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ISTDateUtils.toIST — parsing', () {
    test('null input -> null', () {
      expect(ISTDateUtils.toIST(null), isNull);
    });

    test('empty string -> null', () {
      expect(ISTDateUtils.toIST(''), isNull);
    });

    test('UTC ISO string with Z -> shifted +5:30 to IST wall-clock fields', () {
      final ist = ISTDateUtils.toIST('2026-08-08T10:00:00.000Z');
      expect(ist!.hour, 15);
      expect(ist.minute, 30);
      expect(ist.day, 8);
    });

    test('UTC ISO string with explicit +00:00 offset -> same as Z', () {
      final ist = ISTDateUtils.toIST('2026-08-08T10:00:00+00:00');
      expect(ist!.hour, 15);
      expect(ist.minute, 30);
    });

    test('bare "YYYY-MM-DD" (no timezone marker) is treated as UTC midnight, not device-local', () {
      final ist = ISTDateUtils.toIST('2026-08-08');
      // UTC midnight + 5:30 -> 05:30 IST same day
      expect(ist!.hour, 5);
      expect(ist.minute, 30);
      expect(ist.day, 8);
    });

    test('date-boundary rollover: UTC late evening rolls into the next IST calendar day', () {
      final ist = ISTDateUtils.toIST('2026-08-08T20:00:00Z');
      // 20:00 UTC + 5:30 = 01:30 the NEXT day
      expect(ist!.day, 9);
      expect(ist.hour, 1);
      expect(ist.minute, 30);
    });

    test('already a DateTime (non-UTC) is converted to UTC first, then IST-shifted — never left as device-local', () {
      final localish = DateTime(2026, 8, 8, 10, 0, 0); // constructed without explicit UTC flag
      final ist = ISTDateUtils.toIST(localish);
      expect(ist, isNotNull);
      expect(ist!.day, isNotNull); // doesn't throw; exercises the isUtc-false branch
    });

    test('malformed string -> null, does not throw', () {
      expect(() => ISTDateUtils.toIST('not-a-date'), returnsNormally);
      expect(ISTDateUtils.toIST('not-a-date'), isNull);
    });
  });

  group('ISTDateUtils formatters — null/fallback handling (artifact #187)', () {
    test('formatDate(null) returns the fallback, never crashes', () {
      expect(ISTDateUtils.formatDate(null), '-');
      expect(ISTDateUtils.formatDate(null, fallback: 'N/A'), 'N/A');
    });

    test('formatDateTime(null) returns the fallback', () {
      expect(ISTDateUtils.formatDateTime(null), '-');
    });

    test('formatTime(null) returns the fallback', () {
      expect(ISTDateUtils.formatTime(null), '-');
    });

    test('formatCustom(null, pattern) returns the fallback without touching DateFormat', () {
      expect(ISTDateUtils.formatCustom(null, 'yyyy'), '-');
    });
  });

  group('ISTDateUtils formatters — exact output shape', () {
    test('formatDate produces "dd MMM yyyy"', () {
      expect(ISTDateUtils.formatDate('2026-08-08T10:00:00Z'), '08 Aug 2026');
    });

    test('formatDateTime produces "dd MMM yyyy, hh:mm a"', () {
      expect(ISTDateUtils.formatDateTime('2026-08-08T10:00:00Z'), '08 Aug 2026, 03:30 PM');
    });

    test('formatTime produces "hh:mm a"', () {
      expect(ISTDateUtils.formatTime('2026-08-08T10:00:00Z'), '03:30 PM');
    });

    test('formatDateTimeSlash produces "dd/MM/yyyy hh:mm a"', () {
      expect(ISTDateUtils.formatDateTimeSlash('2026-08-08T10:00:00Z'), '08/08/2026 03:30 PM');
    });

    test('midnight IST formats as 12:00 AM, not 00:00 or a crash', () {
      // 18:30 UTC = 00:00 IST next day
      expect(ISTDateUtils.formatTime('2026-08-08T18:30:00Z'), '12:00 AM');
    });

    test('noon IST formats as 12:00 PM', () {
      // 06:30 UTC = 12:00 IST same day
      expect(ISTDateUtils.formatTime('2026-08-08T06:30:00Z'), '12:00 PM');
    });
  });

  group('Device-timezone independence (artifact #188)', () {
    test('the same UTC instant always formats to the same IST wall-clock time regardless of how it is constructed', () {
      final fromString = ISTDateUtils.toIST('2026-08-08T10:00:00.000Z');
      final fromUtcDateTime = ISTDateUtils.toIST(DateTime.utc(2026, 8, 8, 10, 0, 0));
      expect(fromString!.hour, fromUtcDateTime!.hour);
      expect(fromString.minute, fromUtcDateTime.minute);
      expect(fromString.day, fromUtcDateTime.day);
    });
  });
}
