import 'dart:async';
import 'dart:convert';

import 'package:arobo_app/models/know_more_data.dart';
import 'package:arobo_app/models/seasonal_forecast_data.dart';
import 'package:arobo_app/models/seasonal_picks_data.dart';
import 'package:arobo_app/models/top_treks_data.dart';
import 'package:arobo_app/widgets/logger.dart';
import 'package:flutter/material.dart';

import 'package:arobo_app/models/dashboard/trek_modal.dart';
import 'package:arobo_app/models/user_profile/state_list_model.dart';
import 'package:arobo_app/models/dispute/dispute_detail_modal.dart';
import 'package:get/get.dart' hide FormData, Response, MultipartFile;
import 'package:intl/intl.dart';
import '../freezed_models/booking/booking_history_model.dart';
import '../freezed_models/profile/user_profile_model.dart';
import '../freezed_models/treks/treks_model_data.dart';
import '../models/dashboard/cities_model.dart';
import '../models/treaks/booking_cancelled_modal.dart';
import 'package:dio/dio.dart';
import '../repository/api_result.dart';
import '../repository/network_url.dart';
import '../repository/repository.dart';
import '../services/invoice_pdf_service.dart';
import '../utils/custom_snackbar.dart';

class DashboardController extends GetxController {
  final Repository _repository = Repository();

  VoidCallback? onDateAutoSelected;

  final whatsNewObserver =
      const ApiResult<WhatsNewDataResponseModel>.init().obs;
  final topTreksObserver =
      const ApiResult<TopTreksDataResponseModel>.init().obs;
  final seasonalForcastObserver =
      const ApiResult<SeasonalForecastDataResponseModel>.init().obs;
  final seasonalPicksObserver =
      const ApiResult<SeasonalPicksDataResponseModel>.init().obs;

  final bookingHistoryObserver = PaginationModel(
    data: const ApiResult<BookingHistoryModel>.init().obs,
    isLoading: false,
    isPaginationCompleted: false,
    page: 1,
    error: "",
  ).obs;

  final bookingDetailsObserver =
      ApiResult<BookingDetailsResponseModel>.init().obs;

  RxMap<String, int> availableDates = <String, int>{}.obs;
  final calenderTrekDatesObserver =
      const ApiResult<CalenderDatesResponseModel>.init().obs;

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

  // Track routes the user has clicked "Notify Me" for.
  RxMap<String, bool> notifiedRoutes = <String, bool>{}.obs;

  Timer? _calendarDebounceTimer;
  final bool _hasAttemptedInitialCalendarFetch = false;

  Rx<BookingHistoryData?> bookingHistoryModal = BookingHistoryData().obs;
  RxList<BookingHistoryData> bookingList = <BookingHistoryData>[].obs;
  RxBool isLoadingBookingHistory = false.obs;
  RxInt currentBookingPage = 1.obs;
  RxBool hasMoreBookings = true.obs;
  RxString selectedFilter = 'All Bookings'.obs;
  Rx<BookingCancelledModal> bookingCancelledModal = BookingCancelledModal().obs;
  Rx<BookingCancelledData> bookingCancelledData = BookingCancelledData().obs;

  RxList<Map<String, dynamic>> failedBookingAttempts =
      <Map<String, dynamic>>[].obs;
  RxBool isLoadingFailedAttempts = false.obs;

  RxBool isLoadingDisputeDetail = false.obs;
  Rx<DisputeDetailModal> disputeDetailModal = DisputeDetailModal().obs;
  RxList<Disputes> disputeDetailDataList = <Disputes>[].obs;

  @override
  void onInit() {
    super.onInit();
    _initializeControllers();
    _setupObservers();
  }

  @override
  void onReady() {
    super.onReady();
    // onReady fires in a post-first-frame callback — the dashboard's initial
    // frame has already painted by the time these three network calls kick
    // off, so they no longer compete with the (heavy) first build for the
    // main isolate. Previously in onInit(), which runs BEFORE the first
    // build and made the splash→dashboard reveal jank.
    Future.wait([fetchCitiesList(), fetchTrekList(), fetchStateList()]);
  }

  void _initializeControllers() {
    // Field initializers already construct them; no action needed here.
  }

  void _setupObservers() {
    ever(selectedCityId, (cityId) {
      logger.d('City ID changed to: $cityId');
      _onCityOrTrekChanged();
    });

    ever(selectedTrekId, (trekId) {
      logger.d('Trek ID changed to: $trekId');
      _onCityOrTrekChanged();
    });
  }

