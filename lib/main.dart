import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences_android/shared_preferences_android.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'database.dart';
import 'customer_dao.dart';
import 'customer_item.dart';
import 'app_localizations.dart';

/// Entry point of the Flutter application.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (isAndroid()) {
    SharedPreferencesAndroid.registerWith();
  }
  runApp(const MyApp());
}
/// Checks whether the platform is Android.
bool isAndroid() {
  return const bool.fromEnvironment('dart.library.android_jni') == true;
}
/// Root widget of the application.
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
  /// Sets the current locale of the application.
  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.changeLanguage(newLocale);
  }
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('en', '');
  /// Updates the locale and rebuilds the widget.
  void changeLanguage(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Customer List Page',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      locale: _locale,
      supportedLocales: const [
        Locale('en', ''),
        Locale('tr', ''),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const CustomerPage(title: 'Customer List Page'),
    );
  }
}

class CustomerPage extends StatefulWidget {
  const CustomerPage({super.key, required this.title});

  final String title;

  @override
  State<CustomerPage> createState() => _CustomerPageState();
}
/// Represents the main screen showing the list and details of customers.
class _CustomerPageState extends State<CustomerPage> {
  /// List of customers displayed in the UI.
  final List<CustomerItem> customers = [];
  /// Controllers for handling user input fields.
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();
  /// Currently selected customer for viewing or editing.
  CustomerItem? selectedCustomer;
  /// DAO to interact with the customer database.
  late CustomerDao customerDao;
  /// Indicates if customer data has been loaded from the database.
  bool _isLoaded = false;
  /// Whether the user is currently editing a customer.
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    initDatabase();
    loadSavedData();
  }
  /// Loads the last entered customer form data from shared preferences.
  Future<void> loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _firstNameController.text = prefs.getString('lastFirstName') ?? '';
      _lastNameController.text = prefs.getString('lastLastName') ?? '';
      _addressController.text = prefs.getString('lastAddress') ?? '';
      _birthdayController.text = prefs.getString('lastBirthday') ?? '';
    });
  }
  /// Saves the current form input values into shared preferences.
  Future<void> saveLastInputs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastFirstName', _firstNameController.text);
    await prefs.setString('lastLastName', _lastNameController.text);
    await prefs.setString('lastAddress', _addressController.text);
    await prefs.setString('lastBirthday', _birthdayController.text);
  }
  /// Initializes the customer database and loads existing customers.
  Future<void> initDatabase() async {
    final database = await $FloorAppDatabase.databaseBuilder('customer_database.db').build();
    customerDao = database.customerDao;

    // Load customers from the database
    final listOfCustomers = await customerDao.getAllCustomers();
    setState(() {
      customers.clear();
      customers.addAll(listOfCustomers);
      _isLoaded = true;
    });
  }
  /// Validates if all input fields are filled.
  bool _validateInputs() {
    if (_firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _birthdayController.text.isEmpty) {
      // Show validation error dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(AppLocalizations.of(context)?.translate('validation_error') ?? 'Validation Error'),
            content: Text(AppLocalizations.of(context)?.translate('fill_all_fields') ?? 'Please fill all fields'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(AppLocalizations.of(context)?.translate('close') ?? 'Close'),
              ),
            ],
          );
        },
      );
      return false;
    }
    return true;
  }
  /// Handles the creation and saving of a new customer.
  void _addCustomer() {
    if (!_validateInputs()) return;

    // Create new CustomerItem
    final newItemId = CustomerItem.ID++;
    final newCustomer = CustomerItem(
      newItemId,
      _firstNameController.text,
      _lastNameController.text,
      _addressController.text,
      _birthdayController.text,
    );

    setState(() {
      // Add customer to the list
      customers.add(newCustomer);

      // If we were in "add mode" with a temporary customer, replace it with the real one
      if (selectedCustomer?.id == -999) {
        selectedCustomer = newCustomer;
        _isEditing = false;
      } else {
        // On larger screens, just clear the form
        _clearForm();
      }
    });

    // Insert the new customer into the database
    customerDao.insertCustomer(newCustomer);

    // Show success message using SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)?.translate('customer_added') ?? 'Customer added successfully!'),
        duration: const Duration(seconds: 2),
      ),
    );

    // Save inputs to SharedPreferences
    saveLastInputs();
  }
  /// Updates an existing customer's information.
  void _updateCustomer() {
    if (!_validateInputs() || selectedCustomer == null) return;

    // Check if this is a new customer (has our temporary ID) or an existing one
    if (selectedCustomer!.id == -999) {
      // This is actually a new customer, so add it instead of updating
      _addCustomer();
      return;
    }

    // Create updated customer with the same ID
    final updatedCustomer = CustomerItem(
      selectedCustomer!.id,
      _firstNameController.text,
      _lastNameController.text,
      _addressController.text,
      _birthdayController.text,
    );

    // Update database
    customerDao.updateCustomer(updatedCustomer);

    // Update list
    setState(() {
      final index = customers.indexWhere((c) => c.id == selectedCustomer!.id);
      if (index >= 0) {
        customers[index] = updatedCustomer;
      }
      selectedCustomer = updatedCustomer;
      _isEditing = false;
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)?.translate('customer_updated') ?? 'Customer updated successfully!'),
        duration: const Duration(seconds: 2),
      ),
    );

    // Save inputs to SharedPreferences
    saveLastInputs();
  }
  /// Shows confirmation dialog and deletes a customer if confirmed.
  void _deleteCustomer(CustomerItem customer) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)?.translate('delete_confirmation') ?? 'Delete Confirmation'),
          content: Text(AppLocalizations.of(context)?.translate('delete_message') ?? 'Are you sure you want to delete this customer?'),
          actions: [
            TextButton(
              onPressed: () {
                // Delete customer from database
                customerDao.deleteCustomer(customer);

                setState(() {
                  // Remove customer from the list
                  customers.remove(customer);
                  // Clear selected customer if it was the one deleted
                  if (selectedCustomer == customer) {
                    selectedCustomer = null;
                    _clearForm();
                  }
                });

                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context)?.translate('customer_deleted') ?? 'Customer deleted successfully!'),
                    duration: const Duration(seconds: 2),
                  ),
                );

                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context)?.translate('yes') ?? 'Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context)?.translate('no') ?? 'No'),
            ),
          ],
        );
      },
    );
  }
  /// Selects a customer from the list and fills the input form with their data.
  void _selectCustomer(CustomerItem customer) {
    setState(() {
      selectedCustomer = customer;
      _isEditing = false;

      // Fill the form with selected customer data
      _firstNameController.text = customer.firstName;
      _lastNameController.text = customer.lastName;
      _addressController.text = customer.address;
      _birthdayController.text = customer.birthday;
    });
  }
  /// Clears the selected customer and resets the input form.
  void _clearSelectedCustomer() {
    setState(() {
      selectedCustomer = null;
      _clearForm();
    });
  }
  /// Clears all input form fields and disables editing mode.
  void _clearForm() {
    setState(() {
      _firstNameController.clear();
      _lastNameController.clear();
      _addressController.clear();
      _birthdayController.clear();
      _isEditing = false;
    });
  }
  /// Toggles between view and edit mode for customer details.
  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }
  /// Displays a help dialog explaining how to use the application.
  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)?.translate('help') ?? 'Help'),
          content: Text(AppLocalizations.of(context)?.translate('help_message') ??
              'This application allows you to manage customers. You can add new customers using the form at the top. Fill in all required fields and press Save. Select a customer from the list to view details, update, or delete the customer. On phone screens, a single view is shown at a time, while tablets and desktop screens show both the list and details side by side.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context)?.translate('close') ?? 'Close'),
            ),
          ],
        );
      },
    );
  }
  /// Switches the application language between English and Turkish.
  void _changeLanguage() {
    Locale currentLocale = Localizations.localeOf(context);
    Locale newLocale = currentLocale.languageCode == 'en' ? const Locale('tr', '') : const Locale('en', '');
    MyApp.setLocale(context, newLocale);
  }
  /// Builds the customer input form widget.
  ///
  /// Displays input fields for first name, last name, address, and birthday.
  /// If a customer is selected and editing is disabled, the fields become read-only.
  /// Includes buttons for saving, updating, deleting, or closing based on current context.
  Widget _buildInputForm() {
    bool isViewOnly = selectedCustomer != null && !_isEditing;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            selectedCustomer == null
                ? AppLocalizations.of(context)?.translate('add_customer') ?? 'Add Customer'
                : AppLocalizations.of(context)?.translate('customer_details') ?? 'Customer Details',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _firstNameController,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)?.translate('first_name') ?? 'First Name',
              border: const OutlineInputBorder(),
            ),
            enabled: !isViewOnly,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _lastNameController,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)?.translate('last_name') ?? 'Last Name',
              border: const OutlineInputBorder(),
            ),
            enabled: !isViewOnly,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _addressController,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)?.translate('address') ?? 'Address',
              border: const OutlineInputBorder(),
            ),
            enabled: !isViewOnly,
            maxLines: 3,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _birthdayController,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)?.translate('birthday') ?? 'Birthday (DD/MM/YYYY)',
              border: const OutlineInputBorder(),
            ),
            enabled: !isViewOnly,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (selectedCustomer == null)
                ElevatedButton(
                  onPressed: _addCustomer,
                  child: Text(AppLocalizations.of(context)?.translate('save') ?? 'Save'),
                )
              else if (_isEditing)
                ElevatedButton(
                  onPressed: _updateCustomer,
                  child: Text(AppLocalizations.of(context)?.translate('save') ?? 'Save'),
                )
              else ...[
                  ElevatedButton.icon(
                    onPressed: _toggleEditMode,
                    icon: const Icon(Icons.edit),
                    label: Text(AppLocalizations.of(context)?.translate('update') ?? 'Update'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _deleteCustomer(selectedCustomer!),
                    icon: const Icon(Icons.delete),
                    label: Text(AppLocalizations.of(context)?.translate('delete') ?? 'Delete'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              if (selectedCustomer != null)
                ElevatedButton.icon(
                  onPressed: _clearSelectedCustomer,
                  icon: const Icon(Icons.close),
                  label: Text(AppLocalizations.of(context)?.translate('close') ?? 'Close'),
                ),
            ],
          ),
        ],
      ),
    );
  }
  /// Builds and returns a widget displaying the list of customers.
  ///
  /// Shows a loading spinner while data is loading, a message if the list is empty,
  /// or a scrollable list of customer cards. Each card can be tapped to select a customer.
  Widget _buildCustomerList() {
    if (!_isLoaded) {
      return const Center(child: CircularProgressIndicator());
    }
/// [ListView] Builder applied
    return customers.isEmpty
        ? Center(
      child: Text(
        AppLocalizations.of(context)?.translate('no_customers') ?? 'There are no customers in the list. Please add',
        style: const TextStyle(fontSize: 16),
      ),
    )
        : ListView.builder(
      itemCount: customers.length,
      itemBuilder: (context, index) {
        final customer = customers[index];
        return GestureDetector(
          onTap: () => _selectCustomer(customer),
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            color: selectedCustomer?.id == customer.id ? Colors.purple.shade100 : null,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${customer.firstName} ${customer.lastName}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    customer.address,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  /// Wraps the customer list in a scrollable, expandable layout.
  Widget _buildListView() {
    return Column(
      children: [
        Expanded(child: _buildCustomerList()),
      ],
    );
  }

  /// Builds the responsive layout for the customer screen.
  ///
  /// On large screens (tablets), shows customer list and form side by side.
  /// On small screens (mobile), shows either the list or the form.
  Widget _buildReactiveLayout() {
    var size = MediaQuery.of(context).size;
    var height = size.height;
    var width = size.width;

    // Check if we're in landscape with enough width for master-detail
    if ((width > height) && (width > 720)) {
      return Row(
        children: [
          Expanded(
            flex: 2, // Takes 2/5 of the available width
            child: _buildListView(),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            flex: 3, // Takes 3/5 of the available width
            child: SingleChildScrollView(
              child: _buildInputForm(),
            ),
          ),
        ],
      );
    } else {
      // Phone layout - show either list or details
      if (selectedCustomer == null) {
        return _buildListView();
      } else {
        return SingleChildScrollView(
          child: _buildInputForm(),
        );
      }
    }
  }
  /// Builds the main scaffold of the customer management screen.
  ///
  /// Displays an [AppBar] with title, language toggle, and help button.
  /// Shows either a single view or master-detail layout using [_buildReactiveLayout].
  /// On phones, also includes a floating action button for adding new customers.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(AppLocalizations.of(context)?.translate('app_title') ?? widget.title),
        // Add back button in phone mode when viewing details
        leading: (selectedCustomer != null &&
            MediaQuery.of(context).size.width <= 720) ?
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _clearSelectedCustomer,
        ) : null,
        actions: [
          // Language toggle button
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: _changeLanguage,
            tooltip: AppLocalizations.of(context)?.translate('language') ?? 'Language',
          ),
          // Help button
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showHelpDialog,
            tooltip: AppLocalizations.of(context)?.translate('help') ?? 'Help',
          ),
        ],
      ),
      body: _buildReactiveLayout(),
      floatingActionButton: selectedCustomer == null && MediaQuery.of(context).size.width <= 720 ?
      FloatingActionButton(
        onPressed: () {
          // Show a new empty form for adding a customer
          setState(() {
            _clearForm();
            _isEditing = true;

            // Create a temporary dummy customer to trigger showing the detail view
            // We'll set a special ID that won't be saved to the database
            final tempCustomer = CustomerItem(
                -999, // Temporary ID that won't be saved
                "",
                "",
                "",
                ""
            );
            selectedCustomer = tempCustomer;
          });
        },
        tooltip: AppLocalizations.of(context)?.translate('add_customer') ?? 'Add Customer',
        child: const Icon(Icons.person_add),
      ) : null,
    );
  }
}