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

class TrekController extends GetxController {
  final Repository repository = Repository();
  final DashboardController _dashboardC = Get.find<DashboardController>();

  // Bumped on every refresh() call to searchTreks. Lets an in-flight request
  // detect that a newer refresh has since superseded it, so its response gets
  // discarded instead of merged into the new list — without this, two
  // near-simultaneous calls (e.g. a double-tap on the Search button, which has
  // no debounce guard) both reset to page 1 and fire independent requests;
  // whichever response lands second sees the first one's result already
  // sitting in `success` state and appends onto it, duplicating every card.
  int _searchGeneration = 0;

  final treksResponseObserver = PaginationModel(
    data: const ApiResult<FetchTreksResponseModel>.init().obs,
    isLoading: false,
    isPaginationCompleted: false,
    page: 1,
    error: "",
  ).obs;

  final calculateFareRequestModel = CalculateFareRequestModel(
    batchId: 1,
    travelerCount: 1,
    addInsurance: false,
    addFreeCancellationProtection: false,
    couponCode: '',
  ).obs;
  final calculateFareResponseModel =
      const ApiResult<CalculateFareResponseModel>.init().obs;

  final createOrderRequestModel = CreateRazorpayRequestModel(
    fareToken: "",
    travelers: [],
  ).obs;

  final cancellationDetailsResponseObserver =
      const ApiResult<CancellationDetailsResponseModel>.init().obs;
  final requestCancellationResponseObserver =
      const ApiResult<BookingCancelledModal>.init().obs;
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

