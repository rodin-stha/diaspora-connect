/// Whether version [current] is older than [minimum], e.g. "1.9.0" is older
/// than "1.10.0".
///
/// Compared number by number, not as text: as text, "1.10.0" < "1.9.0".
/// Missing parts count as 0 ("1.2" == "1.2.0"), and anything after a "+"
/// or "-" (build number, "-beta") is ignored.
bool isOlderVersion(String current, String minimum) {
  final a = _parts(current);
  final b = _parts(minimum);
  for (var i = 0; i < a.length || i < b.length; i++) {
    final x = i < a.length ? a[i] : 0;
    final y = i < b.length ? b[i] : 0;
    if (x != y) return x < y;
  }
  return false;
}

List<int> _parts(String version) => version
    .split(RegExp('[+-]'))
    .first
    .trim()
    .split('.')
    .map((part) => int.tryParse(part) ?? 0)
    .toList();
