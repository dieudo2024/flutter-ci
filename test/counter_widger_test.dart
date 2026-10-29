import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ci_counter/main.dart';

void main() {
  testWidgets('plus updates the displayed value', (tester) async {
    await tester.pumpWidget(const CounterApp());
    expect(find.text('0'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('increment')));
    await tester.pump();
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('minus at zero keeps the displayed value at zero', (
    tester,
  ) async {
    await tester.pumpWidget(const CounterApp());
    await tester.tap(find.byKey(const ValueKey('decrement')));
    await tester.pump();
    expect(find.text('0'), findsOneWidget);
    expect(find.text('-1'), findsNothing);
  });

  testWidgets('reset updates the displayed value to zero', (tester) async {
    await tester.pumpWidget(const CounterApp());
    await tester.tap(find.byKey(const ValueKey('increment')));
    await tester.tap(find.byKey(const ValueKey('increment')));
    await tester.pump();
    expect(find.text('2'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('reset')));
    await tester.pump();
    expect(find.text('0'), findsOneWidget);
  });
}
