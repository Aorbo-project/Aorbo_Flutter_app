import 'dart:convert';

import 'package:arobo_app/freezed_models/treks/treks_model_data.dart';
import 'package:arobo_app/models/treaks/create_order_modal.dart';
import 'package:arobo_app/models/treaks/treak_detail_modal.dart';
import 'package:arobo_app/models/treaks/verify_order_modal.dart';
import 'package:arobo_app/models/user_profile/user_profile_modal.dart';
import 'package:arobo_app/models/coupon_code/coupon_code_model.dart';
import 'package:arobo_app/models/dispute/submit_issue_modal.dart';
import 'package:arobo_app/utils/custom_snackbar.dart';
import 'package:arobo_app/utils/loader_dialog.dart';
import 'package:arobo_app/widgets/logger.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../repository/api_result.dart';
import '../repository/repository.dart';
import '../repository/network_url.dart';
import '../controller/dashboard_controller.dart';
import '../utils/booking_constants.dart';
// import '../models/trekcard/trek_card_list_model.dart';

class TrekController extends GetxController {
  final Repository repository = Repository();
  final DashboardController _dashboardC = Get.find<DashboardController>();


  final treksResponseObserver = const ApiResult<FetchTreksResponseModel>.init().obs;


  // Trek search results
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;
  Rx<TrekDetailModal> trekDetailModal = TrekDetailModal().obs;
  Rx<TrekDetailData> trekDetailData = TrekDetailData().obs;
  RxInt trekDetailId = 0.obs;

  //region AddTrek
  RxInt trekPersonCount = 0.obs;
  RxList<Travelers> travellerDetailList = <Travelers>[].obs;
  RxInt trekBatchId = 0.obs;
  RxDouble totalAmount = 0.0.obs;
  Rx<CreateOrderModal> orderModal = CreateOrderModal().obs;
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

  //region Coupons
  Rx<CouponCodeModel> couponModal = CouponCodeModel().obs;
  RxList<CouponCardData> couponsList = <CouponCardData>[].obs;
  RxBool isCouponLoading = false.obs;
  RxString couponErrorMessage = ''.obs;
  RxBool isCouponValidating = false.obs;
  RxString appliedCouponCode = ''.obs;
  RxString appliedCouponId = ''.obs;
  RxDouble discountAmount = 0.0.obs;

  //endregion

  //region Issue Report
  Rx<SubmitIssueModal> submitIssueModal = SubmitIssueModal().obs;
  Rx<SubmitIssueData> submitIssueData = SubmitIssueData().obs;

