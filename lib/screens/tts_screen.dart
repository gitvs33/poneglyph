import 'dart:async';
import 'package:flutter/material.dart';
import '../../theme/design_tokens.dart';

class TTSScreen extends StatefulWidget {
  const TTSScreen({super.key});

  @override
  State<TTSScreen> createState() => _TTSScreenState();
}

class _TTSScreenState extends State<TTSScreen> {
  bool _isPlaying = false;
  double _progress = 0.0;
  double _selectedSpeed = 1.0;
  String _selectedVoice = 'Default';
  Timer? _playbackTimer;
  static const double _totalDuration = 930.0; // 15:30 in seconds

  @override
  void dispose() {
    _playbackTimer?.cancel();
    super.dispose();
  }

  void _togglePlayback() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _startPlaybackTimer();
      } else {
        _playbackTimer?.cancel();
      }
    });
  }

  void _startPlaybackTimer() {
    _playbackTimer?.cancel();
    _playbackTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _progress += 0.1 / (_totalDuration / _selectedSpeed);
        if (_progress >= 1.0) {
          _progress = 0.0;
          _isPlaying = false;
          timer.cancel();
        }
      });
    });
  }

  void _rewind() {
    setState(() {
      _progress = (_progress - 0.05).clamp(0.0, 1.0);
    });
  }

  void _forward() {
    setState(() {
      _progress = (_progress + 0.05).clamp(0.0, 1.0);
    });
  }

  String _formatDuration(double progress) {
    final totalSeconds = (_totalDuration * progress).round();
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── Header with back button
            Padding(
              padding: const EdgeInsets.fromLTRB(
                DesignTokens.grid8,
                DesignTokens.grid16,
                DesignTokens.grid24,
                DesignTokens.grid8,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 4),
                  Text('Text to Speech', style: theme.textTheme.displaySmall),
                ],
              ),
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
                            onChanged: (v) {
                              setState(() => _progress = v);
                            },
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_formatDuration(_progress),
                                  style: theme.textTheme.labelSmall),
                              Text(_formatDuration(1.0),
                                  style: theme.textTheme.labelSmall),
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
                          onPressed: _rewind,
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
                            onPressed: _togglePlayback,
                          ),
                        ),
                        const SizedBox(width: DesignTokens.grid24),
                        IconButton(
                          icon: const Icon(Icons.skip_next, size: 36),
                          onPressed: _forward,
                        ),
                      ],
                    ),

                    const SizedBox(height: DesignTokens.grid32),

                    // Speed & Voice
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _speedDropdown(context),
                        const SizedBox(width: DesignTokens.grid16),
                        _voiceDropdown(context),
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

  Widget _speedDropdown(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => _showSpeedPicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          border: Border.all(color: theme.dividerTheme.color!),
        ),
        child: Column(
          children: [
            Text('Speed', style: theme.textTheme.labelSmall),
            const SizedBox(height: 4),
            Text('${_selectedSpeed.toStringAsFixed(1)}x',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                )),
          ],
        ),
      ),
    );
  }

  void _showSpeedPicker(BuildContext context) {
    final speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Playback Speed',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              ...speeds.map((s) => ListTile(
                    title: Text('${s.toStringAsFixed(2)}x'),
                    trailing: Radio<double>(
                      value: s,
                      groupValue: _selectedSpeed,
                      onChanged: (v) {
                        setState(() => _selectedSpeed = v!);
                        if (_isPlaying) {
                          _playbackTimer?.cancel();
                          _startPlaybackTimer();
                        }
                        Navigator.pop(ctx);
                      },
                    ),
                    onTap: () {
                      setState(() => _selectedSpeed = s);
                      if (_isPlaying) {
                        _playbackTimer?.cancel();
                        _startPlaybackTimer();
                      }
                      Navigator.pop(ctx);
                    },
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _voiceDropdown(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => _showVoicePicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          border: Border.all(color: theme.dividerTheme.color!),
        ),
        child: Column(
          children: [
            Text('Voice', style: theme.textTheme.labelSmall),
            const SizedBox(height: 4),
            Text(_selectedVoice,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                )),
          ],
        ),
      ),
    );
  }

  void _showVoicePicker(BuildContext context) {
    final voices = ['Default', 'Female', 'Male', 'British', 'Australian'];
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Voice Selection',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              ...voices.map((v) => ListTile(
                    title: Text(v),
                    trailing: Radio<String>(
                      value: v,
                      groupValue: _selectedVoice,
                      onChanged: (val) {
                        setState(() => _selectedVoice = val!);
                        Navigator.pop(ctx);
                      },
                    ),
                    onTap: () {
                      setState(() => _selectedVoice = v);
                      Navigator.pop(ctx);
                    },
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _controlChip(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        if (label == 'Timer') {
          _showTimerPicker(context);
        }
      },
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

  void _showTimerPicker(BuildContext context) {
    final options = ['Off', '15 min', '30 min', '45 min', 'End of chapter'];
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Sleep Timer',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              ...options.map((o) => ListTile(
                    title: Text(o),
                    trailing: o == 'Off' ? const Icon(Icons.check) : null,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Timer set to $o')),
                      );
                      Navigator.pop(ctx);
                    },
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
