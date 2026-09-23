class EntityId {
  const EntityId(this.value);

  final String value;

  bool get isEmpty => value.isEmpty;

  @override
  String toString() => value;

  @override
  bool operator ==(Object other) {
    return other is EntityId && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}
