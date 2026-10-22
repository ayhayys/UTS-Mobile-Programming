Map<String, dynamic> asMap(dynamic v) =>
    v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{};

List<dynamic> asList(dynamic v) => v is List ? v : <dynamic>[];

String? asString(dynamic v) {
  if (v == null) return null;
  final s = v.toString();
  return s.isEmpty ? null : s;
}

int? asInt(dynamic v) => v == null ? null : int.tryParse(v.toString());

DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
