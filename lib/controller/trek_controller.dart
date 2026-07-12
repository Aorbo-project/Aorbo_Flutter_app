import 'dart:async';
import 'dart:convert';


import 'package:arobo_app/controller/dashboard_controller.dart';
import 'package:arobo_app/freezed_models/booking/booking_data_model.dart';
import 'package:arobo_app/freezed_models/treks/treks_model_data.dart';
import 'package:arobo_app/models/treaks/booking_cancelled_modal.dart';
import 'package:arobo_app/models/treaks/verify_order_modal.dart';
import 'package:arobo_app/models/coupon_code/coupon_code_model.dart';
import 'package:arobo_app/models/dispute/submit_issue_modal.dart';
import 'package:arobo_app/models/refund/refund_status_model.dart';
import 'package:arobo_app/services/socket_service.dart';
import 'package:arobo_app/utils/custom_snackbar.dart';
import 'package:arobo_app/utils/loader_dialog.dart';
import 'package:arobo_app/widgets/logger.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../freezed_models/booking/cancellation_data_model.dart';
import '../freezed_models/profile/user_profile_model.dart';
import '../freezed_models/treks/trek_detail_model.dart';
import '../repository/api_result.dart';
import '../repository/repository.dart';
import '../repository/network_url.dart';
import '../utils/auth_utils.dart';
import '../utils/shared_preferences.dart';
// import '../models/trekcard/trek_card_list_model.dart';

class TrekController extends GetxController {
  final Repository repository = Repository();
  final DashboardController _dashboardC = Get.find<DashboardController>();


  final treksResponseObserver = PaginationModel(
      data: const ApiResult<FetchTreksResponseModel>.init().obs,
      isLoading: false,
      isPaginationCompleted: false,
      page: 1,
      error: "")
      .obs;

  final weekendTreksResponseObserver = PaginationModel(
      data: const ApiResult<FetchTreksResponseModel>.init().obs,
      isLoading: false,
      isPaginationCompleted: false,
      page: 1,
      error: "")
      .obs;



  final calculateFareRequestModel = CalculateFareRequestModel(batchId: 1, travelerCount: 1, addInsurance: false, addFreeCancellationProtection: false, couponCode: '').obs;
  final calculateFareResponseModel = const ApiResult<CalculateFareResponseModel>.init().obs;

  final createOrderRequestModel = CreateRazorpayRequestModel(fareToken: "",travelers: []).obs;

  final cancellationDetailsResponseObserver  = const ApiResult<CancellationDetailsResponseModel>.init().obs;
  final requestCancellationResponseObserver  = const ApiResult<BookingCancelledModal>.init().obs;
  final refundStatusObserver = const ApiResult<RefundStatusModel>.init().obs;

  final _socketService = SocketService();
  Timer? _refundPollTimer;

  Rx<TextEditingController> cancellationReasonController =
      TextEditingController().obs;


  // Trek search results
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;
  Rx<TrekDetailModal> trekDetailModal = TrekDetailModal().obs;
  Rx<TrekDetailData> trekDetailData = TrekDetailData().obs;
  RxInt trekDetailId = 0.obs;

  //region AddTrek
  RxInt trekPersonCount = 0.obs;
  RxList<Traveler> travellerDetailList = <Traveler>[].obs;
  RxInt trekBatchId = 0.obs;

  Rx<BookingResponse> orderModal = BookingResponse().obs;
  Rx<Order> orderData = Order().obs;
  Rx<BookingData> orderBookingData = BookingData().obs;

  // Backend-driven next_action routing — populated from raw API responses so
  // screens don't need to re-derive navigation logic.
  Rx<String> orderNextAction = 'OPEN_RAZORPAY'.obs;
  RxMap<String, dynamic> orderNextActionParams = <String, dynamic>{}.obs;
  Rx<String> cancelNextAction = 'SHOW_CANCELLATION_CONFIRMED'.obs;
  RxMap<String, dynamic> cancelNextActionParams = <String, dynamic>{}.obs;

