abstract interface class JsonSaveStorage {
  Future<void> write(String json);

  Future<String?> read();

  Future<void> delete();
}

class InMemoryJsonSaveStorage implements JsonSaveStorage {
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
