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
    @JsonKey(name: "min_supported_version") String? minSupportedVersion,
    @JsonKey(name: "update_available") bool? updateAvailable,
    /// Hard-block gate — true only when the running app is below
    /// min_supported_version. update_available alone must never block.
    @JsonKey(name: "update_required") bool? updateRequired,
    @JsonKey(name: "release_notes") dynamic releaseNotes,
    @JsonKey(name:"release_date") dynamic releaseDate,
    String? platform
  }) = _ValidateDataModel;

  factory ValidateDataModel.fromJson(Map<String, dynamic> json) => _$ValidateDataModelFromJson(json);
}