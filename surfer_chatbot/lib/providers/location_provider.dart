import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/location.dart';

class LocationState {
  final LocationData? location;
  final bool isLoading;
  final String? error;

  LocationState({
    this.location,
    this.isLoading = false,
    this.error,
  });

  LocationState copyWith({
    LocationData? location,
    bool? isLoading,
    String? error,
  }) {
    return LocationState(
      location: location,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  String toString() {
    return 'LocationState(location: $location, isLoading: $isLoading, error: $error)';
  }
}

class LocationNotifier extends StateNotifier<LocationState> {
  LocationNotifier() : super(LocationState()) {
    getCurrentLocation();
  }

  Future<void> getCurrentLocation() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // First try GPS location
      final gpsLocation = await _getGPSLocation();
      if (gpsLocation != null) {
        state = state.copyWith(
          location: gpsLocation,
          isLoading: false,
          error: null,
        );
        return;
      }

      // If GPS fails, fall back to IP-based location
      final ipLocation = await _getIPLocation();
      if (ipLocation != null) {
        state = state.copyWith(
          location: ipLocation,
          isLoading: false,
          error: null,
        );
        return;
      }

      // If both methods fail
      throw Exception('Unable to determine location using either GPS or IP.');

    } catch (e) {
      state = state.copyWith(
        location: null,
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<LocationData?> _getGPSLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied.');
      }


      final position = await Geolocator.getCurrentPosition();

      String? address = await _getAddressFromCoordinates(position.latitude, position.longitude);

      return LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        address: address,
        source: LocationSource.gps,
      );

    } catch (e) {
      return null;
    }
  }

  Future<LocationData?> _getIPLocation() async {
    try {
      // Using ipapi.co for IP-based location (free tier, rate limited)
      final response = await http.get(Uri.parse('https://ipapi.co/json/'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final latitude = double.parse(data['latitude'].toString());
        final longitude = double.parse(data['longitude'].toString());

        // Construct address from IP data
        final addressParts = <String>[
          if (data['city'] != null) data['city'],
          if (data['region'] != null) data['region'],
          if (data['country_name'] != null) data['country_name'],
        ];

        return LocationData(
          latitude: latitude,
          longitude: longitude,
          address: addressParts.join(', '),
          source: LocationSource.ip,
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<String?> _getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://nominatim.openstreetmap.org/reverse?format=json&lat=$latitude&lon=$longitude&zoom=18'
        ),
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'ChatbotApp/1.0'
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['address'] != null) {
          final addressParts = <String>[];

          final possibleFields = [
            'suburb',
            'city_district',
            'city',
            'town',
            'village',
          ];

          String? specificLocation;
          for (var field in possibleFields) {
            if (data['address'][field] != null) {
              specificLocation = data['address'][field];
              break;
            }
          }

          if (specificLocation != null) {
            addressParts.add(specificLocation);
          }

          if (data['address']['city'] != null &&
              data['address']['city'] != specificLocation) {
            addressParts.add(data['address']['city']);
          }

          if (data['address']['state'] != null) {
            addressParts.add(data['address']['state']);
          }

          return addressParts.join(', ');
        }
      }

      // Fallback to geocoding package
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final addressParts = <String>[
          if (place.subLocality?.isNotEmpty == true) place.subLocality!,
          if (place.locality?.isNotEmpty == true) place.locality!,
          if (place.administrativeArea?.isNotEmpty == true) place.administrativeArea!,
        ];
        return addressParts.join(', ');
      }

    } catch (e) {}
    return null;
  }

  void clearLocation() {
    state = LocationState();
  }
}

final locationProvider = StateNotifierProvider<LocationNotifier, LocationState>((ref) {
  return LocationNotifier();
});

final currentLocationProvider = Provider<LocationData?>((ref) {
  return ref.watch(locationProvider).location;
});

final isLocationLoadingProvider = Provider<bool>((ref) {
  return ref.watch(locationProvider).isLoading;
});

final locationErrorProvider = Provider<String?>((ref) {
  return ref.watch(locationProvider).error;
});