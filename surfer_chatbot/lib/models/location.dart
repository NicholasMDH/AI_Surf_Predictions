import 'package:flutter/foundation.dart';

@immutable
class LocationData {
  final double latitude;
  final double longitude;
  final String? address;
  final LocationSource source;
  final DateTime timestamp;

  LocationData({
    required this.latitude,
    required this.longitude,
    this.address,
    this.source = LocationSource.gps,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  LocationData copyWith({
    double? latitude,
    double? longitude,
    String? address,
    LocationSource? source,
    DateTime? timestamp,
  }) {
    return LocationData(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      source: source ?? this.source,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LocationData &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.address == address &&
        other.source == source &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return Object.hash(
      latitude,
      longitude,
      address,
      source,
      timestamp,
    );
  }

  @override
  String toString() {
    return 'LocationData(lat: $latitude, lng: $longitude, address: $address, source: $source, timestamp: $timestamp)';
  }
}

enum LocationSource {
  gps,
  network,
  ip,
  manual
}