import 'package:diaspora_connect/app/api/api_exception.dart';
import 'package:diaspora_connect/features/app_update/update_gate.dart';
import 'package:diaspora_connect/features/app_update/version.dart';
import 'package:diaspora_connect/features/platform_settings/data/platform_settings_provider.dart';
import 'package:diaspora_connect/features/platform_settings/models/platform_settings.dart';
import 'package:diaspora_connect/l10n/app_localizations.dart';
import 'package:diaspora_connect/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() {
  group('isOlderVersion', () {
    test('compares number by number, not as text', () {
      expect(isOlderVersion('1.9.0', '1.10.0'), isTrue);
      expect(isOlderVersion('1.10.0', '1.9.0'), isFalse);
    });

    test('the same version is not older', () {
      expect(isOlderVersion('1.2.0', '1.2.0'), isFalse);
      expect(isOlderVersion('1.2', '1.2.0'), isFalse);
    });

    test('ignores build numbers and suffixes', () {
      expect(isOlderVersion('1.2.0+7', '1.2.0'), isFalse);
      expect(isOlderVersion('1.2.0-beta', '1.2.1'), isTrue);
    });
  });

  test('min_version is read per platform, and optional', () {
    final settings = PlatformSettings.fromJson({
      'min_version': {'android': '1.1.0', 'ios': ''},
    });
    expect(settings.minVersion.android, '1.1.0');
    expect(settings.minVersion.ios, isNull);
    expect(PlatformSettings.fromJson({}).minVersion.android, isNull);
  });

  group('UpdateGate', () {
    setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

    Future<void> pumpGate(
      WidgetTester tester, {
      required Future<PlatformSettings> Function() settings,
      String appVersion = '1.0.0',
    }) async {
      PackageInfo.setMockInitialValues(
        appName: 'Diaspora Connect',
        packageName: 'com.kumolabs.diaspora_connect',
        version: appVersion,
        buildNumber: '1',
        buildSignature: '',
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            platformSettingsProvider.overrideWith((ref) => settings()),
          ],
          child: MaterialApp(
            theme: TAppTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (context, child) => UpdateGate(child: child!),
            home: const Text('Home'),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('blocks a version older than the minimum', (tester) async {
      await pumpGate(
        tester,
        settings: () async => const PlatformSettings(
          minVersion: MinVersion(android: '1.1.0'),
        ),
      );
      expect(find.text('Update required'), findsOneWidget);
      expect(find.text('Update now'), findsOneWidget);
      expect(find.text('Home'), findsNothing);
    });

    testWidgets('lets the minimum version itself in', (tester) async {
      await pumpGate(
        tester,
        appVersion: '1.1.0',
        settings: () async => const PlatformSettings(
          minVersion: MinVersion(android: '1.1.0'),
        ),
      );
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Update required'), findsNothing);
    });

    testWidgets(
      "only checks this device's platform",
      (tester) async {
        await pumpGate(
          tester,
          // Android must update, but the iOS update isn't approved yet.
          settings: () async => const PlatformSettings(
            minVersion: MinVersion(android: '1.1.0'),
          ),
        );
        expect(find.text('Home'), findsOneWidget);
      },
      variant: TargetPlatformVariant.only(TargetPlatform.iOS),
    );

    testWidgets('lets the user in when the API fails', (tester) async {
      await pumpGate(
        tester,
        settings: () async =>
            throw const ApiException(ApiErrorType.noConnection),
      );
      expect(find.text('Home'), findsOneWidget);
    });
  });
}
