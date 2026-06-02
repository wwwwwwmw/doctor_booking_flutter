import 'package:flutter_test/flutter_test.dart';
import 'package:doctor_booking_app/data/models/user_model.dart';

void main() {
  group('UserModel', () {
    test('should create from JSON', () {
      final json = {
        'id': 'test-id',
        'email': 'test@example.com',
        'full_name': 'Test User',
        'role': 'patient',
        'is_active': true,
        'created_at': '2026-01-01T00:00:00Z',
      };

      final user = UserModel.fromJson(json);

      expect(user.id, 'test-id');
      expect(user.email, 'test@example.com');
      expect(user.fullName, 'Test User');
      expect(user.isPatient, true);
      expect(user.isDoctor, false);
    });

    test('should convert to JSON', () {
      final user = UserModel(
        id: 'test-id',
        email: 'test@example.com',
        fullName: 'Test User',
        role: 'patient',
        createdAt: DateTime(2026, 1, 1),
      );

      final json = user.toJson();
      expect(json['full_name'], 'Test User');
      expect(json['role'], 'patient');
    });

    test('should support copyWith', () {
      final user = UserModel(
        id: 'test-id',
        email: 'test@example.com',
        fullName: 'Old Name',
        role: 'patient',
        createdAt: DateTime(2026, 1, 1),
      );

      final updated = user.copyWith(fullName: 'New Name');
      expect(updated.fullName, 'New Name');
      expect(updated.email, 'test@example.com'); // unchanged
    });
  });
}
