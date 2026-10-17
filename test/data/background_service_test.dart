import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_app/data/background/background_service.dart';

void main() {
  group('BackgroundService.delayUntilNextReminder', () {
    test('targets 11:00 today when it is earlier in the morning', () {
      final now = DateTime(2026, 1, 15, 8, 30);

      expect(
        BackgroundService.delayUntilNextReminder(now),
        const Duration(hours: 2, minutes: 30),
      );
    });

    test('targets 11:00 tomorrow when 11:00 has already passed', () {
      final now = DateTime(2026, 1, 15, 15, 45);

      expect(
        BackgroundService.delayUntilNextReminder(now),
        const Duration(hours: 19, minutes: 15),
      );
    });

    test('targets tomorrow when it is exactly 11:00', () {
      final now = DateTime(2026, 1, 15, 11);

      expect(
        BackgroundService.delayUntilNextReminder(now),
        const Duration(hours: 24),
      );
    });

    test('returns one second when it is one second before 11:00', () {
      final now = DateTime(2026, 1, 15, 10, 59, 59);

      expect(
        BackgroundService.delayUntilNextReminder(now),
        const Duration(seconds: 1),
      );
    });

    test('rolls over to the next month and year correctly', () {
      final now = DateTime(2026, 12, 31, 12);

      expect(
        BackgroundService.delayUntilNextReminder(now),
        const Duration(hours: 23),
      );
    });

    test('never returns a zero or negative delay', () {
      for (var hour = 0; hour < 24; hour++) {
        final now = DateTime(2026, 1, 15, hour);

        expect(
          BackgroundService.delayUntilNextReminder(now),
          greaterThan(Duration.zero),
        );
      }
    });
  });
}