extension NumberUtilExtension on double {
  double remapValue({
    double srcMin = 0,
    double srcMax = 100,
    double targetMin = 0,
    double targetMax = 1,
  }) {
    return ((this - srcMin) / (srcMax - srcMin)) * (targetMax - targetMin) +
        targetMin;
  }
}
