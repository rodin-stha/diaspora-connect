/// Public web pages the app links to.
///
/// The same in dev and prod: there's one public policy, and store
/// reviewers check this exact URL.
abstract final class AppLinks {
  /// Served by the backend from docs/privacy-policy.html.
  // TODO: confirm the final URL with the backend team once it's live.
  static final privacyPolicy = Uri.parse(
    'https://diaspora.kumo-labs.com/privacy',
  );
}
