import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:diaspora_connect/app/api/paged.dart';
import 'package:diaspora_connect/app/api/paged_notifier.dart';

/// Serves the ids in [_all] a page at a time, recording each request.
List<int> _all = [];
final _requests = <({int page, int perPage})>[];

/// When true, every page is page 1 (a server that ignores `page`).
bool _ignoresPage = false;

class _NumbersNotifier extends PagedNotifier<int> {
  @override
  int get perPage => 3;

  @override
  Object idOf(int item) => item;

  @override
  Future<Paged<int>> fetchPage({
    required int page,
    required int perPage,
  }) async {
    _requests.add((page: page, perPage: perPage));
    final start = _ignoresPage ? 0 : (page - 1) * perPage;
    return Paged(
      items: _all.skip(start).take(perPage).toList(),
      hasMore: _ignoresPage || start + perPage < _all.length,
      total: _all.length,
    );
  }
}

final _numbersProvider =
    AsyncNotifierProvider<_NumbersNotifier, PagedList<int>>(
      _NumbersNotifier.new,
    );

void main() {
  setUp(() {
    _all = [for (var i = 1; i <= 7; i++) i];
    _requests.clear();
    _ignoresPage = false;
  });

  group('Paged.fromJson', () {
    test('reads the last page of the API sample', () {
      // /announcements?page=4&per_page=5, trimmed to what's read.
      final page = Paged.fromJson(
        {
          'data': [
            {'id': 11},
            {'id': 10},
          ],
          'meta': {'current_page': 4, 'last_page': 4, 'total': 20},
        },
        (item) => item['id'] as int,
        perPage: 5,
      );

      expect(page.items, [11, 10]);
      expect(page.hasMore, isFalse);
      expect(page.total, 20);
    });

    test('without meta, a full page means there may be more', () {
      Paged<int> read(int count) => Paged.fromJson(
        {
          'data': [
            for (var i = 0; i < count; i++) {'id': i},
          ],
        },
        (item) => item['id'] as int,
        perPage: 5,
      );

      expect(read(5).hasMore, isTrue);
      expect(read(3).hasMore, isFalse);
    });
  });

  group('PagedNotifier', () {
    test('loads page by page until the last', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(_numbersProvider.notifier);

      expect((await container.read(_numbersProvider.future)).items, [1, 2, 3]);
      await notifier.loadMore();
      await notifier.loadMore();
      final list = container.read(_numbersProvider).value!;

      expect(list.items, [1, 2, 3, 4, 5, 6, 7]);
      expect(list.hasMore, isFalse);
      expect(list.total, 7);

      await notifier.loadMore(); // nothing left: no request
      expect(_requests.length, 3);
    });

    test('a newer item pushing the pages down is not shown twice', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await container.read(_numbersProvider.future); // 1, 2, 3

      _all.insert(0, 0); // posted meanwhile: page 2 is now 3, 4, 5
      await container.read(_numbersProvider.notifier).loadMore();

      expect(container.read(_numbersProvider).value!.items, [1, 2, 3, 4, 5]);
    });

    test('stops when a page brings nothing new', () async {
      _ignoresPage = true;
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await container.read(_numbersProvider.future);

      final notifier = container.read(_numbersProvider.notifier);
      await notifier.loadMore(); // same 1, 2, 3 again
      await notifier.loadMore();

      expect(container.read(_numbersProvider).value!.hasMore, isFalse);
      expect(_requests.length, 2);
    });

    test('reloadLoaded fetches all loaded pages in one request', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await container.read(_numbersProvider.future);
      final notifier = container.read(_numbersProvider.notifier);
      await notifier.loadMore();
      _requests.clear();

      await notifier.reloadLoaded();

      expect(_requests, [(page: 1, perPage: 6)]);
      final list = container.read(_numbersProvider).value!;
      expect(list.items, [1, 2, 3, 4, 5, 6]);
      expect(list.pagesLoaded, 2);
    });
  });
}
