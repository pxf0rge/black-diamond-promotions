import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:bd_accounting/core/di/app_dependencies.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await Hive.close();
  });

  test('initializes storage with empty state on fresh install', () async {
    final deps = await AppDependencies.create();
    await deps.storageService.clearAll();

    final event = await deps.eventRepository.getCurrentEvent();
    expect(event, isNull);

    final events = await deps.eventRepository.getAllEvents();
    expect(events, isEmpty);

    final transactions = await deps.transactionRepository.getRecentTransactions(
      eventId: null,
    );
    expect(transactions, isEmpty);
  });
}
