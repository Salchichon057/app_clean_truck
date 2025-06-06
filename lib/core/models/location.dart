class Location {
  final double lat;
  final double long;

  Location({required this.lat, required this.long});

  Map<String, dynamic> toJson() {
    return {'lat': lat, 'long': long};
  }

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      lat: (json['lat'] as num).toDouble(),
      long: (json['long'] as num).toDouble(),
    );
  }
}
