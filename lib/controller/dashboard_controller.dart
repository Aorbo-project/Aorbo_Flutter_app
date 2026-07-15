import 'dart:async';
import 'dart:convert';

import 'package:arobo_app/models/know_more_data.dart';
import 'package:arobo_app/models/seasonal_forecast_data.dart';
import 'package:arobo_app/models/shorts_treks_data.dart';
import 'package:arobo_app/models/top_treks_data.dart';
import 'package:arobo_app/widgets/logger.dart';
import 'package:flutter/material.dart';

import 'package:arobo_app/models/dashboard/trek_modal.dart';
import 'package:arobo_app/models/user_profile/state_list_model.dart';
import 'package:arobo_app/models/dispute/dispute_detail_modal.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../freezed_models/booking/booking_history_model.dart';
import '../freezed_models/profile/user_profile_model.dart';
import '../freezed_models/treks/treks_model_data.dart';
import '../models/dashboard/cities_model.dart';
import '../models/treaks/booking_cancelled_modal.dart';
import '../repository/api_result.dart';
import '../repository/network_url.dart';
import '../repository/repository.dart';
import '../utils/custom_snackbar.dart';

class DashboardController extends GetxController {
  final Repository _repository = Repository();

  VoidCallback? onDateAutoSelected;

  final whatsNewObserver = const ApiResult<WhatsNewDataResponseModel>.init().obs;
  final topTreksObserver = const ApiResult<TopTreksDataResponseModel>.init().obs;
  final shortsTreksObserver = const ApiResult<ShortsTreksDataResponseModel>.init().obs;
  final seasonalForcastObserver = const ApiResult<SeasonalForecastDataResponseModel>.init().obs;

  final bookingHistoryObserver = PaginationModel(
      data: const ApiResult<BookingHistoryModel>.init().obs,
      isLoading: false,
      isPaginationCompleted: false,
      page: 1,
      error: "")
      .obs;

  final bookingDetailsObserver = ApiResult<BookingDetailsResponseModel>.init().obs;

  RxMap<String, int> availableDates = <String, int>{}.obs;
  final calenderTrekDatesObserver = const ApiResult<CalenderDatesResponseModel>.init().obs;

  // Cities list variables
  RxInt selectedCityId = 0.obs;
  RxInt selectedTrekId = 0.obs;
  Rx<TextEditingController> fromController = TextEditingController().obs;
  Rx<TextEditingController> toController = TextEditingController().obs;
  Rx<TextEditingController> dateController = TextEditingController().obs;
  Rx<DateTime?> selectedDate = Rx<DateTime?>(null);

  RxBool isLoadingCities = false.obs;
  Rx<GetCities> citiesData = GetCities().obs;
  Rx<TrekModal> trekData = TrekModal().obs;
  Rx<StateListModel> stateListData = StateListModel().obs;
  RxList<StateListData> stateList = <StateListData>[].obs;
  RxBool isLoadingTreks = false.obs;
  RxString errorMessage = ''.obs;
  RxInt selectedScreen = 0.obs;

  // Debounce timer for calendar API calls
  Timer? _calendarDebounceTimer;

  // Track if initial fetch has been attempted
  final bool _hasAttemptedInitialCalendarFetch = false;

  //region Booking history
  Rx<BookingHistoryData?> bookingHistoryModal = BookingHistoryData().obs;
  RxList<BookingHistoryData> bookingList = <BookingHistoryData>[].obs;
  RxBool isLoadingBookingHistory = false.obs;
  RxInt currentBookingPage = 1.obs;
  RxBool hasMoreBookings = true.obs;
  RxString selectedFilter = 'All Bookings'.obs;
  Rx<BookingCancelledModal> bookingCancelledModal = BookingCancelledModal().obs;
  Rx<BookingCancelledData> bookingCancelledData = BookingCancelledData().obs;

  // Failed/expired payment attempts — never became a real booking, so they
  // live outside bookingHistoryObserver's pagination pipeline entirely and
  // are fetched from a dedicated endpoint (see getFailedBookingAttempts).
  RxList<Map<String, dynamic>> failedBookingAttempts =
      <Map<String, dynamic>>[].obs;
  RxBool isLoadingFailedAttempts = false.obs;

  //endregion


  //endregion

  //region Dispute Detail
  RxBool isLoadingDisputeDetail = false.obs;
  Rx<DisputeDetailModal> disputeDetailModal = DisputeDetailModal().obs;
  RxList<Disputes> disputeDetailDataList = <Disputes>[].obs;

