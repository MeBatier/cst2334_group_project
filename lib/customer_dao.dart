import 'package:floor/floor.dart';
import 'customer_item.dart';
/// Data Access Object (DAO) for performing operations on [CustomerItem]s.
///
/// This abstract class defines the database queries and operations supported
/// for the `CustomerItem` table. The Floor library generates the actual
/// implementation at build time.
@dao
abstract class CustomerDao {
  // Retrieves all customers from the database.
  @Query("SELECT * FROM CustomerItem")
  Future<List<CustomerItem>> getAllCustomers();
  // Inserts a new customer into the database.
  @insert
  Future<void> insertCustomer(CustomerItem customer);
  // update a customer into the database.
  @update
  Future<void> updateCustomer(CustomerItem customer);
  /// delete a  into the database.
  @delete
  Future<void> deleteCustomer(CustomerItem customer);
}