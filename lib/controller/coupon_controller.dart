


import 'package:arobo_app/repository/network_url.dart';

import '../models/coupon_code/coupon_code_model.dart';
import '../repository/api_result.dart';
import 'package:get/get.dart';

import '../repository/repository.dart';
import '../utils/custom_snackbar.dart';

class CouponController extends GetxController {
  Repository repository = Repository();


  final adminCouponsObserver = const ApiResult<CouponCodeModel>.init().obs;


  /// Fetches active PLATFORM-scoped coupons for display in the Trek Listing
  /// screen carousel.
  ///
  /// Calls GET /api/v1/coupons/platform — no auth required, no trek/destination
  /// context needed. PLATFORM coupons are global marketing banners shown on
  /// every destination.
  ///
  /// Failure is non-fatal: if the endpoint returns an error the carousel is
  /// simply hidden; the trek list still loads normally.
  Future<void> fetchPlatformCoupons() async {
    try {
      adminCouponsObserver.value = const ApiResult.loading("");
      final response =
          await repository.getApiCall(url: NetworkUrl.fetchPlatformCoupons);
      if (response != null) {
        final responseData = CouponCodeModel.fromJson(response);
        if (responseData.success == true) {
          adminCouponsObserver.value = ApiResult.success(responseData);
          return;
        }
        throw "${responseData.message}";
      }
      throw "Response Body Null";
    } catch (e) {
      // Non-fatal — missing coupon carousel is acceptable.
      // Do NOT show a snackbar; do NOT crash the listing screen.
      adminCouponsObserver.value = ApiResult.error(e.toString());
    }
  }

  /// Legacy method kept for any future trek-specific coupon lookups.
  /// Not used by the Trek Listing screen — see [fetchPlatformCoupons].
  Future<void> fetchAdminCoupons(int trekId) async {
    try {
      adminCouponsObserver.value = const ApiResult.loading("");
      final response = await repository.getApiCall(url:NetworkUrl.fetchAdminCoupons(trekId));
      if (response != null) {
        final responseData = CouponCodeModel.fromJson(response);
        if (responseData.success == true) {
          adminCouponsObserver.value = ApiResult.success(responseData);
          return;
        }
        throw "${responseData.message}";
      }
      throw "Response Body Null";
    } catch (e) {
      print("Error On Coupon ${e.toString()}");
      CustomSnackBar.show(Get.context!, message: e.toString());
      adminCouponsObserver.value = ApiResult.error(e.toString());
    }
  }


}