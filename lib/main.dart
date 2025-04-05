import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'database/maintenance_database.dart';
import 'model/maintenance_record.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

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
    _initDb();
  }

  Future<void> _initDb() async {
    db = await $FloorMaintenanceDatabase.databaseBuilder('maintenance.db').build();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    final data = await db.maintenanceDao.getAllRecords();
    setState(() {
      records = data;
    });
  }

  Future<void> _onRecordTap(int index) async {
    final action = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Select Action"),
        content: const Text("What would you like to do with this record?"),
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
      appBar: AppBar(title: const Text("Maintenance Records")),
      body: records.isEmpty
          ? const Center(child: Text("No records yet."))
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

  String? vehicleType;
  String? serviceType;
  String? serviceDateFormatted;

  final vehicleTypes = ['Car', 'Truck', 'Motorcycle', 'SUV', 'Sport Car'];
  final serviceTypes = ['Oil Service', 'Tire Change', 'Battery Replace', 'Inspection'];

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
    }
  }

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

  Future<void> _saveRecord() async {
    if (vehicleNameCtrl.text.isEmpty || mileageCtrl.text.isEmpty || costCtrl.text.isEmpty ||
        vehicleType == null || serviceType == null || serviceDateFormatted == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields.")),
      );
      return;
    }

    final mileageParsed = double.tryParse(mileageCtrl.text);
    final costParsed = double.tryParse(costCtrl.text);

    if (mileageParsed == null || costParsed == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mileage and Cost must be valid numbers.")),
      );
      return;
    }

    final costFormatted = NumberFormat.currency(locale: 'en_US', symbol: '\$')
        .format(costParsed);

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
    }
    Navigator.pop(context, true);
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

  Widget _buildTextField(TextEditingController ctrl, String label, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        keyboardType: isNumber ? TextInputType.text : TextInputType.text,
      ),
    );
  }

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
}
