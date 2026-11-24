import 'package:flutter_test/flutter_test.dart';
import 'package:to_do_app/main.dart';
import 'package:to_do_app/services/task_service.dart';

void main() {
  testWidgets('Daily Planner app builds successfully', (WidgetTester tester) async {
    final taskService = TaskService();

    // Build our app and trigger a frame.
    await tester.pumpWidget(DailyPlannerApp(taskService: taskService));

    // Verify that the title appears.
    expect(find.text('Daily Planner'), findsOneWidget);
  });
}
