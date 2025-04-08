// File Name: main.dart
// Name: Kenil Patel
// Student id: 041127140
// Course and Section: CST2335 031
// Date: April 8, 2025
// Purpose: Final Project - Handle Vehicle Maintenance record with Using flutter and local storage.
//          The Vehicle Maintenance application's entry point and user interface logic, which includes form processing and record management.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'database/maintenance_database.dart';
import 'model/maintenance_record.dart';
import 'package:intl/intl.dart';

// Application entry point
void main() {
  runApp(const MyApp());
}

// Root widget for the app
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.light,
      ),
      home: const RecordListPage(),
    );
  }
}

// Home page widget to display all records
class RecordListPage extends StatefulWidget {
  const RecordListPage({super.key});

  @override
  State<RecordListPage> createState() => _RecordListPageState();
}

class _RecordListPageState extends State<RecordListPage> {
  late MaintenanceDatabase db;
  List<MaintenanceRecord> records = [];

  @override
  void initState() {
    super.initState();
    _initDb(); // Initialize database
  }

  // Create and open the local database
  Future<void> _initDb() async {
    db = await $FloorMaintenanceDatabase.databaseBuilder('maintenance.db').build();
    _loadRecords();
  }

  // Load all saved maintenance records from database
  Future<void> _loadRecords() async {
    final data = await db.maintenanceDao.getAllRecords();
    setState(() {
      records = data;
    });
  }