  //endregion
  //region VerifyTrek
  RxString orderId = ''.obs;
  RxString paymentId = ''.obs;
  RxString signature = ''.obs;
  Rx<VerifyOrderModal> verifyOrderModal = VerifyOrderModal().obs;

  //endregion
  //region Rate and review
  RxDouble rating = 0.0.obs;
  Rx<TextEditingController> reviewController = TextEditingController().obs;

  //endregion

  final vendorCouponsObserver = const ApiResult<CouponCodeModel>.init().obs;
  final validateCouponObserver = const ApiResult<ValidateCouponCodeResponseModel>.init().obs;



  //endregion

  //region Issue Report
  Rx<SubmitIssueModal> submitIssueModal = SubmitIssueModal().obs;
  Rx<SubmitIssueData> submitIssueData = SubmitIssueData().obs;

  //endregion


  @override
  void onInit() {
    super.onInit();
    _registerRefundSocketListeners();
  }

  void _registerRefundSocketListeners() {
    _socketService.addListener('refund:initiated', (data) {
      refundStatusObserver.value.maybeWhen(
        success: (model) {
          final d = model?.data;
          if (d == null) return;
          // refund:initiated payload: {bookingId, tbrId, amount, method, refund_speed, expected_by, poll_interval_seconds}
          // NO refundId yet — Razorpay issues it only after the refund is processed
          final updated = RefundStatusData(
            bookingId:          d.bookingId,
            cancellationId:     d.cancellationId,
            cancellationNumber: d.cancellationNumber,
            cancellationDate:   d.cancellationDate,
            refundAmount:       d.refundAmount,
            refundApplicable:   d.refundApplicable,
            refundStatus:       'processing',
            refundId:           d.refundId, // not yet available at initiated stage
            refundSpeed:        data['refund_speed']?.toString() ?? d.refundSpeed,
            refundInitiatedAt:  d.refundInitiatedAt,
            statusMessage:      'Refund submitted — being processed by your bank',
          );
          refundStatusObserver.value = ApiResult.success(
            RefundStatusModel(success: true, data: updated, nextAction: 'POLL_REFUND_STATUS'),
          );
        },
        orElse: () {},
      );
    });

    _socketService.addListener('refund:processed', (data) {
      stopRefundPolling();
      refundStatusObserver.value.maybeWhen(
        success: (model) {
          final d = model?.data;
          if (d == null) return;
          final updated = RefundStatusData(
            bookingId:          d.bookingId,
            cancellationId:     d.cancellationId,
            cancellationNumber: d.cancellationNumber,
            cancellationDate:   d.cancellationDate,
            refundAmount:       d.refundAmount,
            refundApplicable:   d.refundApplicable,
            refundStatus:       'processed',
            refundId:           data['refund_id']?.toString() ?? d.refundId, // backend sends snake_case
            refundSpeed:        d.refundSpeed,
            refundInitiatedAt:  d.refundInitiatedAt,
            refundProcessedAt:  data['settled_at']?.toString(), // backend sends snake_case
            statusMessage:      'Refund credited to your original payment method',
          );
          refundStatusObserver.value = ApiResult.success(
            RefundStatusModel(success: true, data: updated, nextAction: 'SHOW_REFUND_CREDITED'),
          );
        },
        orElse: () {},
      );
    });

    _socketService.addListener('refund:failed', (data) {
      stopRefundPolling();
      refundStatusObserver.value.maybeWhen(
        success: (model) {
          final d = model?.data;
          if (d == null) return;
          final updated = RefundStatusData(
            bookingId:           d.bookingId,
            cancellationId:      d.cancellationId,
            cancellationNumber:  d.cancellationNumber,
            cancellationDate:    d.cancellationDate,
            refundAmount:        d.refundAmount,
            refundApplicable:    d.refundApplicable,
            refundStatus:        'failed',
            refundFailureReason: data['message']?.toString(),
            statusMessage:       'Refund failed — our team will contact you shortly',
          );
          refundStatusObserver.value = ApiResult.success(
            RefundStatusModel(success: true, data: updated, nextAction: 'CONTACT_SUPPORT'),
          );
        },
        orElse: () {},
      );
      if (Get.context != null) {
        CustomSnackBar.show(
          Get.context!,
          message: 'Your refund could not be processed. Our support team will contact you.',
        );
      }
    });
  }

