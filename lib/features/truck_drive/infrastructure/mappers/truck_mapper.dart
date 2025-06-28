import 'package:comaslimpio/features/truck_drive/domain/models/truck.dart';

class TruckMapper {
  static Truck fromJson(Map<String, dynamic> json) {
    return Truck(
      idTruck: json['id_truck'],
      brand: json['brand'],
      model: json['model'],
      yearOfManufacture: json['year_of_manufacture'],
      serialNumber: json['serial_number'],
      color: json['color'],
      engineNumber: json['engine_number'],
      vehicleType: json['vehicle_type'],
      status: json['status'],
      idAppUser: json['id_app_user'],
    );
  }

  static Map<String, dynamic> toJson(Truck truck) {
    return {
      'id_truck': truck.idTruck,
      'brand': truck.brand,
      'model': truck.model,
      'year_of_manufacture': truck.yearOfManufacture,
      'serial_number': truck.serialNumber,
      'color': truck.color,
      'engine_number': truck.engineNumber,
      'vehicle_type': truck.vehicleType,
      'status': truck.status,
      'id_app_user': truck.idAppUser,
    };
  }
}
