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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['otp'] = this.otp;
    data['message'] = this.message;
    data['expiresIn'] = this.expiresIn;
    return data;
  }
}
