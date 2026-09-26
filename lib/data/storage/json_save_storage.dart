abstract interface class JsonSaveStorage {
  Future<void> write(
    String json, {
    String slotKey = 'autosave',
  });

  Future<String?> read({
    String slotKey = 'autosave',
  });

  Future<void> delete({
    String slotKey = 'autosave',
  });
}

class InMemoryJsonSaveStorage
    implements JsonSaveStorage {
  final Map<String, String> _jsonBySlot = {};

  @override
  Future<void> write(
    String json, {
    String slotKey = 'autosave',
  }) async {
    _jsonBySlot[slotKey] = json;
  }

  @override
  Future<String?> read({
    String slotKey = 'autosave',
  }) async {
    return _jsonBySlot[slotKey];
  }

  @override
  Future<void> delete({
    String slotKey = 'autosave',
  }) async {
    _jsonBySlot.remove(slotKey);
  }
}
