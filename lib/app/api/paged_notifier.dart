import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_exception.dart';
import 'paged.dart';

/// A list loaded a page at a time: the items so far, and whether more can
/// load.
class PagedList<T> {
  final List<T> items;
  final int pagesLoaded;
  final bool hasMore;

  /// How many there are in all (`meta.total`), if the server says.
  final int? total;

  /// True while the next page is loading (shows a skeleton at the end).
  final bool isLoadingMore;

  /// True if loading the next page failed (shows Retry at the end).
  final bool loadMoreFailed;

  const PagedList({
    required this.items,
    required this.pagesLoaded,
    required this.hasMore,
    this.total,
    this.isLoadingMore = false,
    this.loadMoreFailed = false,
  });

  PagedList<T> copyWith({
    List<T>? items,
    bool? isLoadingMore,
    bool? loadMoreFailed,
  }) => PagedList(
    items: items ?? this.items,
    pagesLoaded: pagesLoaded,
    hasMore: hasMore,
    total: total,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    loadMoreFailed: loadMoreFailed ?? this.loadMoreFailed,
  );
}

/// Base for a provider that loads a list page by page: the first page on
/// build, the next one on [loadMore].
///
/// Subclasses say how to fetch a page ([fetchPage]) and how to tell items
/// apart ([idOf]). Pull-to-refresh (`ref.refresh`) runs [build] again,
/// which starts the list over.
abstract class PagedNotifier<T> extends AsyncNotifier<PagedList<T>> {
  /// How many items to ask for at a time.
  int get perPage;

  Future<Paged<T>> fetchPage({required int page, required int perPage});

  /// Identifies an item, to skip repeats when pages shift.
  Object idOf(T item);

  @override
  Future<PagedList<T>> build() async {
    final page = await fetchPage(page: 1, perPage: perPage);
    return PagedList(
      items: page.items,
      pagesLoaded: 1,
      hasMore: page.hasMore,
      total: page.total,
    );
  }

  /// Appends the next page. Does nothing if it's already loading or there
  /// are no more, so it's safe to call on every scroll.
  Future<void> loadMore() async {
    final list = state.value;
    if (list == null || !list.hasMore || list.isLoadingMore) return;

    final loading = list.copyWith(isLoadingMore: true, loadMoreFailed: false);
    state = AsyncData(loading);
    try {
      final page = await fetchPage(
        page: list.pagesLoaded + 1,
        perPage: perPage,
      );
      // Refreshed meanwhile: that list starts over, so this page doesn't
      // belong on it.
      if (!ref.mounted || !identical(state.value, loading)) return;

      // Something added while scrolling pushes the rest down a page, so
      // the last item seen can come again. Skip repeats.
      final seen = {for (final item in list.items) idOf(item)};
      final added = [
        for (final item in page.items)
          if (!seen.contains(idOf(item))) item,
      ];
      state = AsyncData(
        PagedList(
          items: [...list.items, ...added],
          pagesLoaded: list.pagesLoaded + 1,
          // Nothing new: stop, rather than ask again and again (e.g. a
          // server that ignores `page` and sends the same items).
          hasMore: page.hasMore && added.isNotEmpty,
          total: page.total ?? list.total,
        ),
      );
    } on ApiException {
      if (!ref.mounted || !identical(state.value, loading)) return;
      state = AsyncData(
        loading.copyWith(isLoadingMore: false, loadMoreFailed: true),
      );
    }
  }

  /// Fetches everything loaded so far again in one request (page 1, all of
  /// it), without a loading state, so the list stays where the user
  /// scrolled. For background checks and expiring links.
  ///
  /// Throws [ApiException] if that fails, leaving the list unchanged.
  Future<void> reloadLoaded() async {
    final list = state.value;
    if (list == null) return;

    final page = await fetchPage(
      page: 1,
      perPage: list.pagesLoaded * perPage,
    );
    // Skipped if the list changed meanwhile (more loaded, or refreshed).
    if (!ref.mounted || !identical(state.value, list)) return;
    state = AsyncData(
      PagedList(
        items: page.items,
        pagesLoaded: list.pagesLoaded,
        hasMore: page.hasMore,
        total: page.total,
      ),
    );
  }
}
