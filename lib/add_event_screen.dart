import 'package:flutter/material.dart';
import 'event_item.dart';
import 'event_database.dart';
import 'event_preferences.dart';

/// A form screen for creating a new event.
class AddEventScreen extends StatefulWidget {
  final Function(Event) onEventAdded;

  /// Callback to notify parent when an event is added.
  const AddEventScreen({super.key, required this.onEventAdded});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  bool _loadedFromPrefs = false;

  @override
  void initState() {
    super.initState();
    _loadLastEventDialog();
  }

  /// Checks if shared preferences contain the last event and offers prefill.
  void _loadLastEventDialog() async {
    await Future.delayed(Duration.zero); // Prevent dialog opening too early
    final prefs = await EventPreferences.loadLastEvent();
    if (prefs.isNotEmpty) {
      _showPrefillDialog(prefs);
    }
  }

  /// Shows a dialog offering to copy data from the last event.
  void _showPrefillDialog(Map<String, String> data) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Copy Last Event?'),
        content: Text('Would you like to prefill this form using the last event?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('No'),
          ),
          TextButton(
            onPressed: () {
              _nameController.text = data['name'] ?? '';
              _locationController.text = data['location'] ?? '';
              _descriptionController.text = data['description'] ?? '';
              if (data['date'] != null) {
                _selectedDate = DateTime.tryParse(data['date']!);
              }
              if (data['time'] != null) {
                final parts = data['time']!.split(':');
                if (parts.length == 2) {
                  _selectedTime = TimeOfDay(
                    hour: int.parse(parts[0]),
                    minute: int.parse(parts[1]),
                  );
                }
              }
              setState(() {
                _loadedFromPrefs = true;
              });
              Navigator.pop(context);
            },
            child: Text('Yes'),
          ),
        ],
      ),
    );
  }

  /// Builds the event form UI.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Event')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Event Name'),
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(labelText: 'Location'),
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 20),
              ListTile(
                title: Text(_selectedDate == null
                    ? 'Pick Date'
                    : 'Date: ${_selectedDate!.toLocal().toString().split(' ')[0]}'),
                trailing: Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),
              ListTile(
                title: Text(_selectedTime == null
                    ? 'Pick Time'
                    : 'Time: ${_selectedTime!.format(context)}'),
                trailing: Icon(Icons.access_time),
                onTap: _pickTime,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitEvent,
                child: Text('Save Event'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Shows the date picker and stores the selected date.
  void _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  /// Shows the time picker and stores the selected time.
  void _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  /// Validates the form, saves the event to the database and preferences, then returns to the previous screen.
  void _submitEvent() async {
    if (_formKey.currentState!.validate() &&
        _selectedDate != null &&
        _selectedTime != null) {
      final event = Event(
        name: _nameController.text,
        location: _locationController.text,
        description: _descriptionController.text,
        date: _selectedDate!.toIso8601String(),
        time:
        '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}',
      );

      final id = await EventDatabase.instance.insertEvent(event);
      print('EVENT INSERTED WITH ID: $id');
      event.id = id;


      await EventPreferences.saveLastEvent({
        'name': event.name,
        'location': event.location,
        'description': event.description,
        'date': event.date,
        'time': event.time,
      });

      widget.onEventAdded(event);
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill out all fields.')),
      );
    }
  }
}
