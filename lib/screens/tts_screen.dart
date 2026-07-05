import 'package:flutter/material.dart';
import '../../theme/design_tokens.dart';

class TTSScreen extends StatefulWidget {
  const TTSScreen({super.key});

  @override
  State<TTSScreen> createState() => _TTSScreenState();
}

class _TTSScreenState extends State<TTSScreen> {
  bool _isPlaying = false;
  double _speed = 1.0;
  double _progress = 0.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                DesignTokens.grid24,
                DesignTokens.grid16,
                DesignTokens.grid24,
                DesignTokens.grid8,
              ),
              child: Text('Text to Speech', style: theme.textTheme.displaySmall),
            ),

            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Book info
                    Container(
                      width: 100,
                      height: 140,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withAlpha(30),
                        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                      ),
                      child: Icon(Icons.menu_book, size: 48,
                          color: theme.colorScheme.primary),
                    ),
                    const SizedBox(height: DesignTokens.grid24),
                    Text('The Great Gatsby',
                        style: theme.textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Text('Chapter 3 · Page 42',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withAlpha(120),
                        )),

                    const SizedBox(height: DesignTokens.grid48),

                    // Progress
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: DesignTokens.grid32),
                      child: Column(
                        children: [
                          Slider(
                            value: _progress,
                            onChanged: (v) => setState(() => _progress = v),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('0:00', style: theme.textTheme.labelSmall),
                              Text('15:30', style: theme.textTheme.labelSmall),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: DesignTokens.grid32),

                    // Controls
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.skip_previous, size: 36),
                          onPressed: () {},
                        ),
                        const SizedBox(width: DesignTokens.grid24),
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(
                              _isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.white,
                              size: 32,
                            ),
                            onPressed: () => setState(() => _isPlaying = !_isPlaying),
                          ),
                        ),
                        const SizedBox(width: DesignTokens.grid24),
                        IconButton(
                          icon: const Icon(Icons.skip_next, size: 36),
                          onPressed: () {},
                        ),
                      ],
                    ),

                    const SizedBox(height: DesignTokens.grid32),

                    // Speed & Voice
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _controlChip(context, 'Speed', '${_speed.toStringAsFixed(1)}x'),
                        const SizedBox(width: DesignTokens.grid16),
                        _controlChip(context, 'Voice', 'Default'),
                        const SizedBox(width: DesignTokens.grid16),
                        _controlChip(context, 'Timer', 'Off'),
                      ],
                    ),

                    const SizedBox(height: DesignTokens.grid16),

                    // Sleep timer
                    if (_isPlaying)
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: DesignTokens.grid32),
                        padding: const EdgeInsets.all(DesignTokens.grid16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withAlpha(10),
                          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                          border: Border.all(
                            color: theme.colorScheme.primary.withAlpha(30),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.timer, color: theme.colorScheme.primary),
                            const SizedBox(width: 12),
                            const Text('Sleep Timer'),
                            const Spacer(),
                            TextButton(
                              onPressed: () {},
                              child: const Text('15 min'),
                            ),
                            TextButton(
                              onPressed: () {},
                              child: const Text('30 min'),
                            ),
                            TextButton(
                              onPressed: () {},
                              child: const Text('End of chapter'),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _controlChip(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          border: Border.all(color: theme.dividerTheme.color!),
        ),
        child: Column(
          children: [
            Text(label, style: theme.textTheme.labelSmall),
            const SizedBox(height: 4),
            Text(value, style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            )),
          ],
        ),
      ),
    );
  }
}
