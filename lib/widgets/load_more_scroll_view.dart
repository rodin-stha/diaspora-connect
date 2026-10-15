import 'package:flutter/material.dart';

import '../theme/sizes.dart';
import 'load_error.dart';
import 'skeleton.dart';

/// Start loading the next page this close to the bottom, so it's usually
/// there before the user reaches the end.
const _loadMoreThreshold = 600.0;

/// A scrolling page that calls [onLoadMore] when the user nears the
/// bottom, for lists loaded a page at a time.
///
/// Also checks after every build: a short page may not fill the screen,
/// and then there's no scroll to trigger the next one.
class LoadMoreScrollView extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;

  /// False while the next page can't or shouldn't load: none left, or the
  /// last attempt failed (then it waits for Retry).
  final bool canLoadMore;

  /// Safe to be called often; the provider ignores calls while loading.
  final VoidCallback onLoadMore;

  const LoadMoreScrollView({
    super.key,
    required this.child,
    required this.canLoadMore,
    required this.onLoadMore,
    this.padding,
    this.physics,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
  });

  @override
  State<LoadMoreScrollView> createState() => _LoadMoreScrollViewState();
}

class _LoadMoreScrollViewState extends State<LoadMoreScrollView> {
  final _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_loadMoreIfNearEnd);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _loadMoreIfNearEnd() {
    if (!mounted || !widget.canLoadMore || !_controller.hasClients) return;
    // `extentAfter`: how far is left to scroll.
    if (_controller.position.extentAfter < _loadMoreThreshold) {
      widget.onLoadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    // After this frame is laid out, the new content height is known.
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadMoreIfNearEnd());

    return SingleChildScrollView(
      controller: _controller,
      physics: widget.physics,
      padding: widget.padding,
      keyboardDismissBehavior: widget.keyboardDismissBehavior,
      child: widget.child,
    );
  }
}

/// The end of a paged list: [skeleton] while the next page loads, or an
/// error with Retry if it failed. Nothing otherwise.
class LoadMoreFooter extends StatelessWidget {
  final bool isLoading;
  final bool failed;
  final String errorMessage;
  final VoidCallback onRetry;

  /// One placeholder item, shaped like the list's items. Pulses.
  final Widget skeleton;

  const LoadMoreFooter({
    super.key,
    required this.isLoading,
    required this.failed,
    required this.errorMessage,
    required this.onRetry,
    required this.skeleton,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) return Skeleton(child: skeleton);
    if (failed) {
      return Padding(
        padding: const EdgeInsets.only(top: TSizes.sm),
        child: LoadError(message: errorMessage, onRetry: onRetry),
      );
    }
    return const SizedBox.shrink();
  }
}
