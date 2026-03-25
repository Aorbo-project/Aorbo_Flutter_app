import 'dart:convert';

import 'package:arobo_app/widgets/logger.dart';
import 'package:flutter/material.dart';

import 'package:arobo_app/models/dashboard/trek_modal.dart';
import 'package:arobo_app/models/treaks/booking_history_modal.dart';
import 'package:arobo_app/models/user_profile/state_list_model.dart';
import 'package:arobo_app/models/refund/refund_detail_modal.dart';
import 'package:arobo_app/models/dispute/dispute_detail_modal.dart';
import 'package:get/get.dart';
import '../models/dashboard/cities_model.dart';
import '../models/treaks/booking_cancelled_modal.dart';
import '../repository/network_url.dart';
import '../repository/repository.dart';
import '../utils/custom_snackbar.dart';

class DashboardController extends GetxController {
  final Repository _repository = Repository();

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

  //region Booking history
  Rx<BookingHistoryModel> bookingHistoryModal = BookingHistoryModel().obs;
  RxList<BookingHistoryData> bookingList = <BookingHistoryData>[].obs;
  RxBool isLoadingBookingHistory = false.obs;
  RxInt currentBookingPage = 1.obs;
  RxBool hasMoreBookings = true.obs;
  RxString selectedFilter = 'All Bookings'.obs;
  Rx<BookingCancelledModal> bookingCancelledModal = BookingCancelledModal().obs;
  Rx<BookingCancelledData> bookingCancelledData = BookingCancelledData().obs;

  //endregion

  //region Refund Detail
  RxBool isLoadingRefundDetail = false.obs;

  Rx<RefundDetailModal> refundDetailModal = RefundDetailModal().obs;
  Rx<RefundDetailData> refundDetailData = RefundDetailData().obs;
  Rx<TextEditingController> cancellationReasonController =
      TextEditingController().obs;

  //endregion

  //region Dispute Detail
  RxBool isLoadingDisputeDetail = false.obs;
  Rx<DisputeDetailModal> disputeDetailModal = DisputeDetailModal().obs;
  RxList<Disputes> disputeDetailDataList = <Disputes>[].obs;

  //endregion

  @override
  void onInit() {
    super.onInit();
    Future.wait([fetchCitiesList(), fetchTrekList(), fetchStateList()]);
  }

