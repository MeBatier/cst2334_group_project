import 'package:floor/floor.dart';

@entity
class MaintenanceRecord {
  @primaryKey
  final int id;
  final String vehicleName;
  final String vehicleType;
  final String serviceType;
  final String serviceDate;
  final String mileage;
  final String cost;

  MaintenanceRecord(
      this.id,
      this.vehicleName,
      this.vehicleType,
      this.serviceType,
      this.serviceDate,
      this.mileage,
      this.cost,
      );

  static int ID = 1;

  MaintenanceRecord.create(
      String vehicleName,
      String vehicleType,
      String serviceType,
      String serviceDate,
      String mileage,
      String cost,
      )   : id = ID++,
        vehicleName = vehicleName,
        vehicleType = vehicleType,
        serviceType = serviceType,
        serviceDate = serviceDate,
        mileage = mileage,
        cost = cost;
}
