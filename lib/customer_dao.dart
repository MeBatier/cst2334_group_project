import 'package:floor/floor.dart';
import 'customer_item.dart';

@dao
abstract class CustomerDao {
  @Query("SELECT * FROM CustomerItem")
  Future<List<CustomerItem>> getAllCustomers();

  @insert
  Future<void> insertCustomer(CustomerItem customer);

  @update
  Future<void> updateCustomer(CustomerItem customer);

  @delete
  Future<void> deleteCustomer(CustomerItem customer);
}