  //endregion

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    reviewController.value.dispose();
    super.onClose();
  }

  static String convertDateYYYYMMDD(String date) {
    if (date.isEmpty) return '';

    try {
      DateFormat inputFormat;

      // Detect the format
      if (date.contains('/')) {
        inputFormat = DateFormat('dd/MM/yyyy');
      } else if (date.contains('-')) {
        inputFormat = DateFormat('dd-MM-yyyy');
      } else {
        throw FormatException('Unknown date separator');
      }

      final inputDate = inputFormat.parse(date);
      final outputFormat = DateFormat('yyyy-MM-dd');
      return outputFormat.format(inputDate);
    } catch (e) {
      logger.w('Invalid date format: $e');
      return '';
    }
  }

  Future<void> searchTrek({
    required int cityId,
    required int trekId,
    required String date,
  }) async {

    try {
      treksResponseObserver.value = ApiResult.loading("");
      final response = await repository.getApiCall(
        url: NetworkUrl.searchTrek(
          cityId.toString(),
          trekId.toString(),
          convertDateYYYYMMDD(date),
        ),
      );

      final body = response.body;
      if (response.isOk && body != null) {
        final responseData = FetchTreksResponseModel.fromJson(body);
        if (responseData.success == true) {
          treksResponseObserver.value = ApiResult.success(responseData);
          return;
        }
        throw "${responseData.message}";
      }
      throw "Response Body Null";
    } catch (e) {
      errorMessage.value = 'Failed to search treks: ${e.toString()}';
      CustomSnackBar.show(Get.context!, message: errorMessage.value);
      treksResponseObserver.value = ApiResult.error('Failed to search treks: ${e.toString()}');
    }
  }

  Future<void> trekDetail({required int batchId}) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // final selectedDate =
      //     convertDateYYYYMMDD(_dashboardC.dateController.value.text);
      final response = await repository.getApiCall(
        url:
            '${NetworkUrl.getTrekDetail}$trekDetailId?batch_id=$batchId&city_id=${_dashboardC.selectedCityId.value}',
      );

      if (response != null) {
        if (response['success']) {
          trekDetailModal.value = TrekDetailModal.fromJson(response);
          trekDetailData.value = trekDetailModal.value.data ?? TrekDetailData();
          logger.d(trekDetailData.value.latestReviews?.length);
          Get.toNamed('/trek-details');
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

  Future<void> fetchTrekBatches(int trekId) async{
    try{

      final response = await repository.getApiCall(url: NetworkUrl.getTrekBatches(trekId));


    }
    catch(error){

    }
  }


  Future<void> calculateFare() async{
    try{

    }
    catch(error){

    }
  }

  createTrekOrder({
    required String selectedPaymentOption,
    required double remainingAmount,
    required double finalAmount,
  }) async {
    logger.d('TrekController createTrekOrder - finalAmount: $finalAmount');
    String body = json.encode({
      "trekId": trekDetailId.value,
      "travelers": travellerDetailList,
      "batchId": trekBatchId.value,
      "isAdvanceAmount":
      selectedPaymentOption == BookingConstants.partialPayment,
      "remaining_amount": remainingAmount,
      "finalAmount": finalAmount,
    });
    try {
      showLoaderDialog();
      final response = await repository.postApiCall(
        url: NetworkUrl.addBooking,
        body: body,
      );

      if (response != null) {
        if (response['success']) {
          orderModal.value = CreateOrderModal.fromJson(response);
          orderData.value = orderModal.value.order ?? Order();
          orderBookingData.value =
              orderModal.value.bookingData ?? BookingData();

          logger.d(
            'TrekController createTrekOrder - Server returned finalAmount: ${orderBookingData.value.finalAmount}',
          );
        } else {
          errorMessage.value = response['message'];
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
    required String selectedPaymentOption,
    required Map<String, dynamic> fareBreakup,
  }) async {
    showLoaderDialog();

    // Transform traveler field names to camelCase for API
    List<Map<String, dynamic>> transformedTravelers = travellerDetailList.map((traveler) {
      return {
        "id": traveler.id,
        "customerId": traveler.customerId,
        "name": traveler.name,
        "age": traveler.age,
        "gender": traveler.gender,
        "isActive": traveler.isActive,
        "createdAt": traveler.createdAt,
        "updatedAt": traveler.updatedAt,
      };
    }).toList();

    String body = json.encode({
      "orderId": orderId.value,
      "cityId": _dashboardC.selectedCityId.value,
      "paymentId": paymentId.value,
      "signature": signature.value,
      "travelers": transformedTravelers,
      "trekId": trekDetailId.value,
      "batchId": trekBatchId.value,
      "isPartialAmount":
      selectedPaymentOption == BookingConstants.partialPayment,
      "fareBreakup": fareBreakup,
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
      "customer_id": customerId,
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
          await _dashboardC.getBookingHistory(isRefresh: true);
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

  Future<void> getCoupons() async {
    isCouponLoading.value = true;
    couponErrorMessage.value = '';

    try {
      final vendorId = trekDetailData.value.vendorId;
      if (vendorId == null) {
        throw Exception('Vendor ID not found');
      }

      final response = await repository.getApiCall(
        url: NetworkUrl.couponCode(vendorId.toString()),
      );

      if (response != null) {
        if (response['success'] == true) {
          couponModal.value = CouponCodeModel.fromJson(response);
          couponsList.value = couponModal.value.data ?? [];
        } else {
          couponErrorMessage.value =
              response['message'] ?? 'Failed to fetch coupons';
          CustomSnackBar.show(Get.context!, message: couponErrorMessage.value);
        }
      }
    } catch (e) {
      couponErrorMessage.value = 'Failed to fetch coupons: ${e.toString()}';
      CustomSnackBar.show(Get.context!, message: couponErrorMessage.value);
    } finally {
      isCouponLoading.value = false;
    }
  }

  Future<bool> validateCoupon({
    required String couponCode,
    required int customerId,
    required double baseAmount,
  }) async {
    isCouponValidating.value = true;
    couponErrorMessage.value = '';

    String body = json.encode({
      "code": couponCode,
      "customer_id": customerId.toString(),
      "amount": baseAmount.toInt(),
    });

    try {
      final response = await repository.postApiCall(
        url: NetworkUrl.validatedCoupon,
        body: body,
      );

      if (response != null) {
        if (response['success'] == true) {
          // Store validated coupon details
          appliedCouponCode.value = couponCode;

          // Extract coupon ID from response
          if (response['data'] != null && response['data']['id'] != null) {
            appliedCouponId.value = response['data']['id'].toString();
          } else {
            appliedCouponId.value = '';
          }

          // Extract discount amount from response
          // Assuming the response contains discount information
          if (response['data'] != null &&
              response['data']['discount_amount'] != null) {
            final discountValue = response['data']['discount_amount'];
            discountAmount.value =
                double.tryParse(discountValue.toString()) ?? 0.0;
          } else if (response['data'] != null &&
              response['data']['discount_percentage'] != null) {
            // If percentage is returned, calculate discount amount
            final percentageValue = response['data']['discount_percentage'];
            final percentage =
                double.tryParse(percentageValue.toString()) ?? 0.0;
            discountAmount.value = (baseAmount * percentage) / 100;
          }

          // Update total amount with discount applied
          _updateTotalAmountWithDiscount();

          CustomSnackBar.show(
            Get.context!,
            message: 'Coupon applied successfully!',
          );
          return true;
        } else {
          couponErrorMessage.value =
              response['message'] ?? 'Invalid coupon code';
          CustomSnackBar.show(Get.context!, message: couponErrorMessage.value);
          return false;
        }
      }
    } catch (e) {
      couponErrorMessage.value = 'Failed to validate coupon: ${e.toString()}';
      CustomSnackBar.show(Get.context!, message: couponErrorMessage.value);
    } finally {
      isCouponValidating.value = false;
    }
    return false;
  }

  void _updateTotalAmountWithDiscount() {
    // Note: This method only updates the base trek amount for coupon validation
    // The final comprehensive calculation including GST, insurance, etc.
    // is handled in the traveller information screen

    // Calculate base amount for the number of travelers
    final basePricePerPerson = double.parse(
      trekDetailData.value.basePrice ?? "0.0",
    );
    final baseAmount = basePricePerPerson * trekPersonCount.value;

    // Apply discount while maintaining the original fare structure
    final discountedAmount = baseAmount - discountAmount.value;

    // Ensure total amount doesn't go below 0
    totalAmount.value = discountedAmount > 0 ? discountedAmount : 0.0;
    logger.i("TrekController totalAmount updated: ${totalAmount.value}");
  }

  void removeCoupon() {
    appliedCouponCode.value = '';
    appliedCouponId.value = '';
    discountAmount.value = 0.0;

    // Recalculate total amount without discount
    final basePricePerPerson = double.parse(
      trekDetailData.value.basePrice ?? "0.0",
    );
    totalAmount.value = basePricePerPerson * trekPersonCount.value;

    logger.i(
      "Coupon removed - TrekController totalAmount reset: ${totalAmount.value}",
    );
    CustomSnackBar.show(Get.context!, message: 'Coupon removed successfully');
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
              Get.find<DashboardController>().getDisputeDetail(
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
    totalAmount.value = 0.0;

    // Clear order data
    orderModal.value = CreateOrderModal();
    orderData.value = Order();
    orderBookingData.value = BookingData();

    // Clear payment verification data
    orderId.value = '';
    paymentId.value = '';
    signature.value = '';
    verifyOrderModal.value = VerifyOrderModal();

    // Clear coupon data
    appliedCouponCode.value = '';
    appliedCouponId.value = '';
    discountAmount.value = 0.0;

    // Clear review data
    rating.value = 0.0;
    reviewController.value.clear();

    logger.d('TrekController: Booking data cleared');
  }
}
