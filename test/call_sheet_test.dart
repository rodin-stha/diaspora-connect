import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:diaspora_connect/features/home/widgets/call_sheet.dart';
import 'package:diaspora_connect/features/platform_settings/data/platform_settings_provider.dart';
import 'package:diaspora_connect/features/platform_settings/models/platform_settings.dart';
import 'package:diaspora_connect/l10n/app_localizations.dart';
import 'package:diaspora_connect/theme/app_theme.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  group('PlatformSettings.fromJson', () {
    test('reads the API sample, where nothing is set yet', () {
      final settings = PlatformSettings.fromJson({
        'sos_number': null,
        'helpline_number': null,
      });
      expect(settings.sosNumber, isNull);
      expect(settings.helplineNumber, isNull);
    });

    test('reads the fallback image', () {
      final settings = PlatformSettings.fromJson({
        'sos_number': '9800001111',
        'helpline_number': '9525990012',
        'fallback_image': {
          'id': 87,
          'file_name': 'about-img-1.testingwala.jpg',
          'mime_type': 'image/jpeg',
          'size': 1464841,
          'url': 'https://diaspora.kumo-labs.com/storage/87/a.jpg?signature=x',
          'expires_at': '2026-10-15T05:43:11+00:00',
        },
      });

      final image = settings.fallbackImage!;
      expect(image.id, 87);
      expect(image.fileName, 'about-img-1.testingwala.jpg');
      expect(image.url, contains('signature=x'));
    });

    test('trims numbers and treats blank as none', () {
      final settings = PlatformSettings.fromJson({
        'sos_number': ' 100 ',
        'helpline_number': '  ',
      });
      expect(settings.sosNumber, '100');
      expect(settings.helplineNumber, isNull);
    });
  });

  group('CallSheet', () {
    Future<void> pumpSheet(
      WidgetTester tester,
      Future<PlatformSettings> Function() fetch,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [platformSettingsProvider.overrideWith((ref) => fetch())],
          child: MaterialApp(
            theme: TAppTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: CallSheet(
                title: 'Helpline',
                numberOf: (settings) => settings.helplineNumber,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('shows the number with a Call button', (tester) async {
      await pumpSheet(
        tester,
        () async => const PlatformSettings(helplineNumber: '+977 1-4200000'),
      );
      expect(find.text('+977 1-4200000'), findsOneWidget);
      expect(find.text('Call'), findsOneWidget);
    });

    testWidgets('says so when no number is set', (tester) async {
      await pumpSheet(tester, () async => const PlatformSettings());
      expect(find.text("This number isn't available yet."), findsOneWidget);
      expect(find.text('Call'), findsNothing);
    });

    testWidgets('a failed fetch offers a retry', (tester) async {
      await pumpSheet(tester, () async => throw Exception('offline'));
      expect(find.text("Couldn't load the number."), findsOneWidget);
    });
  });
}
