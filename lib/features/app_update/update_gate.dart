import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/update_required_provider.dart';
import 'update_required_screen.dart';

/// Shows [UpdateRequiredScreen] instead of [child] when this version is too
/// old.
///
/// Wraps the whole app (MaterialApp's `builder`), not a route: there's no
/// screen to navigate to around it, and it also covers Login and push
/// notification taps.
///
/// While the check runs, the app shows as usual, so a slow connection
/// doesn't delay every launch.
class UpdateGate extends ConsumerWidget {
  final Widget child;

  const UpdateGate({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final updateRequired = ref.watch(updateRequiredProvider).value ?? false;
    return updateRequired ? const UpdateRequiredScreen() : child;
  }
}
