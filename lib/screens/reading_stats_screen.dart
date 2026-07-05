import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/design_tokens.dart';
import '../../providers/reading_stats_provider.dart';
import '../../utils/helpers.dart';

class ReadingStatsScreen extends StatelessWidget {
  const ReadingStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer<ReadingStatsProvider>(
      builder: (context, stats, _) {
        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      DesignTokens.grid24,
                      DesignTokens.grid16,
                      DesignTokens.grid24,
                      DesignTokens.grid8,
                    ),
                    child: Text('Reading Stats', style: theme.textTheme.displaySmall),
                  ),
                  const SizedBox(height: DesignTokens.grid16),

                  // Stats grid
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: DesignTokens.grid16),
                    child: GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: DesignTokens.grid12,
                      mainAxisSpacing: DesignTokens.grid12,
                      childAspectRatio: 1.2,
                      children: [
                        _StatCard(
                          icon: Icons.timer_outlined,
                          label: 'Time Read',
                          value: Helpers.formatDuration(stats.totalTimeRead),
                          color: const Color(0xFF6C63FF),
                        ),
                        _StatCard(
                          icon: Icons.auto_stories,
                          label: 'Pages Read',
                          value: '${stats.totalPagesRead}',
                          color: const Color(0xFFFF6584),
                        ),
                        _StatCard(
                          icon: Icons.flag_outlined,
                          label: 'Books Finished',
                          value: '${stats.booksFinished}',
                          color: const Color(0xFF45B7D1),
                        ),
                        _StatCard(
                          icon: Icons.local_fire_department,
                          label: 'Day Streak',
                          value: '${stats.readingStreak}',
                          color: const Color(0xFFFFAA44),
                        ),
                      ],
                    ),
                  ),

                  // Weekly chart
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      DesignTokens.grid24,
                      DesignTokens.grid32,
                      DesignTokens.grid24,
                      DesignTokens.grid8,
                    ),
                    child: Text('This Week', style: theme.textTheme.titleLarge),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: DesignTokens.grid16),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(DesignTokens.grid24),
                        child: SizedBox(
                          height: 180,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: stats.weeklyChart.entries.map((entry) {
                              final maxValue = stats.weeklyChart.values
                                  .fold(0, (a, b) => a > b ? a : b);
                              final height = maxValue > 0
                                  ? (entry.value / maxValue) * 140
                                  : 0.0;
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  if (entry.value > 0)
                                    Text(
                                      '${entry.value}m',
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                  const SizedBox(height: 4),
                                  Container(
                                    width: 28,
                                    height: height,
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary.withAlpha(
                                        (150 + (entry.value / (maxValue > 0 ? maxValue : 1) * 105).round()).clamp(50, 255),
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    entry.key,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.textTheme.labelSmall?.color?.withAlpha(120),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Reading goal
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      DesignTokens.grid24,
                      DesignTokens.grid32,
                      DesignTokens.grid24,
                      DesignTokens.grid8,
                    ),
                    child: Text('Reading Goal', style: theme.textTheme.titleLarge),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: DesignTokens.grid16),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(DesignTokens.grid24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Daily Goal',
                                    style: theme.textTheme.titleMedium),
                                Text('${stats.totalTimeRead.inMinutes} min / 20 min',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.primary,
                                    )),
                              ],
                            ),
                            const SizedBox(height: DesignTokens.grid16),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: (stats.totalTimeRead.inMinutes / 20)
                                    .clamp(0, 1.0),
                                minHeight: 8,
                              ),
                            ),
                            const SizedBox(height: DesignTokens.grid16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('You\'re making great progress!',
                                    style: theme.textTheme.bodySmall),
                                Text(
                                  '${(stats.totalTimeRead.inMinutes / 20 * 100).round()}%',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: DesignTokens.grid32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.grid16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withAlpha(150),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
