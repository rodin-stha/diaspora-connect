import 'package:flutter/material.dart';

import '../theme/colors.dart';

/// Matches the slide of a page closing (iOS's back animation).
const _duration = Duration(milliseconds: 300);

/// How far the tab underneath starts to the left, as a fraction of the
/// width: it moves a little while the top one slides away (parallax).
const _underneathStart = -0.3;

/// Tells [TabSwitchContainer] whether the latest tab change was "back".
/// Provided by MainShell, which knows why the tab changed.
class TabBackScope extends InheritedWidget {
  final bool lastChangeWasBack;

  const TabBackScope({
    super.key,
    required this.lastChangeWasBack,
    required super.child,
  });

  @override
  bool updateShouldNotify(TabBackScope oldWidget) =>
      lastChangeWasBack != oldWidget.lastChangeWasBack;
}

/// Shows the current tab, keeping the others alive (their scroll position,
/// loaded data) like an IndexedStack.
///
/// Going back animates like closing a page: the tab being left slides off
/// to the right, showing the previous tab underneath. Other tab changes
/// (tapping the bottom bar) are instant, as tab bars usually are.
class TabSwitchContainer extends StatefulWidget {
  final int currentIndex;
  final List<Widget> children;

  const TabSwitchContainer({
    super.key,
    required this.currentIndex,
    required this.children,
  });

  @override
  State<TabSwitchContainer> createState() => _TabSwitchContainerState();
}

class _TabSwitchContainerState extends State<TabSwitchContainer>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: _duration,
  );

  /// The tab sliding away during a back animation; null otherwise.
  int? _leaving;

  late final _curve = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
  );
  late final _leavingOffset = Tween(
    begin: Offset.zero,
    end: const Offset(1, 0),
  ).animate(_curve);
  late final _underneathOffset = Tween(
    begin: const Offset(_underneathStart, 0),
    end: Offset.zero,
  ).animate(_curve);

  @override
  void didUpdateWidget(TabSwitchContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex == widget.currentIndex) return;

    final isBack =
        context
            .getInheritedWidgetOfExactType<TabBackScope>()
            ?.lastChangeWasBack ??
        false;
    // Respects the phone's "reduce motion" setting.
    if (!isBack || MediaQuery.disableAnimationsOf(context)) {
      _leaving = null;
      _controller.value = 0;
      return;
    }

    _leaving = oldWidget.currentIndex;
    _controller.forward(from: 0).whenCompleteOrCancel(() {
      if (mounted) setState(() => _leaving = null);
    });
  }

  @override
  void dispose() {
    _curve.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final leaving = _leaving;
    final current = widget.currentIndex;

    Widget tab(int index) {
      final isLeaving = index == leaving;
      final isUnderneath = leaving != null && index == current;
      final visible = index == current || isLeaving;

      // Every tab gets the same wrappers in the same order, whatever its
      // role: changing them would make Flutter rebuild the tab from
      // scratch and lose its state.
      return KeyedSubtree(
        key: ValueKey(index),
        child: Offstage(
          offstage: !visible,
          // Hidden tabs don't run animations (e.g. loading skeletons).
          child: TickerMode(
            enabled: visible,
            // No taps on either tab while they move.
            child: IgnorePointer(
              ignoring: leaving != null,
              child: SlideTransition(
                position: isLeaving
                    ? _leavingOffset
                    : isUnderneath
                    ? _underneathOffset
                    : const AlwaysStoppedAnimation(Offset.zero),
                child: DecoratedBox(
                  // The edge shadow of a page sliding away.
                  decoration: BoxDecoration(
                    boxShadow: isLeaving
                        ? [
                            BoxShadow(
                              color: context.colors.shadow,
                              blurRadius: 16,
                            ),
                          ]
                        : null,
                  ),
                  child: widget.children[index],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // The tab sliding away goes last, so it's drawn on top. Keys let
        // Flutter move it there without rebuilding it.
        for (var i = 0; i < widget.children.length; i++)
          if (i != leaving) tab(i),
        if (leaving != null) tab(leaving),
      ],
    );
  }
}
