import 'package:flutterquiz/features/quiz/models/quiz_type.dart';

/// Represents a single quiz, such as daily quiz, fun and learn, or guess the word.
///
/// A zone defines a specific type of quiz that users can play.
/// It is a named tuple containing the following properties:
///
/// - type: The [QuizTypes] enum value representing the type of quiz (e.g., daily quiz, fun and learn).
/// - title: The localization key for the title of the quiz zone. This key is used with `context.tr()` to display the localized title.
/// - img: The asset path for the icon representing the quiz zone.
/// - desc: The localization key for the description of the quiz zone. This key is used with `context.tr()` to display the localized description.
typedef Zone = ({QuizTypes type, String title, String img, String desc});
