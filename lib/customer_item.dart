import 'package:floor/floor.dart';
/// Represents a customer entity stored in the local database.
///
/// This class is annotated with [@entity] for use with the Floor ORM.
/// It includes personal information such as name, address, and birthday.
///
/// The [ID] static field tracks the next available ID for new customers.
/// If a customer is initialized with an ID greater than [ID], it updates the counter.
@entity
class CustomerItem {
  // Static counter used to auto-generate incremental IDs for new customers.
  static int ID = 1;
  // Unique identifier for the customer. Serves as the primary key.
  @primaryKey
  final int id;
  final String firstName;
  final String lastName;
  final String address;
  final String birthday;
  /// Creates a [CustomerItem] with the specified fields.
  ///
  /// Updates the static [ID] tracker if the provided [id] exceeds it.
  CustomerItem(this.id, this.firstName, this.lastName, this.address, this.birthday) {
    if (id > ID) {
      ID = id + 1;
    }
  }
}