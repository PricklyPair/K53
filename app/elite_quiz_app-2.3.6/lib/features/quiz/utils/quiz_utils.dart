sealed class QuizUtils {
  // UI
  static const questionContainerHeightPercentage = 0.785;
  static const questionContainerWidthPercentage = 0.90;

  /// Guess The Word
  static String buildGuessTheWordQuestionAnswer(List<String> submittedAnswer) {
    return submittedAnswer.join();
  }

  /// Coin Distribution
  static int calculateCoinsFromPercentage(
    double percentage, {
    required double minPercentageForMaxCoins,
    required int maxCoins,
  }) {
    final earnedCoins =
        (maxCoins - ((minPercentageForMaxCoins - percentage) / 10)).toInt();

    // Ensure coins are between 0 and maxCoins
    return earnedCoins.clamp(0, maxCoins);
  }
}
