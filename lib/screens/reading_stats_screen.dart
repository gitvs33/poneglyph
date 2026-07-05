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

                  // Circular progress ring
                  Center(
                    child: _CircularProgressWidget(
                      progress: (stats.totalTimeRead.inMinutes / 20).clamp(0, 1.0),
                    ),
                  ),
                  const SizedBox(height: DesignTokens.grid24),

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
                    child: Row(
                      children: [
                        Text('Reading Activity', style: theme.textTheme.titleLarge),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => _showPeriodPicker(context, stats),
                          child: Row(
                            children: [
                              Text(
                                _periodLabel(stats.selectedPeriod),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              Icon(
                                Icons.arrow_drop_down,
                                color: theme.colorScheme.primary,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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

  String _periodLabel(StatsPeriod period) {
    switch (period) {
      case StatsPeriod.thisWeek:
        return 'This Week';
      case StatsPeriod.thisMonth:
        return 'This Month';
      case StatsPeriod.allTime:
        return 'All Time';
    }
  }

  void _showPeriodPicker(BuildContext context, ReadingStatsProvider stats) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              title: const Text('This Week'),
              trailing: stats.selectedPeriod == StatsPeriod.thisWeek
                  ? Icon(Icons.check, color: Theme.of(ctx).colorScheme.primary)
                  : null,
              onTap: () {
                stats.setSelectedPeriod(StatsPeriod.thisWeek);
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              title: const Text('This Month'),
              trailing: stats.selectedPeriod == StatsPeriod.thisMonth
                  ? Icon(Icons.check, color: Theme.of(ctx).colorScheme.primary)
                  : null,
              onTap: () {
                stats.setSelectedPeriod(StatsPeriod.thisMonth);
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              title: const Text('All Time'),
              trailing: stats.selectedPeriod == StatsPeriod.allTime
                  ? Icon(Icons.check, color: Theme.of(ctx).colorScheme.primary)
                  : null,
              onTap: () {
                stats.setSelectedPeriod(StatsPeriod.allTime);
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
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

// ── Circular Progress Ring ─────────────────────────────────

class _CircularProgressRingPainter extends CustomPainter {
  final double progress;
  final Color primaryColor;
  final Color textColor;
  final Color mutedColor;

  _CircularProgressRingPainter({
    required this.progress,
    required this.primaryColor,
    required this.textColor,
    required this.mutedColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 24) / 2;
    const strokeWidth = 12.0;

    // Track circle
    final trackPaint = Paint()
      ..color = Colors.grey[850]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, trackPaint);

    // Progress arc
    final arcPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    final sweepAngle = 2 * 3.141592653589793 * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.141592653589793 / 2,
      sweepAngle,
      false,
      arcPaint,
    );

    // Percentage text
    final percentageText = '${(progress * 100).round()}%';
    final percentageSpan = TextSpan(
      text: percentageText,
      style: TextStyle(
        fontSize: 40,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
    );
    final percentageTp = TextPainter(
      text: percentageSpan,
      textDirection: TextDirection.ltr,
    )..layout();
    percentageTp.paint(
      canvas,
      Offset(center.dx - percentageTp.width / 2, center.dy - percentageTp.height - 4),
    );

    // "Completed" label
    final completedSpan = TextSpan(
      text: 'Completed',
      style: TextStyle(fontSize: 14, color: mutedColor),
    );
    final completedTp = TextPainter(
      text: completedSpan,
      textDirection: TextDirection.ltr,
    )..layout();
    completedTp.paint(
      canvas,
      Offset(center.dx - completedTp.width / 2, center.dy + 4),
    );
  }

  @override
  bool shouldRepaint(_CircularProgressRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _CircularProgressWidget extends StatefulWidget {
  final double progress;

  const _CircularProgressWidget({required this.progress});

  @override
  State<_CircularProgressWidget> createState() => _CircularProgressWidgetState();
}

class _CircularProgressWidgetState extends State<_CircularProgressWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: widget.progress).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(_CircularProgressWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _animation = Tween<double>(begin: _animation.value, end: widget.progress).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(200, 200),
          painter: _CircularProgressRingPainter(
            progress: _animation.value,
            primaryColor: theme.colorScheme.primary,
            textColor: theme.textTheme.bodyLarge?.color ?? Colors.white,
            mutedColor: theme.textTheme.bodySmall?.color?.withAlpha(150) ?? Colors.grey,
          ),
        );
      },
    );
  }
}
