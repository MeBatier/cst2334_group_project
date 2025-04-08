import 'package:flutter/material.dart';
import 'event_item.dart';
import 'event_database.dart';
import 'add_event_screen.dart';
import 'event_detail_screen.dart';

// 👇 Required for sqflite to work on Windows
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';

/// The root of the Event Planner application.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 👇 Initialize sqflite for desktop platforms
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(EventPlannerApp());
}

/// The main app widget.
class EventPlannerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Event Planner',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: EventListScreen(),
    );
  }
}

/// Displays a list of all events with options to add or view/edit them.
class EventListScreen extends StatefulWidget {
  @override
  _EventListScreenState createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  /// List of events loaded from the database.
  List<Event> events = [];

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  /// Loads all events from the database into the local list.
  Future<void> _loadEvents() async {
    final loadedEvents = await EventDatabase.instance.getAllEvents();
    setState(() {
      events = loadedEvents;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event Planner'),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () {
              _showInstructions(context);
            },
          ),
        ],
      ),
      body: events.isEmpty
          ? Center(child: Text('No events added yet.'))
          : ListView.builder(
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return ListTile(
            title: Text(event.name),
            subtitle: Text('${event.date.split("T")[0]} at ${event.time}'),
            /// Tapping an event opens its detail/edit page.
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EventDetailScreen(
                    event: event,
                    onEventUpdatedOrDeleted: _loadEvents,
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add Event',
        child: Icon(Icons.add),
        /// Opens the Add Event form screen.
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEventScreen(
                onEventAdded: (newEvent) {
                  setState(() {
                    events.add(newEvent);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Event added')),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  /// Displays usage instructions in an AlertDialog.
  void _showInstructions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('How to Use'),
        content: Text(
          'Tap the + button to add a new event.\n\nTap on an event to view, edit, or delete it.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Got it'),
          ),
        ],
      ),
    );
  }
}
