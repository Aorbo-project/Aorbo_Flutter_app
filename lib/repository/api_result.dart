import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_result.freezed.dart';

@Freezed()
@immutable
sealed class ApiResult<T> with _$ApiResult {
  const factory ApiResult.success(T? data) = _Success<T>;
  const factory ApiResult.error(String error) = Error;
  const factory ApiResult.loading(String? data) = _Loading;
  const factory ApiResult.init() = Init;
}