import 'package:flutter_riverpod/flutter_riverpod.dart';

class SurfConditionsState {
  final double rating;
  final double confidence;
  final Map<String, double> factors;
  final Map<String, String> factorDescriptions;

  SurfConditionsState({
    this.rating = 0.0,
    this.confidence = 0.85,
    this.factors = const {
      'Wave Power': 0.0,
      'Wind Points': 0.0,
      'Wind Direction': 0.0,
      'Wave Height': 0.0,
      'Wind Speed': 0.0,
      'Swell Angle': 0.0,
    },
    this.factorDescriptions = const {
      'Wave Power': 'Overall wave energy',
      'Wind Points': 'Points off ideal wind',
      'Wind Direction': 'Wind angle impact',
      'Wave Height': 'Current wave height',
      'Wind Speed': 'Primary wind speed',
      'Swell Angle': 'Primary swell direction',
    },
  });

  SurfConditionsState copyWith({
    double? rating,
    double? confidence,
    Map<String, double>? factors,
    Map<String, String>? factorDescriptions,
  }) {
    return SurfConditionsState(
      rating: rating ?? this.rating,
      confidence: confidence ?? this.confidence,
      factors: factors ?? this.factors,
      factorDescriptions: factorDescriptions ?? this.factorDescriptions,
    );
  }
}

class SurfConditionsNotifier extends StateNotifier<SurfConditionsState> {
  SurfConditionsNotifier() : super(SurfConditionsState());

  void updateConditions(String message) {
    // Only update if the message contains surf condition information
    if (!message.contains('score of') || !message.contains('surf height is')) {
      print('Message does not contain surf conditions, skipping update');
      return;
    }

    print('Updating conditions from message: $message');

    // Extract rating
    double rating = 0.0;
    if (message.contains('score of')) {
      try {
        final ratingMatch =
            RegExp(r'score of (\d+\.?\d*) out of 4').firstMatch(message);
        if (ratingMatch != null) {
          rating = double.tryParse(ratingMatch.group(1) ?? '0.0') ?? 0.0;
          print('Extracted rating: $rating');
        }
      } catch (e) {
        print('Error parsing rating: $e');
      }
    }

    // Extract wave height
    double waveHeight = 0.0;
    if (message.contains('surf height is')) {
      try {
        final heightMatch =
            RegExp(r'surf height is (\d+\.?\d*) feet').firstMatch(message);
        if (heightMatch != null) {
          waveHeight = double.tryParse(heightMatch.group(1) ?? '0.0') ?? 0.0;
          print('Extracted wave height: $waveHeight');
          waveHeight = (waveHeight /
              8.0); // Normalize to 0-1 range (assuming max height of 8ft)
        }
      } catch (e) {
        print('Error parsing wave height: $e');
      }
    }

    // Extract wind speed
    double windSpeed = 0.0;
    if (message.contains('wind speed is')) {
      try {
        final speedMatch =
            RegExp(r'wind speed is (\d+\.?\d*)').firstMatch(message);
        if (speedMatch != null) {
          windSpeed = double.tryParse(speedMatch.group(1) ?? '0.0') ?? 0.0;
          windSpeed = windSpeed /
              25.0; // Normalize to 0-1 range (assuming max speed of 25mph)
        }
      } catch (e) {
        print('Error parsing wind speed: $e');
      }
    }

    // Calculate base values
    double wavePower = (rating / 4.0) * 0.767; // Based on Feature Importance
    double windPoints = 0.084; // From Feature Importance
    double windDirection = 0.070; // From Feature Importance
    double swellAngle = 0.003; // From Feature Importance

    print('Updating state with rating: $rating');
    print('Wave Power: $wavePower, Wind Points: $windPoints');
    print('Wind Direction: $windDirection, Wave Height: $waveHeight');
    print('Wind Speed: $windSpeed, Swell Angle: $swellAngle');

    state = state.copyWith(
      rating: rating,
      factors: {
        'Wave Power': wavePower,
        'Wind Points': windPoints,
        'Wind Direction': windDirection,
        'Wave Height': waveHeight,
        'Wind Speed': windSpeed,
        'Swell Angle': swellAngle,
      },
    );
  }
}

final surfConditionsProvider =
    StateNotifierProvider<SurfConditionsNotifier, SurfConditionsState>((ref) {
  return SurfConditionsNotifier();
});
