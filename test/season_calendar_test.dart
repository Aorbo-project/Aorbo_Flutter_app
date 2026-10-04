import 'package:arobo_app/utils/dashboard_header_theme.dart';
import 'package:arobo_app/utils/seasonal_forecast_mock_data.dart';
import 'package:flutter_test/flutter_test.dart';

// The app's own season calendar must match the backend's (utils/trekSeason.js):
// spring 1 Mar, summer 1 May, monsoon 1 Jul, autumn 15 Sep, winter 1 Dec.
// The server decides the season the app shows; this copy only drives the
// header's offline first-launch fallback, which used a different month split
// before 2026-10-04.
void main() {
  test('season boundaries match the server calendar', () {
    final cases = <String, TrekSeason>{
      '2027-02-28': TrekSeason.winter,
      '2027-03-01': TrekSeason.spring,
      '2027-04-30': TrekSeason.spring,
      '2027-05-01': TrekSeason.summer,
      '2027-06-30': TrekSeason.summer,
      '2027-07-01': TrekSeason.monsoon,
      '2027-09-14': TrekSeason.monsoon,
      '2027-09-15': TrekSeason.autumn,
      '2027-11-30': TrekSeason.autumn,
      '2027-12-01': TrekSeason.winter,
      '2028-01-15': TrekSeason.winter,
      '2028-02-29': TrekSeason.winter,
    };
    cases.forEach((day, season) {
      expect(trekSeasonFor(DateTime.parse(day)), season, reason: day);
    });
  });

  test('the offline header fallback follows the same calendar', () {
    final c = HeaderThemeController();
    expect(c.seasonalFallback(DateTime(2027, 2, 15)), DashboardHeaderTheme.winter);
    expect(c.seasonalFallback(DateTime(2027, 4, 15)), DashboardHeaderTheme.spring);
    expect(c.seasonalFallback(DateTime(2027, 6, 15)), DashboardHeaderTheme.summer);
    expect(c.seasonalFallback(DateTime(2027, 9, 14)), DashboardHeaderTheme.monsoon);
    expect(c.seasonalFallback(DateTime(2027, 9, 15)), DashboardHeaderTheme.autumn);
  });
}
