import 'package:arobo_app/utils/common_colors.dart';
import 'package:arobo_app/utils/screen_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

showToastMessage({String? msg}) {
  Get.closeAllSnackbars();
  Get.rawSnackbar(
    message: msg,
    backgroundColor: CommonColors.appColor,
  );
}

showErrorToastMessage({String? msg}) {
  Get.closeAllSnackbars();
  Get.rawSnackbar(
    message: msg,
    backgroundColor: CommonColors.red_B52424,
  );
}

showAlertDialog({String? msg}) {
  AlertDialog alert = AlertDialog(
    contentPadding: EdgeInsets.zero,
    content: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Text(
        msg!.contains("Exception") ? msg.replaceAll("Exception: ", "") : msg,
        style: const TextStyle(
            color: CommonColors.blackColor,
            fontWeight: FontWeight.normal,
            fontSize: 13),
      ),
    ),
    //insetPadding: const EdgeInsets.all(10),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    actions: [
      GestureDetector(
        onTap: () {
          Get.back();
        },
        child: Container(
          alignment: Alignment.center,
          height: ScreenConstant.size40,
          width: ScreenConstant.size80,
          decoration: BoxDecoration(
              color: CommonColors.appGreenColor,
              borderRadius: BorderRadius.circular(10)),
          child: const Text(
            "Ok",
            textAlign: TextAlign.center,
            style: TextStyle(color: CommonColors.whiteColor),
          ),
        ),
      ),
    ],
  );
  showDialog(
    context: Get.context!,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

noInternetDialog({required Function() onRetry}) {
  showDialog(
    context: Get.context!,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      title: const Text('No Internet Connection.'),
      content: const Text('Please check your internet connection and try.'),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: CommonColors.blueColor,
            fixedSize: const Size.fromWidth(100),
            padding: const EdgeInsets.all(10),
          ),
          child: const Text("Retry"),
          onPressed: () {
            Get.back();
            onRetry();
          },
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: CommonColors.blueColor,
            fixedSize: const Size.fromWidth(100),
            padding: const EdgeInsets.all(10),
          ),
          child: const Text("Ok"),
          onPressed: () {
            Get.back();
          },
        )
      ],
    ),
  );
}
