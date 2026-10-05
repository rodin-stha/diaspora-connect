import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:diaspora_connect/theme/app_theme.dart';
import 'package:diaspora_connect/widgets/loading_button.dart';

Widget wrap(Widget child) => MaterialApp(
  theme: TAppTheme.light,
  home: Scaffold(body: Center(child: child)),
);

void main() {
  testWidgets('shows the label and handles taps when idle', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      wrap(LoadingButton(label: 'Send OTP', onPressed: () => taps++)),
    );

    expect(find.text('Send OTP'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    await tester.tap(find.byType(LoadingButton));
    expect(taps, 1);
  });

  testWidgets('shows a spinner, is disabled and keeps its size', (
    tester,
  ) async {
    var taps = 0;
    Widget button({required bool isLoading}) => wrap(
      LoadingButton(
        label: 'Send OTP',
        onPressed: () => taps++,
        isLoading: isLoading,
      ),
    );

    await tester.pumpWidget(button(isLoading: false));
    final idleSize = tester.getSize(find.byType(FilledButton));

    await tester.pumpWidget(button(isLoading: true));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(tester.getSize(find.byType(FilledButton)), idleSize);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).enabled,
      isFalse,
    );

    await tester.tap(find.byType(LoadingButton));
    expect(taps, 0);
  });
}
