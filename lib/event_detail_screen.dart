import 'package:flutter/material.dart';
import 'event_item.dart';
import 'event_database.dart';

/// A screen that allows viewing, editing, and deleting a selected event.
class EventDetailScreen extends StatefulWidget {
  final Event event;
  final Function() onEventUpdatedOrDeleted;

  /// [event] is the event to view/edit.
  /// [onEventUpdatedOrDeleted] is called after update/delete to refresh the parent list.
  const EventDetailScreen({
    super.key,
    required this.event,
    required this.onEventUpdatedOrDeleted,
  });

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _locationController;
  late TextEditingController _descriptionController;

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.event.name);
    _locationController = TextEditingController(text: widget.event.location);
    _descriptionController = TextEditingController(text: widget.event.description);
    _selectedDate = DateTime.tryParse(widget.event.date);

    final timeParts = widget.event.time.split(':');
    if (timeParts.length == 2) {
      _selectedTime = TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Opens a date picker to change the event's date.
  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(Duration(days: 365)),
      lastDate: DateTime.now().add(Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  /// Opens a time picker to change the event's time.
  void _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  /// Updates the event in the database and returns to the list.
  void _updateEvent() async {
    if (_formKey.currentState!.validate() &&
        _selectedDate != null &&
        _selectedTime != null) {
      final updatedEvent = Event(
        id: widget.event.id,
        name: _nameController.text,
        location: _locationController.text,
        description: _descriptionController.text,
        date: _selectedDate!.toIso8601String(),
        time:
        '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}',
      );

      await EventDatabase.instance.updateEvent(updatedEvent);
      widget.onEventUpdatedOrDeleted();
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill out all fields.')),
      );
    }
  }

  /// Deletes the event from the database and returns to the list.
  void _deleteEvent() async {
    await EventDatabase.instance.deleteEvent(widget.event.id!);
    widget.onEventUpdatedOrDeleted();
    Navigator.pop(context);
  }

  /// Builds the UI for editing and deleting the event.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Event Details')),
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
                    : 'Date: ${_selectedDate!.toLocal()}'.split(' ')[0]),
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
                onPressed: _updateEvent,
                child: Text('Update'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _deleteEvent,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text('Delete'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
