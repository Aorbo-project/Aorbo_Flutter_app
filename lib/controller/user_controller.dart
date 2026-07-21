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

  // ── LEGACY SHARED CONTROLLERS ──────────────────────────────────────────
  // Kept ONLY for backwards compatibility with older screens that still
  // read/write them. Do NOT attach these to TextFields in new code —
  // sharing these across routes/bottom sheets is what caused the
  // "TextEditingController was used after being disposed" red screen.
  Rx<TextEditingController> emailController = TextEditingController().obs;
  Rx<TextEditingController> phoneNumberController = TextEditingController().obs;
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
        phoneNumberController.value.text =
            userProfileData.value.customer?.phone?.replaceFirst('+91', '') ??
            '';
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // ── PARAMETERIZED API METHODS ──────────────────────────────────────────
  // All return true only on confirmed backend success, so callers can
  // decide what to do with their own UI state.

  Future<bool> updateProfileDetails({
    required String email,
    required int stateId,
  }) async {
    isLoading.value = true;
    try {
      final String body = json.encode({"email": email, "state_id": stateId});
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
        response?['message']?.toString() ??
            'Could not add traveller. Please try again.',
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
        response?['message']?.toString() ??
            'Could not update traveller. Please try again.',
      );
      return false;
    } catch (e) {
      _showError(e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Returns true only once the backend has confirmed the soft-delete —
  // callers must not remove the traveler from local/UI state on any other
  // outcome, or a failed delete looks identical to a successful one.
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

  // ── LEGACY WRAPPERS (older call sites) ─────────────────────────────────
  Future<void> updateUserProfile() async {
    await updateProfileDetails(
      email: emailController.value.text,
      stateId: stateUpdateId.value,
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
