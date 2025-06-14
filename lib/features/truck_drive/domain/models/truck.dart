class Truck {
  final String idTruck;
  final String brand;
  final String model;
  final int yearOfManufacture;
  final String serialNumber;
  final String color;
  final String engineNumber;
  final String vehicleType;
  final String status;

  Truck({
    required this.idTruck,
    required this.brand,
    required this.model,
    required this.yearOfManufacture,
    required this.serialNumber,
    required this.color,
    required this.engineNumber,
    required this.vehicleType,
    required this.status,
  });

  Truck copyWith({
    String? idTruck,
    String? brand,
    String? model,
    int? yearOfManufacture,
    String? serialNumber,
    String? color,
    String? engineNumber,
    String? vehicleType,
    String? status,
  }) {
    return Truck(
      idTruck: idTruck ?? this.idTruck,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      yearOfManufacture: yearOfManufacture ?? this.yearOfManufacture,
      serialNumber: serialNumber ?? this.serialNumber,
      color: color ?? this.color,
      engineNumber: engineNumber ?? this.engineNumber,
      vehicleType: vehicleType ?? this.vehicleType,
      status: status ?? this.status,
    );
  }
}
