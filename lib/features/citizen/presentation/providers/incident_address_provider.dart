import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:comaslimpio/core/models/location.dart';
import 'package:comaslimpio/core/config/map_token.dart';
import 'package:comaslimpio/core/services/geocoding_service.dart';

final incidentAddressProvider = FutureProvider.family<String?, Location>((
  ref,
  location,
) async {
  final mapboxToken = await MapToken.getMapToken();
  return await GeocodingService.getAddressFromLatLng(
    location.lat,
    location.long,
    mapboxToken,
  );
});
