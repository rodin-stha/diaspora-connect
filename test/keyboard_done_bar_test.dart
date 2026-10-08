import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:diaspora_connect/l10n/app_localizations.dart';
import 'package:diaspora_connect/theme/app_theme.dart';
import 'package:diaspora_connect/widgets/keyboard_done_bar.dart';

/// In logical pixels, like the rest of the layout.
const _keyboardHeight = 300.0;

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Future<void> pumpField(WidgetTester tester, TargetPlatform platform) async {
    await tester.pumpWidget(
      MaterialApp(
        // The bar checks the theme's platform.
        theme: TAppTheme.light.copyWith(platform: platform),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => KeyboardDoneBar(child: child!),
        home: const Scaffold(
          body: Center(child: TextField(keyboardType: TextInputType.number)),
        ),
      ),
    );
  }

  /// Focuses the field and makes the "keyboard" appear, as tests have none.
  Future<void> openKeyboard(WidgetTester tester) async {
    await tester.tap(find.byType(TextField));
    await tester.enterText(find.byType(TextField), '12345');
    // The test window takes physical pixels.
    tester.view.viewInsets = FakeViewPadding(
      bottom: _keyboardHeight * tester.view.devicePixelRatio,
    );
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();
  }

  bool fieldHasFocus(WidgetTester tester) =>
      tester.widget<EditableText>(find.byType(EditableText)).focusNode.hasFocus;

  testWidgets('iOS: Done sits on the keyboard and closes it', (tester) async {
    await pumpField(tester, TargetPlatform.iOS);
    expect(find.text('Done'), findsNothing);

    await openKeyboard(tester);
    expect(find.text('Done'), findsOneWidget);
    // The keyboard appearing doesn't rebuild the screen: the field keeps
    // its focus and text.
    expect(fieldHasFocus(tester), isTrue);
    expect(find.text('12345'), findsOneWidget);

    final screenHeight =
        tester.view.physicalSize.height / tester.view.devicePixelRatio;
    final keyboardTop = screenHeight - _keyboardHeight;
    final bar = tester.getRect(
      find
          .descendant(
            of: find.byType(KeyboardDoneBar),
            // The first is the page's swipe-back edge; the bar is drawn last.
            matching: find.byType(Positioned),
          )
          .last,
    );
    expect(bar.bottom, keyboardTop);

    await tester.tap(find.text('Done'));
    await tester.pump();
    expect(fieldHasFocus(tester), isFalse);
  });

  testWidgets('Android: no bar', (tester) async {
    await pumpField(tester, TargetPlatform.android);
    await openKeyboard(tester);
    expect(find.text('Done'), findsNothing);
  });
}
