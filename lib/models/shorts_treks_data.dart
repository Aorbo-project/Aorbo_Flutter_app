import 'package:freezed_annotation/freezed_annotation.dart';
import '../utils/common_images.dart';

part 'shorts_treks_data.freezed.dart';
part 'shorts_treks_data.g.dart';
@freezed
class ShortsTreksDataResponseModel with _$ShortsTreksDataResponseModel {
  const factory ShortsTreksDataResponseModel({
    bool? success,
    String? message,
    List<ShortsTreksData>? data,
    int? count
  }) = _ShortsTreksDataResponseModel;

  factory ShortsTreksDataResponseModel.fromJson(Map<String, dynamic> json) => _$ShortsTreksDataResponseModelFromJson(json);
}
@freezed
class ShortsTreksData with _$ShortsTreksData {
  const factory ShortsTreksData({
    String? title,
    String? description,
    String? imagePath
  }) = _ShortsTreksData;

  factory ShortsTreksData.fromJson(Map<String, dynamic> json) => _$ShortsTreksDataFromJson(json);
}


final List<Map<String, dynamic>> shortsTreksCardsData = [
  {
    'title': 'Lorem ipsum | Sit amet | consectetur adipiscing elit..',
    'description': '24M views',
    'imagePath': CommonImages.shorts1,
  },
  {
    'title': 'Lorem ipsum | Sit amet | consectetur adipiscing elit..',
    'description': '4M views',
    'imagePath': CommonImages.shorts2,
  },
  {
    'title': 'Lorem ipsum | Sit amet | consectetur adipiscing elit..',
    'description': '4M views',
    'imagePath': CommonImages.shorts3,
  },
  {
    'title': 'Lorem ipsum | Sit amet | consectetur adipiscing elit..',
    'description': '2M views',
    'imagePath': CommonImages.shorts4,
  },
  {
    'title': 'Lorem ipsum | Sit amet | consectetur adipiscing elit..',
    'description': '25M views',
    'imagePath': CommonImages.shorts5,
  },
];
