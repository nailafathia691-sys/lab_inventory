import 'package:flutter_test/flutter_test.dart';
import 'package:lab_inventory/core/models.dart';

import 'support/fakes.dart';

void main() {
  final today = DateTime(2026, 10, 18);
  String? validate({
    int amount = 1,
    DateTime? start,
    DateTime? due,
    String purpose = 'Praktikum',
  }) => validateBorrowing(
    item: availableItem,
    amount: amount,
    borrowDate: start,
    returnDate: due,
    purpose: purpose,
    now: today,
  );
  test('missing dates, past dates, and reversed dates are rejected', () {
    expect(validate(), isNotNull);
    expect(validate(start: DateTime(2026, 10, 17), due: today), isNotNull);
    expect(validate(start: today, due: DateTime(2026, 10, 17)), isNotNull);
  });
  test('positive quantity within stock and nonempty purpose are required', () {
    for (final amount in [0, -1, 3]) {
      expect(validate(amount: amount, start: today, due: today), isNotNull);
    }
    expect(validate(start: today, due: today, purpose: ' '), isNotNull);
    expect(validate(start: today, due: today, purpose: 'a' * 2001), isNotNull);
    expect(validate(start: today, due: today), isNull);
  });
  test('damaged items cannot be borrowed even when stock is positive', () {
    const item = InventoryItem(
      id: 'damaged',
      name: 'Damaged',
      code: 'D',
      category: 'Komputer',
      condition: 'Perlu Perbaikan',
      stock: 4,
      location: 'Rak',
    );
    expect(item.canBorrow, false);
    expect(
      validateBorrowing(
        item: item,
        amount: 1,
        borrowDate: today,
        returnDate: today,
        purpose: 'Praktikum',
        now: today,
      ),
      isNotNull,
    );
  });
  test(
    'business dates preserve the selected calendar date without UTC conversion',
    () {
      expect(businessDate(DateTime(2026, 10, 18)), '2026-10-18');
    },
  );
}
