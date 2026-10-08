import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;

import '../features/auth/data/auth_provider.dart';
import '../features/auth/data/token_storage.dart';

/// The app's [ProviderScope], started over from scratch when the user signs
/// out.
///
/// Providers cache the signed-in user's data (issues, profile, activity…)
/// for as long as the app runs. Refetching on sign-out isn't enough:
/// while reloading, Riverpod keeps the previous value, so the next user
/// would briefly see the last user's name and issues. A new container has
/// nothing cached, and covers every provider, including ones added later.
///
/// Like a full page reload after logout on the web. Anything that should
/// survive it (language, notification settings) lives in
/// SharedPreferences.
class SessionProviderScope extends StatefulWidget {
  /// Overrides for every container, e.g. SharedPreferences.
  final List<Override> overrides;

  /// The token saved on the device at launch. Null after a sign-out.
  final String? savedToken;

  final Widget child;

  const SessionProviderScope({
    super.key,
    required this.overrides,
    required this.savedToken,
    required this.child,
  });

  @override
  State<SessionProviderScope> createState() => _SessionProviderScopeState();
}

class _SessionProviderScopeState extends State<SessionProviderScope> {
  late ProviderContainer _container = _createContainer(widget.savedToken);

  ProviderContainer _createContainer(String? savedToken) {
    final container = ProviderContainer(
      overrides: [
        ...widget.overrides,
        savedTokenProvider.overrideWithValue(savedToken),
      ],
    );
    container.listen(authProvider.select((auth) => auth.isSignedIn), (
      wasSignedIn,
      isSignedIn,
    ) {
      if (wasSignedIn == true && !isSignedIn) _startOver();
    });
    return container;
  }

  void _startOver() {
    final old = _container;
    // The token was just deleted, so the new session starts signed out.
    setState(() => _container = _createContainer(null));
    // Only once the old widgets are gone: they still read it until then.
    WidgetsBinding.instance.addPostFrameCallback((_) => old.dispose());
  }

  @override
  void dispose() {
    _container.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return UncontrolledProviderScope(
      // A new key per container, so every widget below is built fresh too
      // and none keeps the old user's state (form fields, scroll position).
      key: ObjectKey(_container),
      container: _container,
      child: widget.child,
    );
  }
}
