// import 'package:freezed_annotation/freezed_annotation.dart';


// @freezed
// class SurfConditions with _$SurfConditions {
//   const factory SurfConditions({
//     required SpotInfo spot,
//     required CurrentConditions currentConditions,
//     required List<FeatureContribution> featureContributions,
//     required List<ForecastPoint> forecast,
//     required String timestamp,
//   }) = _SurfConditions;

//   factory SurfConditions.fromJson(Map<String, dynamic> json) =>
//       _$SurfConditionsFromJson(json);
// }

// @freezed
// class SpotInfo with _$SpotInfo {
//   const factory SpotInfo({
//     required String name,
//     required double lat,
//     required double lng,
//   }) = _SpotInfo;

//   factory SpotInfo.fromJson(Map<String, dynamic> json) =>
//       _$SpotInfoFromJson(json);
// }

// @freezed
// class CurrentConditions with _$CurrentConditions {
//   const factory CurrentConditions({
//     required double rating,
//     required double confidence,
//     required double waveHeight,
//     required String waveDirection,
//     required double windSpeed,
//     required String windDirection,
//   }) = _CurrentConditions;

//   factory CurrentConditions.fromJson(Map<String, dynamic> json) =>
//       _$CurrentConditionsFromJson(json);
// }

// @freezed
// class FeatureContribution with _$FeatureContribution {
//   const factory FeatureContribution({
//     required String name,
//     required double value,
//     required double importance,
//     required String description,
//   }) = _FeatureContribution;

//   factory FeatureContribution.fromJson(Map<String, dynamic> json) =>
//       _$FeatureContributionFromJson(json);
// }

// @freezed
// class ForecastPoint with _$ForecastPoint {
//   const factory ForecastPoint({
//     required int hour,
//     required double rating,
//     required double waveHeight,
//     required double windSpeed,
//   }) = _ForecastPoint;

//   factory ForecastPoint.fromJson(Map<String, dynamic> json) =>
//       _$ForecastPointFromJson(json);
// }