  // Customer's chosen boarding/source city for this booking (Booking.city_id
  // on the backend). Auto-selected when the trek has exactly one boarding
  // point; must be explicitly chosen by the customer on trek_details_screen
  // when there's more than one, and survives navigation into
  // traveller_information_screen where calculateFare() actually sends it.
  Rx<int?> selectedBoardingCityId = Rx<int?>(null);

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
  final validateCouponObserver =
      const ApiResult<ValidateCouponCodeResponseModel>.init().obs;

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
          final updated = RefundStatusData(
            bookingId: d.bookingId,
            cancellationId: d.cancellationId,
            cancellationNumber: d.cancellationNumber,
            cancellationDate: d.cancellationDate,
            refundAmount: d.refundAmount,
            refundApplicable: d.refundApplicable,
            refundStatus: 'processing',
            refundId: d.refundId,
            refundSpeed: data['refund_speed']?.toString() ?? d.refundSpeed,
            refundInitiatedAt: d.refundInitiatedAt,
            statusMessage: 'Refund submitted — being processed by your bank',
          );
          refundStatusObserver.value = ApiResult.success(
            RefundStatusModel(
              success: true,
              data: updated,
              nextAction: 'POLL_REFUND_STATUS',
            ),
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
            bookingId: d.bookingId,
            cancellationId: d.cancellationId,
            cancellationNumber: d.cancellationNumber,
            cancellationDate: d.cancellationDate,
            refundAmount: d.refundAmount,
            refundApplicable: d.refundApplicable,
            refundStatus: 'processed',
            refundId: data['refund_id']?.toString() ?? d.refundId,
            refundSpeed: d.refundSpeed,
            refundInitiatedAt: d.refundInitiatedAt,
            refundProcessedAt: data['settled_at']?.toString(),
            statusMessage: 'Refund credited to your original payment method',
          );
          refundStatusObserver.value = ApiResult.success(
            RefundStatusModel(
              success: true,
              data: updated,
              nextAction: 'SHOW_REFUND_CREDITED',
            ),
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
            bookingId: d.bookingId,
            cancellationId: d.cancellationId,
            cancellationNumber: d.cancellationNumber,
            cancellationDate: d.cancellationDate,
            refundAmount: d.refundAmount,
            refundApplicable: d.refundApplicable,
            refundStatus: 'failed',
            refundFailureReason: data['message']?.toString(),
            statusMessage: 'Refund failed — our team will contact you shortly',
          );
          refundStatusObserver.value = ApiResult.success(
            RefundStatusModel(
              success: true,
              data: updated,
              nextAction: 'CONTACT_SUPPORT',
            ),
          );
        },
        orElse: () {},
      );
      if (Get.context != null) {
        CustomSnackBar.show(
          Get.context!,
          message:
              'Your refund could not be processed. Our support team will contact you.',
        );
      }
    });
  }

  /// Fetch live refund status from backend (driven by Razorpay webhooks).
  Future<void> fetchRefundStatus(String bookingId) async {
    try {
      final response = await repository.getApiCall(
        url: NetworkUrl.refundStatus(bookingId),
      );
      if (response != null) {
        final model = RefundStatusModel.fromJson(response);
        refundStatusObserver.value = ApiResult.success(model);
        // A full-deduction cancellation's refund_status stays null forever —
        // nothing was ever going to move it to processing/processed, so
        // without this the 5-minute timer below ran indefinitely (until the
        // screen closed) polling for a status that could never change.
        if (model.nextAction == 'NO_REFUND_APPLICABLE') {
          stopRefundPolling();
        }
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
      const Duration(seconds: 300),
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
          success: (response) => (response as CalculateFareResponseModel)
              .breakdown
              ?.amountToPayNow,
          orElse: () => "0",
        ),
        travelerCount: calculateFareRequestModel.value.travelerCount,
        // trekBatchId.value gets reset to 0 by clearBookingData() after every
        // successful booking and is only repopulated when the Trek Details
        // screen re-initializes — if the coupon dialog opens before that
        // happens for a new trek, it stays 0 and the request silently drops
        // batch context, making the backend check "already used" across ALL
        // of this customer's bookings instead of just this TBR. trekDetailData
        // is populated directly from the trek-detail API response that must
        // already be loaded for this screen to exist, so it's never stale.
        batchId: (trekDetailData.value.batchId != null &&
                trekDetailData.value.batchId! > 0)
            ? trekDetailData.value.batchId
            : (trekBatchId.value > 0 ? trekBatchId.value : null),
      );

      final validateResponse = AuthUtils.validateRequestFields([
        "code",
        "trekId",
        "amount",
      ], requestModel.toJson());
      if (validateResponse != null) throw validateResponse;

      final response = await repository.postApiCall(
        url: NetworkUrl.validateCoupon,
        body: requestModel.toJson(),
      );

      if (response != null) {
        final responseData = ValidateCouponCodeResponseModel.fromJson(response);
        if (responseData.success == true) {
          validateCouponObserver.value = ApiResult.success(responseData);
          calculateFareRequestModel.value = calculateFareRequestModel.value
              .copyWith(couponCode: coupon);
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

  Future<void> searchTreks({
    required int cityId,
    required int trekId,
    required String date,
    required bool refresh,
  }) async {
    final observer = treksResponseObserver;

    if (refresh == true) {
      _searchGeneration++;
      observer.value = PaginationModel(
        data: const ApiResult<FetchTreksResponseModel>.init().obs,
        isLoading: false,
        isPaginationCompleted: false,
        page: 1,
        error: "",
      );
    }
    final myGeneration = _searchGeneration;

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

      final response = await repository.getApiCall(
        url: NetworkUrl.searchTrek(
          cityId.toString(),
          trekId.toString(),
          convertDateYYYYMMDD(date),
          null,
          observer.value.page,
          20,
        ),
      );

      // A newer refresh() call started while this request was in flight —
      // that call already reset observer.value to its own fresh state, so
      // merging this stale response into it would duplicate every card.
      if (myGeneration != _searchGeneration) return;

      final body = response;
      if (body != null) {
        final responseData = FetchTreksResponseModel.fromJson(body);
        if (responseData.success == true) {
          observer.value.data.value.maybeWhen(
            success: (data) {
              final oldList = (data as FetchTreksResponseModel?)?.data
                  ?.toList();
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
      final response = await repository.getApiCall(
        url:
            '${NetworkUrl.getTrekDetail}$trekDetailId?batch_id=$batchId&city_id=${_dashboardC.selectedCityId.value}',
      );

      if (response != null) {
        if (response['success']) {
          trekDetailModal.value = TrekDetailModal.fromJson(response);
          trekDetailData.value = trekDetailModal.value.data ?? TrekDetailData();

          // Reset per-trek, then auto-select when there's exactly one
          // boarding option — matches trek_details_screen's existing
          // boardingCandidates logic (is_boarding_point==true, deduped).
          // When there's more than one, this stays null until the customer
          // picks one on that screen.
          selectedBoardingCityId.value = null;
          final boardingStages = (trekDetailData.value.trekStages ?? [])
              .where((s) => s.isBoardingPoint == true && s.cityId != null)
              .toList();
          final uniqueBoardingCityIds = boardingStages
              .map((s) => s.cityId)
              .toSet();
          if (uniqueBoardingCityIds.length == 1) {
            selectedBoardingCityId.value = uniqueBoardingCityIds.first;
          }
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
      // Always send the customer's current boarding-city selection (set on
      // trek_details_screen, required when the trek has more than one
      // boarding option) rather than whatever was in the model when it was
      // first constructed.
      calculateFareRequestModel.value = calculateFareRequestModel.value
          .copyWith(boardingCityId: selectedBoardingCityId.value);
      final response = await repository.postApiCall(
        url: NetworkUrl.calculateFare,
        body: calculateFareRequestModel.value.toJson(),
      );

      if (response != null) {
        final responseData = CalculateFareResponseModel.fromJson(response);
        if (responseData.success == true) {
          calculateFareResponseModel.value = ApiResult.success(responseData);
          logger.d('fareToken: ${responseData.fareToken ?? ""}');
          createOrderRequestModel.value = createOrderRequestModel.value
              .copyWith(fareToken: responseData.fareToken ?? "");
          return;
        }
        throw "${responseData.message}";
      }
      throw "Response Body Null";
    } catch (e) {
      errorMessage.value = 'Failed to search treks: ${e.toString()}';
      CustomSnackBar.show(Get.context!, message: errorMessage.value);
      calculateFareResponseModel.value = ApiResult.error(
        'Failed to search treks: ${e.toString()}',
      );
    }
  }

  Future<void> createTrekOrder() async {
    try {
      showLoaderDialog();
      createOrderRequestModel.value = createOrderRequestModel.value.copyWith(
        travelers: travellerDetailList.map((t) {
          final g = t.gender ?? '';
          final normalizedGender = g.isNotEmpty
              ? g[0].toUpperCase() + g.substring(1).toLowerCase()
              : g;
          return t.copyWith(gender: normalizedGender);
        }).toList(),
      );

      final response = await repository.postApiCall(
        url: NetworkUrl.addBooking,
        body: createOrderRequestModel.toJson(),
      );

      if (response != null) {
        if (response['success']) {
          orderModal.value = BookingResponse.fromJson(response);
          orderData.value = orderModal.value.order ?? Order();
          orderBookingData.value =
              orderModal.value.bookingData ?? BookingData();
          orderNextAction.value = response['next_action'] ?? 'OPEN_RAZORPAY';
          orderNextActionParams.value = Map<String, dynamic>.from(
            response['next_action_params'] ?? {},
          );

          final pendingOrderId = orderData.value.id;
          if (pendingOrderId != null && pendingOrderId.toString().isNotEmpty) {
            final pref = await SpUtil.getInstance();
            await pref.putString(
              SpUtil.pendingOrderId,
              pendingOrderId.toString(),
            );
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
  /// than once with the SAME orderId/paymentId — the backend is idempotent.
  /// Returns true only when the booking was confirmed; false on any failure.
  /// Verifies a Razorpay payment and creates the booking. Safe to call more
  /// than once with the SAME orderId/paymentId — the backend is idempotent.
  /// Returns true only when the booking was confirmed; false on any failure.
  Future<bool> verifyTrekOrder({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    // REMOVED showLoaderDialog() to prevent UI conflicts and flashes.

    String body = json.encode({
      "razorpay_order_id": razorpayOrderId,
      "razorpay_payment_id": razorpayPaymentId,
      "razorpay_signature": razorpaySignature,
    });

    try {
      final response = await repository.postApiCall(
        url: NetworkUrl.verifyBooking,
        body: body,
      );

      if (response != null) {
        if (response['success']) {
          verifyOrderModal.value = VerifyOrderModal.fromJson(response);
          final nextAction =
              response['next_action'] ?? 'SHOW_BOOKING_CONFIRMED';

          if (nextAction == 'SHOW_BOOKING_CONFIRMED') {
            // Booking is confirmed — nothing left to resume on next launch.
            final pref = await SpUtil.getInstance();
            await pref.remove(SpUtil.pendingOrderId);
            // Refresh cached list in background so My Bookings is up to date
            Get.find<DashboardController>().getBookingHistory(refresh: true);
            return true;
          }
          return false;
        } else {
          errorMessage.value =
              response['message'] ?? 'Payment verification failed';
          return false;
        }
      }
      errorMessage.value = 'Payment verification failed';
      return false;
    } catch (e, s) {
      logger.e('Stack trace: $s');
      logger.e('Error: $e');
      errorMessage.value = 'Failed to verify payment: ${e.toString()}';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> checkPendingOrderOnResume() async {
    final pref = await SpUtil.getInstance();
    final pendingOrderId = pref.getString(SpUtil.pendingOrderId);
    if (pendingOrderId == null || pendingOrderId.isEmpty) return;

    try {
      final response = await repository.getApiCall(
        url: NetworkUrl.orderStatus(pendingOrderId),
      );

      if (response == null || response['success'] != true) {
        await pref.remove(SpUtil.pendingOrderId);
        return;
      }

      final status = response['data']?['status'] as String?;

      switch (status) {
        case 'paid':
          await pref.remove(SpUtil.pendingOrderId);
          logger.d(
            'checkPendingOrderOnResume: order already paid — booking exists, nothing to reopen',
          );
          Get.find<DashboardController>().getBookingHistory(refresh: true);
          if (Get.context != null) {
            CustomSnackBar.show(
              Get.context!,
              message:
                  'Your earlier booking payment was confirmed — check My Bookings.',
            );
          }
          break;
        case 'expired':
        case 'refunded':
          await pref.remove(SpUtil.pendingOrderId);
          break;
        case 'pending':
        default:
          break;
      }
    } catch (e) {
      logger.w('checkPendingOrderOnResume failed: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>?> checkOrderStatus(String orderId) async {
    if (orderId.isEmpty) return null;
    try {
      final response = await repository.getApiCall(
        url: NetworkUrl.orderStatus(orderId),
      );
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
      final response = await repository.getApiCall(
        url: NetworkUrl.refundDetail(bookingId),
      );

      if (response != null) {
        final responseData = CancellationDetailsResponseModel.fromJson(
          response,
        );
        if (responseData.success == true) {
          cancellationDetailsResponseObserver.value = ApiResult.success(
            responseData,
          );
          return responseData.data?.canCancel == true
              ? null
              : responseData.data?.cancellationMessage;
        }
        throw "${responseData.message}";
      }
      throw "Response Body Null";
    } catch (e) {
      CustomSnackBar.show(Get.context!, message: errorMessage.value);
      cancellationDetailsResponseObserver.value = ApiResult.error(
        'Failed to get calcellation details treks: ${e.toString()}',
      );
      return e.toString();
    }
  }

  Future<String?> reqCancellation(String bookingId) async {
    try {
      requestCancellationResponseObserver.value = ApiResult.loading("");
      final response = await repository.postApiCall(
        url: NetworkUrl.refund,
        body: {
          "booking_id": bookingId,
          "reason": cancellationReasonController.value.text.toString(),
        },
      );

      if (response != null) {
        final responseData = BookingCancelledModal.fromJson(response);
        if (responseData.success == true) {
          cancelNextAction.value =
              response['next_action'] ?? 'SHOW_CANCELLATION_CONFIRMED';
          cancelNextActionParams.value = Map<String, dynamic>.from(
            response['next_action_params'] ?? {},
          );
          requestCancellationResponseObserver.value = ApiResult.success(
            responseData,
          );
          Get.find<DashboardController>().getBookingHistory(refresh: true);
          return null;
        }
        throw "${responseData.message}";
      }
      throw "Response Body Null";
    } catch (e) {
      final errMsg = e.toString();
      if (errMsg.contains('already cancelled') ||
          errMsg.contains('Booking is already cancelled')) {
        requestCancellationResponseObserver.value = ApiResult.success(
          BookingCancelledModal(
            success: true,
            message: 'Booking cancelled successfully',
          ),
        );
        Get.find<DashboardController>().getBookingHistory(refresh: true);
        return null;
      }
      CustomSnackBar.show(Get.context!, message: errMsg);
      requestCancellationResponseObserver.value = ApiResult.error(
        'Failed to get cancellation details: $errMsg',
      );
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
          submitIssueModal.value = SubmitIssueModal.fromJson(response);
          submitIssueData.value =
              submitIssueModal.value.data ?? SubmitIssueData();

          CustomSnackBar.show(
            Get.context!,
            message:
                response['message'] ?? 'Issue report submitted successfully!',
          );

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
    trekPersonCount.value = 0;
    travellerDetailList.clear();
    trekBatchId.value = 0;

    orderModal.value = BookingResponse();
    orderData.value = Order();
    orderBookingData.value = BookingData();

    orderId.value = '';
    paymentId.value = '';
    signature.value = '';
    verifyOrderModal.value = VerifyOrderModal();

    rating.value = 0.0;
    reviewController.value.clear();

    logger.d('TrekController: Booking data cleared');
  }
}
