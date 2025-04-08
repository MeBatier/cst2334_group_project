// File Name: maintenance_record.dart
// Name: Kenil Patel
// Student id: 041127140
// Course and Section: CST2335 031
// Date: April 8, 2025
// Purpose: Describes the data model that is used in the database for a vehicle maintenance record.


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


  factory MaintenanceRecord.create(
      String vehicleName,
      String vehicleType,
      String serviceType,
      String serviceDate,
      String mileage,
      String cost,
      ) {
    return MaintenanceRecord(
      null,
      vehicleName,
      vehicleType,
      serviceType,
      serviceDate,
      mileage,
      cost,
    );
  }
}
// By Kenil Patel
