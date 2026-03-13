import 'dart:convert';

import 'package:arobo_app/models/user_profile/user_profile_modal.dart';
import 'package:arobo_app/repository/network_url.dart';
import 'package:arobo_app/repository/repository.dart';
import 'package:arobo_app/utils/custom_snackbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class UserController extends GetxController {
  final Repository repository = Repository();
  Rx<UserProfileModal> userModal = UserProfileModal().obs;
  Rx<UserProfileData> userProfileData = UserProfileData().obs;
  RxBool isLoading = false.obs;
  Rx<TextEditingController> emailController = TextEditingController().obs;
  Rx<TextEditingController> phoneNumberController = TextEditingController().obs;
  RxInt stateUpdateId = 0.obs;

//region traveller
  RxString selectedGender = ''.obs;
  Rx<TextEditingController> nameControllerTraveller =
      TextEditingController().obs;
  Rx<TextEditingController> ageControllerTraveller =
      TextEditingController().obs;
  RxInt travellerId = 0.obs;

  //endregion
  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    emailController.value.dispose();
    phoneNumberController.value.dispose();
    nameControllerTraveller.value.dispose();
    ageControllerTraveller.value.dispose();
    super.onClose();
  }

  getUserProfile() async {
    isLoading.value = true;

    try {
      final response = await repository.getApiCall(
        url: NetworkUrl.getUserProfile,
      );

      if (response != null) {
        userModal.value = UserProfileModal.fromJson(response);
        userProfileData.value = userModal.value.data ?? UserProfileData();
        phoneNumberController.value.text =
            userProfileData.value.customer?.phone?.replaceFirst('+91', '') ??
                '-';
      }
    } catch (e) {
      CustomSnackBar.show(
        Get.context!,
        message: e.toString(),
      );
    } finally {
      isLoading.value = false;
    }
  }

  updateUserProfile() async {
    isLoading.value = true;
    String body = json.encode({
      "email": emailController.value.text,
      "state_id": stateUpdateId.value,
    });
    try {
      final response = await repository.putApiCall(
          url: NetworkUrl.getUserProfile, body: body);
      if (response != null) {
        if (response['success']) {
          await getUserProfile();
        } else {
          CustomSnackBar.show(Get.context!, message: response['message']);
        }
      }
    } catch (e) {
      CustomSnackBar.show(
        Get.context!,
        message: e.toString(),
      );
    } finally {
      isLoading.value = false;
    }
  }

  addTraveler() async {
    isLoading.value = true;
    String body = json.encode({
      "name": nameControllerTraveller.value.text,
      "age": ageControllerTraveller.value.text,
      "gender": selectedGender.value,
    });
    try {
      final response = await repository.postApiCall(
          url: NetworkUrl.addTraveller, body: body);
      if (response != null) {
        if (response['success']) {
          await getUserProfile();
          nameControllerTraveller.value.clear();
          ageControllerTraveller.value.clear();
          selectedGender.value = '';
        } else {
          CustomSnackBar.show(Get.context!, message: response['message']);
        }
      }
    } catch (e) {
      CustomSnackBar.show(
        Get.context!,
        message: e.toString(),
      );
    } finally {
      isLoading.value = false;
    }
  }

  updateTraveler() async {
    isLoading.value = true;
    String body = json.encode({
      "name": nameControllerTraveller.value.text,
      "age": ageControllerTraveller.value.text,
      "gender": selectedGender.value,
    });
    try {
      final response = await repository.putApiCall(
          url: "${NetworkUrl.addTraveller}/${travellerId.value}", body: body);
      if (response != null) {
        if (response['success']) {
          await getUserProfile();
          nameControllerTraveller.value.clear();
          ageControllerTraveller.value.clear();
          selectedGender.value = '';
        } else {
          CustomSnackBar.show(Get.context!, message: response['message']);
        }
      }
    } catch (e) {
      CustomSnackBar.show(
        Get.context!,
        message: e.toString(),
      );
    } finally {
      isLoading.value = false;
    }
  }
}
