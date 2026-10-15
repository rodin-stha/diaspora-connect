/// One page of a paginated list from the API.
class Paged<T> {
  final List<T> items;

  /// Whether the server has a next page.
  final bool hasMore;

  /// How many there are in all pages together (`meta.total`), if the
  /// server says.
  final int? total;

  const Paged({required this.items, required this.hasMore, this.total});

  /// Reads one page of a Laravel paginated response: `data` is the list,
  /// `meta.current_page`/`last_page` say if there's more. Without them, a
  /// full page means there may be more.
  factory Paged.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic> item) fromItem, {
    required int perPage,
  }) {
    final data = (json['data'] as List).cast<Map<String, dynamic>>();
    final meta = json['meta'] as Map<String, dynamic>?;
    final current = meta?['current_page'] as int?;
    final last = meta?['last_page'] as int?;

    return Paged(
      items: data.map(fromItem).toList(),
      hasMore: (current != null && last != null)
          ? current < last
          : data.length >= perPage,
      total: meta?['total'] as int?,
    );
  }
}
