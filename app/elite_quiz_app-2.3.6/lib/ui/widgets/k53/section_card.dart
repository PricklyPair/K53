import 'package:flutter/material.dart';
import 'package:flutterquiz/features/k53/models/learning_section.dart';

class SectionCard extends StatelessWidget {
  const SectionCard({
    required this.section,
    required this.onTap,
    super.key,
  });

  final LearningSection section;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isLocked = !section.isUnlocked;
    final theme = Theme.of(context);

    return Card(
      elevation: isLocked ? 1 : 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: isLocked ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: isLocked
                ? null
                : LinearGradient(
                    colors: [
                      Color(section.color).withOpacity(0.1),
                      Color(section.color).withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isLocked
                          ? Colors.grey.shade300
                          : Color(section.color).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      section.icon,
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          section.title,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isLocked ? Colors.grey : null,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          section.statusText,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isLocked
                                ? Colors.grey
                                : Color(section.color),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isLocked)
                    Icon(Icons.lock, color: Colors.grey.shade400, size: 28)
                  else if (section.isComplete)
                    const Icon(Icons.check_circle, color: Colors.green, size: 28)
                  else
                    Icon(Icons.arrow_forward_ios,
                        color: Color(section.color), size: 20),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                section.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isLocked ? Colors.grey : theme.primaryColor,
                ),
              ),
              const SizedBox(height: 16),
              if (!isLocked) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${section.completedQuestions}/${section.totalQuestions} questions',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.primaryColor.withOpacity(0.7),
                      ),
                    ),
                    Text(
                      '${(section.progress * 100).toInt()}%',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Color(section.color),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: section.progress,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(section.color),
                    ),
                    minHeight: 8,
                  ),
                ),
                if (section.completedQuestions > 0) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Accuracy: ${(section.accuracy * 100).toInt()}%',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: section.accuracy >= 0.7
                          ? Colors.green
                          : Colors.orange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ] else ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline,
                          size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Complete previous section to unlock',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
