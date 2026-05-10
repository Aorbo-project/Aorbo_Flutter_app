import 'package:freezed_annotation/freezed_annotation.dart';


part 'validate_version_model.freezed.dart';
part 'validate_version_model.g.dart';

@Freezed()
class ValidateVersionResponseModel with _$ValidateVersionResponseModel{
  const factory ValidateVersionResponseModel({
    bool? success,
    String? message,
    ValidateDataModel? data
  }) = _ValidateVersionResponseModel;

  factory ValidateVersionResponseModel.fromJson(Map<String, dynamic> json) => _$ValidateVersionResponseModelFromJson(json);
}

@Freezed()
class ValidateDataModel with _$ValidateDataModel{
  const factory ValidateDataModel({
    @JsonKey(name: "current_version") String? currentVersion,
    @JsonKey(name: "latest_version") String? latestVersion,
    @JsonKey(name: "update_available") bool? updateAvailable,
    @JsonKey(name: "release_notes") dynamic releaseNotes,
    @JsonKey(name:"release_date") dynamic releaseDate,
    String? platform
  }) = _ValidateDataModel;

  factory ValidateDataModel.fromJson(Map<String, dynamic> json) => _$ValidateDataModelFromJson(json);
}