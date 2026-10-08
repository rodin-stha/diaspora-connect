/// Build-time config, injected with `--dart-define-from-file=env/<name>.json`.
///
/// Values are compiled into the app binary, so anyone can extract them.
/// Only put public config here (URLs, env name) — never secrets.
class Env {
  Env._();

  static const env = String.fromEnvironment('ENV', defaultValue: 'dev');
  static const apiBaseUrl = String.fromEnvironment('API_BASE_URL');

  static const isProd = env == 'prod';

  /// Fails fast if the app was built without an env file.
  ///
  /// A real check, not an `assert`: asserts are stripped from release
  /// builds, so a release build without the env file would otherwise start
  /// with an empty base URL and every API call would silently fail.
  static void validate() {
    if (apiBaseUrl.isEmpty) {
      throw StateError(
        'API_BASE_URL is missing. Run with '
        '--dart-define-from-file=env/dev.json',
      );
    }
  }
}