  /// Fetch live refund status from backend (driven by Razorpay webhooks).
  Future<void> fetchRefundStatus(String bookingId) async {
    try {
      final response = await repository.getApiCall(url: NetworkUrl.refundStatus(bookingId));
      if (response != null) {
        refundStatusObserver.value = ApiResult.success(RefundStatusModel.fromJson(response));
      }
    } catch (e) {
      // Non-fatal — polling failure should not surface an error to the user
    }
  }

  /// Start 5-minute polling for refund status (fallback when socket event is missed).
  void startRefundPolling(String bookingId) {
    stopRefundPolling();
    fetchRefundStatus(bookingId); // immediate first fetch
    _refundPollTimer = Timer.periodic(
      const Duration(seconds: 300), // 5 minutes — matches backend poll_interval_seconds
      (_) => fetchRefundStatus(bookingId),
    );
  }

  void stopRefundPolling() {
    _refundPollTimer?.cancel();
    _refundPollTimer = null;
  }

  @override
  void onClose() {
    stopRefundPolling();
    _socketService.removeAllListeners('refund:initiated');
    _socketService.removeAllListeners('refund:processed');
    _socketService.removeAllListeners('refund:failed');
    reviewController.value.dispose();
    if (cancellationReasonController.value.text.isNotEmpty) {
      cancellationReasonController.value.dispose();
    }
    super.onClose();
  }



  Future<void> fetchVendorCoupons() async {
    try {
      vendorCouponsObserver.value = const ApiResult.loading("");

      final int currentTrekId = trekDetailId.value;
      final int currentBatchId = trekBatchId.value;

      if (currentTrekId == 0) {
        throw Exception('Trek ID not found. Please select a trek first.');
      }

      // Use the authenticated customer endpoint that properly filters coupons
      // by trek/batch assignment. This prevents coupons assigned to other treks
      // from appearing in the list.
      final String url = currentBatchId > 0
          ? NetworkUrl.fetchCouponsForBatch(
              batchId: currentBatchId,
              trekId: currentTrekId,
            )
          : NetworkUrl.fetchCouponsForTrek(currentTrekId);

      final response = await repository.getApiCall(url: url);

      if (response != null) {
        final responseData = CouponCodeModel.fromJson(response);
        if (responseData.success == true) {
          vendorCouponsObserver.value = ApiResult.success(responseData);
          return;
        }
        throw "${responseData.message}";
      }
      throw "Response Body Null";
    } catch (e) {
      logger.e('Coupon error: ${e.toString()}');
      CustomSnackBar.show(Get.context!, message: e.toString());
      vendorCouponsObserver.value = ApiResult.error(e.toString());
    }
  }

