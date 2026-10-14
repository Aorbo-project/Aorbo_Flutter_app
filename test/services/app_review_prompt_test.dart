import 'package:arobo_app/services/app_review_prompt.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_review/in_app_review.dart';

class _FakeReview implements InAppReview {
  _FakeReview({this.available = true, this.throws = false});

  final bool available;
  final bool throws;
  int requests = 0;

  @override
  Future<bool> isAvailable() async {
    if (throws) throw Exception('no Play services');
    return available;
  }

  @override
  Future<void> requestReview() async => requests++;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  tearDown(() => AppReviewPrompt.reviewOverride = null);

  Future<_FakeReview> run(int stars, {bool available = true, bool throws = false}) async {
    final fake = _FakeReview(available: available, throws: throws);
    AppReviewPrompt.reviewOverride = fake;
    await AppReviewPrompt.afterTrekReview(stars, delay: Duration.zero);
    return fake;
  }

  test('4 and 5 star trek reviews open the Play rating box', () async {
    expect((await run(5)).requests, 1);
    expect((await run(4)).requests, 1);
  });

  test('1-3 star reviews never ask for a Play rating', () async {
    for (final stars in [0, 1, 2, 3]) {
      expect((await run(stars)).requests, 0, reason: '$stars stars');
    }
  });

  test('not available or failing is silent', () async {
    expect((await run(5, available: false)).requests, 0);
    await expectLater(run(5, throws: true), completes);
  });
}
