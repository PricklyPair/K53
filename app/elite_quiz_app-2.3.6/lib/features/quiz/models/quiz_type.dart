/// Enumerates the different types of quizzes available in the application.
///
/// Each [QuizTypes] value represents a distinct quiz format or mode.
/// Quizzes are categorized by their [typeValue] and, in some cases, [subTypeValue],
/// which are used to retrieve the appropriate quiz data from the server.
///
/// ## Key Concepts:
///
/// *   **typeValue:** A string identifier that categorizes the quiz type.
///     This value is used to fetch the relevant quiz data from the server.
/// *   **subTypeValue:** An optional string identifier that further specifies
///     a sub-category within a quiz type. Sub-types are used for quizzes that
///     are variations or modes within a broader quiz category.
///     Sub-type quizzes do not have premium categories.
/// *   **Quiz Zone:** A special quiz type that acts as a container for multiple
///     sub-quizzes. Quizzes with `typeValue: '1'` are considered to be part of the Quiz Zone.
///     Data for these quizzes is fetched directly from the Quiz Zone.
///
/// ### Quiz Type Categories:
///
/// ##### Quiz Zone: (Main Quiz)
/// below are its sub quizzes
///   1.   [dailyQuiz]
///   2.   [groupPlay]
///   3.   [oneVsOneBattle]
///   4.   [trueAndFalse]
///   5.   [selfChallenge]
///   6.   [quizZone]
///   7.   [bookmarkQuiz]
///   8.   [randomBattle]
/// ##### Other Quiz Types:
///   -   [contest]
///   -   [funAndLearn]
///   -   [guessTheWord]
///   -   [mathMania]
///   -   [audioQuestions]
///   -   [exam]
///   -   [multiMatch]
enum QuizTypes {
  quizZone(typeValue: '1'),
  funAndLearn(typeValue: '2'),
  guessTheWord(typeValue: '3'),
  audioQuestions(typeValue: '4'),
  mathMania(typeValue: '5'),
  multiMatch(typeValue: '6'),
  contest,
  exam,
  dailyQuiz(typeValue: '1'),
  trueAndFalse(typeValue: '1'),
  bookmarkQuiz(typeValue: '1'),
  randomBattle(typeValue: '1'),
  selfChallenge(typeValue: '1', subTypeValue: '1'),
  oneVsOneBattle(typeValue: '1', subTypeValue: '2'),
  groupPlay(typeValue: '1', subTypeValue: '3');

  const QuizTypes({this.typeValue, this.subTypeValue});

  /// The primary identifier for the quiz type, used to fetch data from the server.
  final String? typeValue;

  /// An optional sub-identifier for quizzes that are variations within a type.
  final String? subTypeValue;
}
