


import 'package:arobo_app/repository/network_url.dart';
import 'package:arobo_app/utils/common_colors.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

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
      final body = response.body;
      if (response.isOk && body != null) {
        final responseData = CouponCodeModel.fromJson(body);
        if (responseData.success == true) {
          adminCouponsObserver.value = ApiResult.success(responseData);
          return;
        }
        throw "${responseData.message}";
      }
      throw "Response Body Null";
    } catch (e) {
      CustomSnackBar.show(Get.context!, message: e.toString());
      adminCouponsObserver.value = ApiResult.error(e.toString());
    }
  }


}