  //endregion

  @override
  void onInit() {
    super.onInit();
    _initializeControllers();
    _setupObservers();
    Future.wait([fetchCitiesList(), fetchTrekList(), fetchStateList()]);
  }

  void _initializeControllers() {
    // Initialize controllers if needed
    if (fromController.value.text.isEmpty) {
      fromController.value = TextEditingController();
    }
    if (toController.value.text.isEmpty) {
      toController.value = TextEditingController();
    }
    if (dateController.value.text.isEmpty) {
      dateController.value = TextEditingController();
    }
  }

  void _setupObservers() {
    // Listen to city selection changes
    ever(selectedCityId, (cityId) {
      logger.d('City ID changed to: $cityId');
      _onCityOrTrekChanged();
    });

    // Listen to trek selection changes
    ever(selectedTrekId, (trekId) {
      logger.d('Trek ID changed to: $trekId');
      _onCityOrTrekChanged();
    });
  }

  void _onCityOrTrekChanged() {
    // Cancel previous timer to avoid multiple rapid API calls
    _calendarDebounceTimer?.cancel();

    // Check if both city and trek are selected
    if (selectedCityId.value != 0 && selectedTrekId.value != 0) {
      logger.d('Both city and trek selected, scheduling calendar fetch');
      // Add debounce to prevent rapid API calls when both values change
      _calendarDebounceTimer = Timer(const Duration(milliseconds: 500), () {
        _fetchCalendarDatesForSelection();
      });
    } else {
      // Clear available dates when selection is incomplete
      logger.d('City or trek not selected, clearing available dates');
      _clearCalendarData();
    }
  }

  void _clearCalendarData() {
    availableDates.clear();
    availableDates.refresh();
    calenderTrekDatesObserver.value = const ApiResult.init();
    selectedDate.value = null;
    dateController.value.clear();
    dateController.refresh();
  }

  Future<void> _fetchCalendarDatesForSelection() async {
    if (selectedCityId.value == 0 || selectedTrekId.value == 0) {
      logger.w('Cannot fetch calendar: city or trek not selected');
      return;
    }

    logger.d('Fetching calendar dates for cityId: ${selectedCityId.value}, trekId: ${selectedTrekId.value}');

    final DateTime currentDate = DateTime.now();
    final DateTime threeMonthsLater = currentDate.add(const Duration(days: 90));

    final String startDateStr = DateFormat('yyyy-MM-dd').format(currentDate);
    final String endDateStr = DateFormat('yyyy-MM-dd').format(threeMonthsLater);

    await fetchCalenderTrekDates(
      cityId: selectedCityId.value,
      trekId: selectedTrekId.value,
      statDate: startDateStr,
      endDate: endDateStr,
    );
  }

  @override
  void onClose() {
    _calendarDebounceTimer?.cancel();

    // Dispose controllers
    if (fromController.value.text.isNotEmpty) {
      fromController.value.dispose();
    }
    if (toController.value.text.isNotEmpty) {
      toController.value.dispose();
    }
    if (dateController.value.text.isNotEmpty) {
      dateController.value.dispose();
    }

    super.onClose();
  }

