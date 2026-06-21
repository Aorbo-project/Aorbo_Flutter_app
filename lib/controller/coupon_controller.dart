


import 'package:arobo_app/repository/network_url.dart';

import '../models/coupon_code/coupon_code_model.dart';
import '../repository/api_result.dart';
import 'package:get/get.dart';

import '../repository/repository.dart';
import '../utils/custom_snackbar.dart';

class CouponController extends GetxController {
  Repository repository = Repository();


  final adminCouponsObserver = const ApiResult<CouponCodeModel>.init().obs;


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