  void _onCityOrTrekChanged() {
    _calendarDebounceTimer?.cancel();

    if (selectedCityId.value != 0 && selectedTrekId.value != 0) {
      logger.d('Both city and trek selected, scheduling calendar fetch');
      _calendarDebounceTimer = Timer(const Duration(milliseconds: 500), () {
        _fetchCalendarDatesForSelection();
        // Check notification status when route changes
        checkRouteNotificationStatus(
          selectedCityId.value,
          selectedTrekId.value,
        );
      });
    } else {
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

    logger.d(
      'Fetching calendar dates for cityId: ${selectedCityId.value}, trekId: ${selectedTrekId.value}',
    );

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

  /// Fires the calendar-availability fetch immediately, skipping the
  /// debounce — for use right after a deliberate, completed route
  /// selection (not the reactive per-keystroke case the debounce guards).
  /// Cancels any pending debounced fetch so it doesn't also fire later.
  Future<void> fetchCalendarDatesNow() async {
    _calendarDebounceTimer?.cancel();
    await _fetchCalendarDatesForSelection();
    checkRouteNotificationStatus(selectedCityId.value, selectedTrekId.value);
  }

  @override
  void onClose() {
    _calendarDebounceTimer?.cancel();
    fromController.value.dispose();
    toController.value.dispose();
    dateController.value.dispose();
    super.onClose();
  }

  static String convertDateYYYYMMDD(String date) {
    if (date.isEmpty) return '';

    try {
      if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(date)) {
        return date;
      }

      DateTime parsedDate;

      if (date.contains('/')) {
        parsedDate = DateFormat('dd/MM/yyyy').parseStrict(date);
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
      availableDates.clear();
      calenderTrekDatesObserver.value = ApiResult.loading(
        "Fetching available dates...",
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
        final responseData = CalenderDatesResponseModel.fromJson(response);

        if (responseData.success == true) {
          if (responseData.data?.dates != null &&
              responseData.data!.dates!.isNotEmpty) {
            final sortedDates = responseData.data!.dates!.toList()
              ..sort((a, b) => (a.date ?? '').compareTo(b.date ?? ''));

            for (var dateData in sortedDates) {
              if (dateData.date == null) continue;
              final trekDate = DateTime.tryParse(dateData.date!);
              if (trekDate == null) continue;

              final now = DateTime.now();
              final today = DateTime(now.year, now.month, now.day);

              if (!trekDate.isAfter(today)) continue;

              if (dateData.available == true) {
                availableDates[dateData.date!] = dateData.trekCount ?? 0;
              }
            }

            availableDates.refresh();

            if (selectedDate.value == null && availableDates.isNotEmpty) {
              _autoSelectFirstAvailableDate();
            }
          } else {
            availableDates.clear();
            availableDates.refresh();
          }

          calenderTrekDatesObserver.value = ApiResult.success(responseData);
          return;
        }

        throw responseData.message ?? "Failed to fetch calendar dates";
      }

      throw "Response Body Null";
    } catch (e) {
      logger.e('Error fetching calendar dates: $e');
      errorMessage.value = e.toString();
      calenderTrekDatesObserver.value = ApiResult.error(
        'Failed to fetch calendar dates: ${e.toString()}',
      );
    }
  }

  void _autoSelectFirstAvailableDate() {
    if (availableDates.isEmpty) return;

    final sortedDates = availableDates.keys.toList()..sort();
    final firstDateStr = sortedDates.first;
    final firstDate = DateTime.tryParse(firstDateStr);

    if (firstDate != null) {
      logger.d('Auto-selecting first available date: $firstDateStr');
      selectedDate.value = firstDate;
      dateController.value.text = DateFormat('dd/MM/yyyy').format(firstDate);
      dateController.refresh();
      onDateAutoSelected?.call();
    }
  }

  bool isDateAvailable(DateTime? date) {
    if (date == null) return false;
    String dateStr = DateFormat('yyyy-MM-dd').format(date);
    return availableDates.containsKey(dateStr);
  }

  int getTrekCountForDate(DateTime? date) {
    if (date == null) return 0;
    String dateStr = DateFormat('yyyy-MM-dd').format(date);
    return availableDates[dateStr] ?? 0;
  }

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
      final response = await _repository.getApiCall(
        url: NetworkUrl.fetchWhatsNew,
      );
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
      final response = await _repository.getApiCall(
        url: NetworkUrl.fetchTopTreks,
      );
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

  Future<void> fetchSeasonalPicks({String? season}) async {
    try {
      seasonalPicksObserver.value = const ApiResult.loading("");
      final url = season == null
          ? NetworkUrl.fetchSeasonalPicks
          : '${NetworkUrl.fetchSeasonalPicks}?season=$season';
      final response = await _repository.getApiCall(url: url);
      if (response != null) {
        final responseData = SeasonalPicksDataResponseModel.fromJson(response);
        if (responseData.success == true) {
          seasonalPicksObserver.value = ApiResult.success(responseData);
          return;
        }
        throw responseData.message ?? "Failed to fetch seasonal picks";
      }
      throw "Response Body Null";
    } catch (e) {
      logger.e('Error fetching seasonal picks: $e');
      seasonalPicksObserver.value = ApiResult.error(e.toString());
    }
  }

  Future<bool> toggleTopTrekFavorite(int id, bool currentlyFavorite) async {
    try {
      if (currentlyFavorite) {
        await _repository.deleteApiCall(url: NetworkUrl.topTrekFavorite(id));
      } else {
        await _repository.postApiCall(
          url: NetworkUrl.topTrekFavorite(id),
          body: {},
        );
      }
      return true;
    } catch (e) {
      logger.e('Error toggling top trek favorite: $e');
      return false;
    }
  }

  Future<void> fetchSeasonalForeCasts() async {
    try {
      seasonalForcastObserver.value = const ApiResult.loading("");
      final response = await _repository.getApiCall(
        url: NetworkUrl.fetchSeasonalForcasts,
      );
      if (response != null) {
        final responseData = SeasonalForecastDataResponseModel.fromJson(
          response,
        );
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

  int _historyGeneration = 0;
  Future<void> getBookingHistory({required bool refresh}) async {
    final observer = bookingHistoryObserver;

    if (refresh == true) {
      _historyGeneration++;
      observer.value = PaginationModel(
        data: const ApiResult<BookingHistoryModel>.init().obs,
        isLoading: false,
        isPaginationCompleted: false,
        page: 1,
        error: "",
      );
    }
    final myGeneration = _historyGeneration;

    try {
      if (observer.value.isPaginationCompleted ||
          observer.value.isLoading == true) {
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

      if (myGeneration != _historyGeneration) return;

      final body = response;
      if (body != null) {
        debugPrint("========== BOOKING HISTORY RESPONSE ==========");
        debugPrint(const JsonEncoder.withIndent('  ').convert(body));
        debugPrint("==============================================");
        final responseData = BookingHistoryModel.fromJson(body);
        if (responseData.success == true) {
          observer.value.data.value.maybeWhen(
            success: (data) {
              final oldList = (data as BookingHistoryModel?)?.data?.toList();
              oldList?.addAll(responseData.data ?? List.empty());
              observer.value.data.value = ApiResult.success(
                responseData.copyWith(data: oldList),
              );
            },
            orElse: () {
              observer.value.data.value = ApiResult.success(responseData);
            },
          );

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
      if (myGeneration != _historyGeneration) return;
      errorMessage.value = 'Failed to search treks: ${e.toString()}';
      CustomSnackBar.show(Get.context!, message: errorMessage.value);
      observer.value.data.value = ApiResult.error(e.toString());
      observer.value.isLoading = false;
      observer.refresh();
    }
  }

  Future<List<BookingHistoryData>> fetchCompletedBookingsForPopup() async {
    try {
      final response = await _repository.getApiCall(
        url: NetworkUrl.bookingHistoryWithStatus(
          page: 1,
          trekStatus: 'completed',
        ),
      );
      if (response != null) {
        final responseData = BookingHistoryModel.fromJson(response);
        if (responseData.success == true) {
          return responseData.data ?? [];
        }
      }
    } catch (e) {
      logger.e('Error fetching completed bookings for popup: $e');
    }
    return [];
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
          bookingDetailsObserver.value = ApiResult.error(
            response['message'] ?? 'Failed to load dispute details',
          );
        }
      }
    } catch (e) {
      bookingDetailsObserver.value = ApiResult.error(
        'Failed to load dispute details: ${e.toString()}',
      );
      if (Get.context != null) {
        CustomSnackBar.show(
          Get.context!,
          message: 'Failed to load dispute details: ${e.toString()}',
        );
      }
    }
    return null;
  }

  Future<void> generateAndUploadInvoice(int bookingId) async {
    try {
      await getBookingDetail(bookingId: bookingId);
      final booking = bookingHistoryModal.value;
      final bookingNumber = booking?.bookingNumber;
      if (booking == null || bookingNumber == null || bookingNumber.isEmpty)
        return;

      final bytes = await InvoicePdfService.generateInvoice(booking: booking);

      final formData = FormData.fromMap({
        'invoice': MultipartFile.fromBytes(
          bytes,
          filename: 'invoice_$bookingNumber.pdf',
        ),
      });
      await _repository.postApiCall(
        url: NetworkUrl.invoiceUpload(bookingNumber),
        body: formData,
      );
      logger.d('Invoice uploaded for booking $bookingNumber');
    } catch (e) {
      logger.e('generateAndUploadInvoice failed for booking $bookingId: $e');
    }
  }

  void clearSearchAndBookingData() {
    selectedTrekId.value = 0;
    fromController.value.clear();
    fromController.refresh();
    toController.value.clear();
    toController.refresh();
    dateController.value.clear();
    dateController.refresh();
    selectedDate.value = null;

    _clearCalendarData();

    bookingCancelledModal.value = BookingCancelledModal();
    bookingCancelledData.value = BookingCancelledData();

    disputeDetailModal.value = DisputeDetailModal();
    disputeDetailDataList.clear();

    logger.d('DashboardController: Search and booking data cleared');
  }

  // --- Notify Me API Integration ---
  Future<void> checkRouteNotificationStatus(
    int fromCityId,
    int toTrekId,
  ) async {
    if (fromCityId == 0 || toTrekId == 0) return;

    final routeKey = '${fromCityId}_$toTrekId';

    try {
      final response = await _repository.checkNotifyStatus(
        fromCityId: fromCityId,
        toTrekId: toTrekId,
      );

      if (response != null && _isNotifySuccess(response)) {
        final dynamic data = response['data'];
        final bool subscribed =
            data is Map &&
            (data['is_subscribed'] == true || data['is_subscribed'] == 1);
        notifiedRoutes[routeKey] = subscribed;
      } else {
        // Response shape unknown or failure — don't assume either way.
        // Leave the existing value (if any) untouched so the UI doesn't
        // flicker back to "Notify Me" on a transient error.
        notifiedRoutes.putIfAbsent(routeKey, () => false);
      }
    } catch (e) {
      logger.w('checkRouteNotificationStatus failed for $routeKey: $e');
      // Fail soft — don't crash the dashboard over a status-check hiccup.
      notifiedRoutes.putIfAbsent(routeKey, () => false);
    }
  }

  Future<bool> subscribeToRouteNotification(
    int fromCityId,
    int toTrekId,
  ) async {
    final routeKey = '${fromCityId}_$toTrekId';

    try {
      final response = await _repository.subscribeToRoute(
        fromCityId: fromCityId,
        toTrekId: toTrekId,
      );

      // Accept both {success: true} and {status: "success"} shapes
      final bool ok = _isNotifySuccess(response);
      if (ok) {
        notifiedRoutes[routeKey] = true;
        return true;
      }

      // Server returned a non-2xx but repository swallowed it — surface the message
      final String? msg = _extractNotifyMessage(response);
      throw Exception(msg ?? 'Failed to save subscription.');
    } on DioException catch (e) {
      // Extract the friendly message from the response body if present
      final dynamic responseData = e.response?.data;
      final String msg =
          (responseData is Map && responseData['message'] != null)
          ? responseData['message'].toString()
          : 'Failed to save subscription.';
      // Re-throw as a plain Exception so the sheet's _extractServerMessage can
      // pick it up cleanly without leaking Dio internals into the UI.
      throw Exception(msg);
    } catch (e) {
      // Already an Exception with a clean message — pass through
      rethrow;
    }
  }

  /// True if the response body indicates success. Handles both the spec's
  /// {status: "success"} shape and the actual {success: true} shape returned
  /// by the live API.
  bool _isNotifySuccess(dynamic response) {
    if (response is! Map) return false;
    if (response['success'] == true) return true;
    if (response['status'] == 'success') return true;
    return false;
  }

  String? _extractNotifyMessage(dynamic response) {
    if (response is Map) {
      return response['message']?.toString();
    }
    return null;
  }
}
