class OtpGeneratedModal {
  bool? success;
  String? otp;
  String? message;
  int? expiresIn;

  OtpGeneratedModal({this.success, this.otp, this.message, this.expiresIn});

  OtpGeneratedModal.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    otp = json['otp'];
    message = json['message'];
    expiresIn = json['expiresIn'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['otp'] = otp;
    data['message'] = message;
    data['expiresIn'] = expiresIn;
    return data;
  }
}
