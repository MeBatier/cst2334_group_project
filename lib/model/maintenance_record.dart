import 'package:floor/floor.dart';

@entity
class MaintenanceRecord {
  @PrimaryKey(autoGenerate: true)  //
  final int? id;

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

  // Factory method for adding new records (id will be null and auto-generated)
  factory MaintenanceRecord.create(
      String vehicleName,
      String vehicleType,
      String serviceType,
      String serviceDate,
      String mileage,
      String cost,
      ) {
    return MaintenanceRecord(
      null, // ✅ Tell Floor to auto-generate ID
      vehicleName,
      vehicleType,
      serviceType,
      serviceDate,
      mileage,
      cost,
    );
  }
}