  static String convertDateYYYYMMDD(String date) {
  if (date.isEmpty) return '';

  try {

    // Already correct format
    if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(date)) {
      return date;
    }

    DateTime parsedDate;

    // dd/MM/yyyy
    if (date.contains('/')) {
      parsedDate = DateFormat('dd/MM/yyyy').parseStrict(date);

    // dd-MM-yyyy
    } else if (date.contains('-')) {
      parsedDate = DateFormat('dd-MM-yyyy').parseStrict(date);

    } else {
      throw FormatException('Unknown date format');
    }

    return DateFormat('yyyy-MM-dd').format(parsedDate);

  } catch (e) {
    logger.w('Invalid date format: $e');
    return '';
  }
}

  Future<void> fetchCalenderTrekDates({
  required int cityId,
  required int trekId,
  required String statDate,
  required String endDate,
}) async {
  try {

    // Clear previous data
    availableDates.clear();

    calenderTrekDatesObserver.value =
        ApiResult.loading("Fetching available dates...");

    logger.d(
      'Fetching calendar dates API - '
      'City: $cityId, '
      'Trek: $trekId, '
      'Start: $statDate, '
      'End: $endDate',
    );

    final response = await _repository.getApiCall(
      url: NetworkUrl.searchCalenderTrekDates(
        cityId.toString(),
        trekId.toString(),
        statDate,
        endDate,
      ),
    );

    if (response != null) {

      logger.d('Calendar API Response: $response');

      final responseData =
          CalenderDatesResponseModel.fromJson(response);

      if (responseData.success == true) {

        if (responseData.data?.dates != null &&
            responseData.data!.dates!.isNotEmpty) {

          // Sort dates ascending
          final sortedDates =
              responseData.data!.dates!.toList()
                ..sort(
                  (a, b) =>
                      (a.date ?? '').compareTo(b.date ?? ''),
                );

          for (var dateData in sortedDates) {

            // Skip null dates
            if (dateData.date == null) continue;

            final trekDate =
                DateTime.tryParse(dateData.date!);

            // Invalid date
            if (trekDate == null) continue;

            final now = DateTime.now();

            final today = DateTime(
              now.year,
              now.month,
              now.day,
            );

            // ─────────────────────────────
            // IMPORTANT FIX
            // Skip today/past dates because
            // backend still marks started
            // treks as available
            // ─────────────────────────────

            if (!trekDate.isAfter(today)) {

              logger.d(
                'Skipping started/past trek date: '
                '${dateData.date}',
              );

              continue;
            }

            // Only add truly available dates
            if (dateData.available == true) {

              logger.d(
                'Adding available future date: '
                '${dateData.date}',
              );

              availableDates[dateData.date!] =
                  dateData.trekCount ?? 0;
            }
          }

          availableDates.refresh();

          logger.d(
            'Available dates loaded: '
            '${availableDates.length}',
          );

          // Auto-select first available date
          if (selectedDate.value == null &&
              availableDates.isNotEmpty) {

            _autoSelectFirstAvailableDate();
          }

        } else {

          logger.d('No available dates found');

          availableDates.clear();
          availableDates.refresh();
        }

        calenderTrekDatesObserver.value =
            ApiResult.success(responseData);

        return;
      }

      throw responseData.message ??
          "Failed to fetch calendar dates";
    }

    throw "Response Body Null";

  } catch (e) {

    logger.e(
      'Error fetching calendar dates: $e',
    );

    errorMessage.value = e.toString();

    calenderTrekDatesObserver.value =
        ApiResult.error(
          'Failed to fetch calendar dates: '
          '${e.toString()}',
        );
  }
}

  void _autoSelectFirstAvailableDate() {
  if (availableDates.isEmpty) return;

  // ── Sort keys so we always pick the earliest available date ──
  final sortedDates = availableDates.keys.toList()..sort();
  final firstDateStr = sortedDates.first;
  final firstDate = DateTime.tryParse(firstDateStr);

  print('FIRST DATE STRING: $firstDateStr');
  print('PARSED DATE: $firstDate');

  if (firstDate != null) {
    logger.d('Auto-selecting first available date: $firstDateStr');

    selectedDate.value = firstDate;
    dateController.value.text = DateFormat('dd/MM/yyyy').format(firstDate);
    dateController.refresh();

    // Notify Dashboard to update weekend dates
    onDateAutoSelected?.call();
  }
}

  bool isDateAvailable(DateTime? date) {
    if (date == null) return false;
    String dateStr = DateFormat('yyyy-MM-dd').format(date);
    final isAvailable = availableDates.containsKey(dateStr);
    logger.d('Date $dateStr is available: $isAvailable');
    return isAvailable;
  }

  int getTrekCountForDate(DateTime? date) {
    if (date == null) return 0;
    String dateStr = DateFormat('yyyy-MM-dd').format(date);
    final count = availableDates[dateStr] ?? 0;
    return count;
  }

  // Get upcoming available dates (next 7 days)
  List<DateTime> getUpcomingAvailableDates() {
    final now = DateTime.now();
    final upcomingDates = <DateTime>[];

    for (int i = 0; i < 30 && upcomingDates.length < 7; i++) {
      final checkDate = now.add(Duration(days: i));
      if (isDateAvailable(checkDate)) {
        upcomingDates.add(checkDate);
      }
    }

    return upcomingDates;
  }

  Future<void> fetchWhatsNew() async {
    try {
      whatsNewObserver.value = const ApiResult.loading("");
      final response = await _repository.getApiCall(url: NetworkUrl.fetchWhatsNew);
      if (response != null) {
        final responseData = WhatsNewDataResponseModel.fromJson(response);
        if (responseData.success == true) {
          whatsNewObserver.value = ApiResult.success(responseData);
          return;
        }
        throw responseData.message ?? "Failed to fetch whats new";
      }
      throw "Response Body Null";
    } catch (e) {
      logger.e('Error fetching whats new: $e');
      whatsNewObserver.value = ApiResult.error(e.toString());
    }
  }

  Future<void> fetchTopTreks() async {
    try {
      topTreksObserver.value = const ApiResult.loading("");
      final response = await _repository.getApiCall(url: NetworkUrl.fetchTopTreks);
      if (response != null) {
        final responseData = TopTreksDataResponseModel.fromJson(response);
        if (responseData.success == true) {
          topTreksObserver.value = ApiResult.success(responseData);
          return;
        }
        throw responseData.message ?? "Failed to fetch top treks";
      }
      throw "Response Body Null";
    } catch (e) {
      logger.e('Error fetching top treks: $e');
      topTreksObserver.value = ApiResult.error(e.toString());
    }
  }

  Future<void> fetchShortsTreks() async {
    try {
      shortsTreksObserver.value = const ApiResult.loading("");
      final response = await _repository.getApiCall(url: NetworkUrl.fetchShotsTreks);
      if (response != null) {
        final responseData = ShortsTreksDataResponseModel.fromJson(response);
        if (responseData.success == true) {
          shortsTreksObserver.value = ApiResult.success(responseData);
          return;
        }
        throw responseData.message ?? "Failed to fetch shorts treks";
      }
      throw "Response Body Null";
    } catch (e) {
      logger.e('Error fetching shorts treks: $e');
      shortsTreksObserver.value = ApiResult.error(e.toString());
    }
  }

  Future<void> fetchSeasonalForeCasts() async {
    try {
      seasonalForcastObserver.value = const ApiResult.loading("");
      final response = await _repository.getApiCall(url: NetworkUrl.fetchSeasonalForcasts);
      if (response != null) {
        final responseData = SeasonalForecastDataResponseModel.fromJson(response);
        if (responseData.success == true) {
          seasonalForcastObserver.value = ApiResult.success(responseData);
          return;
        }
        throw responseData.message ?? "Failed to fetch seasonal forecasts";
      }
      throw "Response Body Null";
    } catch (e) {
      logger.e('Error fetching seasonal forecasts: $e');
      seasonalForcastObserver.value = ApiResult.error(e.toString());
    }
  }

  Future<void> fetchStateList() async {
    isLoadingCities.value = true;
    errorMessage.value = '';

    try {
      final response = await _repository.getApiCall(
        url: NetworkUrl.getStateList,
      );

      if (response != null) {
        stateListData.value = StateListModel.fromJson(response);
        stateList.value = stateListData.value.data ?? [];
        logger.d('States loaded: ${stateList.length}');
      }
    } catch (e) {
      errorMessage.value = 'Failed to load states: ${e.toString()}';
      logger.e(errorMessage.value);
      CustomSnackBar.show(Get.context!, message: errorMessage.value);
    } finally {
      isLoadingCities.value = false;
    }
  }

  Future<void> fetchCitiesList() async {
    isLoadingCities.value = true;
    errorMessage.value = '';

    try {
      final response = await _repository.getApiCall(
        url: NetworkUrl.getCitiesList,
      );

      if (response != null) {
        citiesData.value = GetCities.fromJson(response);
        logger.d('Cities loaded: ${citiesData.value.data?.length ?? 0}');
      }
    } catch (e) {
      errorMessage.value = 'Failed to load cities: ${e.toString()}';
      logger.e(errorMessage.value);
      CustomSnackBar.show(Get.context!, message: errorMessage.value);
    } finally {
      isLoadingCities.value = false;
    }
  }

  Future<void> fetchTrekList() async {
    isLoadingCities.value = true;
    errorMessage.value = '';

    try {
      final response = await _repository.getApiCall(
        url: NetworkUrl.getTreksList,
      );

      if (response != null) {
        trekData.value = TrekModal.fromJson(response);
        logger.d('Treks loaded: ${trekData.value.data?.length ?? 0}');
      }
    } catch (e) {
      errorMessage.value = 'Failed to load treks: ${e.toString()}';
      logger.e(errorMessage.value);
      CustomSnackBar.show(Get.context!, message: errorMessage.value);
    } finally {
      isLoadingCities.value = false;
    }
  }




  Future<void> getBookingHistory({
    required bool refresh}) async {

    final observer = bookingHistoryObserver;

    try {
      if (refresh == true) {
        observer.value = PaginationModel(
            data: const ApiResult<BookingHistoryModel>.init().obs,
            isLoading: false,
            isPaginationCompleted: false,
            page: 1,
            error: "");
      }

      if (observer.value.isPaginationCompleted || observer.value.isLoading == true) {
        return;
      }

      if (observer.value.page == 1) {
        observer.value.data.value = const ApiResult.loading("");
      } else {
        observer.value.isLoading = true;
        observer.refresh();
      }

      const maxListApiReturns = 20;
      observer.refresh();


      final response = await _repository.getApiCall(
        url: NetworkUrl.bookingHistoryWithStatus(
          page: observer.value.page,
          trekStatus: selectedFilter.value == 'All Bookings'
              ? null
              : selectedFilter.value,
        ),
      );



      final body = response;
      if (body != null) {
        

debugPrint("========== BOOKING HISTORY RESPONSE ==========");
debugPrint(const JsonEncoder.withIndent('  ').convert(body));
debugPrint("==============================================");
        final responseData = BookingHistoryModel.fromJson(body);
        if (responseData.success == true) {
          observer.value.data.value.maybeWhen(success: (data) {
            final oldList = (data as BookingHistoryModel?)?.data?.toList();
            oldList?.addAll(responseData.data ?? List.empty());
            observer.value.data.value =
                ApiResult.success(responseData.copyWith(data: oldList));
          }, orElse: () {
            observer.value.data.value = ApiResult.success(responseData);
          });

          observer.value.page = observer.value.page + 1;
          if ((responseData.data?.length ?? 0) < maxListApiReturns) {
            observer.value.isPaginationCompleted = true;
          }
          observer.value.isLoading = false;
          observer.refresh();
          return;
        }
        throw "${responseData.message}";
      }
      throw "Response Body Null";
    } catch (e) {
      errorMessage.value = 'Failed to search treks: ${e.toString()}';
      CustomSnackBar.show(Get.context!, message: errorMessage.value);
      observer.value.data.value = ApiResult.error(e.toString());
      observer.value.isLoading = false;
      observer.refresh();
    }
  }

  Future<void> getFailedBookingAttempts() async {
    try {
      isLoadingFailedAttempts.value = true;
      final response = await _repository.getApiCall(
        url: NetworkUrl.failedBookingAttempts,
      );
      if (response != null && response['success'] == true) {
        final list = (response['data'] as List?) ?? [];
        failedBookingAttempts.value = list
            .whereType<Map<String, dynamic>>()
            .toList();
      } else {
        failedBookingAttempts.value = [];
      }
    } catch (e) {
      logger.w('getFailedBookingAttempts failed: ${e.toString()}');
      failedBookingAttempts.value = [];
    } finally {
      isLoadingFailedAttempts.value = false;
    }
  }





  getBookingDetail({required dynamic bookingId}) async {

    try {
      bookingDetailsObserver.value = ApiResult.loading("");
      final response = await _repository.getApiCall(
        url: NetworkUrl.bookingDetails(bookingId),
      );

      if (response != null) {
        if (response['success']) {
          final body = BookingDetailsResponseModel.fromJson(response);
          bookingDetailsObserver.value = ApiResult.success(body);
          bookingHistoryModal.value = body.data;
        } else {
          bookingDetailsObserver.value = ApiResult.error(response['message'] ?? 'Failed to load dispute details');
        }
      }
    } catch (e) {
      bookingDetailsObserver.value = ApiResult.error('Failed to load dispute details: ${e.toString()}');
      if (Get.context != null) {
        CustomSnackBar.show(Get.context!, message: 'Failed to load dispute details: ${e.toString()}');
      }
    }
    return null;
  }

  /// Clears search and temporary booking related data
  /// Call this after successful payment to reset filters and temporary data
  void clearSearchAndBookingData() {
    // Clear search filters
    selectedTrekId.value = 0;
    fromController.value.clear();
    fromController.refresh();
    toController.value.clear();
    toController.refresh();
    dateController.value.clear();
    dateController.refresh();
    selectedDate.value = null;

    // Clear calendar data
    _clearCalendarData();


    // Clear booking cancellation data (temporary)
    bookingCancelledModal.value = BookingCancelledModal();
    bookingCancelledData.value = BookingCancelledData();

    // Clear dispute detail data (temporary)
    disputeDetailModal.value = DisputeDetailModal();
    disputeDetailDataList.clear();

    logger.d('DashboardController: Search and booking data cleared');
  }
}