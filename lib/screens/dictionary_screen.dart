import 'package:flutter/material.dart';
import '../../theme/design_tokens.dart';

class DictionaryScreen extends StatefulWidget {
  const DictionaryScreen({super.key});

  @override
  State<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  final TextEditingController _controller = TextEditingController();
  String? _word;
  String? _definition;
  bool _isLoading = false;

  static const _dictionary = {
    'eloquent': 'Fluent or persuasive in speaking or writing.',
    'ephemeral': 'Lasting for a very short time; transitory.',
    'serendipity': 'The occurrence of events by chance in a happy or beneficial way.',
    'ubiquitous': 'Present, appearing, or found everywhere.',
    'ethereal': 'Extremely delicate and light in a way that seems not of this world.',
    'quintessential': 'Representing the most perfect or typical example of a quality or class.',
    'resilient': 'Able to withstand or recover quickly from difficult conditions.',
    'phenomenon': 'A fact or situation that is observed to exist or happen.',
    'surreptitious': 'Kept secret, especially because it would not be approved of.',
  };

  void _lookupWord() {
    final word = _controller.text.trim().toLowerCase();
    if (word.isEmpty) return;

    setState(() {
      _isLoading = true;
      _word = word;
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        _isLoading = false;
        _definition = _dictionary[word];
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
              child: Text('Dictionary', style: theme.textTheme.displaySmall),
            ),

            // Search input
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: DesignTokens.grid16),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                ),
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'Search a word…',
                    prefixIcon: Icon(Icons.search,
                        color: theme.textTheme.bodyMedium?.color?.withAlpha(100)),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.volume_up, size: 18),
                      onPressed: _word != null ? () {} : null,
                    ),
                    border: InputBorder.none,
                    filled: false,
                  ),
                  onSubmitted: (_) => _lookupWord(),
                ),
              ),
            ),
            const SizedBox(height: DesignTokens.grid16),

            // Quick actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: DesignTokens.grid16),
              child: Row(
                children: [
                  _actionChip(context, Icons.language, 'Wikipedia'),
                  const SizedBox(width: 8),
                  _actionChip(context, Icons.translate, 'Translate'),
                  const SizedBox(width: 8),
                  _actionChip(context, Icons.record_voice_over, 'Pronunciation'),
                ],
              ),
            ),

            const SizedBox(height: DesignTokens.grid24),

            // Results
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _word == null
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.menu_book, size: 56,
                                  color: theme.textTheme.bodySmall?.color?.withAlpha(60)),
                              const SizedBox(height: 16),
                              Text('Search for a word',
                                  style: theme.textTheme.bodyLarge),
                              const SizedBox(height: 8),
                              Text('Offline dictionary powered by WordNet',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.textTheme.bodySmall?.color?.withAlpha(120),
                                  )),
                            ],
                          ),
                        )
                      : _definition != null
                          ? SingleChildScrollView(
                              padding: const EdgeInsets.all(DesignTokens.grid24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _word!.toUpperCase(),
                                    style: theme.textTheme.displaySmall?.copyWith(
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Text('/ˈ${_word}/',
                                          style: theme.textTheme.bodyLarge?.copyWith(
                                            color: theme.textTheme.bodyLarge?.color?.withAlpha(150),
                                          )),
                                      const SizedBox(width: 16),
                                      Icon(Icons.volume_up, size: 18,
                                          color: theme.colorScheme.primary),
                                      const SizedBox(width: 4),
                                      Text('Listen',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: theme.colorScheme.primary,
                                          )),
                                    ],
                                  ),
                                  const SizedBox(height: DesignTokens.grid32),
                                  Container(
                                    padding: const EdgeInsets.all(DesignTokens.grid20),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary.withAlpha(8),
                                      borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                                      border: Border.all(
                                        color: theme.colorScheme.primary.withAlpha(20),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Definition',
                                            style: theme.textTheme.labelLarge),
                                        const SizedBox(height: 8),
                                        Text(_definition!,
                                            style: theme.textTheme.bodyLarge?.copyWith(
                                              height: 1.5,
                                            )),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: DesignTokens.grid24),
                                  Text('Synonyms',
                                      style: theme.textTheme.labelLarge),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: ['brief', 'fleeting', 'transient', 'momentary', 'passing']
                                        .map((s) => Chip(
                                              label: Text(s, style: const TextStyle(fontSize: 12)),
                                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            ))
                                        .toList(),
                                  ),
                                ],
                              ),
                            )
                          : Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.search_off, size: 48,
                                      color: Colors.orange[300]),
                                  const SizedBox(height: 16),
                                  Text('Word not found',
                                      style: theme.textTheme.bodyLarge),
                                  const SizedBox(height: 8),
                                  Text('"$_word" is not in our dictionary',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.textTheme.bodySmall?.color?.withAlpha(120),
                                      )),
                                  const SizedBox(height: 16),
                                  OutlinedButton.icon(
                                    onPressed: () {
                                      // Open Wikipedia
                                    },
                                    icon: const Icon(Icons.language, size: 16),
                                    label: const Text('Search on Wikipedia'),
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

  Widget _actionChip(BuildContext context, IconData icon, String label) {
    final theme = Theme.of(context);
    return ActionChip(
      avatar: Icon(icon, size: 16, color: theme.colorScheme.primary),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      onPressed: () {},
    );
  }
}
