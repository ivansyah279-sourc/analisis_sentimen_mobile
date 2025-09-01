import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:url_launcher/url_launcher.dart';

/// Membuka Google Maps dengan koordinat lokasi.
Future<void> openMap(String location) async {
  final coordinates = location.split(',').map((e) => e.trim()).toList();
  final latitude = coordinates[0];
  final longitude = coordinates[1];

  final String googleMapsUrl =
      'geo:$latitude,$longitude?q=$latitude,$longitude';
  final Uri uri = Uri.parse(googleMapsUrl);

  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    final Uri fallbackUri =
        Uri.parse('https://www.google.com/maps?q=$latitude,$longitude');
    if (await canLaunchUrl(fallbackUri)) {
      await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not open the map.';
    }
  }
}

/// Mengambil nama lokasi berdasarkan koordinat menggunakan geocoding.
Future<String?> getLocationName(double? latitude, double? longitude) async {
  try {
    if (latitude == null || longitude == null) return null;

    List<Placemark> placemarks =
        await placemarkFromCoordinates(latitude, longitude);

    if (placemarks.isNotEmpty) {
      Placemark p = placemarks[0];
      return [
        p.street,
        p.subLocality,
        p.locality,
        p.subAdministrativeArea,
        p.administrativeArea,
        p.postalCode,
        p.country,
      ].where((e) => e != null && e.isNotEmpty).join(', ');
    }
  } catch (e) {
    if (kDebugMode) {
      print("Error getting location name: $e");
    }
  }
  return null;
}

/// Mengubah string koordinat menjadi nama lokasi.
Future<String> getLocationCoordinate(String location) async {
  final coordinates = location.split(',').map((e) => e.trim()).toList();
  final latitude = double.parse(coordinates[0]);
  final longitude = double.parse(coordinates[1]);

  String? locationName = await getLocationName(latitude, longitude);
  return locationName ?? 'Lokasi tidak ditemukan';
}