  // Show dialog for update/delete on record tap
  Future<void> _onRecordTap(int index) async {
    final action = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Select Action"),
        content: const Text("What you want to do with this record?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, "cancel"), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context, "update"), child: const Text("Update")),
          TextButton(onPressed: () => Navigator.pop(context, "delete"), child: const Text("Delete")),
        ],
      ),
    );

    if (action == "delete") {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Confirm Delete"),
          content: const Text("Are you sure you want to delete this record?"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete")),
          ],
        ),
      );
      if (confirm == true) {
        await db.maintenanceDao.deleteRecord(records[index]);
        setState(() => records.removeAt(index));
      }
    } else if (action == "update") {
      final updated = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddEditPage(
            db: db,
            recordToEdit: records[index],
          ),
        ),
      );
      if (updated == true) _loadRecords();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Maintenance Records"),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Instructions',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Instructions'),
                  content: const Text('Click + to add a record. Click record to update or delete.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
                  ],
                ),
              );
            },
          )
        ],
      ),
      body: records.isEmpty
          ? const Center(child: Text("Your maintenance list is empty."))
          : ListView.builder(
        itemCount: records.length,
        itemBuilder: (context, index) {
          final rec = records[index];
          return Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            child: ListTile(
              title: Text(rec.vehicleName, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                "${rec.serviceDate} | ${rec.serviceType}\nMileage: ${rec.mileage} km | Cost: ${rec.cost}",
              ),
              isThreeLine: true,
              onTap: () => _onRecordTap(index),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final added = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddEditPage(db: db)),
          );
          if (added == true) _loadRecords();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// The Add/Edit page handles creation or update of a single maintenance record
class AddEditPage extends StatefulWidget {
  final MaintenanceDatabase db;
  final MaintenanceRecord? recordToEdit;
  const AddEditPage({super.key, required this.db, this.recordToEdit});

  @override
  State<AddEditPage> createState() => _AddEditPageState();
}

class _AddEditPageState extends State<AddEditPage> {
  final vehicleNameCtrl = TextEditingController();
  final mileageCtrl = TextEditingController();
  final costCtrl = TextEditingController();
  final secureStorage = FlutterSecureStorage();

  String? vehicleType;
  String? serviceType;
  String? serviceDateFormatted;

  final vehicleTypes = ['Car', 'Truck', 'Motorcycle', 'SUV', 'Sport Car', 'Tractor'];
  final serviceTypes = ['Oil Service', 'Tire Change', 'Battery Replace', 'Inspection','Accessories Replacement', 'Battery Test', 'Air Filter Replacement'];

  @override
  void initState() {
    super.initState();
    if (widget.recordToEdit != null) {
      final r = widget.recordToEdit!;
      vehicleNameCtrl.text = r.vehicleName;
      mileageCtrl.text = r.mileage;
      costCtrl.text = r.cost.replaceAll('\$', '');
      vehicleType = r.vehicleType;
      serviceType = r.serviceType;
      serviceDateFormatted = r.serviceDate;
    } else {
      _loadLastRecordIfPrompted();
    }
  }

  // Open calendar to pick service date
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => serviceDateFormatted = DateFormat('d MMM y').format(picked));
    }
  }

  // Save form data securely for future pre-fill
  Future<void> _saveLastRecordLocally(MaintenanceRecord record) async {
    final data = jsonEncode({
      'vehicleName': record.vehicleName,
      'vehicleType': record.vehicleType,
      'serviceType': record.serviceType,
      'serviceDate': record.serviceDate,
      'mileage': record.mileage,
      'cost': record.cost.replaceAll('\$', ''),
    });
    await secureStorage.write(key: 'last_record', value: data);
  }

  // Load previous form data and offer to apply it
  Future<void> _loadLastRecordIfPrompted() async {
    final data = await secureStorage.read(key: 'last_record');
    if (data != null) {
      final useIt = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Use Previous Record?"),
          content: const Text("Do you want to keep fields from your last record?"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("No")),
            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Yes")),
          ],
        ),
      );
      if (useIt == true) {
        final decoded = jsonDecode(data);
        setState(() {
          vehicleNameCtrl.text = decoded['vehicleName'];
          vehicleType = decoded['vehicleType'];
          serviceType = decoded['serviceType'];
          serviceDateFormatted = decoded['serviceDate'];
          mileageCtrl.text = decoded['mileage'];
          costCtrl.text = decoded['cost'];
        });
      }
    }
  }

  // Validate input and insert or update the record
  Future<void> _saveRecord() async {
    if (vehicleNameCtrl.text.isEmpty || mileageCtrl.text.isEmpty || costCtrl.text.isEmpty ||
        vehicleType == null || serviceType == null || serviceDateFormatted == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all the data.")),
      );
      return;
    }

    final mileageParsed = double.tryParse(mileageCtrl.text);
    final costParsed = double.tryParse(costCtrl.text);

    if (mileageParsed == null || costParsed == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mileage and Cost must be numbers.")),
      );
      return;
    }

    final costFormatted = NumberFormat.currency(locale: 'en_US', symbol: '\$').format(costParsed);

    if (widget.recordToEdit != null) {
      final updated = MaintenanceRecord(
        widget.recordToEdit!.id,
        vehicleNameCtrl.text,
        vehicleType!,
        serviceType!,
        serviceDateFormatted!,
        mileageCtrl.text,
        costFormatted,
      );
      await widget.db.maintenanceDao.updateRecord(updated);
      await _saveLastRecordLocally(updated);
    } else {
      final newRecord = MaintenanceRecord.create(
        vehicleNameCtrl.text,
        vehicleType!,
        serviceType!,
        serviceDateFormatted!,
        mileageCtrl.text,
        costFormatted,
      );
      await widget.db.maintenanceDao.insertRecord(newRecord);
      await _saveLastRecordLocally(newRecord);
    }
    Navigator.pop(context, true);
  }

  // Builds input fields
  Widget _buildTextField(TextEditingController ctrl, String label, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      ),
    );
  }

  // Builds dropdown fields
  Widget _buildDropdown(String label, List<String> items, String? selected, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: DropdownButtonFormField<String>(
        value: selected,
        items: items.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recordToEdit != null ? "Update Record" : "Add Record"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildTextField(vehicleNameCtrl, "Vehicle Name"),
          _buildDropdown("Vehicle Type", vehicleTypes, vehicleType, (val) => setState(() => vehicleType = val)),
          _buildDropdown("Service Type", serviceTypes, serviceType, (val) => setState(() => serviceType = val)),
          GestureDetector(
            onTap: _pickDate,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(serviceDateFormatted ?? "Select Service Date",
                  style: TextStyle(color: serviceDateFormatted == null ? Colors.grey : Colors.black)),
            ),
          ),
          const SizedBox(height: 12),
          _buildTextField(mileageCtrl, "Mileage (km)", isNumber: true),
          _buildTextField(costCtrl, "Cost (\$)", isNumber: true),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _saveRecord,
            icon: Icon(widget.recordToEdit != null ? Icons.edit : Icons.save),
            label: Text(widget.recordToEdit != null ? "Update Record" : "Save Record"),
          ),
        ],
      ),
    );
  }
}

// By Kenil Patel