  Future<void> validateCoupon(String coupon) async {
    try {
      validateCouponObserver.value = const ApiResult.loading("");
      final requestModel = ValidateCouponCodeRequestModel(
        code: coupon,
        trekId: trekDetailId.value,
        bookingAmount: calculateFareResponseModel.value.maybeWhen(
          success: (response) => (response as CalculateFareResponseModel).breakdown?.amountToPayNow,
          orElse: () => "0",
        ),
        // Pass traveler count so the backend can validate group-discount minimum participant rule
        travelerCount: calculateFareRequestModel.value.travelerCount,
      );

      // Validate using serialized JSON keys (not Dart property names).
      // bookingAmount is annotated @JsonKey(name: 'amount'), so toJson()
      // produces "amount" — validate against that key, not "bookingAmount".
      final validateResponse = AuthUtils.validateRequestFields(
        ["code", "trekId", "amount"],
        requestModel.toJson(),
      );
      if (validateResponse != null) throw validateResponse;

      print("===== Coupon Request =====");
      print(requestModel.toJson());
      debugPrint("===== Coupon Request =====");
debugPrint(jsonEncode(requestModel.toJson()));
debugPrint("==========================");

      final response = await repository.postApiCall(
        url: NetworkUrl.validateCoupon,
        body: requestModel.toJson(),
      );

      if (response != null) {
        final responseData = ValidateCouponCodeResponseModel.fromJson(response);
        if (responseData.success == true) {
          validateCouponObserver.value = ApiResult.success(responseData);
          calculateFareRequestModel.value = calculateFareRequestModel.value.copyWith(couponCode: coupon);
          Get.back();
          return;
        }
        throw "${responseData.message}";
      }
      throw "Response Body Null";
    } catch (e) {
      logger.e('Coupon error: ${e.toString()}');
      CustomSnackBar.show(Get.context!, message: e.toString());
      validateCouponObserver.value = ApiResult.error(e.toString());
    }
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



  Future<void> searchTreks({required int cityId,
    required int trekId,
    required String date,
    required bool refresh}) async {
    final observer = treksResponseObserver;

    try {
      if (refresh == true) {
        observer.value = PaginationModel(
            data: const ApiResult<FetchTreksResponseModel>.init().obs,
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

      final response = await repository.getApiCall(
        url: NetworkUrl.searchTrek(
            cityId.toString(),
            trekId.toString(),
            convertDateYYYYMMDD(date),
            null,
            observer.value.page,
            20
        ),
      );

      final body = response;
      if (body != null) {
        final responseData = FetchTreksResponseModel.fromJson(body);
        if (responseData.success == true) {
          observer.value.data.value.maybeWhen(success: (data) {
            final oldList =
            (data as FetchTreksResponseModel?)?.data?.toList();
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


  Future<void> fetchWeekendTreks({
    required String cityId,
    required String trekId,
    required String date,
    required bool refresh}) async {

    final observer = weekendTreksResponseObserver;

    try {
      if (refresh == true) {
        observer.value = PaginationModel(
            data: const ApiResult<FetchTreksResponseModel>.init().obs,
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

      final response = await repository.getApiCall(
        url: NetworkUrl.fetchWeekEndTreks(
            cityId.toString(),
            trekId.toString(),
            convertDateYYYYMMDD(date),
            observer.value.page,
            20
        ),
      );
      
      final body = response;
      if (body != null) {
        final responseData = FetchTreksResponseModel.fromJson(body);
        if (responseData.success == true) {
          observer.value.data.value.maybeWhen(success: (data) {
            final oldList =
            (data as FetchTreksResponseModel?)?.data?.toList();
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





  Future<void> trekDetail({required int batchId}) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // final selectedDate =
      //     convertDateYYYYMMDD(_dashboardC.dateController.value.text);
      final response = await repository.getApiCall(
        url: '${NetworkUrl.getTrekDetail}$trekDetailId?batch_id=$batchId&city_id=${_dashboardC.selectedCityId.value}',
      );

      if (response != null) {
        if (response['success']) {
          trekDetailModal.value = TrekDetailModal.fromJson(response);
          trekDetailData.value = trekDetailModal.value.data ?? TrekDetailData();
        } else {
          errorMessage.value = response['message'];
          CustomSnackBar.show(Get.context!, message: errorMessage.value);
        }
      }
    } catch (e, st) {
      errorMessage.value = 'Failed to load trek details: ${e.toString()}';
      logger.e(st);
      CustomSnackBar.show(Get.context!, message: errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }


  Future<void> calculateFare() async {

    try {
      calculateFareResponseModel.value = ApiResult.loading("");
      final response = await repository.postApiCall(
        url: NetworkUrl.calculateFare,
        body: calculateFareRequestModel.value.toJson()
      );

      if (response != null) {
        final responseData = CalculateFareResponseModel.fromJson(response);
        if (responseData.success == true) {
          calculateFareResponseModel.value = ApiResult.success(responseData);
          logger.d('fareToken: ${responseData.fareToken ?? ""}');
          createOrderRequestModel.value = createOrderRequestModel.value.copyWith(fareToken: responseData.fareToken ?? "");
          return;
        }
        throw "${responseData.message}";
      }
      throw "Response Body Null";
    } catch (e) {
      errorMessage.value = 'Failed to search treks: ${e.toString()}';
      CustomSnackBar.show(Get.context!, message: errorMessage.value);
      calculateFareResponseModel.value = ApiResult.error('Failed to search treks: ${e.toString()}');
    }
  }



  Future<void> createTrekOrder() async {
    try {
      showLoaderDialog();
      // Populate travelers from the selected list, normalizing gender to title case
      createOrderRequestModel.value = createOrderRequestModel.value.copyWith(
  travelers: travellerDetailList.map((t) {
    final g = t.gender ?? '';
    final normalizedGender = g.isNotEmpty
        ? g[0].toUpperCase() + g.substring(1).toLowerCase()
        : g;
    return t.copyWith(gender: normalizedGender);
  }).toList(),
);

// ===== DEBUG START =====
debugPrint("========== CREATE ORDER ==========");
debugPrint("Traveller Count: ${travellerDetailList.length}");

for (final t in travellerDetailList) {
  debugPrint(
    "ID=${t.id}, Name=${t.name}, Age=${t.age}, Gender=${t.gender}",
  );
}

debugPrint("Request JSON:");
debugPrint(jsonEncode(createOrderRequestModel.value.toJson()));
debugPrint("========== END CREATE ORDER ==========");
// ===== DEBUG END =====

final response = await repository.postApiCall(
  url: NetworkUrl.addBooking,
  body: createOrderRequestModel.toJson(),
);

      if (response != null) {
        if (response['success']) {
          orderModal.value = BookingResponse.fromJson(response);
          orderData.value = orderModal.value.order ?? Order();
          orderBookingData.value = orderModal.value.bookingData ?? BookingData();
          orderNextAction.value = response['next_action'] ?? 'OPEN_RAZORPAY';
          orderNextActionParams.value = Map<String, dynamic>.from(
              response['next_action_params'] ?? {});

          // Persist BEFORE Razorpay checkout opens (caller does that next) —
          // not after success — so a killed/crashed app can find this on
          // relaunch and ask the backend whether it already went through,
          // instead of the user unknowingly attempting to pay twice.
          final pendingOrderId = orderData.value.id;
          if (pendingOrderId != null && pendingOrderId.toString().isNotEmpty) {
            final pref = await SpUtil.getInstance();
            await pref.putString(SpUtil.pendingOrderId, pendingOrderId.toString());
          }

          logger.d(
            'TrekController createTrekOrder - next_action: ${orderNextAction.value}',
          );
        } else {
          errorMessage.value = response['message'];
          logger.e(errorMessage.value);
          CustomSnackBar.show(Get.context!, message: errorMessage.value);
        }
      }
    } catch (e) {
      errorMessage.value = 'Failed to create booking: ${e.toString()}';
      CustomSnackBar.show(Get.context!, message: errorMessage.value);
    } finally {
      hideLoaderDialog();
      isLoading.value = false;
    }
  }

  /// Verifies a Razorpay payment and creates the booking. Safe to call more
  /// than once with the SAME orderId/paymentId — the backend
  /// (paymentService._completeBookingCore) is idempotent on order_id: a
  /// second call for an already-completed order returns the existing
  /// booking instead of erroring or double-charging. This is what makes it
  /// safe for the UI to retry this exact call after a network failure
  /// instead of restarting checkout from scratch.
  ///
  /// Returns true only when the booking was confirmed (fresh or
  /// already-processed); false on any failure, so the caller can decide
  /// how to surface the error instead of this always doing it via snackbar.
  Future<bool> verifyTrekOrder({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    showLoaderDialog();

    String body = json.encode({
      "razorpay_order_id": razorpayOrderId,
      "razorpay_payment_id": razorpayPaymentId,
      "razorpay_signature": razorpaySignature
    });

    try {
      final response = await repository.postApiCall(
        url: NetworkUrl.verifyBooking,
        body: body,
      );

      if (response != null) {
        if (response['success']) {
          verifyOrderModal.value = VerifyOrderModal.fromJson(response);
          final nextAction = response['next_action'] ?? 'SHOW_BOOKING_CONFIRMED';
          hideLoaderDialog();
          if (nextAction == 'SHOW_BOOKING_CONFIRMED') {
            // Booking is confirmed — nothing left to resume on next launch.
            final pref = await SpUtil.getInstance();
            await pref.remove(SpUtil.pendingOrderId);
            // BUGFIX: unlike the review-submit and cancellation flows below,
            // this success path never invalidated the cached bookings list —
            // "My Bookings" kept showing whatever was loaded before this
            // payment, with the new booking missing until a manual pull-to-
            // refresh or app restart.
            Get.find<DashboardController>().getBookingHistory(refresh: true);
            Get.offNamedUntil(
              '/payment-success',
              ModalRoute.withName('/dashboard'),
            );
            CustomSnackBar.show(Get.context!, message: 'Payment Successful!');
            return true;
          }
          return false;
        } else {
          hideLoaderDialog();
          errorMessage.value = response['message'] ?? 'Payment verification failed';
          return false;
        }
      }
      hideLoaderDialog();
      errorMessage.value = 'Payment verification failed';
      return false;
    } catch (e, s) {
      hideLoaderDialog();
      logger.e('Stack trace: $s');
      logger.e('Error: $e');
      errorMessage.value = 'Failed to verify payment: ${e.toString()}';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Called once on app launch/resume (see DashboardMain.initState) — before
  /// the user ever gets a chance to reopen Razorpay checkout again. If a
  /// previous session created an order and then the app was killed/crashed
  /// before verify-payment could run (network drop, OS reclaim, force-close),
  /// this is the only way we'd otherwise find out whether that payment
  /// actually went through.
  ///
  /// Deliberately silent — no loader, no snackbar on the common paths. This
  /// runs in the background while the dashboard is already rendering; a
  /// blocking dialog here would stall app startup for a case that mostly
  /// resolves to "nothing to do".
  Future<void> checkPendingOrderOnResume() async {
    final pref = await SpUtil.getInstance();
    final pendingOrderId = pref.getString(SpUtil.pendingOrderId);
    if (pendingOrderId == null || pendingOrderId.isEmpty) return;

    try {
      final response = await repository.getApiCall(
        url: NetworkUrl.orderStatus(pendingOrderId),
      );

      if (response == null || response['success'] != true) {
        // 404 etc. — order isn't findable/ownable anymore; nothing left to
        // resume. Clear it so we stop checking on every future launch.
        await pref.remove(SpUtil.pendingOrderId);
        return;
      }

      final status = response['data']?['status'] as String?;

      switch (status) {
        case 'paid':
          // Payment succeeded server-side (client callback or the Razorpay
          // webhook completed it) even though this device never found out.
          await pref.remove(SpUtil.pendingOrderId);
          logger.d('checkPendingOrderOnResume: order already paid — booking exists, nothing to reopen');
          // Refresh so "check My Bookings" below is actually true by the
          // time the user taps it, not stale from before this booking.
          Get.find<DashboardController>().getBookingHistory(refresh: true);
          if (Get.context != null) {
            CustomSnackBar.show(
              Get.context!,
              message: 'Your earlier booking payment was confirmed — check My Bookings.',
            );
          }
          break;
        case 'expired':
        case 'refunded':
          // Genuinely dead — safe to let the user start a fresh booking next time.
          await pref.remove(SpUtil.pendingOrderId);
          break;
        case 'pending':
        default:
          // Still genuinely in flight (or an unrecognized shape) — leave the
          // stored id in place and re-check on the next launch rather than
          // guessing. Never auto-reopen Razorpay checkout from here.
          break;
      }
    } catch (e) {
      // Network failure / server error — unknown state, not a definitive
      // answer. Keep the stored id so we try again next launch instead of
      // silently discarding the one clue we have.
      logger.w('checkPendingOrderOnResume failed: ${e.toString()}');
    }
  }

  /// One-off order-status check for a specific order_id — used when
  /// Razorpay's own checkout SDK reports an error, but that doesn't
  /// guarantee the payment actually failed server-side (the webhook, or a
  /// racing client call, may have already completed it). Returns the
  /// `data` object (`{status, booking_id, booking_number, ...}`) on success,
  /// or null if the check itself was inconclusive (network error, or the
  /// order genuinely isn't found) — callers must treat null as "don't know",
  /// not as "definitely failed".
  Future<Map<String, dynamic>?> checkOrderStatus(String orderId) async {
    if (orderId.isEmpty) return null;
    try {
      final response = await repository.getApiCall(url: NetworkUrl.orderStatus(orderId));
      if (response == null || response['success'] != true) return null;
      return response['data'] as Map<String, dynamic>?;
    } catch (e) {
      logger.w('checkOrderStatus failed: ${e.toString()}');
      return null;
    }
  }

  createReview({
    required int trekId,
    required int customerId,
    required int bookingId,
    required int batchId,
    required bool safetySecurity,
    required bool organizerManner,
    required bool trekPlanning,
    required bool womenSafety,
  }) async {
    String body = json.encode({
      "trek_id": trekId,
      "booking_id": bookingId,
      "batch_id": batchId,
      "rating_value": rating.value,
      "content": reviewController.value.text,
      "safety_security_count": safetySecurity ? 1 : 0,
      "organizer_manner_count": organizerManner ? 1 : 0,
      "trek_planning_count": trekPlanning ? 1 : 0,
      "women_safety_count": womenSafety ? 1 : 0,
    });
    try {
      final response = await repository.postApiCall(
        url: NetworkUrl.review,
        body: body,
      );

      if (response != null) {
        if (response['success']) {
          await _dashboardC.getBookingHistory(refresh: true);
          reviewController.value.clear();
          Get.back();
          Get.back();
          CustomSnackBar.show(
            Get.context!,
            message: 'Thank you for your valuable feedback!',
          );
          update();
        } else {
          errorMessage.value = response['message'];
          CustomSnackBar.show(Get.context!, message: errorMessage.value);
          reviewController.value.clear();
        }
      }
    } catch (e) {
      errorMessage.value = 'Failed to submit review: ${e.toString()}';
      CustomSnackBar.show(Get.context!, message: errorMessage.value);
    } finally {
      reviewController.value.clear();
      isLoading.value = false;
    }
  }


  Future<String?> fetchCancellationDetails(String bookingId) async {
    try {
      cancellationDetailsResponseObserver.value = ApiResult.loading("");
      final response = await repository.getApiCall(url: NetworkUrl.refundDetail(bookingId));

      if (response != null) {
        final responseData = CancellationDetailsResponseModel.fromJson(response);
        if (responseData.success == true) {
          cancellationDetailsResponseObserver.value = ApiResult.success(responseData);
          return responseData.data?.canCancel == true ? null : responseData.data?.cancellationMessage;
        }
        throw "${responseData.message}";
      }
      throw "Response Body Null";
    } catch (e) {
      CustomSnackBar.show(Get.context!, message: errorMessage.value);
      cancellationDetailsResponseObserver.value = ApiResult.error('Failed to get calcellation details treks: ${e.toString()}');
      return e.toString();
    }
  }

  Future<String?> reqCancellation(String bookingId) async {
    try {
      requestCancellationResponseObserver.value = ApiResult.loading("");
      final response = await repository.postApiCall(url: NetworkUrl.refund,body: {"booking_id":bookingId,"reason":cancellationReasonController.value.text.toString()});

      if (response != null) {
        final responseData = BookingCancelledModal.fromJson(response);
        if (responseData.success == true) {
          cancelNextAction.value =
              response['next_action'] ?? 'SHOW_CANCELLATION_CONFIRMED';
          cancelNextActionParams.value =
              Map<String, dynamic>.from(response['next_action_params'] ?? {});
          requestCancellationResponseObserver.value = ApiResult.success(responseData);
          Get.find<DashboardController>().getBookingHistory(refresh: true);
          return null;
        }
        throw "${responseData.message}";
      }
      throw "Response Body Null";
    } catch (e) {
      // If the server says "already cancelled", the first call actually succeeded
      // (the booking was cancelled) but the response parse crashed locally.
      // Treat it as success so the user sees the confirmation screen.
      final errMsg = e.toString();
      if (errMsg.contains('already cancelled') || errMsg.contains('Booking is already cancelled')) {
        requestCancellationResponseObserver.value = ApiResult.success(
          BookingCancelledModal(success: true, message: 'Booking cancelled successfully'),
        );
        Get.find<DashboardController>().getBookingHistory(refresh: true);
        return null;
      }
      CustomSnackBar.show(Get.context!, message: errMsg);
      requestCancellationResponseObserver.value = ApiResult.error('Failed to get cancellation details: $errMsg');
      return errMsg;
    }
  }




  Future<bool> submitIssueReport({
    required String name,
    required String phoneNumber,
    required String email,
    required int bookingId,
    required String issueType,
    String? issueCategory,
    String? description,
    required String priority,
    required String sla,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';

    String body = json.encode({
      "name": name,
      "phone_number": phoneNumber,
      "email": email,
      "booking_id": bookingId,
      "issue_type": issueType,
      if (issueCategory != null) "issue_category": issueCategory,
      if (description != null && description.isNotEmpty)
        "description": description,
      "priority": priority,
      "sla": sla,
    });

    try {
      final response = await repository.postApiCall(
        url: NetworkUrl.submitIssue,
        body: body,
      );

      if (response != null) {
        if (response['success'] == true) {
          // Parse the response into the modal
          submitIssueModal.value = SubmitIssueModal.fromJson(response);
          submitIssueData.value =
              submitIssueModal.value.data ?? SubmitIssueData();

          CustomSnackBar.show(
            Get.context!,
            message:
                response['message'] ?? 'Issue report submitted successfully!',
          );

          // Add a small delay before fetching dispute details to allow backend processing
          Future.delayed(Duration(milliseconds: 500), () {
            try {
              Get.find<DashboardController>().getBookingDetail(
                bookingId: bookingId.toString(),
              );
            } catch (e) {
              logger.w('Error refreshing dispute details: $e');
            }
          });

          Get.back();
          // Get.forceAppUpdate();
          // update();
          return true;
        } else {
          errorMessage.value =
              response['message'] ?? 'Failed to submit issue report';
          CustomSnackBar.show(Get.context!, message: errorMessage.value);
          return false;
        }
      }
    } catch (e) {
      errorMessage.value = 'Failed to submit issue report: ${e.toString()}';
      CustomSnackBar.show(Get.context!, message: errorMessage.value);
    } finally {
      isLoading.value = false;
    }
    return false;
  }

  /// Clears all booking and payment related data
  /// Call this after successful payment to reset the controller for next booking
   clearBookingData() {
    // Clear trek selection
    trekPersonCount.value = 0;
    travellerDetailList.clear();
    trekBatchId.value = 0;

    // Clear order data
    orderModal.value = BookingResponse();
    orderData.value = Order();
    orderBookingData.value = BookingData();

    // Clear payment verification data
    orderId.value = '';
    paymentId.value = '';
    signature.value = '';
    verifyOrderModal.value = VerifyOrderModal();


    // Clear review data
    rating.value = 0.0;
    reviewController.value.clear();

    logger.d('TrekController: Booking data cleared');
  }
}