  @override
  void onClose() {
    fromController.value.dispose();
    toController.value.dispose();
    dateController.value.dispose();
    cancellationReasonController.value.dispose();
    super.onClose();
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
      }
    } catch (e) {
      errorMessage.value = 'Failed to load states: ${e.toString()}';
      CustomSnackBar.showGlobalError(message: errorMessage.value);
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
      }
    } catch (e) {
      errorMessage.value = 'Failed to load cities: ${e.toString()}';
      CustomSnackBar.showGlobalError(message: errorMessage.value);
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
      }
    } catch (e) {
      errorMessage.value = 'Failed to load treks: ${e.toString()}';
      CustomSnackBar.showGlobalError(message: errorMessage.value);
    } finally {
      isLoadingCities.value = false;
    }
  }

  getBookingHistory({bool isRefresh = false}) async {
    if (isRefresh) {
      currentBookingPage.value = 1;
      hasMoreBookings.value = true;
    }

    if (isLoadingBookingHistory.value) return;

    isLoadingBookingHistory.value = true;
    errorMessage.value = '';

    try {
      final response = await _repository.getApiCall(
        url: NetworkUrl.bookingHistoryWithStatus(
          page: currentBookingPage.value,
          trekStatus: selectedFilter.value == 'All Bookings'
              ? null
              : selectedFilter.value,
        ),
      );

      if (response != null) {
        if (response['success']) {
          bookingHistoryModal.value = BookingHistoryModel.fromJson(response);
          final newBookings = bookingHistoryModal.value.data ?? [];

          if (isRefresh || currentBookingPage.value == 1) {
            bookingList.value = newBookings;
          } else {
            bookingList.addAll(newBookings);
          }

          final pagination = bookingHistoryModal.value.pagination;
          hasMoreBookings.value = pagination?.hasNextPage ?? false;

          if (hasMoreBookings.value) {
            currentBookingPage.value++;
          }

          // Get.forceAppUpdate();
          update();
        } else {
          errorMessage.value = response['message'];
          CustomSnackBar.showGlobalError(message: errorMessage.value);
        }
      }
    } catch (e) {
      errorMessage.value = 'Failed to load booking history: ${e.toString()}';
      CustomSnackBar.showGlobalError(message: errorMessage.value);
    } finally {
      isLoadingBookingHistory.value = false;
    }
  }

  getRefundDetail(String bookingId) async {
    isLoadingRefundDetail.value = true;
    errorMessage.value = '';

    try {
      final response = await _repository.getApiCall(
        url: NetworkUrl.refundDetail(bookingId),
      );

      if (response != null) {
        if (response['success']) {
          refundDetailModal.value = RefundDetailModal.fromJson(response);
          refundDetailData.value =
              refundDetailModal.value.data ?? RefundDetailData();
        } else {
          errorMessage.value =
              response['message'] ?? 'Failed to load refund details';
          CustomSnackBar.showGlobalError(message: errorMessage.value);
        }
      }
    } catch (e) {
      errorMessage.value = 'Failed to load refund details: ${e.toString()}';
      CustomSnackBar.showGlobalError(message: errorMessage.value);
    } finally {
      isLoadingRefundDetail.value = false;
    }

    return null;
  }

  getDisputeDetail({required String bookingId}) async {
    isLoadingDisputeDetail.value = true;
    errorMessage.value = '';

    try {
      final response = await _repository.getApiCall(
        url: NetworkUrl.bookingDispute(bookingId),
      );

      if (response != null) {
        if (response['success']) {
          disputeDetailModal.value = DisputeDetailModal.fromJson(response);

          disputeDetailDataList.value =
              disputeDetailModal.value.data?.disputes ?? [];
        } else {
          errorMessage.value =
              response['message'] ?? 'Failed to load dispute details';
          // CustomSnackBar.showGlobalError(message: errorMessage.value);
        }
      }
    } catch (e) {
      errorMessage.value = 'Failed to load dispute details: ${e.toString()}';
      // Only show error if context is available (user is still on a screen)
      if (Get.context != null) {
        CustomSnackBar.showGlobalError(message: errorMessage.value);
      }
    } finally {
      isLoadingDisputeDetail.value = false;
    }

    return null;
  }

  reqCancellation({
    required int bookingId,
    required BookingHistoryData bookingData,
  }) async {
    try {
      String body = json.encode({
        'booking_id': bookingId,
        'total_refundable_amount':
            refundDetailData.value.refundCalculation?.refund ?? 0,
        'reason': cancellationReasonController.value.text,
        'deduction': refundDetailData.value.refundCalculation?.deduction ?? 0,
      });
      final response = await _repository.postApiCall(
        url: NetworkUrl.refund,
        body: body,
      );

      if (response != null) {
        if (response['success']) {
          bookingCancelledModal.value = BookingCancelledModal.fromJson(
            response,
          );
          bookingCancelledData.value =
              bookingCancelledModal.value.data ?? BookingCancelledData();
          Get.toNamed('/booking-cancellation-success', arguments: bookingData);
        } else {
          Get.back();
          errorMessage.value =
              response['message'] ?? 'Failed to load refund details';
          CustomSnackBar.showGlobalError(message: errorMessage.value);
        }
      }
    } catch (e) {
      errorMessage.value = 'Failed to load refund details: ${e.toString()}';
      CustomSnackBar.showGlobalError(message: errorMessage.value);
    } finally {
      cancellationReasonController.value.clear();
      isLoadingRefundDetail.value = false;
    }
  }

  /// Clears search and temporary booking related data
  /// Call this after successful payment to reset filters and temporary data
  void clearSearchAndBookingData() {
    // Clear search filters
    selectedTrekId.value = 0;
    fromController.value.clear();
    fromController.refresh(); // Notify observers
    toController.value.clear();
    toController.refresh(); // Notify observers
    dateController.value.clear();
    dateController.refresh(); // Notify observers that the text has changed
    selectedDate.value = null;

    // Clear refund detail data (temporary)
    refundDetailModal.value = RefundDetailModal();
    refundDetailData.value = RefundDetailData();
    cancellationReasonController.value.clear();

    // Clear booking cancellation data (temporary)
    bookingCancelledModal.value = BookingCancelledModal();
    bookingCancelledData.value = BookingCancelledData();

    // Clear dispute detail data (temporary)
    disputeDetailModal.value = DisputeDetailModal();
    disputeDetailDataList.clear();

    // Note: We keep selectedCityId, citiesData, trekData, stateList, bookingList, selectedScreen
    // as these are user preferences or master data that should persist

    logger.d('DashboardController: Search and booking data cleared');
  }
}
