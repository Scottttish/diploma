/// Who sent a chat message — drives the left/right UI alignment decision.
enum SenderType {
  worker('worker'),
  client('client'),
  dispatcher('dispatcher');

  const SenderType(this.value);
  final String value;

  static SenderType fromString(String raw) {
    return SenderType.values.firstWhere(
      (s) => s.value == raw.toLowerCase(),
      orElse: () => SenderType.client,
    );
  }

  /// Worker messages go to the right; everyone else goes to the left.
  bool get isOutgoing => this == SenderType.worker;
}
