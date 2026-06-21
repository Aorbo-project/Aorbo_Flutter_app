import 'dart:convert';

import 'package:arobo_app/controller/dashboard_controller.dart';
import 'package:arobo_app/freezed_models/booking/booking_data_model.dart';
import 'package:arobo_app/freezed_models/treks/treks_model_data.dart';
import 'package:arobo_app/models/treaks/booking_cancelled_modal.dart';
import 'package:arobo_app/models/treaks/verify_order_modal.dart';
import 'package:arobo_app/models/coupon_code/coupon_code_model.dart';
import 'package:arobo_app/models/dispute/submit_issue_modal.dart';
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
  void onClose() {
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

      final validateResponse =  AuthUtils.validateRequestFields(["code","trekId","bookingAmount"], requestModel.toJson());
      if(validateResponse != null) throw validateResponse;

      final response = await repository.postApiCall(
        url: NetworkUrl.validateCoupon,
        body: requestModel.toJson(),
      );

      if (response != null) {
        final responseData = ValidateCouponCodeResponseModel.fromJson(response);
        if (responseData.success == true) {
          validateCouponObserver.value = ApiResult.success(responseData);
          calculateFareRequestModel.value = calculateFareRequestModel.value.copyWith(couponCode: coupon ?? '');
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
      final response = await repository.postApiCall(
        url: NetworkUrl.addBooking,
        body: createOrderRequestModel.toJson(),
      );

      if (response != null) {
        if (response['success']) {
          orderModal.value = BookingResponse.fromJson(response);
          orderData.value = orderModal.value.order ?? Order();
          orderBookingData.value = orderModal.value.bookingData ?? BookingData();

          logger.d(
            'TrekController createTrekOrder - Server returned finalAmount: ${orderBookingData.value.finalAmount}',
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

  verifyTrekOrder({
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
          hideLoaderDialog();
          Get.offNamedUntil(
            '/payment-success',
            ModalRoute.withName('/dashboard'),
          );
          CustomSnackBar.show(Get.context!, message: 'Payment Successful!');
        } else {
          hideLoaderDialog();

          errorMessage.value = response['message'];
          CustomSnackBar.show(Get.context!, message: errorMessage.value);
        }
      }
    } catch (e, s) {
      hideLoaderDialog();
      logger.e('Stack trace: $s');
      logger.e('Error: $e');
      errorMessage.value = 'Failed to verify payment: ${e.toString()}';
      CustomSnackBar.show(Get.context!, message: errorMessage.value);
    } finally {
      isLoading.value = false;
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
          requestCancellationResponseObserver.value = ApiResult.success(responseData);
          Get.find<DashboardController>().getBookingHistory(refresh: true);
          return null;
        }
        throw "${responseData.message}";
      }
      throw "Response Body Null";
    } catch (e) {
      CustomSnackBar.show(Get.context!, message: e.toString());
      requestCancellationResponseObserver.value = ApiResult.error('Failed to get cancellation details: ${e.toString()}');
      return e.toString();
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
