enum AdType {
  // not used
  none('0'),
  admob('1'),
  ironSource('2'),
  unity('3');

  const AdType(this.value);
  final String value;

  static AdType fromString(String value) {
    return AdType.values.firstWhere((e) => e.value == value);
  }
}
