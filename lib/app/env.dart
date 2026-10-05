/// Build-time config, injected with `--dart-define-from-file=env/<name>.json`.
///
/// Values are compiled into the app binary, so anyone can extract them.
/// Only put public config here (URLs, env name) — never secrets.
class Env {
  Env._();

  static const env = String.fromEnvironment('ENV', defaultValue: 'dev');
  static const apiBaseUrl = String.fromEnvironment('API_BASE_URL');

  static const isProd = env == 'prod';

  /// Fails fast in debug if the app was started without an env file.
  static void validate() {
    assert(
      apiBaseUrl.isNotEmpty,
      'API_BASE_URL is missing. Run with '
      '--dart-define-from-file=env/dev.json',
    );
  }
}
