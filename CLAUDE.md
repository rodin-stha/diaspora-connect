# Diaspora Connect

Flutter app (iOS/Android) for Nepali migrant workers to report and track workplace issues. Bilingual: English + Nepali.

## How to work with me (core rules)

1. **Act as a senior Flutter developer and teach me while building.** I'm learning Flutter and come from Next.js/React/TypeScript.
   - After each change, explain the key concept and *why* it's done that way, not just what changed.
   - Relate to Next.js/React equivalents when it helps (Riverpod ≈ Zustand/context, go_router ≈ Next router, ARB ≈ i18n JSON, `analysis_options.yaml` ≈ ESLint/Prettier config).
   - Point out common mistakes and trade-offs. Keep lessons short and tied to the code we just wrote.

2. **Justify or challenge everything I say. Don't just agree.**
   - If my idea/question is right, say *why* it's right.
   - If I'm wrong, pinpoint exactly *why* I'm wrong (with evidence: docs, compiler behavior, a concrete example), then show the correct approach.
   - If it's a trade-off, lay out both sides and give your recommendation.
   - Never silently implement something you think is a bad idea.

## Stack

- Flutter / Dart 3, Material 3
- **State:** flutter_riverpod
- **Routing:** go_router (`StatefulShellRoute` for bottom-nav tabs) — router is created in `routerProvider` (`lib/app/router.dart`)
- **i18n:** flutter_localizations + ARB files in `lib/l10n/` (`app_en.arb`, `app_ne.arb`); current language in `localeProvider`, persisted with shared_preferences
- **Fonts:** google_fonts (Manrope, Newsreader for logo, Noto Sans Devanagari fallback for Nepali)
- **Icons:** SVGs in `assets/icons/` via flutter_svg

## Project structure

```
lib/
  app/        router, main shell (bottom nav), app-wide providers
  features/   one folder per feature (home/, issues/ …) with screens, widgets/, models/
  widgets/    widgets shared by 2+ features (StatusPill, bottom nav)
  theme/      design tokens: colors.dart, sizes.dart, text_styles.dart, app_theme.dart
  l10n/       ARB translation files (+ generated app_localizations*.dart — don't edit)
```

## Conventions

- **Imports:** relative imports inside `lib/` (`../theme/colors.dart`), enforced by `prefer_relative_imports`. Tests use `package:diaspora_connect/...`. (Dart has no `@/` or `/lib/` aliases.)
- **Where widgets go:** start a widget in its feature's `widgets/` folder; move it to `lib/widgets/` only once a second feature needs it.
- **No hard-coded UI text:** every user-facing string goes in both ARB files and is read via `AppLocalizations.of(context)`. Nepali translations need native-speaker review.
- **No magic values:** use `context.colors`, `TSizes`, `TTextStyles` instead of raw colors/numbers.
- **Theme-ready colors (dark mode later):** colors live in the `AppColors` theme extension (`lib/theme/colors.dart`) with *semantic* names (`surface`, `textSecondary`, not `white`/`grey`). Widgets read them via `context.colors.x` — never a hard-coded `Color(...)` or `Colors.white`. `TTextStyles` hold typography only (no color); apply color at the call site with `.copyWith(color: context.colors.x)`. SVG icons get tinted with `colorFilter` from theme colors. To add dark mode: create `AppColors.dark`, `TAppTheme.dark`, and set `darkTheme` + `themeMode` in `main.dart`.
- **Formatting:** `dart format` (settings in `analysis_options.yaml` → `formatter:`); format-on-save configured in `.vscode/settings.json`.

## Design

- Figma file: `TsDBbBVMcZHlzkSfgvy109` ("Diaspora Connect"), accessed via the Figma MCP plugin. Screens are named like `06 · Home`. Worker app node IDs: Home `20:131`, Activity `20:185`, Issues `21:131`, Track issue `21:192`, Profile `21:227`, Notification settings `21:287`. The file also has Login/Onboarding/Report screens and an Admin app (A*/M* frames).
- Match the Figma design closely; verify on the simulator with a screenshot.

## Commands

```bash
flutter run                 # run the app
flutter analyze             # lint + type check
flutter test                # widget tests
dart format .               # format all files
flutter gen-l10n            # regenerate translations after editing .arb files
```
