import 'package:flutter_test/flutter_test.dart';
import 'package:ndis_connect/models/appointment.dart';
import 'package:ndis_connect/models/budget.dart';
import 'package:ndis_connect/models/task.dart';
import 'package:ndis_connect/models/circle.dart';
import 'package:ndis_connect/models/shift.dart';

void main() {
  group('NDIS Connect Unit Tests', () {
    group('Appointment Model Tests', () {
      test('Appointment creation and serialization', () {
        final appointment = Appointment(
          id: 'test-1',
          title: 'Physiotherapy Session',
          description: 'Weekly physio session',
          startTime: DateTime(2024, 1, 15, 10, 0),
          endTime: DateTime(2024, 1, 15, 11, 0),
          providerId: 'provider-1',
          participantId: 'participant-1',
          status: AppointmentStatus.scheduled,
          location: 'Health Center',
          notes: 'Bring exercise sheet',
        );

        expect(appointment.id, 'test-1');
        expect(appointment.title, 'Physiotherapy Session');
        expect(appointment.status, AppointmentStatus.scheduled);
        expect(appointment.duration.inMinutes, 60);

        // Test serialization
        final map = appointment.toMap();
        expect(map['id'], 'test-1');
        expect(map['title'], 'Physiotherapy Session');
        expect(map['status'], 'scheduled');

        // Test deserialization
        final fromMap = Appointment.fromMap(map);
        expect(fromMap.id, appointment.id);
        expect(fromMap.title, appointment.title);
        expect(fromMap.status, appointment.status);
      });

      test('Appointment status transitions', () {
        final appointment = Appointment(
          id: 'test-2',
          title: 'Test Appointment',
          startTime: DateTime.now(),
          endTime: DateTime.now().add(const Duration(hours: 1)),
          providerId: 'provider-1',
          participantId: 'participant-1',
        );

        expect(appointment.status, AppointmentStatus.scheduled);

        // Test status update
        final updated =
            appointment.copyWith(status: AppointmentStatus.completed);
        expect(updated.status, AppointmentStatus.completed);
        expect(updated.id, appointment.id); // ID should remain the same
      });
    });

    group('Budget Model Tests', () {
      test('Budget creation and calculations', () {
        final budget = Budget(
          id: 'budget-1',
          participantId: 'participant-1',
          totalAmount: 10000.0,
          usedAmount: 2500.0,
          categories: {
            'Core': BudgetCategory(
              name: 'Core',
              allocatedAmount: 5000.0,
              usedAmount: 1500.0,
            ),
            'Capital': BudgetCategory(
              name: 'Capital',
              allocatedAmount: 3000.0,
              usedAmount: 800.0,
            ),
            'Capacity Building': BudgetCategory(
              name: 'Capacity Building',
              allocatedAmount: 2000.0,
              usedAmount: 200.0,
            ),
          },
        );

        expect(budget.totalAmount, 10000.0);
        expect(budget.usedAmount, 2500.0);
        expect(budget.remainingAmount, 7500.0);
        expect(budget.usagePercentage, 0.25);

        // Test category calculations
        final coreCategory = budget.categories['Core']!;
        expect(coreCategory.remainingAmount, 3500.0);
        expect(coreCategory.usagePercentage, 0.3);
      });

      test('Budget alerts', () {
        final budget = Budget(
          id: 'budget-2',
          participantId: 'participant-1',
          totalAmount: 10000.0,
          usedAmount: 8500.0, // 85% used
          categories: {},
        );

        expect(budget.usagePercentage, 0.85);
        expect(budget.isNearLimit, true);
        expect(budget.isOverLimit, false);

        // Test over limit
        final overLimitBudget = budget.copyWith(usedAmount: 10500.0);
        expect(overLimitBudget.isOverLimit, true);
      });
    });

    group('Task Model Tests', () {
      test('Task creation and completion', () {
        final task = PlanTask(
          id: 'task-1',
          title: 'Book physiotherapy appointment',
          description: 'Schedule weekly physio session',
          priority: 1,
          dueDate: DateTime(2024, 1, 20),
          category: 'Health',
        );

        expect(task.id, 'task-1');
        expect(task.title, 'Book physiotherapy appointment');
        expect(task.priority, 1);
        expect(task.done, false);
        expect(task.isOverdue, false);

        // Test task completion
        final completedTask = task.toggle();
        expect(completedTask.done, true);
        expect(completedTask.completedAt, isNotNull);

        // Test overdue task
        final overdueTask = task.copyWith(
          dueDate: DateTime.now().subtract(const Duration(days: 1)),
        );
        expect(overdueTask.isOverdue, true);
      });

      test('Task priority levels', () {
        final highPriorityTask = PlanTask(
          id: 'task-2',
          title: 'High Priority Task',
          priority: 1,
        );

        final lowPriorityTask = PlanTask(
          id: 'task-3',
          title: 'Low Priority Task',
          priority: 3,
        );

        expect(highPriorityTask.priority, 1);
        expect(lowPriorityTask.priority, 3);
        expect(highPriorityTask.priority < lowPriorityTask.priority, true);
      });
    });

    group('Circle Model Tests', () {
      test('Support circle creation', () {
        final circle = SupportCircle(
          id: 'circle-1',
          name: 'Family Support Circle',
          description: 'Main family support network',
          participantId: 'participant-1',
          members: [
            CircleMember(
              id: 'member-1',
              name: 'John Doe',
              role: 'Family Member',
              email: 'john@example.com',
              phone: '+61412345678',
            ),
            CircleMember(
              id: 'member-2',
              name: 'Jane Smith',
              role: 'Support Worker',
              email: 'jane@example.com',
              phone: '+61412345679',
            ),
          ],
        );

        expect(circle.id, 'circle-1');
        expect(circle.name, 'Family Support Circle');
        expect(circle.members.length, 2);
        expect(circle.members.first.name, 'John Doe');
        expect(circle.members.last.role, 'Support Worker');
      });

      test('Circle member management', () {
        final circle = SupportCircle(
          id: 'circle-2',
          name: 'Test Circle',
          participantId: 'participant-1',
          members: [],
        );

        expect(circle.members.length, 0);

        // Test adding member
        final newMember = CircleMember(
          id: 'member-3',
          name: 'New Member',
          role: 'Friend',
          email: 'new@example.com',
        );

        final updatedCircle = circle.copyWith(
          members: [...circle.members, newMember],
        );

        expect(updatedCircle.members.length, 1);
        expect(updatedCircle.members.first.name, 'New Member');
      });
    });

    group('Shift Model Tests', () {
      test('Shift creation and validation', () {
        final shift = Shift(
          id: 'shift-1',
          providerId: 'provider-1',
          startTime: DateTime(2024, 1, 15, 9, 0),
          endTime: DateTime(2024, 1, 15, 17, 0),
          location: 'Health Center',
          status: ShiftStatus.available,
          maxParticipants: 5,
        );

        expect(shift.id, 'shift-1');
        expect(shift.providerId, 'provider-1');
        expect(shift.duration.inHours, 8);
        expect(shift.status, ShiftStatus.available);
        expect(shift.maxParticipants, 5);

        // Test shift booking
        final bookedShift = shift.copyWith(
          status: ShiftStatus.booked,
          participantIds: ['participant-1', 'participant-2'],
        );

        expect(bookedShift.status, ShiftStatus.booked);
        expect(bookedShift.participantIds.length, 2);
        expect(bookedShift.availableSpots, 3);
      });

      test('Shift capacity management', () {
        final shift = Shift(
          id: 'shift-2',
          providerId: 'provider-1',
          startTime: DateTime.now(),
          endTime: DateTime.now().add(const Duration(hours: 4)),
          maxParticipants: 3,
        );

        expect(shift.availableSpots, 3);
        expect(shift.isFullyBooked, false);

        // Test full booking
        final fullShift = shift.copyWith(
          participantIds: ['p1', 'p2', 'p3'],
        );

        expect(fullShift.availableSpots, 0);
        expect(fullShift.isFullyBooked, true);
      });
    });

    group('Model Validation Tests', () {
      test('Required field validation', () {
        expect(
            () => Appointment(
                  id: '',
                  title: 'Test',
                  startTime: DateTime.now(),
                  endTime: DateTime.now().add(const Duration(hours: 1)),
                  providerId: 'provider-1',
                  participantId: 'participant-1',
                ),
            throwsA(isA<ArgumentError>()));

        expect(
            () => Budget(
                  id: '',
                  participantId: 'participant-1',
                  totalAmount: 0,
                ),
            throwsA(isA<ArgumentError>()));
      });

      test('Date validation', () {
        final now = DateTime.now();
        final past = now.subtract(const Duration(hours: 1));

        expect(
            () => Appointment(
                  id: 'test',
                  title: 'Test',
                  startTime: past,
                  endTime: now,
                  providerId: 'provider-1',
                  participantId: 'participant-1',
                ),
            throwsA(isA<ArgumentError>()));
      });

      test('Amount validation', () {
        expect(
            () => Budget(
                  id: 'test',
                  participantId: 'participant-1',
                  totalAmount: -100,
                ),
            throwsA(isA<ArgumentError>()));

        expect(
            () => Budget(
                  id: 'test',
                  participantId: 'participant-1',
                  totalAmount: 1000,
                  usedAmount: -100,
                ),
            throwsA(isA<ArgumentError>()));
      });
    });
  });
}
