/// Paging primitives.
///
/// Present from day one because the feed, search, events, communities and
/// notifications all need them, and retrofitting paging into screens written
/// against a plain `List` is a rewrite. Cursor-based: the Cirqles tables are
/// ordered by `created_at`/`starts_at`, where offsets skip and duplicate rows
/// as data shifts under the reader.
class PageRequest {
  const PageRequest({this.cursor, this.limit = 20});

  final String? cursor;
  final int limit;

  Map<String, Object?> toQuery() => <String, Object?>{
        if (cursor != null) 'cursor': cursor,
        'limit': limit,
      };
}

class Paginated<T> {
  const Paginated({required this.items, this.nextCursor});

  final List<T> items;
  final String? nextCursor;

  bool get hasMore => nextCursor != null;

  static Paginated<T> empty<T>() => Paginated<T>(items: <T>[]);
}
