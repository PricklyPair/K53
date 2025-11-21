enum MultiMatchAnswerType {
  multiSelect('1'),
  sequence('2');

  const MultiMatchAnswerType(this.value);

  final String value;

  static MultiMatchAnswerType fromString(String v) {
    return MultiMatchAnswerType.values.firstWhere((s) => s.value == v);
  }
}
