abstract interface class JsonSaveStorage {
  Future<void> write(
    String json,
    String slotKey,
  );

  Future<String?> read(
    String slotKey,
  );

  Future<void> delete(
    String slotKey,
  );
}

class InMemoryJsonSaveStorage
    implements JsonSaveStorage {
  final Map<String, String> _jsonBySlot = {};

  @override
  Future<void> write(
    String json,
    String slotKey,
  ) async {
    _jsonBySlot[slotKey] = json;
  }

  @override
  Future<String?> read(
    String slotKey,
  ) async {
    return _jsonBySlot[slotKey];
  }

  @override
  Future<void> delete(
    String slotKey,
  ) async {
    _jsonBySlot.remove(slotKey);
  }
}
  String? _json;

  @override
  Future<void> write(String json) async {
    _json = json;
  }

  @override
  Future<String?> read() async {
    return _json;
  }

  @override
  Future<void> delete() async {
    _json = null;
  }
}
