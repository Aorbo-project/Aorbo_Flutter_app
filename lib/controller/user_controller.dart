import 'dart:convert';
import 'package:arobo_app/repository/network_url.dart';
import 'package:arobo_app/repository/repository.dart';
import 'package:arobo_app/utils/custom_snackbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../freezed_models/profile/user_profile_model.dart';

class UserController extends GetxController {
  final Repository repository = Repository();
  Rx<UserProfileModal> userModal = UserProfileModal().obs;
  Rx<UserProfileData> userProfileData = UserProfileData().obs;
  RxBool isLoading = false.obs;

  // Legacy controllers kept for backward compatibility
  Rx<TextEditingController> emailController = TextEditingController().obs;
  Rx<TextEditingController> phoneNumberController = TextEditingController().obs;
  Rx<TextEditingController> nameController = TextEditingController().obs;
  RxInt stateUpdateId = 0.obs;
  RxString selectedGender = ''.obs;
  Rx<TextEditingController> nameControllerTraveller =
      TextEditingController().obs;
  Rx<TextEditingController> ageControllerTraveller =
      TextEditingController().obs;
  RxInt travellerId = 0.obs;

  @override
  void onClose() {
    emailController.value.dispose();
    phoneNumberController.value.dispose();
    nameController.value.dispose();
    nameControllerTraveller.value.dispose();
    ageControllerTraveller.value.dispose();
    super.onClose();
  }

  void _showError(String message) {
    final ctx = Get.context;
    if (ctx != null) CustomSnackBar.show(ctx, message: message);
  }

  Future<void> getUserProfile() async {
    isLoading.value = true;
    try {
      final response = await repository.getApiCall(
        url: NetworkUrl.getUserProfile,
      );
      if (response != null) {
        userModal.value = UserProfileModal.fromJson(response);
        userProfileData.value = userModal.value.data ?? UserProfileData();

        final customer = userProfileData.value.customer;
        phoneNumberController.value.text =
            customer?.phone?.replaceFirst('+91', '') ?? '';
        nameController.value.text = customer?.name ?? '';
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateProfileDetails({
    required String email,
    required int stateId,
    String? name,
  }) async {
    isLoading.value = true;
    try {
      final Map<String, dynamic> bodyMap = {
        "email": email,
        "state_id": stateId,
      };
      if (name != null && name.trim().isNotEmpty) bodyMap["name"] = name.trim();

      final String body = json.encode(bodyMap);
      final response = await repository.putApiCall(
        url: NetworkUrl.getUserProfile,
        body: body,
      );

      if (response != null && response['success'] == true) {
        await getUserProfile();
        return true;
      }
      _showError(
        response?['message']?.toString() ??
            'Could not update profile. Please try again.',
      );
      return false;
    } catch (e) {
      _showError(e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addTravelerDetails({
    required String name,
    required String age,
    required String gender,
  }) async {
    isLoading.value = true;
    try {
      final String body = json.encode({
        "name": name,
        "age": age,
        "gender": gender,
      });
      final response = await repository.postApiCall(
        url: NetworkUrl.addTraveller,
        body: body,
      );
      if (response != null && response['success'] == true) {
        await getUserProfile();
        return true;
      }
      _showError(
        response?['message']?.toString() ?? 'Could not add traveller.',
      );
      return false;
    } catch (e) {
      _showError(e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateTravelerDetails({
    required int id,
    required String name,
    required String age,
    required String gender,
  }) async {
    isLoading.value = true;
    try {
      final String body = json.encode({
        "name": name,
        "age": age,
        "gender": gender,
      });
      final response = await repository.putApiCall(
        url: "${NetworkUrl.addTraveller}/$id",
        body: body,
      );
      if (response != null && response['success'] == true) {
        await getUserProfile();
        return true;
      }
      _showError(
        response?['message']?.toString() ?? 'Could not update traveller.',
      );
      return false;
    } catch (e) {
      _showError(e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteTraveler(int travelerId) async {
    isLoading.value = true;
    try {
      final response = await repository.deleteApiCall(
        url: "${NetworkUrl.addTraveller}/$travelerId",
      );
      if (response != null && response['success'] == true) {
        await getUserProfile();
        return true;
      }
      _showError(
        response?['message']?.toString() ?? 'Could not delete traveller.',
      );
      return false;
    } catch (e) {
      _showError(e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateUserProfile() async {
    await updateProfileDetails(
      email: emailController.value.text,
      stateId: stateUpdateId.value,
      name: nameController.value.text,
    );
  }

  Future<void> addTraveler() async {
    final ok = await addTravelerDetails(
      name: nameControllerTraveller.value.text,
      age: ageControllerTraveller.value.text,
      gender: selectedGender.value,
    );
    if (ok) {
      nameControllerTraveller.value.clear();
      ageControllerTraveller.value.clear();
      selectedGender.value = '';
    }
  }

  Future<void> updateTraveler() async {
    final ok = await updateTravelerDetails(
      id: travellerId.value,
      name: nameControllerTraveller.value.text,
      age: ageControllerTraveller.value.text,
      gender: selectedGender.value,
    );
    if (ok) {
      nameControllerTraveller.value.clear();
      ageControllerTraveller.value.clear();
      selectedGender.value = '';
    }
  }
}
