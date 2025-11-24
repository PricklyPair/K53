import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterquiz/features/k53/models/learning_section.dart';
import 'package:flutterquiz/ui/widgets/custom_appbar.dart';
import 'package:flutterquiz/ui/widgets/k53/section_card.dart';
import 'package:flutterquiz/utils/extensions.dart';

class LearningPathScreen extends StatefulWidget {
  const LearningPathScreen({super.key});

  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
      builder: (_) => const LearningPathScreen(),
    );
  }

  @override
  State<LearningPathScreen> createState() => _LearningPathScreenState();
}

class _LearningPathScreenState extends State<LearningPathScreen> {
  // Mock data - will be replaced with actual user progress from Firebase
  late List<LearningSection> sections;

  @override
  void initState() {
    super.initState();
    _initializeSections();
  }

  void _initializeSections() {
    // TODO: Load actual progress from user profile/Firebase
    sections = [
      const LearningSection(
        id: 'signs',
        title: 'Traffic Signs',
        description:
            'Learn regulatory, warning, guidance, and temporary road signs',
        totalQuestions: 100,
        completedQuestions: 15,
        correctAnswers: 12,
        isUnlocked: true,
        icon: '🚦',
        color: 0xFF003DA5, // K53 Road Sign Blue
      ),
      const LearningSection(
        id: 'rules',
        title: 'Rules of the Road',
        description:
            'Master right of way, parking, lane usage, and traffic regulations',
        totalQuestions: 150,
        completedQuestions: 0,
        correctAnswers: 0,
        isUnlocked: false,
        icon: '📖',
        color: 0xFFFFD100, // K53 Warning Yellow
      ),
      const LearningSection(
        id: 'controls',
        title: 'Vehicle Controls',
        description:
            'Understand dashboard lights, pre-trip checks, and vehicle operation',
        totalQuestions: 50,
        completedQuestions: 0,
        correctAnswers: 0,
        isUnlocked: false,
        icon: '🚗',
        color: 0xFF008450, // K53 Success Green
      ),
      const LearningSection(
        id: 'mock_tests',
        title: 'Mock Tests',
        description:
            'Take full-length practice tests under real exam conditions',
        totalQuestions: 10,
        completedQuestions: 0,
        correctAnswers: 0,
        isUnlocked: false,
        icon: '📝',
        color: 0xFFC8102E, // K53 Stop Red
      ),
    ];

    // Check unlock status based on completion
    _updateUnlockStatus();
  }

  void _updateUnlockStatus() {
    // Signs section is always unlocked
    if (sections[0].isComplete) {
      sections[1] = sections[1].copyWith(isUnlocked: true);
    }

    if (sections[1].isComplete) {
      sections[2] = sections[2].copyWith(isUnlocked: true);
    }

    if (sections[0].isComplete &&
        sections[1].isComplete &&
        sections[2].isComplete) {
      sections[3] = sections[3].copyWith(isUnlocked: true);
    }
  }

  void _onSectionTap(LearningSection section) {
    // TODO: Navigate to section practice screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Starting ${section.title}...'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: QAppBar(
        title: Text(
          context.tr('k53LearningPath') ?? 'K53 Learning Path',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                context.tr('yourLearningJourney') ?? 'Your Learning Journey',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                context.tr('k53PathDescription') ??
                    'Complete each section to unlock the next. Pass all sections to access mock tests.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).primaryColor.withOpacity(0.7),
                    ),
              ),
              const SizedBox(height: 24),

              // Overall Progress
              _buildOverallProgress(),
              const SizedBox(height: 32),

              // Section Cards
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sections.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final section = sections[index];
                  return SectionCard(
                    section: section,
                    onTap: () => _onSectionTap(section),
                  );
                },
              ),
              const SizedBox(height: 32),

              // Tips Card
              _buildTipsCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverallProgress() {
    final totalQuestions =
        sections.fold<int>(0, (sum, section) => sum + section.totalQuestions);
    final completedQuestions = sections.fold<int>(
        0, (sum, section) => sum + section.completedQuestions);
    final overallProgress =
        totalQuestions > 0 ? completedQuestions / totalQuestions : 0.0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              const Color(0xFF003DA5).withOpacity(0.1),
              const Color(0xFF003DA5).withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.tr('overallProgress') ?? 'Overall Progress',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  '${(overallProgress * 100).toInt()}%',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF003DA5),
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: overallProgress,
                backgroundColor: Colors.grey.shade200,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Color(0xFF003DA5)),
                minHeight: 12,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '$completedQuestions of $totalQuestions questions completed',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).primaryColor.withOpacity(0.7),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipsCard() {
    return Card(
      elevation: 2,
      color: const Color(0xFFFFD100).withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lightbulb_outline,
                    color: Color(0xFFFFD100), size: 28),
                const SizedBox(width: 12),
                Text(
                  context.tr('studyTips') ?? 'Study Tips',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTipItem('Master each section before moving forward'),
            _buildTipItem('Aim for at least 70% accuracy in practice'),
            _buildTipItem('Review explanations for incorrect answers'),
            _buildTipItem('Take mock tests when all sections are complete'),
          ],
        ),
      ),
    );
  }

  Widget _buildTipItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16)),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
