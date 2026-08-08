import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:marqueslab_wifi_people_counter/main.dart';
import 'package:marqueslab_wifi_people_counter/state/occupancy_state.dart';

void main() {
  testWidgets('dashboard renders', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => OccupancyState(),
        child: const PeopleCounterApp(),
      ),
    );

    expect(find.text('PEOPLE COUNTER'), findsOneWidget);
    expect(find.text('PESSOAS PRESENTES'), findsOneWidget);
  });
}
